/**
*  Copyright (c) 2020-present, Chukwudi Okechukwu
*
*  This source code is licensed under the MIT license found in the
*  LICENSE file in the root directory of this source tree.
*
*/

// TODO: contains for all types

package wavemode.immutable;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#end

using wavemode.immutable.Functional;
import wavemode.immutable.util.MapType;
import wavemode.immutable.util.Trie;
import wavemode.immutable.util.Pair;
import stdlib.Exception;

@:forward
abstract Map<K, V>(MapObject<K, V>) from MapObject<K, V> to MapObject<K, V> {

	/**
		Create a new empty Map.
	**/
	public function new()
		this = new MapObject();

	/**
		Create a new `Map` from a `KeyValueIterable`
	**/
	@:from public static function fromMap<K, V>(map:KeyValueIterable<K, V>):Map<K, V> {
		var map = new Map();
		for (k => v in map)
			map = map.set(k, v);
		return map;
	}

	/**
		Macro which creates a new `Map` from a struct literal.

		```haxe
		Map.make({a: 10, b: 5})
		```

		is equivalent to

		```haxe
		new Map().set("a", 10).set("b", 5)
		```
	**/
	public static macro function make<K, V>(expr:Expr):ExprOf<Map<K, V>> {
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
			var result = new Map();
			$a{arrExprs}
			result;
		}
		return expr;
	}

	private var data(get, never):Trie<K,V>;
	private function get_data() return this.data;

}

private class MapObject<K, V> implements MapType<K, V> {

	/**
		Returns a new Map containing the new (key, value) pair. If an equivalent key already
		exists in this Map, it will be replaced.
	**/
	public function set(key:K, newValue:V):Map<K, V> {
		var h = hash(key);
		var map = new MapObject(hash);
		map.data = data.copyInsert(h, new Pair(key, newValue));
		return map;
	}

	/**
		Returns a new Map containing the all the values in `keys` set to all values in `values`.
		If any equivalent keys already exists in this Map, they will be replaced.

		This is equivalent to calling `set()` for each pair individually, but potentially more
		efficient.
	**/
	public function setEach(keys:Sequence<K>, values:Sequence<V>):Map<K, V> {
		if (keys.empty())
			return this;
		else
			initHash(keys[0]);
		var map = new MapObject(hash);
		map.data = data.copyInsertEach(keys.map(hash).toArray(), values.mapIndex((i, v) -> new Pair(keys[i], values[i])).toArray());
		return map;
	}

	/**
		Returns a new Map having updated the value at this key with the return value of calling `updater`
		with the existing value.

		Similar to `map.set(key, updater(map.get(key)))`.

		If `key` does not exist, this function returns the unaltered map.
	**/
	public function update(key:K, updater:V->V):Map<K, V> {
		var h = hash(key);
		var map = new MapObject(hash);
		map.data = data.copyUpdate(h, key, updater);
		return map;
	}

	/**
		Returns a new Map having updated the values at the keys in `keys` with the return values of calling
		`updater` with the existing values. If any key in `keys` does not exist in the map, it is ignored.

		Equivalent to calling `update()` for each key individually, but potentially more efficient.
	**/
	public function updateEach(keys:Sequence<K>, updater:V->V):Map<K, V> {
		if (keys.empty())
			return this;
		else
			initHash(keys[0]);
		var map = new MapObject(hash);
		map.data = data.copyUpdateEach([for (k in keys) hash(k)], keys.toArray(), updater);
		return map;
	}

	/**
		Returns a new Map having every instance of the given value replaced with the value `newVal`.

		If the value does not exist, this function returns the unaltered set.
	**/
	public function replace(value:V, newVal:V):Map<K, V>
		throw new Exception("not implemented");

	/**
		Returns a new Map having the given values replaced with the values in `newVals`.

		If any value does not exist, the value is ignored.

		This is equivalent to calling `replace()` for every value individually, but is
		potentially more efficient, and previous replacements do not affect subsequent
		ones.
	**/
	public function replaceEach(values:Iterable<V>, newVals:Iterable<V>):Map<K, V>
		throw new Exception("not implemented");

