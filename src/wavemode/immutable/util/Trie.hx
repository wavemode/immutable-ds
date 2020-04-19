package wavemode.immutable.util;

import stdlib.Exception;
import haxe.ds.Vector;

/**
    A hash array mapped trie.

    Operations beginning with "copy" return a new modified trie without
    mutating the original. (This does not require copying the entire
    structure; the new trie will share most of its internal structure
    with the old.) The non-copy variants mutate the trie in place.
**/
@:nullSafety(Off)
class Trie<K,V> {
    public var array:Null<Vector<Trie<K,V>>>;
    public var chain:Null<Array<Pair<K,V>>>;
    public var length:Int = 0;
    public var pair:Null<Pair<K,V>>;
    public var hash:Int = -1;
    
    private var _keys:Null<Array<K>>;
    private var _values:Null<Array<V>>;

    public inline function new() {}

    public inline function copy():Trie<K,V> {
        var result = new Trie();
        if (pair != null) {
            result.hash = hash;
            result.pair = pair;
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

    public function copyInsert(h:Int, p:Pair<K,V>, depth:Int = 0):Trie<K,V> {
        if (hash == h) {
            if (pair.key == p.key) {
                var clone = copy();
                clone.pair = new Pair(p.key, p.value);
                return clone;
            }
        }
        if (hash == -1 && length == 0) {
            var obj = copy();
            obj.pair = p;
            obj.hash = h;
            return obj;
        } else if (hash != -1 && length == 0) {
            if (depth < 6) {
                var clone = copy();
                clone.array = new Vector(32);
                var obj = new Trie();
                obj.hash = hash;
                obj.pair = pair;
                clone.array[indexOf(obj.hash, depth)] = obj;
                clone.hash = -1;
                clone.pair = null;
                clone.length = 1;
                clone.insert(h, p, depth);
                return clone;
            } else if (depth >= 6) {
                var clone = copy();
                clone.chain = [p];
                ++clone.length;
                return clone;
            }
        } else if (hash == -1 && length != 0) {
            var index = indexOf(h, depth);
            if (array[index] == null) {
                var obj = new Trie();
                obj.insert(h, p);
                var clone = copy();
                clone.array[index] = obj;
                ++clone.length;
                return clone;
            } else {
                var clone = copy();
                clone.array[index] = clone.array[index].copyInsert(h, p, depth + 1);
                return clone;
            }
        } else { // hash != -1 && length != 0
            for (i in 0...length) {
                if (chain[i].key == p.key) {
                    var clone = copy();
                    clone.chain[i] = new Pair(p.key, p.value);
                    return clone;
                }
            }
            var clone = copy();
            clone.chain.push(p);
            ++clone.length;
            return clone;
        }
        return this;
    }

    public function insert(h:Int, p:Pair<K,V>, depth:Int = 0):Void {
        if (hash == h) {
            if (pair.key == p.key) {
                pair.value = p.value;
                return;
            }
        }
        if (hash == -1 && length == 0) {
            pair = p;
            hash = h;
        } else if (hash != -1 && length == 0) {
            if (depth < 6) {
                array = new Vector(32);
                var obj = new Trie();
                obj.hash = hash;
                obj.pair = pair;
                array[indexOf(obj.hash, depth)] = obj;
                hash = -1;
                pair = null;
                length = 1;
                insert(h, p, depth);
            } else if (depth >= 6) {
                chain = [p];
                ++length;
            }
        } else if (hash == -1 && length != 0) {
            var index = indexOf(h, depth);
            if (array[index] == null) {
                var obj = new Trie();
                obj.insert(h, p);
                array[index] = obj;
                ++length;
            } else {
                array[index].insert(h, p, depth + 1);
            }
        } else { // hash != -1 && length != 0
            for (i in 0...length) {
                if (chain[i].key == p.key) {
                    chain[i].value = p.value;
                    return;
                }
            }
            chain.push(p);
            ++length;
        }
    }

    public function retrieve(h:Int, k:K, depth = 0):Null<V> {
        if (hash == h)
            if (pair.key == k)
                return pair.value;

        if (chain != null)
            for (pair in chain)
                if (pair.key == k)
                    return pair.value;

        if (array != null) {
            var index = indexOf(h, depth);
            if (array[index] != null)
                return array[index].retrieve(h, k, depth + 1);
        }

        return null;
    }

    public function delete(h:Int, k:K, depth = 0):Void {
        if (depth < 6) {
            if (hash == h) {
                if (pair.key == k) {
                    hash = -1;
                    pair = null;
                    return;
                }
            }
            if (array != null) {
                var index = indexOf(h, depth);
                if (array[index] != null)
                    array[index].delete(h, k, depth + 1);
                return;
            }
        } else {
            if (hash == h) {
                if (pair.key == k) {
                    if (chain != null) {
                        pair = chain[chain.length - 1];
                        --length;
                        if (chain.length == 1)
                            chain = null;
                        else
                            chain.remove(pair);
                    } else {
                        hash = -1;
                        pair = null;
                    }
                    return;
                }
            }
            if (chain != null) {
                for (i in 0...chain.length) {
                    if (chain[i].key == k) {
                        if (chain.length == 1)
                            chain = null;
                        else
                            chain.remove(chain[i]);
                        --length;
                        return;
                    }
                }
            }
        }
    }

    public function copyDelete(h:Int, k:K, depth = 0):Trie<K,V> {
        if (depth < 6) {
            if (hash == h) {
                if (pair.key == k) {
                    return new Trie();
                }
            }
            if (array != null) {
                var index = indexOf(h, depth);
                if (array[index] != null) {
                    var clone = copy();
                    clone.array[index] = array[index].copyDelete(h, k, depth + 1);
                    return clone;
                }
            }
        } else {
            if (hash == h) {
                if (pair.key == k) {
                    if (chain == null) {
                        return new Trie();
                    } else {
                        var clone = copy();
                        clone.pair = chain[chain.length - 1];
                        --clone.length;
                        if (chain.length == 1)
                            clone.chain = null;
                        else
                            clone.chain.remove(pair);
                        return clone;
                    }
                }
            }
            if (chain != null) {
                for (i in 0...chain.length) {
                    if (chain[i].key == k) {
                        var clone = copy();
                        if (chain.length == 1)
                            clone.chain = null;
                        else
                            clone.chain.remove(chain[i]);
                        --clone.length;
                        return clone;
                    }
                }
            }
        }
        return this;
    }

    public function count():Int {
        var count = 0;
        if (pair != null)
            ++count;
        if (array != null)
            for (trie in array)
                if (trie != null)
                    count += trie.count();
        if (chain != null)
            count += chain.length;
        return count;
    }

    // TODO: optimize w/ Sequence suspensions
    public function keys():Array<K> {
        if (_keys != null)
            return _keys;
        var keys = [];
        if (pair != null)
            keys.push(pair.key);
        if (array != null)
            for (trie in array)
                if (trie != null)
                    keys = keys.concat(trie.keys());
        if (chain != null)
            for (p in chain)
                keys.push(p.key);
        return _keys = keys;
    }

    // TODO: optimize w/ Sequence suspensions
    public function values():Array<V> {
        if (_values != null)
            return _values;
        var values = [];
        if (pair != null)
            values.push(pair.value);
        if (array != null)
            for (trie in array)
                if (trie != null)
                    values = values.concat(trie.values());
        if (chain != null)
            for (p in chain)
                values.push(p.value);
        return _values = values;
    }

    private static inline function indexOf(hash:Int, depth:Int)
        return (hash & (31 << (5 * depth))) >> (5 * depth);
}

class Pair<K,V> {
    public static function set<T>(value:T) return new Pair(value, value);
    public function new(k, v) {
        key = k;
        value = v;
    }
    public var key: K;
    public var value: V;
}
