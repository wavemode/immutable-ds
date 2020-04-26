/**
 *  Copyright (c) 2020-present, Chukwudi Okechukwu
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the root directory of this source tree.
 *
 */

package wavemode.immutable;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
#end

import haxe.Exception;
import wavemode.immutable._internal.VectorTrie;
import haxe.ds.Vector;
import wavemode.immutable._internal.FunctionalIterator;
import wavemode.immutable.Stack;
using wavemode.immutable._internal.Functional;

abstract List<T>(ListObject<T>) from ListObject<T> to ListObject<T> {

	/**
		Create a new empty List, or a clone of an Iterable.
	**/
	public inline function new(?seq:Sequence<T>)
		if (seq != null)
			this = seq.toList();
		else
			this = new ListObject();

	/**
		Create a new List from any iterable.
	**/
	public static inline function fromSequence<T>(seq:Sequence<T>):List<T>
		return new List().pushEach(seq);
	
	/**
		Macro which creates a new List from any number of values.
	**/
	public static macro function make<T>(exprs:Array<ExprOf<T>>):ExprOf<List<T>>
		return macro @:pos(Context.currentPos()) new List().pushEach([$a{exprs}]);

	/**
		Create a List of `num` repeating values.
	**/
	public static function constant<T>(obj:T, num:Int):List<T>
		return Sequence.constant(obj).take(num).toList();

	/**
		Create a List of numbers from `start` to `end`, inclusive.
	**/
	public static function range(start:Int, end:Int):List<Int>
		return Sequence.range(start, end).toList();

	/**
		Create a List of `len` values starting with `start` and
		repeatedly passed through the `iterator` function.
	**/
	public static function iterate<T>(len:Int, start:T, iterator:T->T):List<T>
		return Sequence.iterate(start, iterator).take(len).toList();
	
	/**
		Create a List representing `len` values starting at `start`
		and incremented by `step` each time.

		`step` is 1 by default. `start` is 0 by default.
	**/
	public static function step(len:Int, start:Int = 0, step:Int = 1)
		return Sequence.step(start, step).take(len).toList();

	/**
		Create a List with each of the given `sequences` concatenated together,
		separated by `separator`
	**/
	public static function join<T>(sequences:Sequence<Sequence<T>>, separator:T):List<T>
		return Sequence.join(sequences, separator).toList();

	/**
		Create a new List with all the values in 	`arr`.
	**/
	@:from public static inline function fromArray<T>(arr:Array<T>):List<T>
		return new List().pushEach(arr);

	/**
		Returns a new List with the given `value` appended to the end.
	**/
	public function push(value:T):List<T> {
		var result = new ListObject();
		if (this.tail == null) {
			result.tail = new Vector(32);
			result.tail.unsafe()[0] = value;
			result.tailLength = 1;
			result.data = this.data;
		} else if (this.tailLength == 32) {
			result.data = this.data.pushVector(this.tail.unsafe());
			result.tail = new Vector(32);
			result.tail.unsafe()[0] = value;
			result.tailLength = 1;
		} else {
			result.tail = this.tail;
			result.tailLength = this.tailLength;
			result.tail.unsafe()[result.tailLength++] = value;
			result.data = this.data;
		}
		return result;
	}

	/**
		Returns a new List with the given `values` appended to the end.

		Equivalent to calling `push()` for each value individually, but
		potentially more efficient.
	**/
	public function pushEach(values:Sequence<T>):List<T> {
		var result = new ListObject();
		result.tail = this.tail.or(new Vector(32));
		result.tailLength = this.tailLength;
		result.data = this.data;
		for (v in values) {
			if (result.tailLength == 32) {
				result.data = result.data.pushVector(result.tail.unsafe());
				result.tail = new Vector(32);
				result.tailLength = 0;
			}
			result.tail.unsafe()[result.tailLength++] = v;
		}
		return result;
	}

	/**
		Returns a new List with one element removed from the end.
	**/
	public function pop():List<T> {
		var result = new ListObject();
		if (this.tailLength == 0) {
			result.data = this.data.pop();
		} else {
			result.data = this.data;
			result.tail = this.tail;
			result.tailLength = this.tailLength - 1;
		}
		return result;
	}

	/**
		Returns a new List with the given `value` inserted at the front.
	**/
	public inline function unshift(value:T):List<T>
		return insert(0, value);

	/**
		Returns a new List with one element removed from the front.
	**/
	public inline function shift():List<T>
		return drop(1);

	/**
		Insert the given `value` at the specified `index`, pushing back every subsequent
		element in the List.

		If `index` is out of bounds, this function returns the unaltered List.
	**/
	public function insert(index:Int, value:T):List<T>
		if (index < 0 || index > length)
			return this;
		else
			return toSequence().insert(index, value).toList();

	/**
		Insert the given `values` at the specified `index`, pushing back every subsequent
		element in the List.

		Equivalent to calling `insert()` for each value individually, but potentially more
		efficient.
	**/
	public function insertEach(index:Int, values:Sequence<T>):List<T>
		if (index < 0 || index > length)
			return this;
		else
			return toSequence().insertEach(index, values).toList();

	/**
		Returns a new List with the given index replaced with the given `value`. 

		If `index` is out of bounds, this function returns the unaltered List.
	**/
	public inline function set(index:Int, value:T):List<T> {
		if (index < 0 || index >= length)
			return this;
		var result = new ListObject();
		result.tailLength = this.tailLength;
		if (index < dataLen) {
			result.data = this.data.set(index, value);
		} else {
			result.data = this.data;
			result.tail = copy(this.tail.unsafe());
			result.tail.unsafe()[index-dataLen] = value;
		}
		return result;
	}


	/**
		Returns a new List with the given `indices` replaced with the respective
		value in `values`. If any of the indices is out of bounds, that pair is ignored.

		Equivalent to calling `set()` for each pair individually, but potentially more
		efficient.
	**/
	public function setEach(indices:Sequence<Int>, values:Sequence<T>):List<T> {
		var result = self,
			indexIter = indices.iterator(),
			valueIter = values.iterator();
		while (indexIter.hasNext() && valueIter.hasNext())
			result = result.set(indexIter.next(), valueIter.next());
		return result;
	}


	/**
		Returns a new List having updated the value at this index with the return value of
		calling `updater` with the existing value.

		Similar to `list.set(index, updater(list.get(index)))`.

		If `index` is out of bounds, this function returns the unaltered list.
	**/
	public function update(index:Int, updater:T->T):List<T>
		if (has(index))
			return set(index, updater(get(index)));
		else
			return this;

	/**
		Returns a new List having updated the values at these indices with the return value
		of calling `updater` with the existing values. If any index in `indices` is out of
		bounds, it is skipped.

		Equivalent to calling `update()` for each index individually, but potentially more
		efficient.
	**/
	public function updateEach(indices:Sequence<Int>, updater:T->T):List<T> {
		var result = self;
		for (index in indices)
			result = result.update(index, updater);
		return result;
	}

	/**
		Returns a new List having all instances of the given `oldVal` replaced with the
		value `newVal`.

		If the value does not exist, this function returns the unaltered list.
	**/
	public function replace(oldVal:T, newVal:T):List<T> {
		var result = self;
		for (i => v in this)
			if (v == oldVal)
				result = result.set(i, newVal);
		return result;
	}

	/**
		Returns a new List having the given `oldValues` replaced with the values in
		`newValues`. If any given value does not exist, it will be skipped.
			
		Equivalent to calling `replace()` for each value individually, but potentially more
		efficient, and earlier replacements do not affect later ones.
	**/
	public function replaceEach(oldValues:Sequence<T>, newValues:Sequence<T>):List<T> {
		var result = self;
		for (i => v in this) {
			var found = oldValues.find(v);
			if (found != -1 && newValues.has(found))
				result = result.set(i, newValues[found]);
		}
		return result;
	}

	/**
		Returns the element at the given index, or throws an Exception if `index` is out of bounds.
	**/
	@:arrayAccess
	public inline function get(index:Int):T
		if (index < 0 || index >= length)
			throw new Exception('index $index out of bounds for List')
		else if (index < dataLen)
			@:nullSafety(Off) return cast this.data.retrieve(index);
		else
			@:nullSafety(Off) return this.tail[index-dataLen];

	/**
		Returns true if the index exists in this List.
	**/
	public inline function has(index:Int):Bool
		return index < length && index >= 0;

	/**
		True if the List is empty.
	**/
	public inline function empty():Bool
		return length == 0;

	/**
		Returns the first index of the given `value`, or -1 if it does not exist in the
		List.

		Begins searching from `start`, or 0 if start is null.
	**/
	public function find(value:T, ?start:Int):Int {
		var i = start.or(0);
		while (i < length) {
			if (value == get(i))
				return i;
			++i;
		}	
		return -1;
	}

	/**
		Returns true if the given value is in this List.
	**/
	public inline function contains(value:T):Bool
		return find(value) != -1;

	/**
		Alias of `find()`. Returns the first index of the given `value`, or -1 if it does
		not exist in the List.

		Begins searching from `start`, or 0 if start is null.
	**/
	public inline function indexOf(value:T, ?start:Int):Int
		return find(value, start);

	/**
		Returns the first index at which `predicate` returns true, or -1 if no match is
		found.

		Begins searching from `start`, or 0 if start is null.
	**/
	public function findWhere(predicate:T->Bool, ?start:Int):Int {
		var i = start.or(0);
		while (i < length) {
			if (predicate(get(i)))
				return i;
			++i;
		}	
		return -1;
	}

	/**
		Returns the first element of the List. Throws an Exception if the List is empty.
	**/
	public function first():T
		return get(0);

	/**
		Returns the last element of the List. Throws an Exception if the List is empty.
	**/
	public function last():T
		return get(length-1);

	/**
		Returns a new List excluding each value that does not satify the `predicate`.
	**/
	public function filter(predicate:T->Bool):List<T> {
		var vec = new List();
		for (v in this)
			if (predicate(v))
				vec = vec.push(v);
		return vec;
	}

	/**
		Returns a new List with the given `index` removed.

		If `index` is out of bound, this function returns the unaltered List.
	**/
	public function delete(index:Int):List<T> {
		if (index < 0 || index >= length)
			return this;
		var result = new List();
		for (i => v in this)
			if (i != index)
				result = result.push(v);
		return result;
	}
	
	/**
		Returns a new List with all instances of the given `value` removed.
	**/
	public inline function remove(value:T):List<T>
		return filter(x -> x != value);

	/**
		Returns a new List with the given indices removed. If an index in `indices` is out
		of bounds, it will be skipped.

		Equivalent to calling `delete()` for each index individually, but potentially more
		efficient.
	**/
	public function deleteEach(indices:Sequence<Int>):List<T> {
		var result = new List();
		for (i => v in this)
			if (!indices.contains(i))
				result = result.push(v);
		return result;
	}

	/**
		Returns a new List with the given `values` removed.

		Equivalent to calling `removeV()` for each value individually, but potentially more
		efficient.
	**/
	public inline function removeEach(values:Sequence<T>):List<T>
		return filter(x -> !values.contains(x));
    
	/**
		Returns an empty List.
	**/
	public inline function clear():List<T>
		return new List();

	/**
		Returns a new List in reverse order.
	**/
	public function reverse():List<T> {
		var result = new List(), i = length;
		while (i > 0)
			result = result.push(get(--i));
		return result;
	}

	/**
		Returns a sorted Sequence according to the comparison function `f`, where
		`f(x,y)` returns a negative integer if `x` should be before `y`, a positive
		integer if `y` should be before `x`, and zero if the values are equivalent.

		For example, `[5, 4, 3, 2, 1].sort((x, y) -> x - y)` returns `[1, 2, 3, 4, 5]`
	**/
	public function sort(f:(T,T)->Int):List<T> {
		var arr = toArray();
		arr.sort(f);
		return new List().pushEach(arr);
	}

	/**
		Returns a List sorted ascending numerically.
	**/
	public macro function sortAsc(ethis:ExprOf<List<T>>):ExprOf<List<T>>
		return macro $e{ethis}.sort((a, b) -> if (a > b) 1 else if (a < b) -1 else 0);

	/**
		Returns a List sorted descending numerically.
	**/
	public macro function sortDesc(ethis:ExprOf<List<T>>):ExprOf<List<T>>
		return macro $e{ethis}.sort((a, b) -> if (a > b) -1 else if (a < b) 1 else 0);

	/**
		Returns a new List with each value in `other` appended to the end.
		Equivalent to `pushEach`
	**/
	public function concat(other:Sequence<T>):List<T>
		return pushEach(other);
    
	/**
		Returns a new List with each value in each iterable in `others` to the end.

		Equivalent to calling `concat()` for each list individually, but potentially
		more efficient.
	**/
	public function concatEach(others:Sequence<Sequence<T>>):List<T> {
		var result = self;
		for (other in others)
			result = result.concat(other);
		return result;
	}

	/**
		Returns a new List with the given `separator` interposed between each element.
	**/
	public function separate(separator:T):List<T> {
		if (empty())
			return this;
		var result = new List(), i = 0;
		while (i < length-1)
			result = result.push(get(i++)).push(separator);
		return result.push(get(i));
	}

	/**
		Returns a new List with the values of `other` interleaved with the elements of this
		Sequence.

		For example, `[1, 2, 3, 4].interleave([9, 9, 9, 9])` returns `[1, 9, 2, 9, 3, 9, 4, 9]`
	**/
	public function interleave(other:Sequence<T>):List<T> {
		var it1 = iterator(), it2 = other.iterator(), result = new List();
		while (it1.hasNext() && it2.hasNext())
			result = result.push(it1.next()).push(it2.next());
		result = result.pushEach(it1).pushEach(it2);
		return result;
	}


	/**
		Create a List of Vectors, split by occurrences of `element`.
	**/
	public function split(element:T):List<List<T>> {
		var result = [[]], index = 0;
		for (v in this) {
			if (v == element) {
				result.push([]);
				++index;
			} else {
				result[index].push(v);
			}
		}
		return new List().pushEach(result.map(fromArray));
	}

	/**
		Create a List of Vectors, split by occurrences where elements satisfy `predicate`.
	**/
	public function splitWhere(predicate:T->Bool):List<List<T>> {
		var result = [[]], index = 0;
		for (v in this) {
			if (predicate(v)) {
				result.push([]);
				++index;
			} else {
				result[index].push(v);
			}
		}
		return new List().pushEach(result.map(fromArray));
	}

	/**
		Returns a new Sequence with values repeated `num` times.

		For example, `[1, 2, 3].repeat(3)` returns `[1, 2, 3, 1, 2, 3, 1, 2, 3]`
	**/
	public inline function repeat(num:Int):List<T>
		return toSequence().repeat(num).toList();

	/**
		Partition this List into a List of Vectors, divided along the given `indices`
	**/
	public inline function partition(indices:Sequence<Int>):List<List<T>>
		return toSequence().partition(indices).map(x -> x.toList()).toList();

	/**

	**/
	public function shuffle():List<T> {
		var i = 0, result = self;
		while (i < length) {
			var index = Std.int(Math.random() * (length-i)) + i;
			var temp = result.get(index);
			result = result.set(index, result[i]);
			result = result.set(i, temp);
			++i;
		}
		return result;
	}

	/**
		Returns elements starting from and including `pos`, ending at but not including `end`.

		If `pos` or `end` are negative, their value is calculated from the end of the List.
	**/
	public function slice(pos:Int, ?end:Int):List<T>
		return toSequence().slice(pos, end).toList();

	/**
		Returns `len` elements (all elements if len is null) from this List, starting at
		and including `pos`.

		If `pos` is negative, its value is calculated from the end of the Sequence.
	**/
	public function splice(pos:Int, ?len:Int):List<T>
		return toSequence().splice(pos, len).toList();

	/**
		Returns `num` elements from the start of the List.
	**/
	public inline function take(num:Int):List<T>
		return splice(0, num);

	/**
		Returns `num` elements from the end of the List.
	**/
	public inline function takeLast(num:Int):List<T>
		return slice(-num);

	/**
		Returns elements from this list until `predicate` returns false.

		For example, `[1, 2, 3, 4].takeWhile(x -> x < 3)` returns `[1, 2]`
	**/
	public function takeWhile(predicate:T->Bool):List<T> {
		var result = new List(), i = 0;
		while (i < length) {
			var val = get(i++);
			if (!predicate(val))
				break;
			result = result.push(val);
		}
		return result;
	}

	/**
		Returns elements from this list until `predicate` returns true.

		For example, `[1, 2, 3, 4].takeUntil(x -> x == 3)` returns `[1, 2]`
	**/
	public function takeUntil(predicate:T->Bool):List<T> {
		var result = new List(), i = 0;
		while (i < length) {
			var val = get(i++);
			if (predicate(val))
				break;
			result = result.push(val);
		}
		return result;
	}

	/**
		Returns a new List with `num` elements removed from the front.
	**/
	public inline function drop(num:Int):List<T>
		return slice(num);

	/**
		Returns a new List with `num` elements removed from the end.
	**/
	public inline function dropLast(num:Int):List<T>
		return slice(0, -num);

	/**
		Returns all elements from this list after `predicate` returns false.
		Even if `predicate` returns true for elements thereafter, they will
		still be included.

		For example, `[1, 2, 3, 4, 2].dropWhile(x -> x != 3)` returns `[3, 4, 2]`
	**/
	public function dropWhile(predicate:T->Bool):List<T> {
		var i = 0;
		while (i < length) {
			var val = get(i);
			if (!predicate(val))
				break;
			++i;
		}
		return slice(i);
	}
	
	/**
		Returns all elements from this list after `predicate` returns true.
		Even if `predicate` returns false for elements thereafter, they will
		still be included.

		For example, `[1, 2, 3, 4, 2].dropUntil(x -> x == 3)` returns `[3, 4, 2]`
	**/
	public function dropUntil(predicate:T->Bool):List<T> {
		var i = 0;
		while (i < length) {
			var val = get(i);
			if (predicate(val))
				break;
			++i;
		}
		return slice(i);
	}

	/**
		Returns a new List with each value passed through the `mapper` function.
	**/
	public function map<M>(mapper:T->M):List<M>
		return toSequence().map(mapper).toList();

	/**
		Returns a new List with each index and corresponding value passed through the `mapper`
		function.
	**/
	public function mapIndex<M>(mapper:(Int, T)->M):List<M>
		return toSequence().mapIndex(mapper).toList();

	/**
		`mapper` is a function that returns an Iterable type (Array, List,
		Map, etc.)
					
		`flatMap` creates a new List with each value passed through the
		`mapper` function, then flattened. 
	
		For example, `[1, 2, 3].flatMap(x -> [x*2, x*10])` returns
		`[2, 10, 4, 20, 6, 30]`
	**/
	public function flatMap<M>(mapper:T->Iterable<M>):List<M>
		return toSequence().flatMap(mapper).toList();

	/**
		Returns a List of Vectors, with elements grouped according to the return value
		of `grouper`.

		For example, `[1, 2, 3, 4, 5].group(x -> x % 2)` results in `[[1, 3, 5], [2, 4]]`
	**/
	public function group<M>(grouper:T->M):List<List<T>> {
		var categories = [], groups = [];
		for (v in this) {
			var group = grouper(v);
			var index = categories.indexOf(group);
			if (index == -1) {
				categories.push(group);
				groups.push([v]);
			} else {
				groups[index].push(v);
			}
		}
		return fromArray(groups.map(fromArray));
	}

	/**
		Takes list A and list B and creates a new List where the i'th element is the
		list [A[i], B[i]]

		For example, `[1, 2, 3].zip([4, 5, 6])` results in `[[1, 4], [2, 5], [3, 6]]`
	**/
	public function zip(other:Sequence<T>):List<List<T>> {
		var result = new List(), it1 = iterator(), it2 = other.iterator();
		while (it1.hasNext() && it2.hasNext())
			result = result.push(new List([it1.next(), it2.next()]));
		return result;
	}

	/**
		Zips each sequence with this list.

		For example, `[1, 2, 3].zipEach([[4, 5, 6], [7, 8, 9]])` returns 
		`[[1, 4, 7], [2, 5, 8], [3, 6, 9]]`
	**/
	public function zipEach(others:Sequence<Sequence<T>>):List<List<T>> {
		var result = [], its = others.unshift(self).toArray().map(seq -> seq.iterator());
		while (true) {
			var row = [];
			for (it in its)
				if (it.hasNext())
					row.push(it.next());
				else
					return fromArray(result);
			result.push(fromArray(row));
		}
		return fromArray(result);
	}

	/**
		Returns the accumulation of this List according to `foldFn`, beginning with
		`initialValue`.

		For example, `[1, 2, 3].fold((a, b) -> a - b, 0)` evaluates `0 - 1 - 2 - 3 = -6`
	**/
	public function fold<R>(foldFn:(R,T)->R, initialValue:R):R {
		var index = 0;
		while (index < length)
			initialValue = foldFn(initialValue, get(index++));
		return initialValue;
	}

	/**
		Returns the accumulation of this List according to `foldFn`, beginning with
		`initialValue`. Identical to `fold()`, except iterating in reverse.

		For example, `[1, 2, 3].foldRight((a, b) -> a - b, 0)` evaluates `0 - 3 - 2 - 1 = -6`
	**/
	public function foldRight<R>(foldFn:(R,T)->R, initialValue:R):R {
		var index = length;
		while (index > 0)
			initialValue = foldFn(initialValue, get(--index));
		return initialValue;
	}

	/**
		A simpler form of `fold()`
		
		Returns the accumulation of this List according to `reducer`.

		For example, `[1, 2, 3, 4].reduce((a, b) -> a + b)` returns `10`

		Throws an Exception if the List is empty.
	**/
	public function reduce(reducer:(T,T)->T):T {
		if (empty())
			throw new Exception("attempt to reduce an empty List");
	
		var initialValue = get(0), index = 1;
		while (index < length)
			initialValue = reducer(initialValue, get(index++));
		return initialValue;
	}

	/**
		A simpler form of `foldRight()`
			
		Returns the accumulation of this List according to `reducer`. Identical
		to `reduce()` except iterating in reverse.

		For example, `[1, 2, 3, 4].reduceRight((a, b) -> a + b)` returns `10`

		Throws an Exception if the List is empty.
	**/
	public function reduceRight(reducer:(T,T)->T):T {
		if (empty())
			throw new Exception("attempt to reduce an empty List");

		var initialValue = get(length-1), index = length-1;
		while (index > 0)
			initialValue = reducer(initialValue, get(--index));
		return initialValue;
	}

	/**
		The number of elements in the List. Read-only property.
	**/
	public var length(get, never):Int;
	private inline function get_length():Int
		return dataLen + this.tailLength;

	private var dataLen(get, never):Int;
	private inline function get_dataLen():Int
		if (this.data == null)
			return 0;
		else
			return this.data.unsafe().length;

	/**
		True if `predicate` is true for every element in the List.
		True if the List is empty.
	**/
	public function every(predicate:T->Bool):Bool {
		for (v in this)
			if (!predicate(v))
				return false;
		return true;
	}

	/**
		True if `predicate` is true for any element in the List.
	**/
	public function some(predicate:T->Bool):Bool {
		for (v in this)
			if (predicate(v))
				return true;
		return false;
	}


	/**
		Returns true if this List and `other` contain an identical sequence of values.
	**/
	public function equals(other:Sequence<T>):Bool {
		var index:Int = 0;
		var it:Iterator<T> = other.iterator();

		while (has(index) && it.hasNext()) {
			if (get(index) != it.next())
				return false;
			++index;
		}

		return index == length && !it.hasNext();
	}

	/**
		Returns the numerical maximum of the List.
	**/
	public macro function max<T>(ethis:ExprOf<List<T>>):ExprOf<T>
		return macro $e{ethis}.reduce((a, b) -> if (a > b) a else b);

	/**
		Returns the numerical minimum of the List.
	**/
	public macro function min<T>(ethis:ExprOf<List<T>>):ExprOf<T>
		return macro $e{ethis}.reduce((a, b) -> if (a < b) a else b);

	/**
		Returns the sum of the elements in the List.
	**/
	public macro function sum<T>(ethis:ExprOf<List<T>>):ExprOf<T>
		return macro $e{ethis}.reduce((a, b) -> a + b);

	/**
		Returns the product of the elements in the List.
	**/
	public macro function product<T>(ethis:ExprOf<List<T>>):ExprOf<T>
		return macro $e{ethis}.reduce((a, b) -> a * b);

	/**
		The `sideEffect` is executed for every value in the List.
	**/
	public function forEach(sideEffect:T->Void):Void
		for (v in this)
			sideEffect(v);

	/**
		The `sideEffect` is executed for every value in the List. Iteration stops once
		`sideEffect` returns false.

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
		Iterator over each value in the List.
	**/
	public function iterator():Iterator<T> {
		var index = 0;
		function hn()
			return index < length;
		function n()
			return get(index++);
		return new FunctionalIterator(hn, n);
	}


	/**
		Iterator over each index-value pair in the List.
	**/
	public function keyValueIterator():KeyValueIterator<Int,T> {
		var index = 0;
		function hn()
			return index < length;
		function n() {
			var result = { key: index, value: get(index) };
			++index;
			return result;
		}
		return new FunctionalIterator(hn, n);
	}

	/**
		Iterator over each index of the list.
	**/
	public inline function indices():Sequence<Int>
		return 0...length;

	/**
		Iterator over each value in the List. Equivalent to `iterator()`
	**/
	public inline function values():Sequence<T>
		return iterator();

	/**
		Iterator over each index-value pair in the list.
	**/
	public inline function entries():Iterator<{key: Int, value: T}>
		return keyValueIterator();

	/**
		Convert this List into an Array<T>
	**/
	public inline function toArray():Array<T>
		return [for (v in this) v];

	/**
		Convert this List into an immutable Map<Int,T>
	**/
	public function toMap():Map<Int, T> {
		var result = new Map();
		for (i => v in this)
			result = result.set(i, v);
		return result;
	}

	/**
		Convert this List into an immutable OrderedMap<Int,T>
	**/
	public function toOrderedMap():OrderedMap<Int, T> {
		var result = new OrderedMap();
		for (i => v in this)
			result = result.set(i, v);
		return result;
	}

	/**
		Convert this List into an immutable Set, discarding duplicate values
	**/
	public inline function toSet():Set<T>
		return new Set().addEach(values());

	/**
		Convert this List into an OrderedSet<T>
	**/
	public inline function toOrderedSet():OrderedSet<T>
		return new OrderedSet().addEach(values());

	/**
		Convert this List into a Sequence<T>
	**/
	public inline function toSequence():Sequence<T>
		return values();

	/**
		Convert this List to an immutable Stack of its values.
	**/
	public inline function toStack():Stack<T> {
		var result = new Stack();
		for (v in this)
			result = result.push(v);
		return result;
	}

	/**
		Convert this List to its String representation.
	**/
	public function toString():String {
		var result = new StringBuf();
		result.add("List [");
		var cut = false;

		var index:Int = 0;
		while (has(index)) {
			cut = true;
			result.add(' ${get(index++)},');
		}

		return
			(if (cut)
				result.toString().substr(0, result.length - 1)
			else
				result.toString())
			+ " ]";
	}

	private static function copy<T>(v:Vector<T>):Vector<T> {
		var vec = new Vector(32);
		for (i in 0...32)
			if ((vec[i] = v[i]) == null)
				break;
		return vec;
	}

	private var self(get, never):List<T>;
	private inline function get_self() return this;

	private var _this(get, never):ListObject<T>;
	private inline function get__this() return this;

}

private class ListObject<T> {
	public inline function new() {}
	public var data:Null<VectorTrie<T>>;
	public var tail:Null<Vector<T>>;
	public var tailLength:Int = 0;

	public function iterator():Iterator<T>
		return (this:List<T>).iterator();

	public function keyValueIterator():KeyValueIterator<Int, T>
		return (this:List<T>).keyValueIterator();

	public function toString():String
		return (this:List<T>).toString();
}
