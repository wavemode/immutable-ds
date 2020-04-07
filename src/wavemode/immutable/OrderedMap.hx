/**
 *  Copyright (c) 2020-present, Chukwudi Okechukwu
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the root directory of this source tree.
 *
 */

// TODO: array index syntax
package wavemode.immutable;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#end

using wavemode.immutable.Functional;
import stdlib.Exception;

// TODO: make all map parameters generic
// TODO: give all classes from and make

class OrderedMap<K, V> {
	private var data:Array<Pair<K, V>>;

	static function fromArray<K, V>(arr:Array<Pair<K, V>>):OrderedMap<K, V> {
		var map = new OrderedMap<K, V>();
		map.data = arr;
		return map;
	}

	public function toString():String {
		var result = "OrderedMap {";
		var cut = false;

		for (k => v in this) {
			cut = true;
			result += ' $k: $v,';
		}

		if (cut)
			result = result.substr(0, result.length - 1);
		return result + " }";
	}

	//////////////////////////////////////////////////////////////////////////////////////////////////////////
	////// API
	//////////////////////////////////////////////////////////////////////////////////////////////////////////

	/**
		Create a new empty Map.
	**/
	public function new() {
		data = [];
	}

	/**
		Iterator over each value in the Map.
	**/
	public function iterator():Iterator<V> {
		var i = 0;
		return {
			hasNext: () -> i < data.length,
			next: () -> data[i++].b
		};
	}

	/**
		Iterator over each key-value pair in the Map.
	**/
	public function keyValueIterator():KeyValueIterator<K, V> {
		var i = 0;
		return {
			hasNext: () -> i < data.length,
			next: () -> {
				var result = {key: data[i].a, value: data[i].b};
				++i;
				result;
			}
		};
	}

	/**
		Macro which creates a new OrderedMap from a struct literal.

		```haxe
		OrderedMap.make({a: 10, b: 5})
		```

		is equivalent to

		```haxe
		new OrderedMap().setEach(["a", "b"], [10, 5])
		```
	**/
	public static macro function make<K, V>(expr:Expr):ExprOf<OrderedMap<K, V>> {
		var names = [], exprs = [];
		switch expr.expr {
			case EObjectDecl(fields):
				for (field in fields) {
					names.push(field.field);
					exprs.push(field.expr);
				}
			default:
				Context.error("Struct literal required here.", expr.pos);
		}
		var arrExprs = [];
		for (i in 0...exprs.length) {
			arrExprs.push(macro result = result.set($v{names[i]}, $e{exprs[i]}));
		}
		var expr = macro @:pos(Context.currentPos()) {
			var result = new OrderedMap();
			$a{arrExprs} result;
		}
		return expr;
	}

	/**
		Create a new `OrderedMap` from a `haxe.ds.Map`
	**/
	public static function fromMap<K, V>(map:haxe.ds.Map<K, V>):OrderedMap<K, V> {
		var result = [];
		for (k => v in map) {
			result.push(new Pair(k, v));
		}
		var map = new OrderedMap();
		map.data = result;
		return map;
	}

	/**
		Number of keys that are in the map. Read-only property.
	**/
	public var length(get, never):Int;

	function get_length()
		return data.length;

	/**
		True if the Map is empty.
	**/
	public function empty():Bool
		return length == 0;

	/**
		Returns a new Map containing the new (key, value) pair. If an equivalent key already
		exists in this Map, it will be replaced.
	**/
	public function set(key:K, newValue:V):OrderedMap<K, V> {
		var i = 0, arr = data.copy();
		var insert = true;
		for (k => v in this) {
			if (key == k) {
				arr[i] = new Pair(k, newValue);
				insert = false;
				break;
			}
			i++;
		}
		if (insert)
			arr.push(new Pair(key, newValue));
		return fromArray(arr);
	}

