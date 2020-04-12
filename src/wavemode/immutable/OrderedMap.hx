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

@:forward
abstract OrderedMap<K, V>(OrderedMapObject<K, V>) from OrderedMapObject<K, V> to OrderedMapObject<K, V> {

	/**
		Create a new empty OrderedMap, or a clone of the given `object`.
	**/
	public function new(?object:OrderedMap<K, V>) {
		this = new OrderedMapObject();
		if (object != null)
			data = object.unsafe().data;
	}

	/**
		Create a new `OrderedMap` from a `haxe.ds.Map`
	**/
	@:from public static function fromMap<K, V>(map:haxe.ds.Map<K, V>):OrderedMap<K, V> {
		var result = [];
		for (k => v in map) {
			result.push({key: k, value: v});
		}
		var map = new OrderedMap();
		map.data = result;
		return map;
	}

	/**
		Macro which creates a new `OrderedMap` from a struct literal.

		```haxe
		OrderedMap.make({a: 10, b: 5})
		```

		is equivalent to

		```haxe
		new OrderedMap().set("a", 10).set("b", 5)
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
		for (i in 0...exprs.length)
			arrExprs.push(macro result = result.set($v{names[i]}, $e{exprs[i]}));
		var expr = macro @:pos(Context.currentPos()) {
			var result = new OrderedMap();
			$a{arrExprs}
			result;
		}
		return expr;
	}

	/**
		Unsafe variant of `get()`. Returns the value associated with the provided key, or throws an Exception
		if the OrderedMap does not contain this key.
	**/
	@:arrayAccess
	public function getValue(key: K):V {
		for (k => v in this) {
			if (key == k) {
				return v;
			}
		}
		throw new Exception("key $key does not exist in the map");
	}

	
	private var data(get, set):Array<{key: K, value: V}>;
	private function get_data() return this.data;
	private function set_data(d) return this.data = d;

}

private class OrderedMapObject<K, V> {

	//////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////// OPERATIONS ///////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////

	/**
		Returns a new OrderedMap containing the new (key, value) pair. If an equivalent key already
		exists in this OrderedMap, it will be replaced.
	**/
	public function set(key:K, newValue:V):OrderedMap<K, V> {
		var i = 0, arr = data.copy();
		var insert = true;
		for (k => v in this) {
			if (key == k) {
				arr[i] = {key: k, value: newValue};
				insert = false;
				break;
			}
			i++;
		}
		if (insert)
			arr.push({key: key, value: newValue});
		return fromArray(arr);
	}

	/**
		Returns a new OrderedMap containing the all the values in `keys` set to all values in `values`.
		If any equivalent keys already exists in this OrderedMap, they will be replaced.

		This is equivalent to calling `set()` for each pair individually, but potentially more
		efficient.
	**/
	public function setEach(keys:Sequence<K>, values:Sequence<V>):OrderedMap<K, V> {
		var index:Int = 0, map = this;
		while (keys.has(index) && values.has(index)) {
			map = map.set(keys.getValue(index), values.getValue(index));
			++index;
		}
		return map;
	}

	/**
			Returns a new OrderedMap having updated the value at this key with the return value of calling `updater` with the existing value.

			Similar to `map.set(key, updater(map.get(key)))`.

			If `key` does not exist, this function returns the unaltered map.
	**/
	public function update(key:K, updater:V->V):OrderedMap<K, V> {
		var i = 0, arr = data.copy();
		for (k => v in this) {
			if (key == k) {
				arr[i] = {key: k, value: updater(v)};
				break;
			}
			i++;
		}
		return fromArray(arr);
	}

	/**
		Returns a new OrderedMap having updated the values at the keys in `keys` with the return values of calling `updater` with the existing values.
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
		Returns a new OrderedMap having every instance of the given value replaced with the value `newVal`.

		If the value does not exist, this function returns the unaltered set.
	**/
	public function replace(value:V, newVal:V):OrderedMap<K, V> {
		var i = 0, arr = data.copy();
		for (k => v in this) {
			if (value == v) {
				arr[i] = {key: k, value: newVal};
			}
			i++;
		}
		return fromArray(arr);
	}

