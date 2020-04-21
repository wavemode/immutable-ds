package wavemode.immutable.util;

import stdlib.Exception;
import haxe.ds.Vector;
using haxe.EnumTools.EnumValueTools;
using wavemode.immutable.Functional;

/**
    A hash array mapped trie.
**/
@:using(wavemode.immutable.util.Trie.TrieTools)
enum Trie<K,V> {
    Value(hash:Int, key:K, value:V);
    Tree(children:Vector<Null<Trie<K,V>>>);
    Chain(hash:Int, pairs:Stack<Pair<K,V>>);
}

class TrieTools {

    private static inline function copy<K,V>(vec:Vector<Null<Trie<K,V>>>):Vector<Null<Trie<K,V>>> {
        var result = new Vector(32);
        var i = 0;
        while (i < 32) {
            result[i] = vec[i];
            ++i;
        }
        return result;
    }

    private static inline function indexOf(hash:Int, depth:Int)
        return (hash & (31 << (5 * depth))) >> (5 * depth);

    public static function insert<K,V>(node:Null<Trie<K,V>>, h:Int, k:K, v:V, depth:Int = 0):Null<Trie<K,V>> {
        if (node == null)
            return Value(h, k, v);
        switch node {
            case Value(hash, key, value):
                if (depth >= 6) {
                    return Chain(h, new Stack().push(new Pair(key, value)).push(new Pair(k, v)));
                }
                if (hash == h) {
                    if (key == k) {
                        return Value(h, k, v);
                    }
                }
                var vec = new Vector(32);
                var index = indexOf(hash, depth);
                var newIndex = indexOf(h, depth);
                vec[index] = Value(hash, key, value);
                var tree = Tree(vec);
                if (index == newIndex) {
                    return insert(tree, h, k, v, depth);
                } else {
                    vec[newIndex] = Value(h, k, v);
                    return tree;
                }
            case Tree(children):
                var vec = copy(children);
                var index = indexOf(h, depth);
                if (vec[index] == null) {
                    vec[index] = Value(h, k, v);
                } else {
                    vec[index] = insert(vec[index], h, k, v, depth+1);
                }
                return Tree(vec);
            case Chain(hash, pairs):
                return Chain(hash, pairs.push(new Pair(k, v)));
        }
    }

    public static function update<K,V>(node:Null<Trie<K,V>>, h:Int, k:K, fn:V->V, depth:Int = 0):Null<Trie<K,V>> {
        if (node == null)
            return node;
        switch node {
            case Value(hash, key, value):
                if (hash == h) {
                    if (key == k) {
                        return Value(h, k, fn(value));
                    }
                }
            case Tree(children):
                var index = indexOf(h, depth);
                if (children[index] != null) {
                    var vec = copy(children);
                    vec[index] = update(vec[index], h, k, fn, depth+1);
                    return Tree(vec);
                }
            case Chain(hash, pairs):
                var stack = new Stack();
                for (pair in pairs)
                    if (pair.key == k)
                        stack = stack.push(new Pair(k, fn(pair.value)));
                    else
                        stack = stack.push(pair);
                return Chain(hash, stack);
        }
        return node;
    }

    public static function replace<K,V>(node:Null<Trie<K,V>>, oldVal:V, newVal:V):Null<Trie<K,V>> {
        if (node == null)
            return null;
        switch node {
            case Value(hash, key, value):
                if (value == oldVal) {
                    return Value(hash, key, newVal);
                }
            case Tree(children):
                var vec = children, copied = false;
                for (i in 0...32) {
                    if (contains(children[i], oldVal)) {
                        if (!copied) {
                            vec = copy(children);
                            copied = true;
                        }
                        vec[i] = replace(vec[i], oldVal, newVal);
                    }
                }
                return Tree(vec);
            case Chain(hash, pairs):
                var stack = new Stack();
                for (pair in pairs)
                    stack = stack.push(new Pair(pair.key, if (pair.value == oldVal) newVal else pair.value));
                return Chain(hash, stack);
        }

        return node;

    }

    public static function retrieve<K,V>(node:Null<Trie<K,V>>, h:Int, k:K, depth = 0):Null<V> {
        if (node == null)
            return null;
        switch node {
            case Value(hash, key, value):
                if (hash == h) {
                    if (key == k) {
                        return value;
                    }
                }
            case Tree(children):
                var index = indexOf(h, depth);
                return retrieve(children[index], h, k, depth+1);
            case Chain(hash, pairs):
                for (pair in pairs)
                    if (pair.key == k)
                        return pair.value;
        }
        return null;
    }

