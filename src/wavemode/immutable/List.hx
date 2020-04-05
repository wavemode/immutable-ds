/**
 *  Copyright (c) 2020-present, Chukwudi Okechukwu
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the root directory of this source tree.
 *
 */

// TODO: array index syntax

package wavemode.immutable;

class List<T> {

    private var data: Array<T>;

    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////// API
    //////////////////////////////////////////////////////////////////////////////////////////////////////////

    /**
        Create a new empty List.
    **/
    public function new() { data = []; }

    /**
        Create a new List from an array.
    **/
    public static inline function fromArray<T>(arr : Array<T>) : List<T> { 
        var list = new List();
        list.data = arr;
        return list; 
    }

    /**
        Returns the element at the given index. Throws an exception if `index` is out of bounds.
    **/
    public function getValue(index : Int) : T {
        if (index >= length || index < 0)
            throw "index $index out of bounds for List length $length";
        return data[index];
    }

    /**
        Returns the elment at the given index. Returns None if `index` is out of bounds.
    **/
    public function get(index : Int) : Option<T> {
        if (index >= length || index < 0)
            return None;
        return Some(data[index]);
    }

    /**
        Returns a new List with the given index replaced with the given `value`.

        If `index` is out of bounds, this function returns the unaltered List.
    **/
    public function set(index : Int, value : T) : List<T> { 
        if (index >= length || index < 0) return this;
        var arr = data.copy();
        arr[index] = value;
        var list = new List();
        list.data = arr;
        return list;
    }

    /**
        Returns a new List with the given `indices` replaced with the respective value in `values`.
        If any of the indices is out of bounds, that pair is ignored.

        Equivalent to calling `set()` for each pair individually, but potentially more efficient.
    **/
    public function setEach(indices : Iterable<Int>, values : Iterable<T>) : List<T> { 
        var indexIter = indices.iterator(), valIter = values.iterator(), result = this;
        while (indexIter.hasNext() && valIter.hasNext()) {
            result = result.set(indexIter.next(), valIter.next());
        }
        return result;
    }

    /**
        Returns a new List with the given `index` removed.

        If `index` is out of bound, this function returns the unaltered List.
    **/
    public function remove(index : Int) : List<T> {
        if (index >= length || index < 0) return this;
        var arr = data.copy();
        arr = arr.slice(0, index).concat(arr.slice(index+1));
        return fromArray(arr);
    }

    /**
        Returns a new List with the given indices removed. If an index in `indices` is out of bound,
        it will be skipped.

        Equivalent to calling `remove()` for each index individually, but potentially more efficient.
    **/
    public function removeEach(indices : Iterable<Int>) : List<T> { 
        var indexIter = indices.iterator(), result = this;
        while (indexIter.hasNext()) {
            result = result.remove(indexIter.next());
        }
        return result;
    }

    public function insert(index: Int) : List<T> { 
        return null; 
    }

    public function insertEach() : List<T> { 
        return null; 
    }


    public function update() : List<T> { return null; }
    public function updateEach() : List<T> { return null; }
    public function replace() : List<T> { return null; }
    public function replaceEach() : List<T> { return null; }
    public function has() : List<T> { return null; }
    public function hasEach() : List<T> { return null; }
    public function clear() : List<T> { return null; }
    public function push() : List<T> { return null; }
    public function pushEach() : List<T> { return null; }
    public function pop() : List<T> { return null; }
    public function unshift() : List<T> { return null; }
    public function shift() : List<T> { return null; }
    public function concat() : List<T> { return null; }
    public function map() : List<T> { return null; }
    public function flatMap() : List<T> { return null; }
    public function filter() : List<T> { return null; }
    public function zip() : List<T> { return null; }
    public function zipAll() : List<T> { return null; }
    public function reverse() : List<T> { return null; }
    public function sort() : List<T> { return null; }
    public function group() : List<T> { return null; }
    public function interpose() : List<T> { return null; }
    public function interleave() : List<T> { return null; }
    public function splice() : List<T> { return null; }
    public function slice() : List<T> { return null; }
    public function take() : List<T> { return null; }
    public function takeLast() : List<T> { return null; }
    public function takeWhile() : List<T> { return null; }
    public function takeUntil() : List<T> { return null; }
    public function drop() : List<T> { return null; }
    public function dropLast() : List<T> { return null; }
    public function dropWhile() : List<T> { return null; }
    public function dropUntil() : List<T> { return null; }
    public function reduce() : List<T> { return null; }
    public function reduceRight() : List<T> { return null; }
    public function every() : List<T> { return null; }
    public function some() : List<T> { return null; }
    public function empty() : List<T> { return null; }
    
    /**
        The number of elements in the List. Read-only property.
    **/
    public var length(get, never) : Int;
    private function get_length() : Int { return data.length; }

    public function indices() : List<T> { return null; }
    public function values() : List<T> { return null; }
    public function entries() : List<T> { return null; }
    public function forEach() : List<T> { return null; }
    public function forWhile() : List<T> { return null; }
    public function max() : List<T> { return null; }
    public function min() : List<T> { return null; }
    public function find() : List<T> { return null; }
    public function findWhere() : List<T> { return null; }
    public function equals() : List<T> { return null; }
    public function toMap() : List<T> { return null; }
    public function toOrderedMap() : List<T> { return null; }
    public function toSet() : List<T> { return null; }
    public function toOrderedSet() : List<T> { return null; }
    public function toStack() : List<T> { return null; }

}