	/**
		Returns a new OrderedMap having the given values replaced with the values in `newVals`.

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
					merges.push([{key: key, value: newVal}]);
			}
		}

		return result.mergeEach(merges.map(fromArray));
	}

	//////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////// SELECTIONS ///////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////

	/**
		Returns the value associated with the provided key, or null if the OrderedMap does not contain this key.
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
		True if a key exists within this OrderedMap.
	**/
	public function has(key:K):Bool {
		for (k => v in this)
			if (key == k)
				return true;
		return false;
	}

	/**
		True if the OrderedMap is empty.
	**/
	public function empty():Bool
		return length == 0;

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
		Returns a new OrderedMap with only the entries for which the predicate function returns true.
	**/
		public function filter(predicate:(K, V) -> Bool):OrderedMap<K, V>
			return fromArray(data.filter(pair -> predicate(pair.key, pair.value)));

	/**
		Returns a new OrderedMap which excludes this value.
	**/
	public function remove(value:V):OrderedMap<K, V> {
		var i = 0, arr = data;
		for (v in this) {
			if (value == v) {
				arr = arr.slice(0, i).concat(arr.slice(i + 1));
				--i;
			}
			i++;
		}
		return fromArray(arr);
	}

	/**
		Returns a new OrderedMap which excludes the provided values.

		This is equivalent to calling `remove()` for each value individually, but potentially more
		efficient.
	**/
	public inline function removeEach(values:Iterable<V>):OrderedMap<K, V> {
		var map = this;
		for (value in values)
			map = map.remove(value);
		return map;
	}

