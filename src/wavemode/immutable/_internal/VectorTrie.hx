package wavemode.immutable._internal;

import haxe.ds.Vector;

// TODO: VectorTrie.setEach / setRange

using wavemode.immutable.Functional;

@:using(wavemode.immutable._internal.VectorTrie.VectorTrieTools)
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
}

@:nullSafety(Off)
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

    public static function pushVector<T>(node:Null<VectorTrie<T>>, vs:haxe.ds.Vector<T>, start = 0):Null<VectorTrie<T>> {

        var vectorIndex = start;

        if (node == null)
            node = new VectorTrie(vs[vectorIndex++]);

        var node = node.clone();

        while (vectorIndex < 32) {

            if (node.length == node.maxLen) {
                var result = new VectorTrie(null, new Vector(32));
                result.tree[0] = node;
                result.maxLen = node.maxLen * 32;
                result.height = node.height + 1;
                result.length = node.length;
                return result.pushVector(vs, vectorIndex);
            }

            var n = node, h = n.height;
            while (h > 0) {
                var index = indexOf(node.length, h--);
                if (n.tree[index] == null)
                    n.tree[index] = new VectorTrie(null, new Vector(32));
                else
                    n.tree[index] = n.tree[index].clone();
                n = n.tree[index];
            }
            var index = indexOf(node.length, 0);
            while (index < 32 && vectorIndex < 32) {
                n.tree[index++] = new VectorTrie(vs[vectorIndex++]);
                node.length = node.length + 1;
            }
        }
        return node;
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

}
