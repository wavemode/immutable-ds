package wavemode.immutable.util;

import stdlib.Exception;
import haxe.ds.Vector;

@:nullSafety(Off)
class Trie<T> {
    public var array:Null<Vector<Trie<T>>>;
    public var chain:Null<Array<T>>;
    public var length:Int = 0;
    public var value:Null<T>;
    public var hash:Int = -1;
    public inline function new() {}

    public inline function clone():Trie<T> {
        var result = new Trie();
        if (value != null) {
            result.hash = hash;
            result.value = value;
        }
        if (array != null) {
            result.length = length;
            result.array = new Vector(32);
            for (i in 0...32)
                result.array[i] = array[i];
        }
        if (chain != null) {
            result.length = length;
            result.chain = chain.copy();
        }
        return result;
    }

    public function insert(h:Int, v:T, depth:Int = 0):Trie<T> {
        if (hash == -1 && length == 0) {
            value = v;
            hash = h;
        } else if (hash != -1 && length == 0) {
            if (depth < 6) {
                if (h == hash)
                    if (v == value)
                        return this;
                array = new Vector(32);
                var obj = new Trie();
                obj.hash = hash;
                obj.value = value;
                array[indexOf(hash, depth)] = obj;
                hash = -1;
                value = null;
                length = 1;
                insert(h, v, depth);
            } else if (depth >= 6 && v != value) {
                chain = [v];
                ++length;
            }
        } else if (hash == -1 && length != 0) {
            var index = indexOf(h, depth);
            if (array[index] == null) {
                array[index] = new Trie().insert(h, v);
                ++length;
            } else {
                array[index].insert(h, v, depth + 1);
            }
        } else if (v != value) { // hash != -1 && length != 0
            for (i in 0...length)
                if (v == chain[i])
                    return this;
            chain.push(v);
            ++length;
        }
        return this;
    }

    public function copyInsert(h:Int, v:T, depth:Int = 0) {
        if (hash == -1 && length == 0) {
            return clone().insert(h, v);
        } else if (hash != -1 && length == 0) {
            var self = null;
            if (depth < 6) {
                if (h == hash)
                    if (v == value)
                        return this;
                self = clone();
                self.array = new Vector(32);
                var obj = new Trie().insert(self.hash, self.value);
                self.array[indexOf(self.hash, depth)] = obj;
                self.hash = -1;
                self.value = null;
                self.length = 1;
                self.insert(h, v, depth);
            } else if (depth >= 6 && v != self.value) {
                self = clone();
                self.chain = [v];
                ++self.length;
            }
            return self;
        } else if (hash == -1 && length != 0) {
            var index = indexOf(h, depth);
            var self = clone();
            if (self.array[index] == null) {
                self.array[index] = new Trie().insert(h, v);
                ++self.length;
            } else {
                self.array[index] = self.array[index].copyInsert(h, v, depth + 1);
            }
            return self;
        } else if (v != value) { // hash != -1 && length != 0
            for (i in 0...length)
                if (v == chain[i])
                    return this;
            var self = clone();
            self.chain.push(v);
            ++self.length;
            return self;
        }
        return this;
    }

    private static inline function indexOf(hash:Int, depth:Int)
        return ((hash & (31 << (5 * depth))) >> (5 * depth));
}