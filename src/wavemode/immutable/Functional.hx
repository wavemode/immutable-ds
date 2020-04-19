/**
 *  Copyright (c) 2020-present, Chukwudi Okechukwu
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the root directory of this source tree.
 *
 */

package wavemode.immutable;

import stdlib.Exception;

// TODO: document and test

class Functional {

	/**
		Unwrap a Null<T>. Throws an Exception if the object is null.
	**/
	public static inline function sure<T>(value:Null<T>):T
		if (value == null)
			throw new Exception("attempted to unwrap null");
		else
			return @:nullSafety(Off) (value:T);

	/**
		Returns an unwrapped Null<T> object or a default alternative if
		the object is null.
	**/
	public static inline function or<T>(value:Null<T>, defaultValue:T):T
		if (value == null)
			return defaultValue;
		else
			return @:nullSafety(Off) (value:T);

	/**
		Returns an unwrapped Null<T> object via @:nullSafety(Off). Unsafe
		unless you have already tested against null.
	**/
	public static inline function unsafe<T>(value:Null<T>):T
		return @:nullSafety(Off) (value:T);

	/**
		Returns true if the Null<T> object contains the given value.
	**/
	public static inline function is<T>(value1:Null<T>, value2:T):Bool
		if (value1 == null)
			return false;
		else
			return value1 == value2;

	/**
		Returns the inverse of a predicate (i.e. x -> !pred(x))
	**/
	public static inline function inverse<T>(pred:T->Bool) {
		return x -> !pred(x);
	}

	/**
		Returns the conjunction of the predicates (i.e. x -> pred1(x) && pred2(x))
	**/
	public static inline function conj<T>(pred1:T->Bool, pred2:T->Bool)
		return x -> pred1(x) && pred2(x);

	/**
		Returns an iterator from `start` up to and including `end`.
	**/
	public static inline function upto(start:Int, end:Int):Iterator<Int>
		return {
			hasNext: () -> start <= end,
			next: () -> start++
		};


	/**
		Returns an iterator from `start` down to and including `end`.
	**/
	public static inline function downto(start:Int, end:Int):Iterator<Int>
		return {
			hasNext: () -> start >= end,
			next: () -> start--
		};

	/**
		Returns an iterator from `start` up to but not including `end`.
	**/
	public static inline function below(start:Int, end:Int):Iterator<Int>
		return {
			hasNext: () -> start < end,
			next: () -> start++
		};

	/**
		Returns an iterator from `start` down to but not including `end`.
	**/
	public static inline function above(start:Int, end:Int):Iterator<Int>
		return {
			hasNext: () -> start > end,
			next: () -> start--
		};

	/**
		Returns conversion from an Iterator to an Iterable.
	**/
	public static inline function iterable<T>(iter:Iterator<T>):Iterable<T>
		return { iterator: () -> iter };

	/**
		Returns conversion from an Iterator to a Sequence.
	**/
	public static inline function seq<T>(iter:Iterator<T>):Sequence<T>
		return Sequence.fromIterator(iter);

}
