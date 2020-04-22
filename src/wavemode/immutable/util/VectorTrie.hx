package wavemode.immutable.util;

import haxe.ds.Vector;
using haxe.EnumTools.EnumValueTools;
using wavemode.immutable.Functional;

@:using(wavemode.immutable.util.VectorTrie.VectorTrieTools)
class VectorTrie<T> {
    public inline function new(?v, ?t) 
        if (v != null)
            value = v;
        else
            tree = t;
    public var value:Null<T>;
    public var tree:Null<Vector<VectorTrie<T>>>;
    public var height:Int = -1;
    public var length:Int = 1;
    public var maxLen:Int = 1;
    public function toString() {
        if (value != null) {
            return 'Value { $value }';
        } else if (tree != null) {
            var str = 'Tree { ';
            for (i in 0...32) {
                if (tree[i] != null)
                    str += tree[i] + ", ";
                else
                    break;
                if (i > 2) {
                    str += " .... ";
                    break;
                }
            }
            return str.substr(0, str.length - 2) + " }";
        } else {
            return 'Empty';
        }
    }
}

class VectorTrieTools<T> {

    private static inline function indexOf(index:Int, height:Int)
        return (index & (31 << (5 * height))) >> (5 * height);

    private static function copy<T>(v:Vector<T>):Vector<T> {
        var vec = new Vector(32);
        for (i in 0...32)
            if ((vec[i] = v[i]) == null)
                break;
        return vec;
    }

    public static function clone<T>(node:Null<VectorTrie<T>>):Null<VectorTrie<T>> {
        if (node == null)
            return null;
        var result = new VectorTrie();
        if (node.tree != null)
            result.tree = copy(node.tree);
        else
            result.value = node.value;
        result.height = node.height;
        result.length = node.length;
        result.maxLen = node.maxLen;
        return result;
    }

    public static function push<T>(node:Null<VectorTrie<T>>, v:T):Null<VectorTrie<T>> {

        if (node == null)
            return new VectorTrie(v);

        if (node.length == node.maxLen) {
            var result = new VectorTrie(null, new Vector(32));
            result.tree[0] = node;
            result.maxLen = node.maxLen * 32;
            result.height = node.height + 1;
            result.length = node.length;
            return result.push(v);
        }

        var result = node.clone(), n = result, h = n.height;
        while (h > 0) {
            var index = indexOf(result.length, h--);
            if (n.tree[index] == null)
                n.tree[index] = new VectorTrie(null, new Vector(32));
            else
                n.tree[index] = n.tree[index].clone();
            n = n.tree[index];
        }
        var index = indexOf(result.length, 0);
        n.tree[index] = new VectorTrie(v);
        result.length = result.length + 1;
        return result;
    }

    public static function pop<T>(node:Null<VectorTrie<T>>):Null<VectorTrie<T>> {
        if (node == null)
            return null;
        var i = node.length - 1;
        var result = node.clone(), n = result, h = n.height;
        while (h > 0) {
            var index = indexOf(i, h--);
            if (n.tree[index] == null)
                n.tree[index] = new VectorTrie(null, new Vector(32));
            else
                n.tree[index] = n.tree[index].clone();
            n = n.tree[index];
        }
        var index = indexOf(i, 0);
        n.tree[index] = null;
        --result.length;
        return result;
    }


    public static function pushEach<T>(node:Null<VectorTrie<T>>, vs:Iterator<T>):Null<VectorTrie<T>> {

        if (!vs.hasNext())
            return node;

        if (node == null)
            node = new VectorTrie(vs.next());

        if (!vs.hasNext())
            return node;        

        if (node.length == node.maxLen) {
            var result = new VectorTrie(null, new Vector(32));
            result.tree[0] = node;
            result.maxLen = node.maxLen * 32;
            result.height = node.height + 1;
            result.length = node.length;
            return result.pushEach(vs);
        }

        var result = node.clone();

        while (vs.hasNext()) {
            var n = result, h = n.height;
            while (h > 0) {
                var index = indexOf(result.length, h--);
                if (n.tree[index] == null)
                    n.tree[index] = new VectorTrie(null, new Vector(32));
                else
                    n.tree[index] = n.tree[index].clone();
                n = n.tree[index];
            }
            var index = indexOf(result.length, 0);
            while (index < 32 && vs.hasNext()) {
                n.tree[index++] = new VectorTrie(vs.next());
                result.length = result.length + 1;
            }
        }
        return result;
    }

    public static function set<T>(node:Null<VectorTrie<T>>, i:Int, v:T):Null<VectorTrie<T>> {
        if (node == null)
            return null;
        if (i >= node.length || i < 0)
            return node;
        var result = node.clone(), n = result, h = n.height;
        while (h > 0) {
            var index = indexOf(i, h--);
            if (n.tree[index] == null)
                n.tree[index] = new VectorTrie(null, new Vector(32));
            else
                n.tree[index] = n.tree[index].clone();
            n = n.tree[index];
        }
        var index = indexOf(i, 0);
        n.tree[index] = new VectorTrie(v);
        return result;
    }

    public static function retrieve<T>(node:Null<VectorTrie<T>>, index:Int):Null<T> {
        if (node == null)
            return null;
        var n = node, h = node.height;
        while (h >= 0) {
            var i = indexOf(index, h--);
            n = n.tree[i];
            if (n == null)
                return null;
        }
        return n.value;
    }

    public static function iterator<T>(node:Null<VectorTrie<T>>):Iterator<T> {
        var index = 0;
        function hn()
            return node != null && index < node.length;
        function n()
            return node.retrieve(index++);
        return new FunctionalIterator(hn, n);
    }

    public static function keyValueIterator<T>(node:Null<VectorTrie<T>>):KeyValueIterator<Int,T> {
        var index = 0;
        function hn()
            return index < node.length;
        function n() {
            var val = {key: index, value: node.retrieve(index)};
            ++index;
            return val;
        }
        return new FunctionalIterator(hn, n);
    }

}
