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
#end

import stdlib.Exception;

@:forward
abstract OrderedSet<T>(OrderedSetObject<T>) from OrderedSetObject<T> to OrderedSetObject<T> {

	/**
		Create an empty Set, or with the values in `object`
	**/
	public inline function new(?object:Sequence<T>)
		if (object != null)
			this = fromSequence(object);
		else
			this = new OrderedSetObject();

	/**
		Create a new Set with the values in `arr`.

		Equivalent to `new OrderedSet().addEach(arr)`
	**/
	public static inline function fromSequence<T>(arr:Sequence<T>):OrderedSet<T>
		return new OrderedSet().addEach(arr);

	/**
		Macro to create a Set from any number of values.
	**/
	public static macro function make<T>(exprs:Array<ExprOf<T>>):ExprOf<OrderedSet<T>>
		return macro OrderedSet.fromSequence([$a{exprs}]);

	/**
		Returns a new Set resulting from merging `other` into this Set. In other words, this
		takes each value in `other` and adds it to this Set.

		Callable with the `+` operator.
	**/
	@:op(A+B)
	@:commutative
	public function union(other:Sequence<T>):OrderedSet<T>
		return this.union(other);

	/**
		Returns a new Set containing only values in this set that do not appear in `other`.

		Callable with the `-` operator.
	**/
	@:op(A-B)
	public function subtract(other:OrderedSet<T>):OrderedSet<T>
		return this.subtract(other);

}

private class OrderedSetObject<T> {

	/**
		Returns a new Set containing the new value. If an equivalent value already
		exists in this Set, this function returns the unaltered Set.
	**/
	public function add(val:T):OrderedSet<T> {
		for (v in this) {
			if (val == v) {
				return this;
			}
		}
		var arr = data.copy();
		arr.push(val);
		var set = new OrderedSet();
		set.data = arr;
		return set;
	}

	/**
		Returns a new Set with each value in `values` added. If an equivalent value already
		exists in this Set, it will be skipped.

		This is equivalent to calling `add()` for each value individually, but is potentially more
		efficient.
	**/
	public function addEach(values:Sequence<T>):OrderedSet<T> {
		var set = this;
		for (val in values) {
			set = set.add(val);
		}
		return set;
	}

	/**
		Returns a new Set having the given value replaced with the value `newVal`.

		If the value does not exist, this function returns the unaltered set.
	**/
	public function replace(value:T, newVal:T):OrderedSet<T> {
		var i = 0, arr = data.copy();
		for (v in this) {
			if (value == v) {
				arr[i] = newVal;
				break;
			}
			i++;
		}
		return OrderedSet.fromSequence(arr);
	}

	/**
		Returns a new Set having the given values replaced with the values in `newVals`.

		If any value does not exist, the value is ignored.

		This is equivalent to calling `replace()` for every value individually, but is
		potentially more efficient.
	**/
	public function replaceEach(values:Sequence<T>, newVals:Sequence<T>):OrderedSet<T> {
		var valIter = values.iterator(),
			newIter = newVals.iterator(),
			result = this;
		while (valIter.hasNext() && newIter.hasNext()) {
			result = result.replace(valIter.next(), newIter.next());
		}
		return result;
	}

	/**
		True if a value exists within this Set.
	**/
	public function has(val:T):Bool {
		for (v in this) {
			if (val == v) {
				return true;
			}
		}
		return false;
	}

	/**
		True if the Set is empty.
	**/
	public function empty():Bool
		return length == 0;

	/**
		Returns a new Set with only the entries for which the predicate function returns true.
	**/
		public function filter(predicate:T->Bool):OrderedSet<T>
			return OrderedSet.fromSequence(data.filter(value -> predicate(value)));

	/**
		Returns a new Set which excludes this key.
	**/
	public function remove(value:T):OrderedSet<T> {
		var i = 0, arr = data;
		for (v in this) {
			if (value == v) {
				arr = arr.slice(0, i).concat(arr.slice(i + 1));
				break;
			}
			i++;
		}
		return OrderedSet.fromSequence(arr);
	}

	/**
		Returns a new Set which excludes the provided values.

		This is equivalent to calling `remove()` for each value individually, but is potentially more
		efficient.
	**/
	public function removeEach(values:Sequence<T>):OrderedSet<T> {
		var set = this;
		for (v in values) {
			set = set.remove(v);
		}
		return set;
	}

	/**
		Returns a new Set containing no keys or values.
	**/
	public function clear():OrderedSet<T>
		return new OrderedSet();

	/**
		Returns a new Set resulting from merging `other` into this Set. In other words, this
		takes each value in `other` and adds it to this Set.
	**/
	public function union(other:Sequence<T>):OrderedSet<T> {
		var result = this;
		for (v in other)
			result = result.add(v);
		return result;
	}

	/**
		Returns a new Set resulting from merging each set in `others` into this Set. In other words, this
		takes each value in each set in `others` and adds it to this Set.

		This is equivalent to calling `union()` for each set individually, but potentially more
		efficient.
	**/
	public function unionEach(others:Sequence<Sequence<T>>):OrderedSet<T> {
		var result = this;
		for (other in others)
			result = result.union(other);
		return result;
	}