    public static function contains<K,V>(node:Null<Trie<K,V>>, v:V):Bool {
        if (node == null)
            return false;
        switch node {
            case Value(hash, key, value):
                return value == v;
            case Tree(children):
                for (i in 0...32) {
                    if (children[i] != null) {
                        if (contains(children[i], v))
                            return true;
                    }
                }
            case Chain(hash, pairs):
                for (pair in pairs)
                    if (pair.value == v)
                        return true;
        }
        return false;
    }

    public static function has<K,V>(node:Null<Trie<K,V>>, h:Int, k:K, depth = 0):Bool {
        if(node == null)
            return false;
        switch node {
            case Value(hash, key, value):
                if (hash == h) {
                    if (key == k) {
                        return true;
                    }
                }
            case Tree(children):
                var index = indexOf(h, depth);
                return has(children[index], h, k, depth+1);
            case Chain(hash, pairs):
                for (pair in pairs)
                    if (pair.key == k)
                        return true;
        }

        return false;
    }

    public static function delete<K,V>(node:Null<Trie<K,V>>, h:Int, k:K, depth = 0):Null<Trie<K,V>> {
        if (node == null)
            return null;
        switch node {
            case Value(hash, key, value):
                if (hash == h) {
                    if (key == k) {
                        return null;
                    }
                }
            case Tree(children):
                var index = indexOf(h, depth);
                if (has(children[index], h, k, depth)) {
                    var vec = copy(children);
                    vec[index] = delete(children[index], h, k, depth+1);
                    // collapse the tree
                    var i = 0, c = 0;
                    for (j in 0...32) {
                        if (vec[j] != null) {
                            i = j;
                            ++c;
                        }
                    }
                    if (c == 0)
                        return null;
                    else if (c == 1)
                        return vec[i];
                    else
                        return Tree(vec);

                }
            case Chain(hash, pairs):
                var stack = new Stack();
                for (pair in pairs)
                    if (pair.key != k)
                        stack = stack.push(pair);
                if (stack.empty())
                    return null;
                else
                    return Chain(hash, pairs);
        }
        return node;
    }

    public static function filter<K,V>(node:Null<Trie<K,V>>, predicate:(K,V)->Bool, depth = 0):Null<Trie<K,V>> {
        if (node == null)
            return null;
        switch node {
            case Value(hash, key, value):
                if (!predicate(key, value))
                    return null;
            case Tree(children):
                var vec = new Vector(32);
                for (i in 0...32)
                    vec[i] = filter(children[i], predicate);
                // collapse the tree
                var i = 0, c = 0;
                for (j in 0...32) {
                    if (vec[j] != null) {
                        i = j;
                        ++c;
                    }
                }
                if (c == 0)
                    return null;
                else if (c == 1)
                    return vec[i];
                else
                    return Tree(vec);
            case Chain(hash, pairs):
                var stack = new Stack();
                for (pair in pairs)
                    if (predicate(pair.key, pair.value))
                        stack = stack.push(pair);
                if (stack.empty())
                    return null;
                else if (stack.next.empty())
                    return Value(hash, stack.value.key, stack.value.value);
                else
                    return Chain(hash, stack);
        }
        return node;
    }

    public static function count<K,V>(node:Null<Trie<K,V>>):Int {
        if (node == null)
            return 0;
        switch node {
            case Value(hash, key, value):
                return 1;
            case Tree(children):
                var c = 0;
                for (i in 0...32)
                    c += count(children[i]);
                return c;
            case Chain(hash, pairs):
                var c = 0;
                for (pair in pairs)
                    ++c;
                return c;
        }
    }

    public static function iterator<K,V>(node:Null<Trie<K,V>>):Iterator<V>
        return keyValueIterator(node).seq().map(pair -> pair.value).iterator();

    public static function keyValueIterator<K,V>(node:Null<Trie<K,V>>):KeyValueIterator<K,V> {
        
        var hn, n;

        if (node == null) {
            hn = () -> false;
            n = () -> null;
        } else switch node {
            case Value(hash, key, value):
                var valid = true;
                hn = () -> valid;
                n = () -> {
                    valid = false;
                    {key: key, value: value};
                }
            case Tree(children):
                var index = 0;
                var nextIt:KeyValueIterator<K,V> = null;
                var valid = false;
                function gv() {
                    if (!valid) {
                        while (nextIt == null || !nextIt.hasNext()) {
                            if (index == 32)
                                return;
                            nextIt = keyValueIterator(children[index++]);
                        }
                        valid = true;
                    }
                }
                hn = () -> {
                    gv();
                    valid;
                }
                n = () -> {
                    gv();
                    valid = false;
                    nextIt.next();
                }
            case Chain(hash, pairs):
                var stack = pairs;
                hn = () -> !stack.empty();
                n = () -> {
                    var val = { key: stack.value.key, value: stack.value.value };
                    stack = stack.next;
                    val;
                }
        }
        
        return new FunctionalIterator(hn, n);

    }

}
