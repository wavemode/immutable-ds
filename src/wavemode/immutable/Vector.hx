/**
 *  Copyright (c) 2020-present, Chukwudi Okechukwu
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the root directory of this source tree.
 *
 */

// TODO: make syntax for all types
// TODO: fix sort
// TODO: @see also in doc comments

package wavemode.immutable;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
#end

import stdlib.Exception;
import wavemode.immutable.util.VectorTrie;
using wavemode.immutable.Functional;

abstract Vector<T>(VectorObject<T>) from VectorObject<T> to VectorObject<T> {

	/**
		Create a new empty Vector, or a clone of an Iterable.
	**/
	public inline function new(?seq:Sequence<T>)
		if (seq != null)
			this = seq.toVector();
		else
			this = new VectorObject();

	/**
		Create a new Vector from any iterable.
	**/
	public static inline function fromSequence<T>(seq:Sequence<T>):Vector<T>
		return new Vector().pushEach(seq);
	
	/**
		Macro which creates a new Vector from any number of values.
	**/
	public static macro function make<T>(exprs:Array<ExprOf<T>>):ExprOf<Vector<T>>
		return macro new Vector().pushEach([$a{exprs}]);

	/**
		Create a Vector of `num` repeating values.
	**/
	public static function repeat<T>(num:Int, obj:T):Vector<T>
		return Sequence.repeat(obj, num).toVector();

	/**
		Create a Vector of numbers from `start` to `end`, inclusive.
	**/
	public static function range(start:Int, end:Int):Vector<Int>
		return Sequence.range(start, end).toVector();

	/**
		Create a Vector of `len` values starting with `start` and
		repeatedly passed through the `iterator` function.
	**/
	public static function iterate<T>(len:Int, start:T, iterator:T->T):Vector<T>
		return Sequence.iterate(start, iterator).take(len).toVector();
	
	/**
		Create a Vector representing `len` values starting at `start`
		and incremented by `step` each time.

		`step` is 1 by default. `start` is 0 by default.
	**/
	public static function step(len:Int, start:Int = 0, step:Int = 1)
		return Sequence.step(start, step).take(len).toVector();

	/**
		Create a Vector with each of the given `sequences` concatenated together,
		separated by `separator`
	**/
	public static function join<T>(sequences:Sequence<Sequence<T>>, separator:T):Vector<T>
		return Sequence.join(sequences, separator).toVector();

	/**
		Create a new Vector with all the values in 	`arr`.
	**/
	@:from public static inline function fromArray<T>(arr:Array<T>):Vector<T>
		return new Vector().pushEach(arr);

	/**
		Returns a new Vector with the given `value` appended to the end.
	**/
	public function push(value:T):Vector<T> {
		var result = new VectorObject();
		result.data = this.data.push(value);
		return result;
	}

	/**
		Returns a new Vector with the given `values` appended to the end.

		Equivalent to calling `push()` for each value individually, but
		potentially more efficient.
	**/
	public function pushEach(values:Sequence<T>):Vector<T> {
		var result = new VectorObject();
		result.data = this.data.pushEach(values.iterator());
		return result;
	}

	/**
		Returns a new Vector with one element removed from the end.
	**/
	public inline function pop():Vector<T> {
		var result = new VectorObject();
		result.data = this.data.pop();
		return result;
	}

	/**
		Returns a new Vector with the given `value` inserted at the front.
	**/
	public inline function unshift(value:T):Vector<T>
		return insert(0, value);

	/**
		Returns a new Vector with one element removed from the front.
	**/
	public inline function shift():Vector<T>
		return drop(1);

	/**
		Insert the given `value` at the specified `index`, pushing back every subsequent
		element in the Vector.

		If `index` is out of bounds, this function returns the unaltered Vector.
	**/
	public function insert(index:Int, value:T):Vector<T> {
		if (index < 0 || index > length)
			return this;
		else if (index == length)
			return push(value);
		var result = self;
		result = result.push(result.last());
		for (i in (result.length-1).above(index))
			result = result.set(i, result.get(i-1));
		result = result.set(index, value);
		return result;
	}


	/**
		Insert the given `values` at the specified `index`, pushing back every subsequent
		element in the Vector.

		Equivalent to calling `insert()` for each value individually, but potentially more
		efficient.
	**/
	public function insertEach(index:Int, values:Sequence<T>):Vector<T> {
		if (index < 0 || index > length)
			return this;
		else if (index == length)
			return pushEach(values);
		var result = new VectorObject();
		result.data = this.data.pushEach(values.iterator());
		var len = result.data.unsafe().length-this.data.unsafe().length;
		var result:Vector<T> = result;
		for (i in (result.length-1).downto(index+len))
			result = result.set(i, result.get(i-len));
		for (i in 0...len)
			result = result.set(index+i, values[i]);
		return result;
	}

	/**
		Returns a new Vector with the given index replaced with the given `value`. 

		If `index` is out of bounds, this function returns the unaltered Vector.
	**/
	public inline function set(index:Int, value:T):Vector<T> {
		if (index < 0 || index >= length)
			return this;
		var result = new VectorObject();
		result.data = this.data.set(index, value);
		return result;
	}


	/**
		Returns a new Vector with the given `indices` replaced with the respective
		value in `values`. If any of the indices is out of bounds, that pair is ignored.

		Equivalent to calling `set()` for each pair individually, but potentially more
		efficient.
	**/
	public function setEach(indices:Sequence<Int>, values:Sequence<T>):Vector<T> {
		var result = self,
			indexIter = indices.iterator(),
			valueIter = values.iterator();
		while (indexIter.hasNext() && valueIter.hasNext())
			result = result.set(indexIter.next(), valueIter.next());
		return result;
	}


	/**
		Returns a new Vector having updated the value at this index with the return value of
		calling `updater` with the existing value.

		Similar to `list.set(index, updater(list.get(index)))`.

		If `index` is out of bounds, this function returns the unaltered list.
	**/
	public function update(index:Int, updater:T->T):Vector<T>
		return set(index, updater(get(index)));

	/**
		Returns a new Vector having updated the values at these indices with the return value
		of calling `updater` with the existing values. If any index in `indices` is out of
		bounds, it is skipped.

		Equivalent to calling `update()` for each index individually, but potentially more
		efficient.
	**/
	public function updateEach(indices:Sequence<Int>, updater:T->T):Vector<T> {
		var result = self;
		for (index in indices)
			result = result.update(index, updater);
		return result;
	}

	/**
		Returns a new Vector having all instances of the given `oldVal` replaced with the
		value `newVal`.

		If the value does not exist, this function returns the unaltered list.
	**/
	public function replace(oldVal:T, newVal:T):Vector<T> {
		var result = self;
		for (i => v in this.data)
			if (v == oldVal)
				result = result.set(i, newVal);
		return result;
	}

	/**
		Returns a new Vector having the given `oldValues` replaced with the values in
		`newValues`. If any given value does not exist, it will be skipped.
			
		Equivalent to calling `replace()` for each value individually, but potentially more
		efficient, and earlier replacements do not affect later ones.
	**/
	public function replaceEach(oldValues:Sequence<T>,newValues:Sequence<T>):Vector<T> {
		var result = self;
		for (i => v in this.data) {
			var found = oldValues.find(v);
			if (found != -1 && newValues.has(found))
				result = result.set(found, newValues[found]);
		}
		return result;
	}

	/**
		Returns the element at the given index, or throws an Exception if `index` is out of bounds.
	**/
	@:arrayAccess
	public inline function get(index:Int):T
		if (index < 0 || index >= length)
			throw new Exception('index $index out of bounds for Vector')
		else
			@:nullSafety(Off) return cast this.data.retrieve(index);

	/**
		Returns true if the index exists in this Vector.
	**/
	public function has(index:Int):Bool
		return index < length && index >= 0;

	/**
		True if the Vector is empty.
	**/
	public function empty():Bool
		return length == 0;

	/**
		Returns the first index of the given `value`, or -1 if it does not exist in the
		Vector.

		Begins searching from `start`, or 0 if start is null.
	**/
	public function find(value:T, ?start:Int):Int {
		var i = start.or(0);
		while (i < length)
			if (value == get(i++))
				return i;
		return -1;
	}

	/**
		Returns true if the given value is in this Vector.
	**/
	public inline function contains(value:T):Bool
		return find(value) != -1;

	/**
		Alias of `find()`. Returns the first index of the given `value`, or -1 if it does
		not exist in the Vector.

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
		while (i < length)
			if (predicate(get(i++)))
				return i;
		return -1;
	}

	/**
		Returns the first element of the Vector, or null if the Vector is empty.
	**/
	public function first():T
		return get(0);

	/**
		Returns the last element of the Vector, or null if the Vector is empty.
	**/
	public function last():T
		return get(length-1);

	/**
		Returns a new Vector excluding each value that does not satify the `predicate`.
	**/
	public function filter(predicate:T->Bool):Vector<T> {
		var vec = new Vector();
		for (v in this)
			if (predicate(v))
				vec = vec.push(v);
		return vec;
	}

	/**
		Returns a new Vector with the given `index` removed.

		If `index` is out of bound, this function returns the unaltered Vector.
	**/
	public function delete(index:Int):Vector<T> {
		if (index < 0 || index >= length)
			return this;
		var result = new VectorObject();
		result.data = this.data.clone();
		for (i in index...(length-1))
			result.data = result.data.set(i, result.data.retrieve(i+1).unsafe());
		--result.data.unsafe().length;
		return result;
	}
	
	/**
		Returns a new Vector with all instances of the given `value` removed.
	**/
	public function remove(value:T):Vector<T>
		return filter(x -> x == value);

	/**
		Returns a new Vector with the given indices removed. If an index in `indices` is out
		of bounds, it will be skipped.

		Equivalent to calling `delete()` for each index individually, but potentially more
		efficient.
	**/
	public function deleteEach(indices:Sequence<Int>):Vector<T> {
		var result = new Vector();
		for (i => v in this)
			if (!indices.contains(i))
				result = result.push(v);
		return result;
	}

	/**
		Returns a new Vector with the given `values` removed.

		Equivalent to calling `removeV()` for each value individually, but potentially more
		efficient.
	**/
	public function removeEach(values:Sequence<T>):Vector<T>
		return filter(x -> !values.contains(x));
    
	/**
		Returns an empty Vector.
	**/
	public inline function clear():Vector<T>
		return new Vector();

	/**
		Returns a new Vector in reverse order.
	**/
	public function reverse():Vector<T> {
		var result = new Vector(), i = length;
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
	public function sort(f:(T,T)->Int):Vector<T>
		throw new Exception("not yet implemented");

	/**
		Returns a Vector sorted ascending numerically.
	**/
	public macro function sortAsc(ethis:ExprOf<Vector<T>>):ExprOf<Vector<T>>
		return macro $e{ethis}.sort((a, b) -> if (a > b) 1 else if (a < b) -1 else 0);

	/**
		Returns a Vector sorted descending numerically.
	**/
	public macro function sortDesc(ethis:ExprOf<Vector<T>>):ExprOf<Vector<T>>
		return macro $e{ethis}.sort((a, b) -> if (a > b) -1 else if (a < b) 1 else 0);

	/**
		Returns a new Vector with each value in `other` appended to the end.
		Equivalent to `pushEach`
	**/
	public function concat(other:Sequence<T>):Vector<T>
		return pushEach(other);
    
	/**
		Returns a new Vector with each value in each iterable in `others` to the end.

		Equivalent to calling `concat()` for each list individually, but potentially
		more efficient.
	**/
	public function concatEach(others:Sequence<Sequence<T>>):Vector<T> {
		var result = self;
		for (other in others)
			result = result.concat(other);
		return result;
	}

	/**
		Returns a new Vector with the given `separator` interposed between each element.
	**/
	public function separate(separator:T):Vector<T> {
		var result = new Vector(), i = 0;
		while (i < length-1)
			result = result.push(get(i++)).push(separator);
		return result.push(get(i));
	}

	/**
		Returns a new Vector with the values of `other` interleaved with the elements of this
		Sequence.

		For example, `[1, 2, 3, 4].interleave([9, 9, 9, 9])` returns `[1, 9, 2, 9, 3, 9, 4, 9]`
	**/
	public function interleave(other:Sequence<T>):Vector<T> {
		var it1 = iterator(), it2 = other.iterator(), result = new VectorObject();
		while (it1.hasNext() && it2.hasNext())
			result.data = result.data.push(it1.next()).push(it2.next());
		result.data = result.data.pushEach(it1).pushEach(it2);
		return result;
	}


	/**
		Create a Vector of Vectors, split by occurrences of `element`.
	**/
	public function split(element:T):Vector<Vector<T>> {
		var result = [[]], index = 0;
		for (v in this) {
			if (v == element) {
				result.push([]);
				++index;
			} else {
				result[index].push(v);
			}
		}
		return new Vector().pushEach(result.map(fromArray));
	}

	/**
		Create a Vector of Vectors, split by occurrences where elements satisfy `predicate`.
	**/
	public function splitWhere(predicate:T->Bool):Vector<Vector<T>> {
		var result = [[]], index = 0;
		for (v in this) {
			if (predicate(v)) {
				result.push([]);
				++index;
			} else {
				result[index].push(v);
			}
		}
		return new Vector().pushEach(result.map(fromArray));
	}

	/**
		Partition this Vector into a Vector of Vectors, divided along the given `indices`
	**/
	public function partition(indices:Sequence<Int>):Vector<Vector<T>>
		return toSequence().partition(indices).map(x -> x.toVector()).toVector();

	/**

	**/
	public function shuffle():Vector<T> {
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

		If `pos` or `end` are negative, their value is calculated from the end of the Vector.
	**/
	public function slice(pos:Int, ?end:Int):Vector<T> {
		var result = new Vector();
		if (length == 0)
			return result;
		while (pos < 0)
			pos += length;
		if (end != null)
			while (end < 0)
				end += length;
		for (i in pos...end.or(length))
			result = result.push(get(i));
		return result;
	}

	/**
		Returns `len` elements (all elements if len is null) from this Vector, starting at
		and including `pos`.

		If `pos` is negative, its value is calculated from the end of the Sequence.
	**/
	public function splice(pos:Int, ?len:Int):Vector<T> {
		var result = new Vector();
		if (length == 0)
			return result;
		while (pos < 0)
			pos += length;
		for (i in pos...(pos+len.or(length)))
			result = result.push(get(i));
		return result;
	}

	/**
		Returns `num` elements from the start of the Vector.
	**/
	public inline function take(num:Int):Vector<T>
		return splice(0, num);

	/**
		Returns `num` elements from the end of the Vector.
	**/
	public inline function takeLast(num:Int):Vector<T>
		return slice(-num);

	/**
		Returns elements from this list until `predicate` returns false.

		For example, `[1, 2, 3, 4].takeWhile(x -> x < 3)` returns `[1, 2]`
	**/
	public function takeWhile(predicate:T->Bool):Vector<T> {
		var result = new Vector(), i = 0;
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
	public function takeUntil(predicate:T->Bool):Vector<T> {
		var result = new Vector(), i = 0;
		while (i < length) {
			var val = get(i++);
			if (predicate(val))
				break;
			result = result.push(val);
		}
		return result;
	}

	/**
		Returns a new Vector with `num` elements removed from the front.
	**/
	public inline function drop(num:Int):Vector<T>
		return slice(num);

	/**
		Returns a new Vector with `num` elements removed from the end.
	**/
	public inline function dropLast(num:Int):Vector<T>
		return slice(0, -num);

	/**
		Returns all elements from this list after `predicate` returns false.
		Even if `predicate` returns true for elements thereafter, they will
		still be included.

		For example, `[1, 2, 3, 4, 2].dropWhile(x -> x != 3)` returns `[3, 4, 2]`
	**/
	public function dropWhile(predicate:T->Bool):Vector<T> {
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
	public function dropUntil(predicate:T->Bool):Vector<T> {
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
		Returns a new Vector with each value passed through the `mapper` function.
	**/
	public function map<M>(mapper:T->M):Vector<M> {
		var result = new Vector();
		for (v in this)
			result = result.push(mapper(v));
		return result;
	}

	/**
		Returns a new Vector with each index and corresponding value passed through the `mapper`
		function.
	**/
	public function mapIndex<M>(mapper:(Int, T)->M):Vector<M> {
		var result = new Vector();
		for (i => v in this)
			result = result.push(mapper(i, v));
		return result;
	}

	/**
		`mapper` is a function that returns an Iterable type (Array, Vector,
		Map, etc.)
					
		`flatMap` creates a new Vector with each value passed through the
		`mapper` function, then flattened. 
	
		For example, `[1, 2, 3].flatMap(x -> [x*2, x*10])` returns
		`[2, 10, 4, 20, 6, 30]`
	**/
	public function flatMap<M>(mapper:T->Sequence<M>):Vector<M> {
		var arr = [];
		for (v in this)
			arr.push(mapper(v));
		var result = new VectorObject();
		for (seq in arr)
			result.data = result.data.pushEach(seq.iterator());
		return result;
	}

	/**
		Returns a Vector of Vectors, with elements grouped according to the return value
		of `grouper`.

		For example, `[1, 2, 3, 4, 5].group(x -> x % 2)` results in `[[1, 3, 5], [2, 4]]`
	**/
	public function group<M>(grouper:T->M):Vector<Vector<T>> {
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
		Takes list A and list B and creates a new Vector where the i'th element is the
		vector [A[i], B[i]]

		For example, `[1, 2, 3].zip([4, 5, 6])` results in `[[1, 4], [2, 5], [3, 6]]`
	**/
	public function zip(other:Sequence<T>):Vector<Vector<T>> {
		var result = new Vector(), it1 = iterator(), it2 = other.iterator();
		while (it1.hasNext() && it2.hasNext())
			result = result.push(new Vector([it1.next(), it2.next()]));
		return result;
	}

	/**
		Zips each sequence with this list.

		For example, `[1, 2, 3].zipEach([[4, 5, 6], [7, 8, 9]])` returns 
		`[[1, 4, 7], [2, 5, 8], [3, 6, 9]]`
	**/
	public function zipEach(others:Sequence<Sequence<T>>):Vector<Vector<T>>
		throw new Exception("not yet implemented");

	/**
		Returns the accumulation of this Vector according to `foldFn`, beginning with
		`initialValue`.

		For example, `[1, 2, 3].fold((a, b) -> a - b, 0)` evaluates `0 - 1 - 2 - 3 = -6`
	**/
	public function fold<R>(foldFn:(R,T)->R, initialValue:R):R
		throw new Exception("not yet implemented");

	/**
		Returns the accumulation of this Vector according to `foldFn`, beginning with
		`initialValue`. Identical to `fold()`, except iterating in reverse.

		For example, `[1, 2, 3].foldRight((a, b) -> a - b, 0)` evaluates `0 - 3 - 2 - 1 = -6`
	**/
	public function foldRight<R>(foldFn:(R,T)->R, initialValue:R):R
		throw new Exception("not yet implemented");

	/**
		A simpler form of `fold()`
		
		Returns the accumulation of this Vector according to `reducer`.

		For example, `[1, 2, 3, 4].reduce((a, b) -> a + b)` returns `10`

		Throws an Exception if the Vector is empty.
	**/
	public function reduce(reducer:(T,T)->T):T
		throw new Exception("not yet implemented");

	/**
		A simpler form of `foldRight()`
			
		Returns the accumulation of this Vector according to `reducer`. Identical
		to `reduce()` except iterating in reverse.

		For example, `[1, 2, 3, 4].reduceRight((a, b) -> a + b)` returns `10`

		Throws an Exception if the Vector is empty.
	**/
	public function reduceRight(reducer:(T,T)->T):T
		throw new Exception("not yet implemented");

	/**
		The number of elements in the Vector. Read-only property.
	**/
	public var length(get, never):Int;
	private inline function get_length():Int {
		if (this.data == null)
			return 0;
		else
			return this.data.unsafe().length;
	}

	/**
		True if `predicate` is true for every element in the Vector.
		True if the Vector is empty.
	**/
	public function every(predicate:T->Bool):Bool
		throw new Exception("not yet implemented");

	/**
		True if `predicate` is true for any element in the Vector.
	**/
	public function some(predicate:T->Bool):Bool
		throw new Exception("not yet implemented");

	/**
		Returns true if this Vector and `other` contain an identical sequence of values.

		If `deep` is true, the objects are compared by their string representations,
		which will properly handle deeply nested vectors and many other edge cases,
		but will incorrectly classify non-printable objects like functions.
	**/
	public function equals(other:Sequence<T>, ?deep:Bool):Bool
		throw new Exception("not yet implemented");

	/**
		Returns the numerical maximum of the Vector.
	**/
	public macro function max<T>(ethis:ExprOf<Vector<T>>):ExprOf<T>
		throw new Exception("not yet implemented");

	/**
		Returns the numerical minimum of the Vector.
	**/
	public macro function min<T>(ethis:ExprOf<Vector<T>>):ExprOf<T>
		throw new Exception("not yet implemented");

	/**
		Returns the sum of the elements in the Vector.
	**/
	public macro function sum<T>(ethis:ExprOf<Vector<T>>):ExprOf<T>
		throw new Exception("not yet implemented");

	/**
		Returns the product of the elements in the Vector.
	**/
	public macro function product<T>(ethis:ExprOf<Vector<T>>):ExprOf<T>
		throw new Exception("not yet implemented");

	/**
		The `sideEffect` is executed for every value in the Vector.
	**/
	public function forEach(sideEffect:T->Void):Void
		throw new Exception("not yet implemented");

	/**
		The `sideEffect` is executed for every value in the Vector. Iteration stops once
		`sideEffect` returns false.

		This function returns the number of times `sideEffects` was executed.
	**/
	public function forWhile(sideEffect:T->Bool):Int
		throw new Exception("not yet implemented");

	/**
		Iterator over each value in the Vector.
	**/
	public inline function iterator():Iterator<T>
		return this.data.iterator();

	/**
		Iterator over each index-value pair in the Vector.
	**/
	public function keyValueIterator():KeyValueIterator<Int, T>
		throw new Exception("not yet implemented");

	/**
		Iterator over each index of the list.
	**/
	public inline function indices():Iterator<Int>
		throw new Exception("not yet implemented");

	/**
		Iterator over each value in the Vector. Equivalent to `iterator()`
	**/
	public inline function values():Iterator<T>
		throw new Exception("not yet implemented");

	/**
		Iterator over each index-value pair in the list.
	**/
	public function entries():Iterator<{key: Int, value: T}>
		throw new Exception("not yet implemented");

	/**
		Convert this Vector into an Array<T>
	**/
	public function toArray():Array<T>
		throw new Exception("not yet implemented");

	/**
		Convert this Vector into an immutable Map<Int,T>
	**/
	public function toMap():Map<Int, T>
		throw new Exception("not yet implemented");

	/**
		Convert this Vector into an immutable OrderedMap<Int,T>
	**/
	public function toOrderedMap():OrderedMap<Int, T>
		throw new Exception("not yet implemented");

	/**
		Convert this Vector into an immutable Set, discarding duplicate values
	**/
	public function toSet():Set<T>
		throw new Exception("not yet implemented");

	/**
		Convert this Vector into an OrderedSet<T>
	**/
	public function toOrderedSet():OrderedSet<T>
		throw new Exception("not yet implemented");

	/**
		Convert this Vector into a Sequence<T>
	**/
	public function toSequence():Sequence<T>
		throw new Exception("not yet implemented");

	/**
		Convert this Vector to its String representation.
	**/
	public function toString():String {
		var result = new StringBuf();
		result.add("Vector [");
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


	private var self(get, never):Vector<T>;
	private inline function get_self() return this;

	private var _this(get, never):VectorObject<T>;
	private inline function get__this() return this;

}

private class VectorObject<T> {
	public inline function new() {}
	public var data:Null<VectorTrie<T>>;

	public function iterator():Iterator<T>
		return data.iterator();

	public function keyValueIterator():KeyValueIterator<Int, T>
		return data.keyValueIterator();

	public function toString():String
		return (this:Vector<T>).toString();
}