	/**
		Returns a new Set containing only values in this set that do not appear in `other`.
	**/
	public function subtract(other:OrderedSet<T>):OrderedSet<T> {
		var result = new OrderedSet();
		for (v in this)
			if (!other.has(v))
				result = result.add(v);
		return result;
	}

	/**
		Returns a new Set containing only values in this set that do not appear in any set in `others`.

		This is equivalent to calling `subtract()` for each set individually, but potentially more
		efficient.
	**/
	public function subtractEach(others:Sequence<OrderedSet<T>>):OrderedSet<T> {
		var result = this;
		for (other in others)
			result = result.subtract(other);
		return result;
	}

	/**
		Returns a new Set with values passed through a mapper function.
	**/
		public function map<M>(mapper:T->M):OrderedSet<M>
			return OrderedSet.fromSequence(data.map(value -> mapper(value)));

	/**
		Returns a new Set containing only values that appear in this set and in `other`.
	**/
	public function intersect(other:Sequence<T>):OrderedSet<T> {
		var result = new OrderedSet();
		for (v in other)
			if (has(v))
				result = result.add(v);
		return result;
	}

	/**
		Returns a new Set containing only values that appear in this set and in every object in `others`.

		This is equivalent to calling `intersect()` for each set individually, but potentially more
		efficient.
	**/
	public function intersectEach(others:Sequence<Sequence<T>>):OrderedSet<T> {
		var result = this;
		for (other in others)
			result = result.intersect(other);
		return result;
	}

	/**
		Returns the accumulation of the values in this OrderedSet according to `foldFn`, beginning
		with `initialValue`

		For example, `(1, 2, 3).fold((a, b) -> a - b, 0)` evaluates `0 - 1 - 2 - 3 = -6`
	**/
	public function fold<R>(foldFn:(R, T)->R, initialValue:R):R
		return Sequence.fromIterable(this).fold(foldFn, initialValue);

	/**
		A simpler form of `fold()`

		Returns the accumulation of the values in this OrderedSet according to `reducer`

		For example, `(1, 2, 3).reduce((a, b) -> a + b)` evaluates `1 + 2 + 3 = 6`

		Throws an Exception if the OrderedMap is empty.
	**/
	public function reduce(reducer:(T, T)->T):T
		if (empty())
			throw new Exception("attempt to reduce empty OrderedSet");
		else
			return Sequence.fromIterable(this).reduce(reducer);

	/**
		Number of values that are in the Set. Read-only property.
	**/
	public var length(get, never):Int;
	function get_length()
		return data.length;

	/**
		Returns true if the given `predicate` is true for every value in the OrderedSet.
	**/
	public function every(predicate:T->Bool):Bool
		return Sequence.fromIterable(this).every(predicate);

	/**
		Returns true if the given `predicate` is true for any value in the OrderedSet.
	**/
	public function some(predicate:T->Bool):Bool
		return Sequence.fromIterable(this).some(predicate);

	/**
		True if this and the other object have identical values.
	**/
	public function equals(other:Sequence<T>):Bool {
		if (length != other.count())
			return false;
		for (value in other)
			if (!has(value))
				return false;
		return true;
	}

	/**
		Returns true if all the values in `other` are in this Set.
	**/
	public function supersetOf(other:Sequence<T>):Bool {
		for (v in other)
			if (!has(v))
				return false;
		return true;
	}

	/**
		Returns true if all the values in this Set are in `other`
	**/
	public function subsetOf(other:Sequence<T>):Bool {
		for (v in this)
			if (other.find(v) == -1)
				return false;
		return true;
	}

	/**
		The `sideEffect` is executed for every entry in the Set.
	**/
	public function forEach(sideEffect:T->Void):Void
		for (v in this)
			sideEffect(v);

	/**
		Iterator over each value in the Set.
	**/
	public function iterator():Iterator<T> {
		var i = 0;
		return {
			hasNext: () -> i < data.length,
			next: () -> data[i++]
		};
	}

	/**
		An iterator of this Set's keys. Equivalent to `iterator()`.
	**/
	public function values():Iterator<T>
		return iterator();

	/**
		Converts this OrderedSet to an Array.
	**/
	public function toArray():Array<T>
		return [for (v in values()) v];

	/**
		Converts this OrderedSet to a Set.
	**/
	public function toSet():Set<T>
		return new Set().addEach(values());

	/**
		Converts this Set to a Vector.
	**/
	public function toVector():Vector<T>
		return toSequence().toVector();

	/**
		Convert this Set to its String representation.
	**/
	public function toString():String {
		var result = "OrderedSet (";
		var cut = false;

		for (v in this) {
			cut = true;
			result += ' $v,';
		}

		if (cut)
			result = result.substr(0, result.length - 1);
		return result + " )";
	}

	/**
		Returns a Sequence of values in this Set.
	**/
	public function toSequence():Sequence<T>
		return Sequence.fromIterable(this);


	public function new() data = [];
	private var data:Array<T>;

}