	/**
		Returns a new OrderedMap which excludes this key.
	**/
	public function delete(key:K):OrderedMap<K, V> {
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
		Returns a new OrderedMap which excludes the provided keys.

		This is equivalent to calling `delete()` for each key individually, but potentially more
		efficient.
	**/
	public function deleteEach(keys:Iterable<K>):OrderedMap<K, V> {
		var map = this;
		for (key in keys) {
			map = map.delete(key);
		}
		return map;
	}

	/////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////// TRANSFORMATIONS ////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////

	/**
		Returns a new OrderedMap containing no keys or values.
	**/
	public function clear():OrderedMap<K, V>
		return new OrderedMap();


	/**
		Returns a new OrderedMap resulting from merging `other` into this OrderedMap. In other words, this
		takes each entry of `other` and sets it on this OrderedMap.

		If `mergeFunction` is provided, it is used to resolve key conflicts. If not, keys from
		`other` override keys from this OrderedMap.
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
		Returns a new OrderedMap resulting from merging each OrderedMap in `others` into this OrderedMap. In other words,
		this takes each entry of each map in `others` and sets it on this OrderedMap.

		If `mergeFunction` is provided, it is used to resolve key conflicts. If not, keys from
		`others` override keys from this OrderedMap, and keys from OrderedMap objects appearing later in the
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


	//////////////////////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////// MAPPINGS ////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////


	/**
		Returns a new OrderedMap with values passed through a mapper function.
	**/
	public function map<M>(mapper:(K, V) -> M):OrderedMap<K, M>
		return fromArray(data.map(pair -> {key: pair.key, value: mapper(pair.key, pair.value)}));

	/**
		Returns a new OrderedMap with keys passed through a mapper function.
	**/
	public function mapKeys<M>(mapper:(K, V) -> M):OrderedMap<M, V>
		return fromArray(data.map(pair -> {key: mapper(pair.key, pair.value), value: pair.value}));


	//////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////// REDUCTIONS ///////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////////////////////

	/**
		Returns the accumulation of the values in this OrderedMap according to `foldFn`, beginning
		with `initialValue`

		For example, `[1, 2, 3].fold((a, b) -> a - b, 0)` evaluates `0 - 1 - 2 - 3 = -6`
	**/
	public function fold<R>(foldFn:(R, V)->R, initialValue:R):R
		return Sequence.fromIterable(this).fold(foldFn, initialValue);

	/**
		A simpler form of `fold()`

		Returns the accumulation of the values in this OrderedMap according to `reducer`

		For example, `[1, 2, 3].reduce((a, b) -> a + b)` evaluates `1 + 2 + 3 = 6`

		Throws an Exception if the OrderedMap is empty.
	**/
	public function reduce(reducer:(V, V)->V):V
		if (empty())
			throw new Exception("attempt to reduce empty OrderedMap");
		else
			return Sequence.fromIterable(this).reduce(reducer);

	/**
		Number of keys that are in the map. Read-only property.
	**/
	public var length(get, never):Int;
	function get_length()
		return data.length;

	/**
		Returns true if the given `predicate` is true for every value in the OrderedMap.
	**/
	public function every(predicate:V->Bool):Bool
		return Sequence.fromIterable(this).every(predicate);

	/**
		Returns true if the given `predicate` is true for any value in the OrderedMap.
	**/
	public function some(predicate:V->Bool):Bool
		return Sequence.fromIterable(this).some(predicate);

	/**
		True if this and the `other` Map have identical keys and values.
	**/
	@:generic
	public function equals<T:MapType<K, V>>(other:T):Bool {
		if (length != other.length)
			return false;
		for (key => value in this)
			if (!other.get(key).is(value))
				return false;
		return true;
	}

	/**
		The `sideEffect` is executed for every entry in the OrderedMap.
	**/
	public function forEach(sideEffect:(K, V) -> Void):Void
		for (k => v in this)
			sideEffect(k, v);


	/////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////// CONVERSIONS //////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////


	/**
		Iterator over each value in the OrderedMap.
	**/
	public function iterator():Iterator<V> {
		var i = 0;
		return {
			hasNext: () -> i < data.length,
			next: () -> data[i++].value
		};
	}

	/**
		Iterator over each key-value pair in the OrderedMap.
	**/
	public function keyValueIterator():KeyValueIterator<K, V> {
		var i = 0;
		return {
			hasNext: () -> i < data.length,
			next: () -> {
				var result = {key: data[i].key, value: data[i].value};
				++i;
				result;
			}
		};
	}

	/**
		An iterator of this OrderedMap's keys.
	**/
	public function keys():Iterator<K> { // TODO: implement
		var i = 0;
		return {
			hasNext: () -> i < data.length,
			next: () -> data[i++].key
		};
	}

	/**
		An iterator of this OrderedMap's keys. Equivalent to `iterator()`.
	**/
	public inline function values():Iterator<V>
		return iterator();

	/**
		An iterator of this OrderedMap's entries as key-value pairs.
	**/
	public inline function entries():Iterator<{key: K, value: V}>
		return data.iterator();

	/**
		Shallowly converts this OrderedMap to an Array.
	**/
	public inline function toArray():Array<V>
		return [for (v in values()) v];

	/**
		Converts this OrderedMap to a Map.
	**/
	public inline function toMap():Map<K, V>
		return new Map().setEach(keys(), values());

	/**
		Converts this OrderedMap to a Vector, discarding keys.
	**/
	public inline function toVector():Vector<V>
		return Vector.fromSequence(values());

	/**
		Converts this OrderedMap to a Set, discarding keys.
	**/
	public inline function toSet():Set<V>
		return new Set().addEach(values());

	/**
		Converts this OrderedMap to an OrderedSet, discarding keys.
	**/
	public inline function toOrderedSet():OrderedSet<V>
		return new OrderedSet().addEach(values());

	/**
		Converts this OrderedMap to a Sequence, discarding keys.
	**/
	public inline function toSequence():Sequence<V>
		return Sequence.fromIterable(this);

	/**
		Convers this OrderedMap to its String representation.
	**/
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


	/////////////////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////// INTERNALS ///////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////////////////

	public function new() data = [];
	public static function fromArray<K, V>(arr:Array<{key: K, value: V}>):OrderedMap<K, V> {
		var map = new OrderedMapObject();
		map.data = arr;
		return map;
	}

	public var data:Array<{key: K, value: V}>;

}

private typedef MapType<K, V> = {
	function has(k:K):Bool;
	function get(k:K):Null<V>;
	var length(get, never):Int;
}

