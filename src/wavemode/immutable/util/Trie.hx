package wavemode.immutable.util;

import stdlib.Exception;
import haxe.ds.Vector;
using haxe.EnumTools.EnumValueTools;
using wavemode.immutable.Functional;

/**
    A hash array mapped trie.
**/
@:using(wavemode.immutable.util.Trie.TrieTools)
class Trie<K,V> {
    public inline function new(?h, ?k, ?v, ?t, ?c) {
        hash = h;
        key = k;
        value = v;
        tree = t;
        chain = c;
    }
    public var hash:Null<Int>;
    public var key:Null<K>;
    public var value:Null<V>;
    public var tree:Null<Vector<Null<Trie<K,V>>>>;
    public var chain:Null<Stack<Pair<K,V>>>;
    public var _count:Null<Int>;
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

    private static inline function clone<K,V>(node:Trie<K,V>):Trie<K,V> {
        var vec = null;
        if (node.tree != null)
            vec = copy(node.tree);
        return new Trie(node.hash, node.key, node.value, vec, node.chain);
    }

    private static inline function stackReplace<K,V>(stack:Stack<Pair<K,V>>, k:K, v:V):Stack<Pair<K,V>> {
        var result = new Stack();
        for (pair in stack)
            if (pair.key == k)
                result = result.push(new Pair(k, v));
            else
                result = result.push(pair);
        return result;
    }

    private static inline function indexOf(hash:Int, depth:Int)
        return (hash & (31 << (5 * depth))) >> (5 * depth);

    public static function insert<K,V>(node:Null<Trie<K,V>>, h:Int, k:K, v:V):Null<Trie<K,V>> {
        if (node == null)
            return new Trie(h, k, v);

        var result = clone(node), n = result, depth = 0;
        while (depth < 6) {
            if (n.hash != null) {
                if (n.hash == h && n.key == k) {
                    n.value = v;
                    return result;
                } else {
                    n.tree = new Vector(32);
                    n.tree[indexOf(n.hash, depth)] = new Trie(n.hash, n.key, n.value);
                    n.hash = null;
                    n.key = null;
                    n.value = null;
                    continue;
                }
            } else {
                var index = indexOf(h, depth);
                if (n.tree[index] == null) {
                    n.tree[index] = new Trie(h, k, v);
                    return result;
                } else {
                    n.tree[index] = clone(n.tree[index]);
                    n = n.tree[index];
                }
            }
            ++depth;
        }
        if (n.chain != null) {
            for (pair in n.chain) {
                if (pair.key == k) {
                    n.chain = stackReplace(n.chain, k, v);
                    return result;
                }
            }
            n.chain = n.chain.push(new Pair(k, v));
            return result;
        }
        n.chain = new Stack().push(new Pair(n.key, n.value)).push(new Pair(k, v));
        n.key = null;
        n.value = null;
        n.hash = null;
        return result;
    }

    public static function update<K,V>(node:Null<Trie<K,V>>, h:Int, k:K, fn:V->V):Null<Trie<K,V>> {
        var n = node;
        if (n == null)
            return null;
        if (n.hash != null) {
            if (n.hash == h && n.key == k)
                return new Trie(h, k, fn(n.value));
            else
                return n;
        }
        var result = clone(node), n = result, depth = 0;
        while (depth < 6) {
            var index = indexOf(h, depth);
            if (n.tree[index] == null) {
                return result;
            } else {
                var trie = n.tree[index];
                if (trie.hash != null) {
                    if (trie.hash == h && trie.key == k)
                        n.tree[index] = new Trie(h, k, fn(trie.value));
                    return result;
                }
                n.tree[index] = clone(n.tree[index]);
                n = n.tree[index];
            }
            ++depth;
        }
        var stack = new Stack();
        for (pair in n.chain)
            if (pair.key == k)
                stack = stack.push(new Pair(k, fn(pair.value)));
            else
                stack = stack.push(pair);
        n.chain = stack;
        return result;
    }

    public static function retrieve<K,V>(node:Null<Trie<K,V>>, h:Int, k:K):Null<V> {
        var n = node, depth = 0;
        if (n == null)
            return null;
        while (depth < 6) {
            if (n.hash != null) {
                if (n.hash == h && n.key == k) {
                    return n.value;
                } else {
                    return null;
                }
            } else {
                var index = indexOf(h, depth);
                if (n.tree[index] == null) {
                    return null;
                } else {
                    n = n.tree[index];
                }
            }
            ++depth;
        }
        if (n.chain != null)
            for (pair in n.chain)
                if (pair.key == k)
                    return pair.value;
        return n.value;
    }