	/**
		Returns the value associated with the provided key, or null if the Map does not contain this key.
	**/
	public function get(key:K):Null<V>
		return data.retrieve(hash(key), key);
	
	/**
		True if a key exists within this Map.
	**/
	public function has(key:K):Bool
		throw new Exception("not implemented");

	/**
		True if the Map is empty.
	**/
	public function empty():Bool
		throw new Exception("not implemented");

	/**
		Returns the key of a given value in the map, or null if the value does not exist.
	**/
	public function find(value:V):Null<K>
		throw new Exception("not implemented");

	/**
		Returns the first key at which `predicate` returns true, or null if no match is found.
	**/
	public function findWhere(predicate:V->Bool):Null<K>
		throw new Exception("not implemented");

	/**
		Returns a new Map with only the entries for which the predicate function returns true.
	**/
		public function filter(predicate:(K, V) -> Bool):Map<K, V>
			throw new Exception("not implemented");

	/**
		Returns a new Map which excludes this value.
	**/
	public function remove(value:V):Map<K, V>
		throw new Exception("not implemented");

	/**
		Returns a new Map which excludes the provided values.

		This is equivalent to calling `remove()` for each value individually, but potentially more
		efficient.
	**/
	public inline function removeEach(values:Iterable<V>):Map<K, V>
		throw new Exception("not implemented");

	/**
		Returns a new Map which excludes this key.
	**/
	public function delete(key:K):Map<K, V>
		throw new Exception("not implemented");

	/**
		Returns a new Map which excludes the provided keys.

		This is equivalent to calling `delete()` for each key individually, but potentially more
		efficient.
	**/
	public function deleteEach(keys:Iterable<K>):Map<K, V>
		throw new Exception("not implemented");

	/**
		Returns a new Map containing no keys or values.
	**/
	public function clear():Map<K, V>
		throw new Exception("not implemented");


	/**
		Returns a new Map resulting from merging `other` into this Map. In other words, this
		takes each entry of `other` and sets it on this Map.

		If `mergeFunction` is provided, it is used to resolve key conflicts. If not, keys from
		`other` override keys from this Map.
	**/
	public function merge(other:Map<K, V>, ?mergeFunction:(V, V) -> V):Map<K, V>
		throw new Exception("not implemented");

	/**
		Returns a new Map resulting from merging each Map in `others` into this Map. In other words,
		this takes each entry of each map in `others` and sets it on this Map.

		If `mergeFunction` is provided, it is used to resolve key conflicts. If not, keys from
		`others` override keys from this Map, and keys from Map objects appearing later in the
		list override keys from earlier ones.

		This is equivalent to calling `merge()` for each map individually, but potentially more
		efficient.
	**/
	public function mergeEach(others:Iterable<Map<K, V>>, ?mergeFunction:(V, V) -> V):Map<K, V>
		throw new Exception("not implemented");

	/**
		Returns a new Map with values passed through a mapper function.
	**/
	public function map<M>(mapper:(K, V) -> M):Map<K, M>
		throw new Exception("not implemented");

	/**
		Returns a new Map with keys passed through a mapper function.
	**/
	public function mapKeys<M>(mapper:(K, V) -> M):Map<M, V>
		throw new Exception("not implemented");


	/**
		Returns the accumulation of the values in this Map according to `foldFn`, beginning
		with `initialValue`

		For example, `[1, 2, 3].fold((a, b) -> a - b, 0)` evaluates `0 - 1 - 2 - 3 = -6`
	**/
	public function fold<R>(foldFn:(R, V)->R, initialValue:R):R
		throw new Exception("not implemented");

	/**
		A simpler form of `fold()`

		Returns the accumulation of the values in this Map according to `reducer`

		For example, `[1, 2, 3].reduce((a, b) -> a + b)` evaluates `1 + 2 + 3 = 6`

		Throws an Exception if the Map is empty.
	**/
	public function reduce(reducer:(V, V)->V):V
		throw new Exception("not implemented");