	/**
		Returns a new Map containing the all the values in `keys` set to all values in `values`.
		If any equivalent keys already exists in this Map, they will be replaced.

		This is equivalent to calling `set()` for each pair individually, but potentially more
		efficient.
	**/
	public function setEach(keys:Iterable<K>, values:Iterable<V>):OrderedMap<K, V> {
		var map = this, keyIter = keys.iterator(), valIter = values.iterator();
		while (keyIter.hasNext() && valIter.hasNext()) {
			map = map.set(keyIter.next(), valIter.next());
		}
		return map;
	}

	/**
		Returns a new Map which excludes this key.
	**/
	public function remove(key:K):OrderedMap<K, V> {
		var i = 0, arr = data;
		for (k => v in this) {
			if (key == k) {
				arr = arr.slice(0, i).concat(arr.slice(i + 1));
				break;
			}
			i++;
		}
		return fromArray(arr);
	}

	/**
		Returns a new Map which excludes this value.
	**/
	public function removeValue(value:V):OrderedMap<K, V> {
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
		Returns a new Map which excludes the provided keys.

		This is equivalent to calling `remove()` for each key individually, but potentially more
		efficient.
	**/
	public function removeEach(keys:Iterable<K>):OrderedMap<K, V> {
		var map = this;
		for (key in keys) {
			map = map.remove(key);
		}
		return map;
	}

	/**
		Returns a new Map which excludes the provided values.

		This is equivalent to calling `remove()` for each value individually, but potentially more
		efficient.
	**/
	public inline function removeEachValue(values:Iterable<V>):OrderedMap<K, V> {
		var map = this;
		for (value in values)
			map = map.removeValue(value);
		return map;
	}

	/**
		Returns a new Map containing no keys or values.
	**/
	public function clear():OrderedMap<K, V> { // TODO: implement
		return fromArray([]);
	}

	/**
			Returns a new Map having updated the value at this key with the return value of calling `updater` with the existing value.

			Similar to `map.set(key, updater(map.get(key)))`.

			If `key` does not exist, this function returns the unaltered map.
	**/
	public function update(key:K, updater:V->V):OrderedMap<K, V> {
		var i = 0, arr = data.copy();
		for (k => v in this) {
			if (key == k) {
				arr[i] = new Pair(k, updater(arr[i].b));
				break;
			}
			i++;
		}
		return fromArray(arr);
	}

	/**
		Returns a new Map having updated the values at the keys in `keys` with the return values of calling `updater` with the existing values.
		If any key in `keys` does not exist in the map, it is ignored.

		Equivalent to calling `update()` for each key individually, but potentially more efficient.
	**/
	public function updateEach(keys:Iterable<K>, updater:V->V):OrderedMap<K, V> {
		var map = this;
		for (key in keys) {
			map = map.update(key, updater);
		}
		return map;
	}

	/**
		Returns a new Map having the given value replaced with the value `newVal`.

		If the value does not exist, this function returns the unaltered map.
	**/
	public function replace(value:V, newVal:V):OrderedMap<K, V> {
		var i = 0, arr = data.copy();
		for (k => v in this) {
			if (value == v) {
				arr[i] = new Pair(k, newVal);
			}
			i++;
		}
		return fromArray(arr);
	}

	/**
        Returns a new Map having the given values replaced with the values in `newVals`.

        If any value does not exist, the value is ignored.

        This is equivalent to calling `replace()` for every value individually, but is
        potentially more efficient, and previous replacements do not affect subsequent
        ones.
	**/
	public function replaceEach(values:Iterable<V>, newVals:Iterable<V>):OrderedMap<K, V> {
		var valIter = values.iterator(),
			newIter = newVals.iterator(),
			result = this;

		var merges = [];

		while (valIter.hasNext() && newIter.hasNext()) {
			var oldVal = valIter.next(), newVal = newIter.next();

			for (key => val in result) {
				if (val == oldVal)
					merges.push([new Pair(key, newVal)]);
			}
		}

		return result.mergeEach(merges.map(fromArray));
	}

	/**
		Returns a new Map resulting from merging `other` into this Map. In other words, this
		takes each entry of `other` and sets it on this Map.

		If `mergeFunction` is provided, it is used to resolve key conflicts. If not, keys from
		`other` override keys from this Map.
	**/
	public function merge(other:OrderedMap<K, V>, ?mergeFunction:(V, V) -> V):OrderedMap<K, V> {
		var result = this;
		for (k => v1 in other) {
			var v2 = get(k);
			if (v2 == null || mergeFunction == null)
				result = result.set(k, v1);
			else
				result = result.set(k, mergeFunction(v2.sure(), v1));
		}
		return result;
	}

	/**
		Returns a new Map resulting from merging each Map in `others` into this Map. In other words,
		this takes each entry of each map in `others` and sets it on this Map.

		If `mergeFunction` is provided, it is used to resolve key conflicts. If not, keys from
		`others` override keys from this Map, and keys from Map objects appearing later in the
		list override keys from earlier ones.

		This is equivalent to calling `merge()` for each map individually, but potentially more
		efficient.
	**/
	public function mergeEach(others:Iterable<OrderedMap<K, V>>, ?mergeFunction:(V, V) -> V):OrderedMap<K, V> { // TODO: implement
		var result = this;
		for (other in others)
			result = result.merge(other, mergeFunction);
		return result;
	}

	/**
		Returns a new Map with values passed through a mapper function.
	**/
	public function map<M>(mapper:V->M):OrderedMap<K, M> {
		return fromArray(data.map(pair -> pair.updateB(mapper)));
	}

	/**
		Returns a new Map with values passed through a mapper function.
		Same as `map` except the mapper function takes a key as well.
	**/
	public function mapWithKey<M>(mapper:(K, V) -> M):OrderedMap<K, M> {
		return fromArray(data.map(pair -> pair.updateB(b -> mapper(pair.a, b))));
	}

	/**
		Returns a new Map with keys passed through a mapper function.
	**/
	public function mapKeys<M>(mapper:(K, V) -> M):OrderedMap<M, V> {
		return fromArray(data.map(pair -> pair.updateA(a -> mapper(a, pair.b))));
	}

	/**
		Returns a new Map with (key, value) entries passed through a mapper function.
	**/
	public function mapEntries<MK, MV>(mapper:(K, V) -> Pair<MK, MV>):OrderedMap<MK, MV> {
		return fromArray(data.map(pair -> mapper(pair.a, pair.b)));
	}

	/**
		Returns a new Map with only the entries for which the predicate function returns true.
	**/
	public function filter(predicate:V->Bool):OrderedMap<K, V> {
		return fromArray(data.filter(pair -> predicate(pair.b)));
	}

	/**
		Returns a new Map with only the entries for which the predicate function returns true.
		Same as `filter` except the predicate function takes a key as well.
	**/
	public function filterWithKey(predicate:(K, V) -> Bool):OrderedMap<K, V> {
		return fromArray(data.filter(pair -> predicate(pair.a, pair.b)));
	}

	/**
		Returns a new Map where the keys and values have been flipped.
	**/
	public function flip():OrderedMap<V, K> {
		return this.mapEntries((k, v) -> new Pair(v, k));
	}

	/**
		An iterator of this Map's keys.
	**/
	public function keys():Iterator<K> { // TODO: implement
		var i = 0;
		return {
			hasNext: () -> i < data.length,
			next: () -> data[i++].a
		};
	}

	/**
		An iterator of this Map's keys. Equivalent to `iterator()`.
	**/
	public function values():Iterator<V> {
		return iterator();
	}

	/**
		An iterator of this Map's entries as key-value pairs.
	**/
	public function entries():Iterator<Pair<K, V>> {
		return data.iterator();
	}

	/**
		True if this and the other Map have identical keys and values.
	**/
	@:generic
	public function equals<T:MapType<K, V>>(other:T):Bool {
		if (length != other.length)
			return false;
		for (key => value in this) {
			if (!other.get(key).is(value))
				return false;
		}
		return true;
	}

	/**
		Returns the value associated with the provided key, or null if the Map does not contain this key.
	**/
	public function get(key:K):Null<V> {
		for (k => v in this) {
			if (key == k) {
				return v;
			}
		}
		return null;
	}

	/**
		Unsafe variant of `get()`. Returns the value associated with the provided key, or throws an Exception
		if the Map does not contain this key.
	**/
	public function getValue(key:K):V {
		for (k => v in this) {
			if (key == k) {
				return v;
			}
		}
		throw new Exception("key $key not found in the map");
	}

	/**
		True if a key exists within this Map.
	**/
	public function has(key:K):Bool {
		return !get(key).equals(null);
	}

	/**
		Returns the key of a given value in the map, or null if the value does not exist.
	**/
	public function find(value:V):Null<K> {
		for (k => v in this)
			if (value == v)
				return k;
		return null;
	}

	/**
		Returns the first key at which `predicate` returns true, or null if no match is found.
	**/
	public function findWhere(predicate:V->Bool):Null<K> {
		for (k => v in this) if (predicate(v)) return k;
		return null;
	}

	/**
		True if a value exists within this Map.
	**/
	public function hasValue(value:V):Bool {
		for (v in this)
			if (value == v)
				return true;
		return false;
	}

	/**
		The `sideEffect` is executed for every entry in the Map.
	**/
	public function forEach(sideEffect:(K, V) -> Void):Void {
		for (k => v in this)
			sideEffect(k, v);
	}

	/**
		The `sideEffect` is executed for every entry in the Map. Iteration stops once `sideEffect` returns false.

		This function returns the number of times `sideEffects` was executed.
	**/
	public function forWhile(sideEffect:(K, V) -> Bool):Int {
		var i = 0;
		for (k => v in this) {
			++i;
			if (!sideEffect(k, v))
				break;
		}
		return i;
	}

	/**
		Shallowly converts this Map to an Array.
	**/
	public function toArray():Array<V> {
		return [for (v in values()) v];
	}

	/**
		Shallowly converts this Map to an Array of key-value pairs.
	**/
	public function toArrayKV():Array<Pair<K, V>> {
		return data.copy();
	}

	// /**
	// 	Returns a Sequence of values in this Map.
	// **/
	// public function toSequence():Sequence<V> { // TODO: implement
	// 	return null;
	// }

	// /**
	// 	Returns a Sequence of key-value pairs in this Map.
	// **/
	// public function toSequenceKV():Sequence<Pair<K, V>> { // TODO: implement
	// 	return null;
	// }

	// /**
	// 	Returns a new Sequence of the keys of this Map, discarding values.
	// **/
	// public function toSequenceKeys():Sequence<K> { // TODO: implement
	// 	return null;
	// }

	// /**
	// 	Converts this OrderedMap to a Map.
	// **/
	// public function toMap() { // TODO: implement
	// 	// return [for (k => v in this) k => v];
	// }

	// /**
	// 	Converts this Map to a Set, discarding keys.
	// **/
	// public function toSet():Null<Set<V>> { // TODO: implement
	// 	return null;
	// }

	// /**
	// 	Converts this map to an OrderedSet, maintaining value order but discarding keys.
	// **/
	// public function toOrderedSet():Null<OrderedSet<V>> { // TODO: implement
	// 	return null;
	// }

	// /**
	// 	Converts this Map to a List, discarding keys.

	// 	```haxe
	// 	var myMap = Map.from({ a: "Apple", b: "Banana" })
	// 	var newMap = myMap.toList(); // List [ "Apple", "Banana" ]
	// 	```
	// **/
	// public function toList():List<V> { // TODO: implement
	// 	return null;
	// }

	// /**
	// 	Converts this Collection to a Stack, discarding keys.
	// **/
	// public function toStack():Null<Stack<V>> { // TODO: implement
	// 	return null;
	// }
}

private typedef MapType<K, V> = {
	function has(k:K):Bool;
	function get(k:K):Null<V>;
	var length(get, never):Int;
}
