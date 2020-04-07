/**
 *  Copyright (c) 2020-present, Chukwudi Okechukwu
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the root directory of this source tree.
 *
 */

// TODO: array index syntax
// TODO: make syntax for all types

package wavemode.immutable;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
#end

import stdlib.Exception;

using wavemode.immutable.Functional;

class List<T> {
	private var data:Array<T>;

	//////////////////////////////////////////////////////////////////////////////////////////////////////////
	////// API
	//////////////////////////////////////////////////////////////////////////////////////////////////////////

	/**
		Create a new empty List.
	**/
	public function new() {
		data = [];
	}

	/**
		Create a new List from an array.
	**/
	public static inline function fromArray<T>(arr:Array<T>):List<T> {
		var list = new List();
		list.data = arr;
		return list;
    }
    
	/**
		Iterator over each value in the List.
	**/
	public function iterator():Iterator<T> {
		var i = 0;
		return {
			hasNext: () -> i < data.length,
			next: () -> data[i++]
		};
	}

	/**
		Iterator over each index-value pair in the List.
	**/
	public function keyValueIterator():KeyValueIterator<Int, T> {
		var i = 0;
		return {
			hasNext: () -> i < data.length,
			next: () -> { 
                var result = {key: i, value: data[i]};
                ++i;
                result;
            }
		};
	}

	/**
		Returns the element at the given index, or null if `index` is out of bounds.
	**/
	public inline function get(index:Int):Null<T>
		if (index >= length || index < 0)
			return null;
		else 
			return data[index];

	/**
		Unsafe variant of `get()`. Returns the element at the given index. Throws an Exception if `index` is out of bounds.
	**/
	public inline function getValue(index:Int):T
		if (index >= length || index < 0)
			throw new Exception('index $index out of bounds for List length $length');
		else
			return data[index];

