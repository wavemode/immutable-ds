/**
*  Copyright (c) 2020-present, Chukwudi Okechukwu
*
*  This source code is licensed under the MIT license found in the
*  LICENSE file in the root directory of this source tree.
*
*/

package wavemode.immutable;

// TODO: empty out OrderedMapObject

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#end

using wavemode.immutable.Functional;
import wavemode.immutable._internal.MapType;
import haxe.Exception;

@:forward
abstract OrderedMap<K, V>(OrderedMapObject<K, V>) from OrderedMapObject<K, V> to OrderedMapObject<K, V> {

	/**
		Create a new empty OrderedMap, or a clone of the given `object`.
	**/
	public function new(?object:OrderedMap<K, V>) {
		if (object != null)
			this = object;
		else
			this = new OrderedMapObject();
	}

	/**
		Create a new `OrderedMap` from a `haxe.ds.Map`
	**/
	@:from public static function fromMap<K, V>(map:haxe.ds.Map<K, V>):OrderedMap<K, V> {
		var result = new OrderedMap();
		for (k => v in map) {
			result = result.set(k, v);
		}
		return result;
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
		Returns the value associated with the provided key, or throws an Exception
		if the OrderedMap does not contain this key.
	**/
	@:arrayAccess
	public inline function get(key: K):Null<V>
		return this.get(key);

}

private class OrderedMapObject<K, V> implements MapType<K, V>  {

	/**
		Returns a new OrderedMap containing the new (key, value) pair. If an equivalent
		key already exists in this OrderedMap, it will be replaced.
	**/
	public function set(key:K, newValue:V):OrderedMap<K, V> {
		var k = if (!_keys.contains(key)) _keys.push(key) else _keys;
		return new OrderedMapObject(_data.set(key, newValue), k);
	}

	/**
		Returns a new OrderedMap containing the all the values in `keys` set to all values
		in `values`. If any equivalent keys already exists in this OrderedMap, they will
		be replaced.

		This is equivalent to calling `set()` for each pair individually, but potentially
		more efficient.
	**/
	public function setEach(keys:Sequence<K>, values:Sequence<V>):OrderedMap<K, V> {
		var keyIter = keys.iterator(),
			valIter = values.iterator(),
			result = this;

		while (valIter.hasNext() && keyIter.hasNext())
			result = result.set(keyIter.next(), valIter.next());
		
		return result;
	}

	/**
		Returns a new OrderedMap having updated the value at this key with the return value
		of calling `updater` with the existing value.

		Similar to `map.set(key, updater(map.get(key)))`.

		If `key` does not exist, this function returns the unaltered map.
	**/
	public function update(key:K, updater:V->V):OrderedMap<K, V>
		return new OrderedMapObject(_data.update(key, updater), _keys);

	/**
		Returns a new OrderedMap having updated the values at the keys in `keys` with the
		return values of calling `updater` with the existing values.
		If any key in `keys` does not exist in the map, it is ignored.

		Equivalent to calling `update()` for each key individually, but potentially more
		efficient.
	**/
	public function updateEach(keys:Sequence<K>, updater:V->V):OrderedMap<K, V>
		return new OrderedMapObject(_data.updateEach(keys, updater), _keys);

	/**
		Returns a new OrderedMap having every instance of the given value replaced
		with the value `newVal`.

		If the value does not exist, this function returns the unaltered set.
	**/
	public function replace(value:V, newVal:V):OrderedMap<K, V>
		return new OrderedMapObject(_data.replace(value, newVal), _keys);

	/**
		Returns a new OrderedMap having the given values replaced with the values in
		`newVals`.

		If any value does not exist, the value is ignored.

		This is equivalent to calling `replace()` for every value individually, but is
		potentially more efficient, and previous replacements do not affect subsequent
		ones.
	**/
	public function replaceEach(values:Sequence<V>, newVals:Sequence<V>):OrderedMap<K, V> {
		var valIter = values.iterator(),
			newIter = newVals.iterator(),
			result = this;

		var merges = [];

		while (valIter.hasNext() && newIter.hasNext()) {
			var oldVal = valIter.next(), newVal = newIter.next();

			for (key => val in result) {
				if (val == oldVal)
					merges.push(new OrderedMap().set(key, newVal));
			}
		}

		return result.mergeEach(merges);
	}

	/**
		Returns the value associated with the provided key, or null if the OrderedMap
		does not contain this key.
	**/
	public function get(key:K):Null<V>
		return _data.get(key);
	
	/**
		True if a key exists within this OrderedMap.
	**/
	public function has(key:K):Bool
		return _data.has(key);

	/**
		True if the OrderedMap is empty.
	**/
	public function empty():Bool
		return _data.empty();

	/**
		Returns the key of a given value in the map, or null if the value does not
		exist.
	**/
	public function find(value:V):Null<K>
		return _data.find(value);

	/**
		Returns the first key at which `predicate` returns true, or null if no match
		is found.
	**/
	public function findWhere(predicate:V->Bool):Null<K>
		return _data.findWhere(predicate);

	/**
		Returns a new OrderedMap with only the entries for which the predicate
		function returns true.
	**/
		public function filter(predicate:(K, V) -> Bool):OrderedMap<K, V> {
			var ks = _keys;
			var d = _data.filter((k, v) -> {
				if (predicate(k, v)) {
					true;
				} else {
					ks = ks.remove(k);
					false;
				}
			});
			return new OrderedMapObject(d, ks);
		}

	/**
		Returns a new OrderedMap which excludes this value.
	**/
	public function remove(value:V):OrderedMap<K, V> {
		var ks = _keys;
		var d = _data.filter((k, v) -> {
			if (v != value) {
				true;
			} else {
				ks = ks.remove(k);
				false;
			}
		});
		return new OrderedMapObject(d, ks);
	}

	/**
		Returns a new OrderedMap which excludes the provided values.

		This is equivalent to calling `remove()` for each value individually, but
		potentially more efficient.
	**/
	public inline function removeEach(values:Sequence<V>):OrderedMap<K, V> {
		var ks = _keys;
		var d = _data.filter((k, v) -> {
			if (!values.contains(v)) {
				true;
			} else {
				ks = ks.remove(k);
				false;
			}
		});
		return new OrderedMapObject(d, ks);
	}

	/**
		Returns a new OrderedMap which excludes this key.
	**/
	public function delete(key:K):OrderedMap<K, V> {
		var d = _data.delete(key);
		var k = _keys.remove(key);
		return new OrderedMapObject(d, k);
	}

	/**
		Returns a new OrderedMap which excludes the provided keys.

		This is equivalent to calling `delete()` for each key individually, but
		potentially more efficient.
	**/
	public function deleteEach(keys:Sequence<K>):OrderedMap<K, V> {
		var d = _data.deleteEach(keys);
		var k = _keys.removeEach(keys);
		return new OrderedMapObject(d, k);
	}

	/**
		Returns a new OrderedMap containing no keys or values.
	**/
	public function clear():OrderedMap<K, V>
		return new OrderedMap();

	/**
		Returns a new OrderedMap resulting from merging `other` into this OrderedMap.
		In other words, this takes each entry of `other` and sets it on this OrderedMap.

		If `mergeFunction` is provided, it is used to resolve key conflicts. If not, keys
		from `other` override keys from this OrderedMap.
	**/
	public function merge(other:KeyValueIterable<K, V>, ?mergeFunction:(V, V) -> V):OrderedMap<K, V> {
		var result = this;
		for (k => v in other) {
			if (!result.has(k) || mergeFunction == null)
				result = result.set(k, v);
			else
				result = result.set(k, mergeFunction(get(k).unsafe(), v));
		}
		return result;
	}

	/**
		Returns a new OrderedMap resulting from merging each OrderedMap in `others` into
		this OrderedMap. In other words, this takes each entry of each map in `others`
		and sets it on this OrderedMap.

		If `mergeFunction` is provided, it is used to resolve key conflicts. If not, keys
		from `others` override keys from this OrderedMap, and keys from OrderedMap objects
		appearing later in the list override keys from earlier ones.

		This is equivalent to calling `merge()` for each map individually, but potentially
		more efficient.
	**/
	public function mergeEach(others:Sequence<OrderedMap<K, V>>, ?mergeFunction:(V, V) -> V):OrderedMap<K, V> { // TODO: implement
		var result = this;
		for (other in others)
			result = result.merge(other, mergeFunction);
		return result;
	}

	/**
		Returns a new OrderedMap with values passed through a mapper function.
	**/
	public function map<M>(mapper:(K, V) -> M):OrderedMap<K, M> {
		var d = _data.map(mapper);
		return new OrderedMapObject(d, _keys);
	}

	/**
		Returns a new OrderedMap with keys passed through a mapper function.
	**/
	public function mapKeys<M>(mapper:(K, V) -> M):OrderedMap<M, V> {
		var result = new OrderedMap();
		for (k => v in this)
			result = result.set(mapper(k, v), v);
		return result;
	}

	/**
		Returns the accumulation of the values in this OrderedMap according to `foldFn`,
		beginning with `initialValue`

		For example, `[1, 2, 3].fold((a, b) -> a - b, 0)` evaluates `0 - 1 - 2 - 3 = -6`
	**/
	public function fold<R>(foldFn:(R, V)->R, initialValue:R):R {
		for (k in _keys) {
			var v = get(k).unsafe();
			initialValue = foldFn(initialValue, v);
		}
		return initialValue;
	}

	/**
		A simpler form of `fold()`

		Returns the accumulation of the values in this OrderedMap according to `reducer`

		For example, `[1, 2, 3].reduce((a, b) -> a + b)` evaluates `1 + 2 + 3 = 6`

		Throws an Exception if the OrderedMap is empty.
	**/
	public function reduce(reducer:(V, V)->V):V {
		if (empty())
			throw new Exception("attempt to reduce empty OrderedMap");

		var initialValue:Null<V> = null;
		for (k in _keys) {
			var v = get(k).unsafe();
			if (initialValue == null)
				initialValue = v;
			else
				initialValue = reducer(initialValue, v);
		}
		return initialValue.unsafe();
	}

	/**
		Number of keys that are in the map. Read-only property.
	**/
	public var length(get, never):Int;
	private inline function get_length()
		return _data.length;

	/**
		Returns true if the given `predicate` is true for every value in the OrderedMap.
	**/
	public function every(predicate:V->Bool):Bool {
		for (k in _keys) {
			var v = get(k).unsafe();
			if (!predicate(v))
				return false;
		}
		return true;
	}

	/**
		Returns true if the given `predicate` is true for any value in the OrderedMap.
	**/
	public function some(predicate:V->Bool):Bool {
		for (k in _keys) {
			var v = get(k).unsafe();
			if (predicate(v))
				return true;
		}
		return false;
	}

	/**
		True if this and the `other` Map have identical keys and values.
	**/
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

	/**
		Iterator over each value in the OrderedMap.
	**/
	public function iterator():Iterator<V> {
		var it = _keys.iterator();
		return {
			hasNext: it.hasNext,
			next: () -> get(it.next()).unsafe()
		};
	}

	/**
		Iterator over each key-value pair in the OrderedMap.
	**/
	public function keyValueIterator():KeyValueIterator<K, V> {
		var it = _keys.iterator();
		return {
			hasNext: it.hasNext,
			next: () -> { 
				var k = it.next();
				{key: k, value: get(k).unsafe()};
			}
		};
	}

	/**
		An iterator of this OrderedMap's keys.
	**/
	public inline function keys():Sequence<K>
		return _keys;

	/**
		An iterator of this OrderedMap's keys. Equivalent to `iterator()`.
	**/
	public inline function values():Sequence<V>
		return iterator();

	/**
		An iterator of this OrderedMap's entries as key-value pairs.
	**/
	public inline function entries():Iterator<{key: K, value: V}>
		return keyValueIterator();

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

	public function new(?d, ?k) {
		if (d != null)
			_data = d;
		else
			_data = new Map();
		if (k != null)
			_keys = k;
		else
			_keys = new Vector();
	}

	private var _data:Map<K,V>;
	private var _keys:Vector<K>;

}
