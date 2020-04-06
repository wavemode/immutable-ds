/**
 *  Copyright (c) 2020-present, Chukwudi Okechukwu
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the root directory of this source tree.
 *
 */

package wavemode.immutable;

using wavemode.immutable.Functional;
import haxe.ds.Option;

import stdlib.Exception;

class Sequence<T> {

    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////// API
    //////////////////////////////////////////////////////////////////////////////////////////////////////////

    public inline function new(hasNext:()->Bool, next:()->T) {
        hn = hasNext;
        n = next;
    }

    public static inline function from<T>(iter:Iterable<T>):Sequence<T> {
        var it = iter.iterator();
        return new Sequence(it.hasNext, it.next);
    }

    public static inline function fromIterator<T>(it:Iterator<T>):Sequence<T> {
        return new Sequence(it.hasNext, it.next);
    }

    private final hn : () -> Bool;
    private final n : () -> T;

    /**
        Returns true if this Sequence still has values.
    **/
    public function hasNext() : Bool {
        return hn();
    }

    /**
        Returns the next value in the Sequence. Throws an Exception if the Sequence is out of values.
    **/
    public function next() : T {
        if (!hn()) throw new Exception("attempted to read value from empty Sequence");
        return n();
    }

    /**
        Returns a new Sequence with each element passed through `mapper`
    **/
    public function map<M>(mapper:T->M):Sequence<M> {
        return new Sequence(hasNext, () -> mapper(next()));
    }

    /**
        Returns a new Sequence with each value passed through the `mapper` function,
        then returns the flattened result.
    **/
    public function flatMap<N, M:Iterable<N>>(mapper:T->M):Sequence<N> {
        return null;
    }
    public function filter():Sequence<T> {
        return null;
    }
    public function reverse():Sequence<T> {
        return null;
    }
    public function sort():Sequence<T> {
        return null;
    }
    public function group():Sequence<T> {
        return null;
    }
    public function replace():Sequence<T> {
        return null;
    }
    public function replaceEach():Sequence<T> {
        return null;
    }
    public function set():Sequence<T> {
        return null;
    }
    public function setEach():Sequence<T> {
        return null;
    }
    public function update():Sequence<T> {
        return null;
    }
    public function updateEach():Sequence<T> {
        return null;
    }
    public function slice():Sequence<T> {
        return null;
    }
    public function splice():Sequence<T> {
        return null;
    }
    public function drop():Sequence<T> {
        return null;
    }
    public function dropLast():Sequence<T> {
        return null;
    }
    public function dropWhile():Sequence<T> {
        return null;
    }
    public function dropUntil():Sequence<T> {
        return null;
    }
    public function take():Sequence<T> {
        return null;
    }
    public function takeLast():Sequence<T> {
        return null;
    }
    public function takeWhile():Sequence<T> {
        return null;
    }
    public function takeUntil():Sequence<T> {
        return null;
    }
    public function concat():Sequence<T> {
        return null;
    }
    public function concatEach():Sequence<T> {
        return null;
    }
    public function reduce():Sequence<T> {
        return null;
    }
    public function reduceRight():Sequence<T> {
        return null;
    }
    public function equals():Sequence<T> {
        return null;
    }
    public function get():Sequence<T> {
        return null;
    }
    public function getValue():Sequence<T> {
        return null;
    }
    public function every():Sequence<T> {
        return null;
    }
    public function some():Sequence<T> {
        return null;
    }
    public function empty():Sequence<T> {
        return null;
    }
    public function count():Sequence<T> {
        return null;
    }
    public function find() {
        return null;
    }
    public function findWhere() {
        return null;
    }
    public function toArray():Sequence<T> {
        return null;
    }
    public function toMap():Sequence<T> {
        return null;
    }
    public function toOrderedMap():Sequence<T> {
        return null;
    }
    public function toSet():Sequence<T> {
        return null;
    }
    public function toOrderedSet():Sequence<T> {
        return null;
    }
    public function toList():Sequence<T> {
        return null;
    }
    public function toStack():Sequence<T> {
        return null;
    }
    public function entries():Sequence<Pair<Int,T>> {
        return null;
    }
    public function iterator():Iterator<T> {
        return this;
    }

}