	/**
		Returns a new List with the given index replaced with the given `value`. 

		If `index` is out of bounds, this function returns the unaltered List.
	**/
	public inline function set(index:Int, value:T):List<T> {
		if (index >= length || index < 0)
			return this;
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
	public function setEach(indices:Iterable<Int>, values:Iterable<T>):List<T> {
		var indexIter = indices.iterator(),
			valIter = values.iterator(),
			result = this;
		while (indexIter.hasNext() && valIter.hasNext()) {
			result = result.set(indexIter.next(), valIter.next());
		}
		return result;
	}

	/**
		Returns a new List with the given `index` removed.

		If `index` is out of bound, this function returns the unaltered List.
	**/
	public function remove(index:Int):List<T> {
		if (index >= length || index < 0)
			return this;
		var arr = data.copy();
		arr = arr.slice(0, index).concat(arr.slice(index + 1));
		return fromArray(arr);
	}
	
	/**
		Returns a new List with all instances of the given `value` removed.
	**/
	public function removeValue(value:T):List<T> {
		var arr = data.copy(), i = 0;
		while (i < arr.length) {
			if (arr[i] == value) {
				arr = arr.slice(0, i).concat(arr.slice(i + 1));
				--i;
			}
			++i;
		}
		return fromArray(arr);
	}

	/**
		Returns a new List with the given indices removed. If an index in `indices` is out of bound,
		it will be skipped.

		Equivalent to calling `remove()` for each index individually, but potentially more efficient.
	**/
	public function removeEach(indices:Iterable<Int>):List<T> {
		var indexIter = indices.iterator(), result = this;
		while (indexIter.hasNext()) {
			result = result.remove(indexIter.next());
		}
		return result;
	}

	/**
		Returns a new List with the given `values` removed.

		Equivalent to calling `removeValue()` for each value individually, but potentially more efficient.
	**/
	public function removeEachValue(values:Iterable<T>):List<T> {
		var valueIter = values.iterator(), result = this;
		while (valueIter.hasNext()) {
			result = result.removeValue(valueIter.next());
		}
		return result;
	}

    /**
        Insert the given `value` at the specified `index`, pushing back every subsequent element in the List.

        If `index` is out of bounds, this function returns the unaltered List.
    **/
	public function insert(index:Int, value:T):List<T> {
		if (index >= length || index < 0)
			return this;
        var arr = data.copy();
        arr.insert(index, value);
        return fromArray(arr);
	}

    /**
        Returns a new List having updated the value at this index with the return value of calling `updater` with the existing value.

        Similar to `list.set(key, updater(list.get(key)))`.

        If `index` is out of bounds, this function returns the unaltered list.
    **/
	public function update(index:Int, updater:T->T):List<T> {
		if (index >= length || index < 0)
			return this;
        var arr = data.copy();
        arr[index] = updater(arr[index]);
        return fromArray(arr);
	}

    /**
        Returns a new List having updated the values at these indices with the return value of calling `updater` with 
        the existing values. If any index in `indices` is out of bounds, it is skipped.

        Equivalent to calling `update()` for each index individually, but potentially more efficient.
    **/
	public function updateEach(indices:Iterable<Int>, updater:T->T):List<T> {
		var indexIter = indices.iterator(),
			result = this;
		while (indexIter.hasNext()) {
			result = result.update(indexIter.next(), updater);
		}
		return result;
	}

	/**
		Returns a new List having the given `oldVal` replaced with the value `newVal`.

		If the value does not exist, this function returns the unaltered list.
	**/
	public function replace(oldVal:T, newVal:T):List<T> {
        var i = 0;
        for (v in this) {
            if (v == oldVal) {
                var arr = data.copy();
                arr[i] = newVal;
                return fromArray(arr);
            }
            ++i;
        }
        return this;
	}

	/**
        Returns a new List having the given `oldValues` replaced with the values in
        `newValues`. If any given value does not exist, it will be skipped.
            
		Equivalent to calling `replace()` for each value individually, but potentially more efficient,
		and earlier replacements do not affect later ones.
	**/
	public function replaceEach(oldValues:Iterable<T>,newValues:Iterable<T>):List<T> {
		var oldIter = oldValues.iterator(),
			newIter = newValues.iterator(),
			arr = data.copy(),
			updates = [];
		while (oldIter.hasNext() && newIter.hasNext()) {
			var oldValue = oldIter.next(), newValue = newIter.next();
			for (i in 0...arr.length) {
				if (arr[i] == oldValue)
					updates.push({k: i, v: newValue});
			}
		}
		for (update in updates)
			arr[update.k] = update.v;
		return fromArray(arr);
	}

    /**
        Returns true if the value exists in this List.
    **/
	public function has(value:T):Bool {
        for (v in this) if (v == value) return true;
        return false;
    }
    
    /**
        Returns the empty List.
    **/
	public inline function clear():List<T> {
		return new List();
	}

    /**
        Returns a new List with the given `value` appended to the end.
    **/
	public function push(value:T):List<T> {
        var arr = data.copy();
        arr.push(value);
        return fromArray(arr);
	}

    /**
        Returns a new List with the given `values` appended to the end.

        Equivalent to calling `push()` for each value individually, but
        potentially more efficient.
    **/
	public function pushEach(values:Iterable<T>):List<T> {
        var result = this;
        for (v in values) result = result.push(v);
        return result;
	}

    /**
        Returns a new List with one element removed from the end.

        Equivalent to `list.dropBack(1)`
    **/
	public function pop():List<T> {
		return dropLast(1);
	}

    /**
        Returns a new List with the given `value` inserted at the front.

        Equivalent to `list.insert(0, value)`
    **/
	public function unshift(value:T):List<T> {
		return insert(0, value);
	}

    /**
        Returns a new List with one element removed from the front.

        Equivalent to `list.drop(1)`
    **/
	public function shift():List<T> {
		return drop(1);
	}

    /**
        Returns a new List with each value in `other` appended to the end.
    **/
	public function concat(other:Iterable<T>):List<T> {
        var result = this;
        for (v in other) result = result.push(v);
        return result;
    }
    
    /**
        Returns a new List with each value in each iterable in `others` to the end.

        Equivalent to calling `concat()` for each list individually, but potentially
        more efficient.
    **/
	public function concatEach(others:Iterable<Iterable<T>>):List<T> {
        var result = this;
        for (obj in others) result = result.concat(obj);
        return result;
	}

    /**
        Returns a new List with each value passed through the `mapper` function.
    **/
	public function map<M>(mapper:T->M):List<M> {
		return fromArray(data.map(mapper));
	}

    /**
        Creates a new List with each value passed through the `mapper` function,
        then returns the flattened result.

        Equivalent to `new List().concatEach(list.map(mapper))`
    **/
	public function flatMap<N, M:Iterable<N>>(mapper:T->M):List<N> {
		return new List().concatEach(map(mapper));
	}

    /**
        Returns a new List excluding each value that does not satify the `predicate`.
    **/
	public function filter(predicate:T->Bool):List<T> {
		return fromArray(data.filter(predicate));
	}

    /**
        Takes list A and list B and creates a new List where the i'th element is the list [A[i], B[i]]

        For example, `[1, 2, 3].zip([4, 5, 6])` results in `[[1, 4], [2, 5], [3, 6]]`
    **/
	public function zip(other:Iterable<T>):List<List<T>> {
        var arr = [for (elem in other) elem];
        return fromArray([for (i in 0...arr.length) fromArray([getValue(i), arr[i]])]);
	}

    /**
        Zips each sequence with this list.

        For example, `[1, 2, 3].zipAll([[4, 5, 6], [7, 8, 9]])` results in `[[1, 4, 7], [2, 5, 8], [3, 6, 9]]`
    **/
	public function zipAll(others:Iterable<Iterable<T>>):List<List<T>> {

		// gather inputs into arrays
		var arr = [for (other in others) [for (elem in other) elem]];
		
		// determine shortest length of input arrays
		var shortest = arr[0].length;
		for (i in 1...arr.length) {
			if (arr[i].length < shortest) shortest = arr[i].length;
		}

		// zip into lists
		return fromArray([
			for (i in 0...shortest) fromArray([for (j in 0...arr.length)
				arr[i][j]
			])
		]);

	}

	/**
		Returns a new List in reverse order.
	**/
	public function reverse():List<T> {
		var arr = data.copy();
		arr.reverse();
		return fromArray(arr);
	}

	// TODO: verify sorting behavior

	/**
		Returns a sorted List according to the comparison function `f`, where
		`f(x,y)` returns a negative Int if `x` should be after `y`, a positive
		Int if `x` should be before `y`, and 0 if the values are equivalent.

		For example, `[5, 4, 3, 2, 1].sort((x, y) -> y - x)` returns `[1, 2, 3, 4, 5]`
	**/
	public function sort(f:(T,T)->Int):List<T> {
		var arr = data.copy();
		arr.sort(f);
		return fromArray(arr);
	}

	/**
		Returns a List sorted ascending numerically.
	**/
	public macro function sortAsc(ethis:ExprOf<List<T>>):ExprOf<List<T>> {
		return macro {
			$e{ethis}.sort((a, b) -> b - a);
		};
	}

	/**
		Returns a List sorted descending numerically.
	**/
	public macro function sortDesc(ethis:ExprOf<List<T>>):ExprOf<List<T>> {
		return macro {
			$e{ethis}.sort((a, b) -> a - b);
		};
	}

	/**
		Returns a List of Lists, with elements grouped according to the return value of `grouper`.

		For example, `[1, 2, 3, 4, 5].group(x -> x % 2)` results in `[[1, 3, 5], [2, 4]]`
	**/
	public function group<M>(grouper:T->M):List<List<T>> {
		var groups = [], result = [];
		for (elem in this) {
			var group = grouper(elem);
			var groupIndex = groups.indexOf(group);
			if (groupIndex == -1) {
				groups.push(group);
				result.push(new List().push(elem));
			} else {
				result[groupIndex] = result[groupIndex].push(elem);
			}
		}
		return fromArray(result);
	}

	/**
		Returns a List with elements separated by `separator`.

		For example, `[1, 2, 3, 4].separate(0)` results in `[1, 0, 2, 0, 3, 0, 4]`
	**/
	public function separate(separator:T):List<T> {
		var result = [];
		for (i in 0...length-1) {
			result.push(getValue(i));
			result.push(separator);
		}
		return fromArray(result);
	}

	/**
		Returns a List with elements from `sequence` interleaved between the elements of this List.

		For example, `[1, 2, 3, 4].interleave([9, 8, 7, 6, 5])` results in `[1, 9, 2, 8, 3, 7, 4, 6, 5]`
	**/
	public function interleave(sequence:Iterable<T>):List<T> {
		var result = [], iter = sequence.iterator();
		var i = 0;
		while (true) {
			if (!iter.hasNext()) {
				while (i < length) {
					result.push(getValue(i++));
				}
				return fromArray(result);
			} else if (i == length) {
				while (iter.hasNext()) {
					result.push(iter.next());
				}
				return fromArray(result);
			} else {
				result.push(getValue(i++));
				result.push(iter.next());
			}
		}
	}

	/**
		Returns `len` elements (all elements if len is null) from the List,
		starting at and including `pos`.

		If `pos` is negative, its value is calculated from the end of the List.

		If `pos` >= length, an empty List is returned.

		If `len` elements cannot be copied, this function copies as many elements 
		as possible and returns them.
	**/
	public function splice(pos:Int, ?len:Int):List<T> {

		while (pos < 0) pos += length;
		if (len == null) len = length;

		var result = [];
		for (i in pos...pos+len) {
			if (i >= length) break;
			result.push(getValue(i));
		}
		return fromArray(result);
	}

	/**
		Returns elements starting from and including `pos`, ending at but not including `end`.

		If `pos` is negative, its value is calculated from the end of the List.

		If `end` is less than `pos` or is null, it defaults to `this.length`.

		If `len` elements cannot be copied, this function copies as many elements 
		as possible and returns them.
	**/
	public function slice(pos:Int, ?end:Int):List<T> {

		while (pos < 0) pos += length;
		if (end == null || end < pos) end = length;

		var result = [];
		for (i in pos...end) {
			if (i >= length) break;
			result.push(getValue(i));
		}
		return fromArray(result);

	}

	/**
		Returns the first element of the List, or null if the List is empty.
	**/
	public function first():Null<T> {
		return get(0);
	}

	/**
		Returns the last element of the List, or null if the List is empty.
	**/
	public function last():Null<T> {
		return get(length-1);
	}

	/**
		Returns `num` elements from the start of the List.
	**/
	public function take(num:Int):List<T> {
		return splice(0, num);
	}

	/**
		Returns `num` elements from the end of the List.
	**/
	public function takeLast(num:Int):List<T> {
		return splice(-num);
	}

	/**
		Returns elements from this list until `predicate` returns false.

		For example, `[1, 2, 3, 4].takeWhile(x -> x < 3)` returns `[1, 2]`
	**/
	public function takeWhile(predicate:T->Bool):List<T> {
		var result = [];
		for (i in 0...length) {
			if (!predicate(getValue(i))) break;
			result.push(getValue(i));
		}
		return fromArray(result);
	}

	/**
		Returns elements from this list until `predicate` returns true.

		For example, `[1, 2, 3, 4].takeUntil(x -> x == 3)` returns `[1, 2]`
	**/
	public function takeUntil(predicate:T->Bool):List<T> {
		var result = [];
		for (i in 0...length) {
			if (predicate(getValue(i))) break;
			result.push(getValue(i));
		}
		return fromArray(result);
	}

	/**
		Returns a new List with `num` elements removed from the front.
	**/
	public inline function drop(num:Int):List<T> {
		return slice(num);
	}

	/**
		Returns a new List with `num` elements removed from the end.
	**/
	public inline function dropLast(num:Int):List<T> {
		return slice(0, length-num);
	}

	/**
		Returns all elements from this list after `predicate` returns false.
		Even if `predicate` returns true for elements thereafter, they will
		still be included.

		For example, `[1, 2, 3, 4, 2].dropWhile(x -> x != 3)` returns `[3, 4, 2]`
	**/
	public function dropWhile(predicate:T->Bool):List<T> {
		var result = [], i = 0;
		while (i < length && predicate(getValue(i))) {
			++i;
		}
		while (i < length) {
			result.push(getValue(i++));
		}
		return fromArray(result);
	}

	
	/**
		Returns all elements from this list after `predicate` returns true.
		Even if `predicate` returns false for elements thereafter, they will
		still be included.

		For example, `[1, 2, 3, 4, 2].dropUntil(x -> x == 3)` returns `[3, 4, 2]`
	**/
	public function dropUntil(predicate:T->Bool):List<T> {
		var result = [], i = 0;
		while (i < length && !predicate(getValue(i))) {
			++i;
		}
		while (i < length) {
			result.push(getValue(i++));
		}
		return fromArray(result);
	}

	/**
		Returns the accumulation of this List accourding to `reducer` beginning with `intialValue`.

		For example, `[1, 2, 3, 4].reduce((a, b) -> a + b, 0)` returns `10`
	**/
	public function reduce<M>(reducer:(M,T)->M, initialValue:M):M {
		var i = 0;
		while (i < length) initialValue = reducer(initialValue, getValue(i++));
		return initialValue;
	}

	/**
		Returns the sum of every element in the List.
	**/
	public macro function sum(ethis:Expr):Expr {
		return macro $e{ethis}.reduce((a, b) -> a + b, 0);
	}

	/**
		Returns the product of every element in the List.
	**/
	public macro function product(ethis:Expr):Expr {
		return macro $e{ethis}.reduce((a, b) -> a * b, 0);
	}

	/**
		Returns the accumulation of this List accourding to `reducer` beginning with `intialValue`.
		Same as `reduce()` but this iterates in reverse.

		For example, `[1, 2, 3, 4].reduce((a, b) -> a + b, 0)` returns `10`
	**/
	public function reduceRight<M>(reducer:(M,T)->M, initialValue:M):M {
		var i = length;
		while (i > 0) initialValue = reducer(initialValue, getValue(--i));
		return initialValue;
	}

	/**
		True if `predicate` is true for every element in the List.
	**/
	public function every(predicate:T->Bool):Bool {
		for (v in this) if (!predicate(v)) return false;
		return true;
	}

	/**
		True if `predicate` is true for any element in the List.
	**/
	public function some(predicate:T->Bool):Bool {
		for (v in this) if (predicate(v)) return true;
		return false;
	}

	/**
		True if the List is empty.
	**/
	public function empty():Bool {
		return length == 0;
	}

	/**
		The number of elements in the List. Read-only property.
	**/
	public var length(get, never):Int;
	private function get_length():Int {
		return data.length;
	}

	/**
		Iterator over each index of the list.
	**/
	public inline function indices():Iterator<Int> {
		return 0...length;
	}

	/**
		Iterator over each value in the List. Equivalent to `iterator()`
	**/
	public inline function values():Iterator<T> {
		return iterator();
	}

	/**
		Iterator over each index-value pair in the list.
	**/
	public function entries():Iterator<{index: Int, value: T}> {
		var i = 0;
		return {
			hasNext: () -> i < length,
			next: () -> {
				var result = { index: i, value: getValue(i++) };
				++i;
				result;
			}	
		};
	}

	/**
		The `sideEffect` is executed for every value in the List.
	**/
	public function forEach(sideEffect:T->Void):Void {
		for (k => v in this)
			sideEffect(v);
	}

	/**
		The `sideEffect` is executed for every value in the List. Iteration stops once `sideEffect` returns false.

		This function returns the number of times `sideEffects` was executed.
	**/
	public function forWhile(sideEffect:T->Bool):Int {
		var i = 0;
		for (v in this) {
			++i;
			if (!sideEffect(v))
				break;
		}
		return i;
	}

	/**
		Returns the numerical maximum of the List.
	**/
	public macro function max(ethis:Expr):Expr {
		return macro $e{ethis}.reduce((a,b)->if(b > a) b else a, $e{ethis}.getValue(0));
	}

	/**
		Returns the numerical minimum of the List.
	**/
	public macro function min(ethis:Expr):Expr {
		return macro $e{ethis}.reduce((a,b)->if(b < a) b else a, $e{ethis}.getValue(0));
	}

	/**
		Returns the first index of the given `value`, or -1 if it does not exist in the List.

		Begins searching from `start`, or 0 if start is null.
	**/
	public function find(value:T, ?start:Int):Int {
		if (start == null) start = 0;
		for (i in start...length) if (getValue(i) == value) return i;
		return -1;
	}

	/**
		Returns the first index at which `predicate` returns true, or -1 if no match is found.

		Begins searching from `start`, or 0 if start is null.
	**/
	public function findWhere(predicate:T->Bool, ?start:Int):Int {
		if (start == null) start = 0;
		for (i in start...length) if (predicate(getValue(i))) return i;
		return -1;
	}

	/**
		Returns true if this List and `other` contain an identical sequence of values.
	**/
	public function equals(other:Iterable<T>):Bool {
		var iter = other.iterator(), thisIter = iterator();
		while(iter.hasNext() && thisIter.hasNext())
			if (iter.next() != thisIter.next()) return false;
		return !(iter.hasNext() || thisIter.hasNext());
	}

	/**
		Convert this List into an Array<T>
	**/
	public function toArray():Array<T> {
		return [for (v in this) v];
	}

	/**
		Convert this List into a Map<Int,T>
	**/
	public function toMap():Map<Int, T> {
		return new Map().setEach(indices().iterable(), values().iterable());
	}

	/**
		Convert this List into an OrderedMap<Int,T>
	**/
	public function toOrderedMap():OrderedMap<Int, T> {
		return new OrderedMap().setEach(indices().iterable(), values().iterable());
	}

	/**
		Convert this List into a Set<T>
	**/
	public function toSet():Set<T> {
		return new Set().addEach(values().iterable());
	}

	/**
		Convert this List into an OrderedSet<T>
	**/
	public function toOrderedSet():OrderedSet<T> {
		return new OrderedSet().addEach(values().iterable());
	}

	/**
		Convert this List into a Stack<T>
	**/
	public function toStack():Stack<T> {
		return new Stack().pushEach(values().iterable());
	}

	/**
		Convert this List into a Sequence<T>
	**/
	public function toSequence():Sequence<T> {
		return Sequence.from(this);
	}

}
