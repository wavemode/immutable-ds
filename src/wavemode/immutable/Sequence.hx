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

    private var length:Option<Int>;
    private var cache:List<T>;

    private dynamic function _hasNext():Bool {
        return false;
    }

    private dynamic function _next():T {
        throw new Exception("attempt to read from empty Iterator");
    }

    private static inline function fromFns<T>(hn, n):Sequence<T> {
        var seq = new Sequence();
        seq._hasNext = hn;
        seq._next = n;
        return seq;
    }

    public function toString():String {
        var result = "Sequence {";
        var cut = false;

        for (v in this) {
            cut = true;
            result += ' $v,';
        }

        if (cut)
            result = result.substr(0, result.length - 1);
        return result + " }";
    }

    //////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////// API
    //////////////////////////////////////////////////////////////////////////////////////////////////////////

    /**
        Create a new empty Sequence.
    **/
    public inline function new() {
        cache = new List();
        length = None;
    }

    /**
        Create a new Sequence from an Iterable.
    **/
    public static inline function from<T>(iter:Iterable<T>):Sequence<T> {
        var it = iter.iterator();
        return fromFns(it.hasNext, it.next);
    }

    /**
        Create a new Sequence from an Iterator.
    **/
    public static inline function fromIterator<T>(it:Iterator<T>):Sequence<T> {
        var seq = new Sequence();
        return fromFns(it.hasNext, it.next);
    }

    /**
        Returns the value at position `index` in this Sequence, or None if the index is out of bounds.

        Calls to `get()` are cached internally, as the data in the underlying iterator is expected to be immutable.
    **/
    public function get(index:Int):Option<T> {

        if (index < 0) return None;

        if (cache.length > index)
            return Some(cache.getValue(index));

        while (_hasNext()) {
            cache = cache.push(_next());
            if (cache.length > index)
                return Some(cache.getValue(index));
        }

        return None;

    }

    /**
        Unsafe variant of `get()`. Returns the value at position `index` in this Sequence, or throws an Exception
        if the index is out of bounds.

        Calls to `getValue()` are cached internally, as the data in the underlying iterator is expected to be immutable.
    **/
    public function getValue(index:Int):T {

        if (index < 0) throw new Exception("index $index out of bounds for Sequence");

        if (cache.length > index)
            return cache.getValue(index);

        while (_hasNext()) {
            cache = cache.push(_next());
            if (cache.length > index)
                return cache.getValue(index);
        }

        throw new Exception("index $index out of bounds for Sequence");

    }

    /**
        Returns the first value of the Sequence, or None if the Sequence is empty.
    **/
    public inline function peek():Option<T> {
        return get(0);
    }

    /**
        Unsafe variant of `peek()`. Returns the first value of the Sequence, or throws
        an Exception if the Sequence is empty.
    **/
    public inline function peekValue():T {
        var val = get(0);
        if (val.empty()) throw new Exception("attempt to peek empty Sequence");
        return val.unwrap();
    }

    /**
        Returns a new Sequence with each element passed through `mapper`.
    **/
    public function map<M>(mapper:T->M):Sequence<M> {

        var index : Int = 0;
        var nextVal : Option<T> = None;

        function getNext():Void
            if (nextVal.empty())
                nextVal = get(index++);

        function hasNext():Bool {
            getNext();
            return !nextVal.empty();
        }

        function next():M {
            getNext();
            if (nextVal.empty()) throw new Exception("attempt to read from empty Iterator");
            var val = mapper(nextVal.unwrap());
            nextVal = None;
            return val; 
        }

        return fromFns(hasNext, next);

    }

    /**
        Returns a new Sequence with each value passed through the `mapper` function,
        then returns the flattened result.
    **/
    public function flatMap<N, M:Iterable<N>>(mapper:T->M):Sequence<N> {

        var index : Int = 0;
        var nextVal : Option<T> = None;
        var nextIter : Option<Iterator<N>> = None;
        var nextElement : Option<N> = None;

        function getNextElement():Void {

            while (true) {
                if (nextIter.empty() || !nextIter.unwrap().hasNext()) {
                    nextVal = get(index++);
                    if (nextVal.empty()) {
                        return;
                    } else {
                        nextIter = Some(mapper(nextVal.unwrap()).iterator());
                    }
                } else {
                    break;
                }
            }

            if (nextElement.empty())
                nextElement = Some(nextIter.unwrap().next());

        }

        function hasNext():Bool {
            getNextElement();
            return !nextElement.empty();
        }

        function next():N {
            getNextElement();
            if (nextElement.empty()) throw new Exception("attempt to read from empty Iterator");
            var val = nextElement;
            nextElement = None;
            return val.unwrap();
        }

        return fromFns(hasNext, next);

    }

    /**
        Returns a new Sequence with values not satisfying `predicate` removed.
    **/
    public function filter(predicate:T->Bool):Sequence<T> {

        var index : Int = 0;
        var nextVal : Option<T> = None;

        function getNext():Void
            while (true)
                if (nextVal.empty()) {
                    nextVal = get(index++);
                    if (nextVal.empty()) break;
                    else if (!predicate(nextVal.unwrap()))
                        nextVal = None;
                } else break;

        function hasNext():Bool {
            getNext();
            return !nextVal.empty();
        }

        function next():T {
            getNext();
            if (nextVal.empty()) throw new Exception("attempt to read from empty Iterator");
            var val = nextVal.unwrap();
            nextVal = None;
            return val; 
        }

        return fromFns(hasNext, next);

    }

    /**
        Returns a new Sequence in reverse order.
    **/
    public function reverse():Sequence<T> {

        var index : Int = -2;

        // defer calling count(), since it will evaluate the entire sequence
        function getNext():Void {
            if (index == -2)
                index = count() - 1;
        }

        function hasNext():Bool {
            getNext();
            return index >= 0;
        }

        function next():T {
            getNext();
            return getValue(index--);
        }

        return fromFns(hasNext, next);

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
    public function every():Sequence<T> {
        return null;
    }
    public function some():Sequence<T> {
        return null;
    }

    /**
        Returns true if this Sequence is empty.
    **/
    public function empty():Bool {
        return get(0).empty();
    }

    /**
        Counts the number of elements in the Sequence. This iterates over and caches
        every value in the Sequence.
    **/
    public function count():Int {
        if (!length.empty())
            return length.unwrap();
        var i = 0, result = get(i);
        while (!result.empty()) result = get(++i);
        length = Some(i);
        return i;
    }

    public function find() {
        return null;
    }
    public function findWhere() {
        return null;
    }
    public function has() {
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

        var index : Int = 0;
        var nextVal : Option<T> = None;

        function getNext():Void
            if (nextVal.empty())
                nextVal = get(index++);

        function hasNext():Bool {
            getNext();
            return !nextVal.empty();
        }

        function next():T {
            getNext();
            if (nextVal.empty()) throw new Exception("attempt to read from empty Iterator");
            var val = nextVal.unwrap();
            nextVal = None;
            return val; 
        }

        return { hasNext: hasNext, next: next };

    }

}

private class SequenceIterator<T> {

    private var sequence:Sequence<T>;


}