	/**
		Number of keys that are in the map. Read-only property.
	**/
	public var length(default, null):Int;

	/**
		Returns true if the given `predicate` is true for every value in the Map.
	**/
	public function every(predicate:V->Bool):Bool
		throw new Exception("not implemented");

	/**
		Returns true if the given `predicate` is true for any value in the Map.
	**/
	public function some(predicate:V->Bool):Bool
		throw new Exception("not implemented");

	/**
		True if this and the `other` Map have identical keys and values.
	**/
	public function equals<T:MapType<K, V>>(other:T):Bool
		throw new Exception("not implemented");
	/**
		The `sideEffect` is executed for every entry in the Map.
	**/
	public function forEach(sideEffect:(K, V) -> Void):Void
		throw new Exception("not implemented");

	/**
		Iterator over each value in the Map.
	**/
	public function iterator():Iterator<V>
		throw new Exception("not implemented");

	/**
		Iterator over each key-value pair in the Map.
	**/
	public function keyValueIterator():KeyValueIterator<K, V>
		throw new Exception("not implemented");

	/**
		An iterator of this Map's keys.
	**/
	public function keys():Iterator<K>
		throw new Exception("not implemented");

	/**
		An iterator of this Map's keys. Equivalent to `iterator()`.
	**/
	public inline function values():Iterator<V>
		throw new Exception("not implemented");

	/**
		An iterator of this Map's entries as key-value pairs.
	**/
	public inline function entries():Iterator<{key: K, value: V}>
		throw new Exception("not implemented");

	/**
		Shallowly converts this Map to an Array.
	**/
	public inline function toArray():Array<V>
		throw new Exception("not implemented");

	/**
		Converts this Map to a Map.
	**/
	public inline function toOrderedMap():OrderedMap<K, V>
		throw new Exception("not implemented");

	/**
		Converts this Map to a Vector, discarding keys.
	**/
	public inline function toVector():Vector<V>
		throw new Exception("not implemented");

	/**
		Converts this Map to a Set, discarding keys.
	**/
	public inline function toSet():Set<V>
		throw new Exception("not implemented");

	/**
		Converts this Map to an OrderedSet, discarding keys.
	**/
	public inline function toOrderedSet():OrderedSet<V>
		throw new Exception("not implemented");

	/**
		Converts this Map to a Sequence, discarding keys.
	**/
	public inline function toSequence():Sequence<V>
		throw new Exception("not implemented");

	/**
		Convers this Map to its String representation.
	**/
	public function toString():String
		throw new Exception("not implemented");

	public function new(?hashFn:K->Int) {
		data = new Trie();
		length = 0;
		if (hashFn != null)
			hash = hashFn;
		else
			hash = initHash;
	}

	public var data:Trie<K,V>;
	private var hash:K->Int;
	
	private function initHash(val:Dynamic):Int {
		if (Std.is(val, String))
			return (hash = cast stringHash)(val);
		else if (Std.is(val, Int))
			return (hash = cast intHash)(val);
		else
			return (hash = dynamicHash)(val);
	}

	private static function dynamicHash(val:Dynamic):Int {
		if (val.hashCode != null)
			return val.hashCode();
		else {
			return stringHash(Std.string(val));
		}
	}

	private static function stringHash(str:String):Int {
		/*
			credit: Dark Sky
			https://github.com/darkskyapp/string-hash
		*/
		var hash = 5381,
			i    = str.length;

		while(i > 0)
			@:nullSafety(Off) hash = (hash * 33) ^ str.charCodeAt(--i);

		return hash;
	}

	private static function intHash(num:Int):Int {
		/*
			credit: Thomas Wang
			http://burtleburtle.net/bob/hash/integer.html
		*/
		num = (num ^ 61) ^ (num >> 16);
		num = num + (num << 3);
		num = num ^ (num >> 4);
		num = num * 0x27d4eb2d;
		num = num ^ (num >> 15);
		return num;
	}

}
