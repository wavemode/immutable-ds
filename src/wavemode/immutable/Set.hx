/**
 *  Copyright (c) 2020-present, Chukwudi Okechukwu
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the root directory of this source tree.
 *
 */

package wavemode.immutable;

class Set<T> {

    private var data : Array<T>;

    public function toString() : String {
        var result = "Set {";
        var cut = false;

        for (v in this) {
            cut = true;
            result += ' $v,';
        }

        if (cut) result = result.substr(0, result.length - 1);
        return result + " }";
    }

    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////// API
    //////////////////////////////////////////////////////////////////////////////////////////////////////////

    /**
        Create a new empty Set.
    **/
    public function new() { data = []; }

    /**
        Iterator over each value in the Set.
    **/
    public function iterator() : Iterator<T> {
        var i = 0;
        return {
            hasNext: () -> i < data.length,
            next: () -> data[i++]
        };
    }

    /**
        Create a new Set with the values in `arr`.
    **/
    public static function fromArray<T>(arr : Array<T>) : Set<T> {
        var map = new Set();
        arr.reverse();
        for (val in arr) map = map.add(val);
        return map;
    }

    /**
        Number of keys that are in the Set. Read-only property.
    **/
    public var length(get, never) : Int;
    function get_length() return data.length;

    /**
        Returns a new Set containing the new value. If an equivalent value already 
        exists in this Set, this function returns the unaltered Set.
    **/
    public function add(val : T): Set<T> {
        for (v in this) {
            if (val == v) {
                return this;
            }
        }
        var arr = data.copy();
        arr.insert(0, val);
        return fromArray(arr);
    }

    /**
        Returns a new Set with each value in `values` added. If an equivalent value already 
        exists in this Set, it will be skipped.

        This is equivalent to calling `add()` for each value individually, but is potentially more
        efficient.
    **/
    public function addAll(values: Iterable<T>): Set<T> {
        var set = this;
        for (val in values) {
            set = set.add(val);
        }
        return set;
    }

    /**
        Returns a new Set which excludes this key.
    **/
    public function remove(value: T): Set<T> {
        var i = 0, arr = data;
        for (v in this) {
            if (value == v) {
                arr = arr.slice(0, i).concat(arr.slice(i + 1));
                break;
            }
            i++;
        }
        return fromArray(arr);
    }

    /**
        Returns a new Set which excludes the provided values.

        This is equivalent to calling `remove()` for each value individually, but is potentially more
        efficient.
    **/
    public function removeAll(values: Iterable<T>) : Set<T> {
        var set = this;
        for (v in values) {
            set = set.remove(v);
        }
        return set;
    }

    /**
        Returns a new Set containing no keys or values.
    **/
    public function clear() : Set<T> {
        return fromArray([]);
    }

    /**
        Returns a new Set having the given value updated with return value of calling `updater` with the existing value.
    
        If `key` does not exist, this function returns the unaltered set.
    **/
    public function update(value: T, updater: T -> T): Set<T> {
        var i = 0, arr = data.copy();
        for (v in this) {
            if (value == v) {
                arr[i] = updater(arr[i]);
                break;
            }
            i++;
        }
        return fromArray(arr);
    }

    /**
        Returns a new Set resulting from merging `other` into this Set. In other words, this 
        takes each value in `other` and adds it to this Set.
    **/
    public function union(other: Iterable<T>) : Set<T> {
        var result = this;
        for (v in other) result = result.add(v);
        return result;
    }

    /**
        Returns a new Set resulting from merging each set in `others` into this Set. In other words, this 
        takes each value in each set in `others` and adds it to this Set.

        This is equivalent to calling `union()` for each set individually, but potentially more
        efficient.
    **/
    public function unionAll(others : Iterable<Iterable<T>>) : Set<T> {
        var result = this;
        for (other in others) result = result.union(other);
        return result;
    }

    /**
        Returns a new Set containing only values that appear in this set and in `other`.
    **/
    public function intersect(other: Iterable<T>) : Set<T> {
        var result = new Set();
        for (v in other) if (has(v)) result = result.add(v);
        return result;
    }

    /**
        Returns a new Set containing only values that appear in this set and in every set in `others`.

        This is equivalent to calling `intersect()` for each set individually, but potentially more
        efficient.
    **/
    public function intersectAll(others : Iterable<Iterable<T>>) : Set<T> {
        var result = this;
        for (other in others) result = result.intersect(other);
        return result;
    }

    /**
        Returns a new Set containing only values in this set that do not appear in `other`.
    **/
    public function subtract(other: Set<T>) : Set<T> {
        var result = new Set();
        for (v in this) if (!other.has(v)) result = result.add(v);
        return result;
    }

    /**
        Returns a new Set containing only values in this set that do not appear in any set in `others`.

        This is equivalent to calling `subtract()` for each set individually, but potentially more
        efficient.
    **/
    public function subtractAll(others : Iterable<Set<T>>) : Set<T> {
        var result = this;
        for (other in others) result = result.subtract(other);
        return result;
    }

    /**
        Returns a new Set with values passed through a mapper function.
    **/
    public function map<M>(mapper: T -> M) : Set<M> {
        return fromArray(data.map(value -> mapper(value)));
    }

    /**
        Returns a new Set with only the entries for which the predicate function returns true.
    **/
    public function filter(predicate: T -> Bool) : Set<T> {
        return fromArray(data.filter(value -> predicate(value)));
    }

    /**
        An iterator of this Set's keys. Equivalent to `iterator()`.
    **/
    public function values(): Iterator<T> {
        return iterator();
    }

    /**
        True if this and the other Set have identical values.
    **/
    public function equals(other: Set<T>): Bool {
        if (length != other.length) return false;
        for (value in this) {
            if (!other.has(value)) return false;
        }
        return true;
    }

    /**
        True if a value exists within this Set.
    **/
    public function has(val : T): Bool {
        for (v in this) {
            if (val == v) {
                return true;
            }
        }
        return false;
    }
    
    /**
        The `sideEffect` is executed for every entry in the Set.
    **/
    public function forEach(sideEffect: T -> Void) : Void {
        for (v in this) sideEffect(v);
    }

    /**
        The `sideEffect` is executed for every entry in the Set. Iteration stops once `sideEffect` returns false.
        
        This function returns the number of times `sideEffects` was executed.
    **/
    public function forWhile(sideEffect: T -> Bool) : Int {
        var i = 0;
        for (v in this) {
            if (!sideEffect(v)) break;
            ++i;
        }
        return i;
    }

    /**
        Shallowly converts this Set to an Array.
    **/
    public function toArray(): Array<T> {
        return [for (v in values()) v];
    }

    /**
        Returns a Sequence of values in this Map.
    **/
    public function toSequence(): Sequence<T> { // TODO: implement
        return null;
    }
    
    /**
        Converts this Map to a Set.
    **/
    public function toSet(): Set<T> { // TODO: implement
        return null;
    }

    /**
        Converts this Set to a List.
    **/
    public function toList(): List<T> { // TODO: implement
        return null;
    }

    /**
        Converts this Set to a Stack.
    **/
    public function toStack(): Stack<T> { // TODO: implement
        return null;
    }

}