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

using wavemode.immutable.Functional;

// TODO: toIterable

abstract Vector<T>(VectorObject<T>) from VectorObject<T> {

	//////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////// CREATION ////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////

	/**
		Create a new empty Vector, or a clone of an Iterable.
	**/
	public inline function new(?seq:Sequence<T>)
		if (seq != null)
			this = seq.toVector()._this;
		else
			this = new VectorObject();

	/**
		Create a new Vector from any iterable.
	**/
	public static inline function fromSequence<T>(seq:Sequence<T>):Vector<T>
		return seq.toVector();
	
	/**
		Create a new Vector from any number of values.
	**/
	public static macro function make<T>(exprs:Array<ExprOf<T>>):ExprOf<Vector<T>>
		return macro Vector.fromSequence([$a{exprs}]);

	/**
		Create a Vector of `num` repeating values.
	**/
	public static function repeat<T>(num:Int, obj:T):Vector<T> {
		var list = new Vector();
		for (i in 0...num)
			list = list.push(obj);
		return list;
	}

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
		return Sequence.iterate(len, start, iterator).toVector();
	
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
	@:from public static function fromArray<T>(arr:Array<T>):Vector<T> {
		var vec = new Vector();
		vec.data = arr.copy();
		return vec;
	}


	//////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////// OPERATIONS ///////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////
	

	/**
		Returns a new Vector with the given `value` appended to the end.
	**/
	public function push(value:T):Vector<T> {
		var arr = this.data.copy();
		arr.push(value);
		return fromArray(arr);
	}

	/**
		Returns a new Vector with the given `values` appended to the end.

		Equivalent to calling `push()` for each value individually, but
		potentially more efficient.
	**/
	public function pushEach(values:Sequence<T>):Vector<T> {
		var result = self;
		for (v in values) result = result.push(v);
		return result;
	}

	/**
		Returns a new Vector with one element removed from the end.
	**/
	public function pop():Vector<T>
		return dropLast(1);

	/**
		Returns a new Vector with the given `value` inserted at the front.
	**/
	public function unshift(value:T):Vector<T>
		return insert(0, value);

	/**
		Returns a new Vector with one element removed from the front.
	**/
	public function shift():Vector<T>
		return drop(1);

	/**
		Insert the given `value` at the specified `index`, pushing back every subsequent
		element in the Vector.

		If `index` is out of bounds, this function returns the unaltered Vector.
	**/
	public function insert(index:Int, value:T):Vector<T> {
		if (index > length || index < 0)
			return this;
		var arr = this.data.copy();
		arr.insert(index, value);
		return fromArray(arr);
	}


	/**
		Insert the given `values` at the specified `index`, pushing back every subsequent
		element in the Vector.

		Equivalent to calling `insert()` for each value individually, but potentially more
		efficient.
	**/
	public function insertEach(index:Int, values:Sequence<T>):Vector<T>
		return toSequence().insertEach(index, values).toVector();

	/**
		Returns a new Vector with the given index replaced with the given `value`. 

		If `index` is out of bounds, this function returns the unaltered Vector.
	**/
	public inline function set(index:Int, value:T):Vector<T> {
		if (index >= length || index < 0)
			return this;
		var arr = this.data.copy();
		arr[index] = value;
		var list = new Vector();
		list.data = arr;
		return list;
	}

	/**
		Returns a new Vector with the given `indices` replaced with the respective
		value in `values`. If any of the indices is out of bounds, that pair is ignored.

		Equivalent to calling `set()` for each pair individually, but potentially more
		efficient.
	**/
	public function setEach(indices:Sequence<Int>, values:Sequence<T>):Vector<T> {
		var indexIter = indices.iterator(),
			valIter = values.iterator(),
			result = self;
		while (indexIter.hasNext() && valIter.hasNext())
			result = result.set(indexIter.next(), valIter.next());
		return result;
	}

	/**
		Returns a new Vector having updated the value at this index with the return value of
		calling `updater` with the existing value.

		Similar to `list.set(key, updater(list.get(key)))`.

		If `index` is out of bounds, this function returns the unaltered list.
	**/
	public function update(index:Int, updater:T->T):Vector<T> {
		if (index >= length || index < 0)
			return this;
		var arr = data.copy();
		arr[index] = updater(arr[index]);
		return fromArray(arr);
	}

	/**
		Returns a new Vector having updated the values at these indices with the return value
		of calling `updater` with the existing values. If any index in `indices` is out of
		bounds, it is skipped.

		Equivalent to calling `update()` for each index individually, but potentially more
		efficient.
	**/
	public function updateEach(indices:Sequence<Int>, updater:T->T):Vector<T> {
		var indexIter = indices.iterator(),
			result = self;
		while (indexIter.hasNext())
			result = result.update(indexIter.next(), updater);
		return result;
	}

	/**
		Returns a new Vector having all instances of the given `oldVal` replaced with the
		value `newVal`.

		If the value does not exist, this function returns the unaltered list.
	**/
	public function replace(oldVal:T, newVal:T):Vector<T> {
		var i = 0;
		var arr = data.copy();
		for (v in self) {
			if (v == oldVal) {
				arr[i] = newVal;
			}
			++i;
		}
		return fromArray(arr);
	}

	/**
		Returns a new Vector having the given `oldValues` replaced with the values in
		`newValues`. If any given value does not exist, it will be skipped.
			
		Equivalent to calling `replace()` for each value individually, but potentially more
		efficient, and earlier replacements do not affect later ones.
	**/
	public function replaceEach(oldValues:Sequence<T>,newValues:Sequence<T>):Vector<T> {
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

	
	//////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////// SELECTIONS ///////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////


	/**
		Returns the element at the given index, or null if `index` is out of bounds.
	**/
	public inline function get(index:Int):Null<T>
		if (index >= length || index < 0)
			return null;
		else 
			return data[index];

	/**
		Unsafe variant of `get()`. Returns the element at the given index. Throws an
		Exception if `index` is out of bounds.
	**/
	@:arrayAccess
	public inline function getValue(index:Int):T
		if (index >= length || index < 0)
			throw new Exception('index $index out of bounds for Vector length $length');
		else
			return data[index];

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
		for (i in start.or(0)...length)
			if (getValue(i) == value)
				return i;
		return -1;
	}

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
		if (start == null) start = 0;
		for (i in start...length) if (predicate(getValue(i))) return i;
		return -1;
	}

	/**
		Returns the first element of the Vector, or null if the Vector is empty.
	**/
	public function first():Null<T>
		return get(0);

	/**
		Returns the last element of the Vector, or null if the Vector is empty.
	**/
	public function last():Null<T>
		return get(length-1);

	/**
		Returns a new Vector excluding each value that does not satify the `predicate`.
	**/
	public function filter(predicate:T->Bool):Vector<T>
		return fromArray(data.filter(predicate));

	/**
		Returns a new Vector with the given `index` removed.

		If `index` is out of bound, this function returns the unaltered Vector.
	**/
	public function delete(index:Int):Vector<T> {
		if (index >= length || index < 0)
			return this;
		var arr = data.copy();
		arr = arr.slice(0, index).concat(arr.slice(index + 1));
		return fromArray(arr);
	}
	
	/**
		Returns a new Vector with all instances of the given `value` removed.
	**/
	public function remove(value:T):Vector<T> {
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
		Returns a new Vector with the given indices removed. If an index in `indices` is out
		of bounds, it will be skipped.

		Equivalent to calling `delete()` for each index individually, but potentially more
		efficient.
	**/
	public function deleteEach(indices:Sequence<Int>):Vector<T>
		return toSequence().deleteEach(indices).toVector();

	/**
		Returns a new Vector with the given `values` removed.

		Equivalent to calling `removeV()` for each value individually, but potentially more
		efficient.
	**/
	public function removeEach(values:Sequence<T>):Vector<T> {
		var valueIter = values.iterator(), result = self;
		while (valueIter.hasNext()) {
			result = result.remove(valueIter.next());
		}
		return result;
	}


	/////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////// TRANSFORMATIONS ////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////
    
	/**
		Returns an empty Vector.
	**/
	public inline function clear():Vector<T>
		return new Vector();

	/**
		Returns a new Vector in reverse order.
	**/
	public function reverse():Vector<T> {
		var arr = data.copy();
		arr.reverse();
		return fromArray(arr);
	}

	/**
		Returns a sorted Sequence according to the comparison function `f`, where
		`f(x,y)` returns a negative integer if `x` should be before `y`, a positive
		integer if `y` should be before `x`, and zero if the values are equivalent.

		For example, `[5, 4, 3, 2, 1].sort((x, y) -> x - y)` returns `[1, 2, 3, 4, 5]`
	**/
	public function sort(f:(T,T)->Int):Vector<T> {
		var arr = data.copy();
		arr.sort(f);
		return fromArray(arr);
	}

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
	public function concat(other:Sequence<T>):Vector<T> {
		var result = self;
		for (v in other) result = result.push(v);
		return result;
	}
    
	/**
		Returns a new Vector with each value in each iterable in `others` to the end.

		Equivalent to calling `concat()` for each list individually, but potentially
		more efficient.
	**/
	public function concatEach(others:Sequence<Sequence<T>>):Vector<T> {
		var result = self;
		for (obj in others) result = result.concat(obj);
		return result;
	}

	/**
		Returns a new Vector with the given `separator` interposed between each element.
	**/
	public function separate(separator:T):Vector<T>
		return Sequence.fromVector(self).separate(separator).toVector();


	/**
		Returns a new Vector with the values of `other` interleaved with the elements of this
		Sequence.

		For example, `[1, 2, 3, 4].interleave([9, 9, 9, 9])` returns `[1, 9, 2, 9, 3, 9, 4, 9]`
	**/
	public function interleave(other:Sequence<T>):Vector<T>
		return Sequence.fromVector(self).interleave(other).toVector();


	/**
		Create a Vector of Vectors, split by occurrences of `element`.
	**/
	public function split(element:T):Vector<Vector<T>>
		return Sequence.fromVector(self).split(element).toVector().map(fromSequence);

	/**
		Create a Vector of Vectors, split by occurrences where elements satisfy `predicate`.
	**/
	public function splitWhere(predicate:T->Bool):Vector<Vector<T>>
		return Sequence.fromVector(self).splitWhere(predicate).toVector().map(fromSequence);

	/**
		Partition this Vector into a Vector of Vectors, divided along the given `indices`
	**/
	public function partition(indices:Sequence<Int>):Vector<Vector<T>>
		return Sequence.fromVector(self).partition(indices).toVector().map(fromSequence);


	//////////////////////////////////////////////////////////////////////////////////////////
	///////////////////////////////////////// SLICES /////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////

	/**
		Returns elements starting from and including `pos`, ending at but not including `end`.

		If `pos` or `end` are negative, their value is calculated from the end of the Vector.
	**/
	public function slice(pos:Int, ?end:Int):Vector<T>
		return Sequence.fromVector(self).slice(pos, end).toVector();

	/**
		Returns `len` elements (all elements if len is null) from this Vector, starting at
		and including `pos`.

		If `pos` is negative, its value is calculated from the end of the Sequence.
	**/
	public function splice(pos:Int, ?len:Int):Vector<T>
		return Sequence.fromVector(self).splice(pos, len).toVector();

	/**
		Returns `num` elements from the start of the Vector.
	**/
	public inline function take(num:Int):Vector<T>
		return slice(0, num);

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
	public function takeUntil(predicate:T->Bool):Vector<T> {
		var result = [];
		for (i in 0...length) {
			if (predicate(getValue(i))) break;
			result.push(getValue(i));
		}
		return fromArray(result);
	}

	/**
		Returns a new Vector with `num` elements removed from the front.
	**/
	public inline function drop(num:Int):Vector<T> {
		return slice(num);
	}

	/**
		Returns a new Vector with `num` elements removed from the end.
	**/
	public inline function dropLast(num:Int):Vector<T> {
		return slice(0, length-num);
	}

	/**
		Returns all elements from this list after `predicate` returns false.
		Even if `predicate` returns true for elements thereafter, they will
		still be included.

		For example, `[1, 2, 3, 4, 2].dropWhile(x -> x != 3)` returns `[3, 4, 2]`
	**/
	public function dropWhile(predicate:T->Bool):Vector<T> {
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
	public function dropUntil(predicate:T->Bool):Vector<T> {
		var result = [], i = 0;
		while (i < length && !predicate(getValue(i))) {
			++i;
		}
		while (i < length) {
			result.push(getValue(i++));
		}
		return fromArray(result);
	}



	//////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////// MAPPINGS ////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////

	/**
		Returns a new Vector with each value passed through the `mapper` function.
	**/
	public function map<M>(mapper:T->M):Vector<M>
		return fromArray(data.map(mapper));

	/**
		Returns a new Vector with each index and corresponding value passed through the `mapper` function.
	**/
	public function mapIndex<M>(mapper:(Int, T)->M):Vector<M> {
		var result = [];
		var i = 0;
		for (v in self) {
			result.push(mapper(i, getValue(i)));
			++i;
		}
		return fromArray(result);
	}

	/**
		`mapper` is a function that returns an Iterable type (Array, Vector,
		Map, etc.)
					
		`flatMap` creates a new Vector with each value passed through the
		`mapper` function, then flattened. 
	
		For example, `[1, 2, 3].flatMap(x -> [x*2, x*10])` returns
		`[2, 10, 4, 20, 6, 30]`
	**/
	public function flatMap<M>(mapper:T->Sequence<M>):Vector<M>
		return new Vector().concatEach(map(mapper));

	/**
		Returns a Vector of Vectors, with elements grouped according to the return value
		of `grouper`.

		For example, `[1, 2, 3, 4, 5].group(x -> x % 2)` results in `[[1, 3, 5], [2, 4]]`
	**/
	public function group<M>(grouper:T->M):Vector<Vector<T>> {
		var groups = [], result = [];
		for (elem in this) {
			var group = grouper(elem);
			var groupIndex = groups.indexOf(group);
			if (groupIndex == -1) {
				groups.push(group);
				result.push(new Vector().push(elem));
			} else {
				result[groupIndex] = result[groupIndex].push(elem);
			}
		}
		return fromArray(result);
	}

	/**
		Takes list A and list B and creates a new Vector where the i'th element is the
		vector [A[i], B[i]]

		For example, `[1, 2, 3].zip([4, 5, 6])` results in `[[1, 4], [2, 5], [3, 6]]`
	**/
	public function zip(other:Sequence<T>):Vector<Vector<T>> {
		var len = if (length > other.count()) other.count() else length;
		return fromArray([for (i in 0...len) fromArray([getValue(i), other[i]])]);
	}

	/**
		Zips each sequence with this list.

		For example, `[1, 2, 3].zipEach([[4, 5, 6], [7, 8, 9]])` returns 
		`[[1, 4, 7], [2, 5, 8], [3, 6, 9]]`
	**/
	public function zipEach(others:Sequence<Sequence<T>>):Vector<Vector<T>> {

		others = others.insert(0, self);

		// gather inputs into arrays
		var arr = [for (other in others) [for (elem in other) elem]];

		// determine shortest length of input arrays
		var shortest = arr[0].length;
		for (i in 1...arr.length)
			if (arr[i].length < shortest) shortest = arr[i].length;

		// zip into lists
		return fromArray([
			for (i in 0...shortest) fromArray([for (j in 0...arr.length)
				arr[j][i]
			])
		]);

	}


	//////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////// REDUCTIONS ///////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////

	/**
		Returns the accumulation of this Vector according to `foldFn`, beginning with
		`initialValue`.

		For example, `[1, 2, 3].fold((a, b) -> a - b, 0)` evaluates `0 - 1 - 2 - 3 = -6`
	**/
	public function fold<R>(foldFn:(R,T)->R, initialValue:R):R {

		var index:Int = 0;

		while (has(index))
			initialValue = foldFn(initialValue, getValue(index++));

		return initialValue;

	}

	/**
		Returns the accumulation of this Vector according to `foldFn`, beginning with
		`initialValue`. Identical to `fold()`, except iterating in reverse.

		For example, `[1, 2, 3].foldRight((a, b) -> a - b, 0)` evaluates `0 - 3 - 2 - 1 = -6`
	**/
	public function foldRight<R>(foldFn:(R,T)->R, initialValue:R):R {

		var index:Int = 0;

		while (has(index))
			initialValue = foldFn(initialValue, getValue(index++));

		return initialValue;

	}

	/**
		A simpler form of `fold()`
		
		Returns the accumulation of this Vector according to `reducer`.

		For example, `[1, 2, 3, 4].reduce((a, b) -> a + b)` returns `10`

		Throws an Exception if the Vector is empty.
	**/
	public function reduce(reducer:(T,T)->T):T {

		if (empty())
			throw new Exception("attempt to reduce empty Sequence");

		var index:Int = 1;
		var value:T = getValue(0);

		while (has(index))
			value = reducer(value, getValue(index++));

		return value;

	}

	/**
		A simpler form of `foldRight()`
			
		Returns the accumulation of this Vector according to `reducer`. Identical
		to `reduce()` except iterating in reverse.

		For example, `[1, 2, 3, 4].reduceRight((a, b) -> a + b)` returns `10`

		Throws an Exception if the Vector is empty.
	**/
	public function reduceRight(reducer:(T,T)->T):T {

		if (empty())
			throw new Exception("attempt to reduce empty Sequence");

		var index:Int = length - 2;
		var value:T = getValue(length - 1);

		while (has(index))
			value = reducer(value, getValue(index--));

		return value;

	}

	/**
		The number of elements in the Vector. Read-only property.
	**/
	public var length(get, never):Int;
	private inline function get_length():Int {
		return data.length;
	}

	/**
		True if `predicate` is true for every element in the Vector.
		True if the Vector is empty.
	**/
	public function every(predicate:T->Bool):Bool {
		for (v in this) if (!predicate(v)) return false;
		return true;
	}

	/**
		True if `predicate` is true for any element in the Vector.
	**/
	public function some(predicate:T->Bool):Bool {
		for (v in this) if (predicate(v)) return true;
		return false;
	}

	/**
		Returns true if this Vector and `other` contain an identical sequence of values.

		If `deep` is true, the objects are compared by their string representations,
		which will properly handle deeply nested subvectors and many other edge cases,
		but will incorrectly classify non-printable objects like functions.
	**/
	public function equals(other:Sequence<T>, ?deep:Bool):Bool {
		if (deep != null && deep.unsafe())
			return toString() == other.toVector().toString();

		var iter = other.iterator(), thisIter = iterator();
		while(iter.hasNext() && thisIter.hasNext())
			if (iter.next() != thisIter.next()) return false;
		return !(iter.hasNext() || thisIter.hasNext());
	}

	/**
		Returns the numerical maximum of the Vector.
	**/
	public macro function max<T>(ethis:ExprOf<Vector<T>>):ExprOf<T>
		return macro $e{ethis}.reduce((a, b) -> if (a > b) a else b);

	/**
		Returns the numerical minimum of the Vector.
	**/
	public macro function min<T>(ethis:ExprOf<Vector<T>>):ExprOf<T>
		return macro $e{ethis}.reduce((a, b) -> if (a < b) a else b);

	/**
		Returns the sum of the elements in the Vector.
	**/
	public macro function sum<T>(ethis:ExprOf<Vector<T>>):ExprOf<T>
		return macro $e{ethis}.reduce((a, b) -> a + b);

	/**
		Returns the product of the elements in the Vector.
	**/
	public macro function product<T>(ethis:ExprOf<Vector<T>>):ExprOf<T>
		return macro $e{ethis}.reduce((a, b) -> a * b);

	/**
		The `sideEffect` is executed for every value in the Vector.
	**/
	public function forEach(sideEffect:T->Void):Void
		for (k => v in this)
			sideEffect(v);

	/**
		The `sideEffect` is executed for every value in the Vector. Iteration stops once `sideEffect` returns false.

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


	/////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////// CONVERSIONS //////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////


	/**
		Iterator over each value in the Vector.
	**/
	public inline function iterator():Iterator<T>
		return this.iterator();

	/**
		Iterator over each index-value pair in the Vector.
	**/
	public function keyValueIterator():KeyValueIterator<Int, T>
		return this.keyValueIterator();

	/**
		Iterator over each index of the list.
	**/
	public inline function indices():Iterator<Int> {
		return 0...length;
	}

	/**
		Iterator over each value in the Vector. Equivalent to `iterator()`
	**/
	public inline function values():Iterator<T> {
		return iterator();
	}

	/**
		Iterator over each index-value pair in the list.
	**/
	public function entries():Iterator<{key: Int, value: T}> {
		var i = 0;
		return {
			hasNext: () -> i < length,
			next: () -> {
				var result = { key: i, value: getValue(i) };
				++i;
				result;
			}	
		};
	}

	/**
		Convert this Vector into an Array<T>
	**/
	public function toArray():Array<T>
		return [for (v in this) v];

	/**
		Convert this Vector into an immutable Map<Int,T>
	**/
	public function toMap():Map<Int, T>
		return new Map().setEach(indices(), values());

	/**
		Convert this Vector into an immutable OrderedMap<Int,T>
	**/
	public function toOrderedMap():OrderedMap<Int, T>
		return new OrderedMap().setEach(indices(), values());

	/**
		Convert this Vector into an immutable Set, discarding duplicate values
	**/
	public function toSet():Set<T>
		return new Set().addEach(values());

	/**
		Convert this Vector into an OrderedSet<T>
	**/
	public function toOrderedSet():OrderedSet<T> {
		return new OrderedSet().addEach(values());
	}

	/**
		Convert this Vector into a Stack<T>
	**/
	public function toStack():Stack<T> {
		return new Stack().pushEach(values());
	}

	/**
		Convert this Vector into a Sequence<T>
	**/
	public function toSequence():Sequence<T>
		return Sequence.fromVector(self);

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
			result.add(' ${getValue(index++)},');
		}

		return
			(if (cut)
				result.toString().substr(0, result.length - 1)
			else
				result.toString())
			+ " ]";
	}
	

	/////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////// INTERNALS ///////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////


	private var self(get, never):Vector<T>;
	private inline function get_self() return this;

	private var _this(get, never):VectorObject<T>;
	private inline function get__this() return this;

	private var data(get, set):Array<T>;
	private inline function get_data() return this.data;
	private inline function set_data(d) return this.data = d;

}

private class VectorObject<T> {
	public inline function new() {}
	public var data:Array<T> = [];

	public function iterator():Iterator<T> {
		var i = 0;
		return {
			hasNext: () -> i < data.length,
			next: () -> data[i++]
		};
	}

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

	public function toString():String
		return (this:Vector<T>).toString();
}