    public static function contains<K,V>(node:Null<Trie<K,V>>, v:V):Bool {
        if (node == null) {
            return false;
        } else if (node.hash != null) {
            if (node.value == v) {
                return true;
            } else {
                return false;
            }
        } else if (node.tree != null) {
            var i = 0;
            while (i < 32) {
                if (node.tree[i] != null && contains(node.tree[i], v))
                    return true;
                ++i;
            }
        } else if (node.chain != null) {
            for (pair in node.chain)
                if (pair.value == v)
                    return true;
        }
        return false;
    }

    public static function has<K,V>(node:Null<Trie<K,V>>, h:Int, k:K):Bool {
        var n = node, depth = 0;
        if (n == null)
            return false;
        while (depth < 6) {
            if (n.hash != null) {
                if (n.hash == h && n.key == k) {
                    return true;
                } else {
                    return false;
                }
            } else {
                var index = indexOf(h, depth);
                if (n.tree[index] == null) {
                    return false;
                } else {
                    n = n.tree[index];
                }
            }
            ++depth;
        }
        if (n.chain != null)
            for (pair in n.chain)
                if (pair.key == k)
                    return true;
        return false;
    }

    public static function delete<K,V>(node:Null<Trie<K,V>>, h:Int, k:K, depth = 0):Null<Trie<K,V>> {
        var n = node;
        if (n == null)
            return null;
        if (n.hash != null) {
            if (n.hash == h && n.key == k)
                return null;
            else
                return n;
        }
        var result = clone(node), n = result, depth = 0;
        while (depth < 6) {
            var index = indexOf(h, depth);
            if (n.tree[index] == null) {
                return result;
            } else {
                var trie = n.tree[index];
                if (trie.hash != null) {
                    if (trie.hash == h && trie.key == k)
                        n.tree[index] = null;
                    return result;
                }
                n.tree[index] = clone(n.tree[index]);
                n = n.tree[index];
            }
            ++depth;
        }
        var stack = new Stack();
        for (pair in n.chain)
            if (pair.key != k)
                stack = stack.push(pair);
        n.chain = stack;
        return result;
    }

    public static function count<K,V>(node:Null<Trie<K,V>>):Int {
        var result = 0;
        if (node == null) {
            return 0;
        } else if (node._count != null) {
            return node._count;
        } else if (node.hash != null) {
            result = 1;
        } else if (node.tree != null) {
            var i = 0, c = 0;
            while (i < 32) {
                c += count(node.tree[i]);
                ++i;
            }
            result = c;
        } else if (node.chain != null) {
            var c = 0;
            for (pair in node.chain)
                ++c;
            result = c;
        }
        return node._count = result;
    }

    public static function iterator<K,V>(node:Null<Trie<K,V>>):Iterator<V> {
        return keyValueIterator(node).seq().map(pair -> pair.value).iterator();
    }

    public static function keyValueIterator<K,V>(node:Null<Trie<K,V>>):KeyValueIterator<K,V> {

        var hn = null, n = null;

        if (node == null) {
            hn = () -> false;
            n = () -> null;
        } else if (node.hash != null) {
            var valid = true;
            hn = () -> {
                if (valid) {
                    valid = false;
                    true;
                } else {
                    false;
                }
            };
            n = () -> {key: node.key, value: node.value};
        } else if (node.tree != null) {

            var valid = false;
            var it = node.tree[0].keyValueIterator();
            var index = 1;

            function gv() {
                if (!valid) {
                    while (!it.hasNext()) {
                        if (index == 32)
                            return;
                        it = node.tree[index++].keyValueIterator();
                    }
                    valid = true;
                }
            }
            hn = () -> {
                gv();
                return valid;
            }
            n = () -> {
                gv();
                valid = false;
                return it.next();
            }

        } else if (node.chain != null) {
            
            var it = node.chain.iterator();
            hn = it.hasNext;
            n = () -> {
                var pair = it.next();
                {key: pair.key, value: pair.value};
            }

        }

        return new FunctionalIterator(hn, n);
    }
}
