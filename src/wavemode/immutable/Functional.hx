package wavemode.immutable;

import haxe.ds.Option;
import stdlib.*;

// TODO: Iterator to Sequence conversion

class Functional {
	/**
		Unwrap an Option<T>. Throws an Exception if the object is null or None.
	**/
	public static inline function unwrap<T>(opt:Option<T>):T {
		if (opt == null)
			throw new Exception("attempted to unwrap null");
		switch opt {
			case Some(v):
				return v;
			case None:
				throw new Exception("attempted to unwrap None");
		}
	}

	/**
		Returns true if the Option<T> object is null or None.
	**/
	public static inline function isEmpty<T>(opt:Option<T>):Bool {
		if (opt == null)
			return true;
		switch opt {
			case Some(v):
				return false;
			case None:
				return true;
		}
	}

	/**
		Returns true if two Option<T> objects are equivalent (both empty, or values equal)
	**/
	public static inline function equals<T>(opt1:Option<T>, opt2:Option<T>) {
		if (opt1 == null)
			return isEmpty(opt2);
		if (opt2 == null)
			return isEmpty(opt1);
		switch opt1 {
			case Some(v1):
				{
					switch opt2 {
						case Some(v2): return v1 == v2;
						case None: return false;
					}
				}
			case None:
				{
					switch opt2 {
						case Some(v2): return false;
						case None: return true;
					}
				}
		}
	}

	/**
		Returns true if the Option<T> object contains the given value.
	**/
	public static inline function is<T>(opt:Option<T>, value:T):Bool {
		if (opt == null)
			return false;
		switch opt {
			case Some(v):
				return value == v;
			case None:
				return false;
		}
	}

	/**
		Returns the inverse of a predicate (i.e. x -> !pred(x))
	**/
	public static inline function inverse<T>(pred:T->Bool) {
		return x -> !pred(x);
	}

	/**
		Returns the conjunction of the predicates (i.e. x -> pred1(x) && pred2(x))
	**/
	public static inline function conj<T>(pred1:T->Bool, pred2:T->Bool) {
		return x -> pred1(x) && pred2(x);
	}

	/**
		Returns an iterator from `start` up to and including `end`.
	**/
	public static inline function upto(start:Int, end:Int):Iterator<Int> {
		return {
			hasNext: () -> start <= end,
			next: () -> start++
		};
	}

	/**
		Returns an iterator from `start` down to and including `end`.
	**/
	public static inline function downto(start:Int, end:Int):Iterator<Int> {
		return {
			hasNext: () -> start >= end,
			next: () -> start--
		};
	}

	/**
		Returns an iterator from `start` up to but not including `end`.
	**/
	public static inline function below(start:Int, end:Int):Iterator<Int> {
		return {
			hasNext: () -> start < end,
			next: () -> start++
		};
	}

	/**
		Returns an iterator from `start` down to but not including `end`.
	**/
	public static inline function above(start:Int, end:Int):Iterator<Int> {
		return {
			hasNext: () -> start > end,
			next: () -> start--
		};
	}

	/**
		Returns conversion from an Iterator to an Iterable.
	**/
	public static inline function iterable<T>(iter:Iterator<T>):Iterable<T> return { iterator: () -> iter };

}
