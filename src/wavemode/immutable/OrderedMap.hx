package wavemode.immutable;

#if macro
import haxe.macro.Expr;
#end

import haxe.ds.Map as HxMap;
import haxe.ds.Option;

abstract OrderedMap<K, V>(Array<{k: K, v: V}>) from Array<{k: K, v: V}> {

    public static macro function from(expr : Expr) : Expr { // TODO: implement
        return macro null;
    }

    @:from public static function fromMap<K, V>(?map : HxMap<K, V>) : OrderedMap<K, V> {
        var result = [];
        if (map != null) {
            for (k => v in map) result.push({k: k, v: v});
        }
        return result;
    }
    /**
        Returns a new Map containing the new (key, value) pair. If an equivalent key already 
        exists in this Map, it will be replaced.

        ```haxe
        var originalMap = new Map<String, String>(); // Map {}
        var newerMap = originalMap.set("key", "value"); // Map { "key": "value" }
        var newestMap = newerMap.set("key", "newer value"); // Map { "key": "newer value" }
        ```
    **/

    public function set(key: K, value: V): OrderedMap<K, V> { // TODO: implement
        return null;
    }

    /**
        Returns a new Map which excludes this key. 

        ```haxe
        var originalMap : Map<String, String> = ["key" => "value", "otherKey" => "other value"];
        var newMap = originalMap.remove("otherKey"); // OrderedMap { "key": "value" }
        ```
    **/
    public function remove(key: K): OrderedMap<K, V> { // TODO: implement
        var originalMap = OrderedMap.fromMap(["key" => "value", "otherKey" => "other value"]);
        var newMap = originalMap.removeAll(["other value", "value"]); // OrderedMap {}
        return null;
    }

    /**
        Returns a new Map which excludes this value. 
        
        ```haxe
        var originalMap : Map<String, String> = ["key" => "value", "otherKey" => "other value"];
        var newMap = originalMap.removeValue("other value"); // OrderedMap { "key": "value" }
        ```
    **/
    public function removeValue(value : V): OrderedMap<K, V> { // TODO: implement
        return null;
    }

    /**
        Returns a new Map which excludes the provided keys.

        ```haxe
        var names : OrderedMap<String, String> = [ "a" => "Aaron", "b" => "Barry", "c" => "Connor" ];
        var newNames = names.removeAll([ "a", "c" ]); // OrderedMap { "b": "Barry" }
        ```
    **/
    public macro function removeAll(ethis : Expr, keys: ExprOf<Iterable<K>>) : ExprOf<OrderedMap<K, V>> { // TODO: implement
        return macro {
            var map = $e{ethis};
            for (key in $e{keys}) {
                var hash : Hash = key;
                map = map.remove(key);
            }
            map;
        }
    }

    /**
        Returns a new Map which excludes the provided values. 
        
        ```haxe
        var originalMap : Map<String, String> = ["key" => "value", "otherKey" => "other value"];
        var newMap = originalMap.removeAllValues(["other value", "value"]); // OrderedMap {}
        ```
    **/
    public inline function removeAllValues(values : Iterable<V>): OrderedMap<K, V> {
        var map : OrderedMap<K, V> = this;
        for (value in values) map = map.removeValue(value);
        return map;
    }

    /**
        Returns a new Map containing no keys or values.

        ```haxe
        var map : Map<String, String> = ["key" => "value" ];
        var clearedMap = map.clear(); // Map {}
        ```
    **/
    public function clear() : OrderedMap<K, V> { // TODO: implement
        return null;
    }

    /**
        Returns a new Map having updated the value at this key with the return value of calling `updater` with the existing value.
    
        Similar to `map.set(key, updater(map.get(key)))`.

        ```haxe
        var aMap : Map<String, String> = ["key" => "value"];
        var newMap = aMap.update("key", value -> value + value); // Map { "key": "valuevalue" }
        ```

        If `key` does not exist, this function returns the unaltered map.
    **/
    public function update(key: K, updater: V -> V): OrderedMap<K, V> { // TODO: implement
        return null;
    }

    /**
        Returns a new Map resulting from merging `other` into this Map. In other words, this 
        takes each entry of `other` and sets it on this Map.
        
        If `mergeFunction` is provided, it is used to resolve key conflicts. If not, keys from
        `other` override keys from this Map.

        ```haxe
        var one : Map<String, Float> = ["a" => 10, "b" => 20, "c" => 30 ];
        var two : Map<String, Float> = ["b" => 40, "a" => 50, "d" => 60 ];

        var three = one.merge(two);
        // Map { "a": 50, "b": 40, "c": 30, "d": 60 }
        
        var four = one.mergeWith(two, (oldVal, newVal) -> oldVal / newVal);
        // Map { "a": 0.2, "b": 0.5, "c": 30, "d": 60 }
        ```
    **/
    public function merge(other: OrderedMap<K, V>, ?mergeFunction : (V, V) -> V) : OrderedMap<K, V> { // TODO: implement
        return null;
    }

    /**
        Returns a new Map resulting from merging each Map in `others` into this Map. In other words, this 
        takes each entry of each map in `others` and sets it on this Map.
        
        If `mergeFunction` is provided, it is used to resolve key conflicts. If not, keys from
        `others` override keys from this Map, and keys from Map objects appearing later in the
        list override keys from earlier ones.

        ```haxe
        var one : Map<String, Float> = ["a" => 10, "b" => 20, "c" => 30 ];
        var two : Map<String, Float> = ["b" => 40, "a" => 50, "d" => 60 ];
        var three : Map<String, Float> = ["d" => 80, "e" => 70, "f" => 100 ];

        var four = one.mergeAll([two, three]);
        // Map { "a": 50, "b": 40, "c": 30, "d": 80, "e": 70, "f": 100 }
        ```
    **/
    public function mergeAll(others : Array<OrderedMap<K, V>>, ?mergeFunction : (V, V) -> V) : OrderedMap<K, V> { // TODO: implement
        return null;
    }

    /**
        Returns a new Map with values passed through a mapper function.

        ```haxe
        var aMap : Map<String, Int> = ["a" => 1, "b": 2 ];
        var newMap = aMap.map(x -> 10 * x); // Map { a: 10, b: 20 }
        ```
    **/
    public function map<M>(mapper: V -> M): OrderedMap<K, M> { // TODO: implement
        return null;
    }

    /**
        Returns a new Map with values passed through a mapper function.
        Same as `map` except the mapper function takes a key as well.

        ```haxe
        var aMap : Map<String, Int> = ["a" => 1, "b": 2 ];
        var newMap = aMap.mapWithKey((k, v) -> 10 * v); // Map { a: 10, b: 20 }
        ```
    **/
    public function mapWithKey<M>(mapper: (K, V) -> M): OrderedMap<K, M> { // TODO: implement
        return null;
    }

    /**
        Returns a new Map with keys passed through a mapper function.

        ```haxe
        var aMap : Map<String, Int> = ["a" => 1, "b": 2 ];
        var newMap = aMap.mapKeys((k, v) -> v + "a"); // Map { aa: 1, ba: 2 }
        ```
    **/
    public function mapKeys<M>(mapper: (K, V) -> M): OrderedMap<M, V> { // TODO: implement
        return null;
    }

    
    /**
        Returns a new Map with (key, value) entries passed through a mapper function.

        ```haxe
        var aMap : Map<String, Int> = ["a" => 1, "b": 2 ];
        var newMap = aMap.mapEntries((k, v) -> {k: v, v: k + "aa"}); // Map { 1: aaa, 2: baa }
        ```
    **/
    public function mapEntries<MK, MV>(mapper: (K, V) -> {k: MK, v: MV}): OrderedMap<MK, MV> { // TODO: implement
        return null;
    }

    /**
        Returns a new Map with only the entries for which the predicate function returns true.

        ```haxe
        var aMap : Map<String, Int> = ["a" => 1, "b" => 2, "c" => 3, "d" => 4];
        var newMap = aMap.filter((x) -> x % 2 === 0); // Map { b: 2, d: 4 }
        ```
    **/
    public function filter(predicate: V -> Bool) : OrderedMap<K, V> { // TODO: implement
        return null;
    }

    /**
        Returns a new Map with only the entries for which the predicate function returns true.
        Same as `filter` except the predicate function takes a key as well.

        ```haxe
        var aMap : Map<String, Int> = ["a" => 1, "b" => 2, "c" => 3, "d" => 4];
        var newMap = aMap.filterWithKey((k, x) -> x % 2 == 0); // Map { b: 2, d: 4 }
        ```
    **/
    public function filterWithKey(predicate: (K, V) -> Bool) : OrderedMap<K, V> { // TODO: implement
        return null;
    }

    /**
        Returns a new Map where the keys and values have been flipped.

        ```haxe
        var aMap = ["a" => "z", "b" => "y"];
        var newMap = aMap.flip(); // Map { "z": "a", "y": "b" }
        ```
    **/
    public function flip(): OrderedMap<V, K> { // TODO: implement
        return null;
    }

    /**
        Shallowly converts this Map to an Array.
    **/
    public function toArray(): Array<V> { // TODO: implement
        return null;
    }

    /**
        Shallowly converts this Map to an Array of key-value pairs.
    **/
    public function toArrayKV(): Array<{k: K, v: V}> { // TODO: implement
        return null;
    }

    /**
        Returns a Sequence of values in this Map.
    **/
    public function toSequence(): Sequence<V> { // TODO: implement
        return null;
    }

    /**
        Returns a Sequence of key-value pairs in this Map.
    **/
    public function toSequenceKV(): Sequence<{k: K, v: V}> { // TODO: implement
        return null;
    }

    /**
        True if this and the other Map have identical keys and values.
    **/
    public function equals(other: Map<K, V>): Bool { // TODO: implement
        return null;
    }

    /**
        Returns the value associated with the provided key, or None if the Map does not contain this key.
    **/
    public function get(key: K): Option<V> { // TODO: implement
        return null;
    }

    /**
        True if a key exists within this Map.
    **/
    public function has(key: K): Bool { // TODO: implement
        return null;
    }

    /**
        True if a value exists within this Map.
    **/
    public function hasValue(value: V) : Bool {
        return null;
    }


    /**
        Returns the first value in the OrderedMap, or None if it is empty.
    **/
    public function first() : Option<V> { // TODO: implement
        return null;
    }

    /**
        Returns the last value in the OrderedMap, or None if it is empty.
    **/
    public function last() : Option<V> { // TODO: implement
        return null;
    }

    /**
        Converts this OrderedMap to a Map.
    **/
    @:to public function toMap(): Map<K, V> { // TODO: implement
        return null;
    }
    
    /**
        Converts this Map to a Set, discarding keys. Returns None if values are not hashable.
    **/
    public function toSet(): Option<Set<V>> { // TODO: implement
        return null;
    }

    /**
        Converts this map to an OrderedSet, maintaining value order but discarding keys. Returns None if values are not hashable.
    **/
    public function toOrderedSet(): Option<OrderedSet<V>> { // TODO: implement
        return null;
    }

    /**
        Converts this Map to a List, discarding keys.

        ```haxe
        var myMap = Map.from({ a: "Apple", b: "Banana" })
        var newMap = myMap.toList(); // List [ "Apple", "Banana" ]
        ```
    **/
    public function toList(): List<V> { // TODO: implement
        return null;
    }

    /**
        Converts this Collection to a Stack, discarding keys. Returns None if values are not hashable.
    **/
    public function toStack(): Option<Stack<V>> { // TODO: implement
        return null;
    }

    /**
        An iterator of this Map's keys.
    **/
    public function keys(): Iterator<K> { // TODO: implement
        return null;
    }

    /**
        An iterator of this Map's keys. Equivalent to `iterator()`.
    **/
    public function values(): Iterator<V> { // TODO: implement
        return null;
    }

    /**
        An iterator of this Map's entries as key-value pairs.
    **/
    public function entries(): Iterator<{k: K, v: V}> { // TODO: implement
        return null;
    }

    /**
        Returns a new Sequence of the keys of this Map, discarding values.
    **/
    public function toSequenceKeys(): Sequence<K> { // TODO: implement
        return null;
    }

    /**
        The `sideEffect` is executed for every entry in the Map.
    **/
    public function forEach(sideEffect: (K, V) -> Void) : Void {
        var map : OrderedMap<K, V> = this;
        for (k => v in map) sideEffect(k, v);
    }

    /**
        The `sideEffect` is executed for every entry in the Map. Iteration stops once `sideEffect` returns false.
        
        This function returns the number of times `sideEffects` was executed.
    **/
    public function forWhile(sideEffect: (K, V) -> Bool) : Int {
        var map : OrderedMap<K, V> = this, i = 0;
        for (k => v in map) {
            sideEffect(k, v);
            ++i;
        }
        return i;
    }

    public function iterator() : Iterator<V> {
        return null;
    }

    public function keyValueIterator() : KeyValueIterator<K, V> {
        return null;
    }

    public function toString() : String {
        var result = "OrderedMap {";
        var map : OrderedMap<K, V> = this;
        var cut = false;

        for (k => v in map) {
            cut = true;
            result += ' $k: $v,';
        }

        if (cut) result = result.substr(0, result.length - 1);
        return result + " }";
    }

}