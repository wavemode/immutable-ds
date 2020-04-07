/**
 *  Copyright (c) 2020-present, Chukwudi Okechukwu
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the root directory of this source tree.
 *
 */

package wavemode.immutable;

import stdlib.Exception;

using wavemode.immutable.Functional;

// TODO: Sequence.range
// TODO: Sequence.repeat
// TODO: Sequence.step

class Sequence<T> {

    private var cache:List<T>;
    private var cacheComplete:Bool;

    private inline function _cacheExpand(index:Int):Bool {

        if (cacheComplete)
            return _cacheLength() > index;

        while (_cacheLength() <= index && 
            if (_hn()) {
                true;
            } else {
                _hn = () -> false;
                _n = null;
                cacheComplete = true;
                false;
            })
        {
            cache = cache.push(_n().sure());
        }

        return _cacheLength() > index;

    }

    private inline function _cacheLength():Int
        return cache.length;

    private inline function _cacheGet(index:Int):T
        return cache.getValue(index);

    private var _hn : () -> Bool = () -> false;
    private var _n : Null<() -> T> = null;

    private static inline function fromFns<T>(hn:()->Bool, n:()->T):Sequence<T> {
        var seq = new Sequence();
        seq._hn = hn;
        seq._n = n;
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
        cacheComplete = false;
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
        Returns the value at position `index` in this Sequence, or null if the index is out of bounds.

        Calls to `get()` are cached internally, as the data in the underlying iterator is expected to be immutable.
    **/
    public function get(index:Int):Null<T>
        if (_cacheExpand(index))
            return _cacheGet(index);
        else
            return null;

    /**
        Unsafe variant of `get()`. Returns the value at position `index` in this Sequence, or throws an Exception
        if the index is out of bounds.

        Calls to `getValue()` are cached internally, as the data in the underlying iterator is expected to be immutable.
    **/
    public function getValue(index:Int):T
        if (_cacheExpand(index))
            return _cacheGet(index).sure();
        else
            throw new Exception('index $index out of bounds for Sequence');



    /**
        Returns the first value of the Sequence, or null if the Sequence is empty.

        Equivalent to `get(0)`
    **/
    public inline function peek():Null<T>
        return get(0);

    /**
        Unsafe variant of `peek()`. Returns the first value of the Sequence, or throws
        an Exception if the Sequence is empty.

        Equivalent to `getValue(0)`
    **/
    public inline function peekValue():T {
        var val = get(0);
        if (val == null) throw new Exception("attempt to peek empty Sequence");
        return val.sure();
    }

    /**
        Returns a new Sequence with each element passed through `mapper`.
    **/
    public function map<M>(mapper:T->M):Sequence<M> {

        var index : Int = 0;
        var nextVal : Null<T> = null;

        function getNext():Void
            if (nextVal == null)
                nextVal = get(index++);

        function hasNext():Bool {
            getNext();
            return nextVal != null;
        }

        function next():M {
            getNext();
            if (nextVal == null) throw new Exception("attempt to read from empty Iterator");
            var val = mapper(nextVal.sure());
            nextVal = null;
            return val; 
        }

        return fromFns(hasNext, next);

    }

    /**
        Returns a new Sequence with each index and corresponding element passed through `mapper`.
    **/
    public function mapWithIndex<M>(mapper:(Int,T)->M):Sequence<M> {

        var index : Int = 0;
        var nextVal : Null<T> = null;

        function getNext():Void
            if (nextVal == null)
                nextVal = get(index++);

        function hasNext():Bool {
            getNext();
            return nextVal != null;
        }

        function next():M {
            getNext();
            if (nextVal == null) throw new Exception("attempt to read from empty Iterator");
            var val = mapper(index, nextVal.sure());
            nextVal = null;
            return val; 
        }

        return fromFns(hasNext, next);

    }

    /**
        `mapper` is a function that returns an Iterable type (Array, List, Map, etc.)
            
        `flatMap` creates a new Sequence with each value passed through the `mapper`
        function, then flattens the result. 

        For example, `[1, 2, 3].flatMap(x -> [x*2, x*10])` returns `[2, 10, 4, 20, 6, 30]`
    **/
    public function flatMap<N, M:Iterable<N>>(mapper:T->M):Sequence<N> {

        var index : Int = 0;
        var nextVal : Null<T> = null;
        var nextIter : Null<Iterator<N>> = null;
        var nextElement : Null<N> = null;

        function getNextElement():Void {
            while (true)
                if (nextIter == null || !nextIter.sure().hasNext()) {
                    nextVal = get(index++);
                    if (nextVal == null)
                        return;
                    else
                        nextIter = mapper(nextVal.sure()).iterator();
                } else break;

            if (nextElement == null)
                nextElement = nextIter.sure().next();

        }

        function hasNext():Bool {
            getNextElement();
            return nextElement != null;
        }

        function next():N {
            getNextElement();
            if (nextElement == null)
                throw new Exception("attempt to read from empty Iterator");
            var val = nextElement.sure();
            nextElement = null;
            return val;
        }

        return fromFns(hasNext, next);

    }

    /**
        Returns a new Sequence with values not satisfying `predicate` removed.
    **/
    public function filter(predicate:T->Bool):Sequence<T> {

        var index : Int = 0;
        var nextVal : Null<T> = null;

        function getNext():Void
            while (true)
                if (nextVal == null) {
                    nextVal = get(index++);
                    if (nextVal == null)
                        return;
                    else if (!predicate(nextVal.sure()))
                        nextVal = null;
                } else break;

        function hasNext():Bool {
            getNext();
            return nextVal != null;
        }

        function next():T {
            getNext();
            if (nextVal == null)
                throw new Exception("attempt to read from empty Iterator");
            var val = nextVal.sure();
            nextVal = null;
            return val; 
        }

        return fromFns(hasNext, next);

    }

    /**
        Returns a new Sequence in reverse order.
    **/
    public function reverse():Sequence<T> {

        var index : Int = -1;

        function getCount():Void
            if (index == -1)
                index = count();

        function hasNext():Bool {
            getCount();
            return index > 0;
        }

        function next():T {
            getCount();
            return getValue(--index);
        }

        return fromFns(hasNext, next);

    }

    /**
        Returns a sorted Sequence according to the comparison function `f`, where
        `f(x,y)` returns a positive integer if `x` should be before `y`, a negative
        integer if `x` should be after `y`, and zero if the values are equivalent.

        For example, `[5, 4, 3, 2, 1].sort((x, y) -> y - x)` returns `[1, 2, 3, 4, 5]`
    **/
    public function sort(f:(T,T)->Int):Sequence<T> {

        var sortedSequence : Null<Array<T>> = null;
        var index = -1;

        function getSequence():Void
            if (index == -1) {
                var c = count(), seq = [];
                seq.resize(c);
                for (i in 0...c) seq[i] = getValue(i);
                seq.sort(f);
                sortedSequence = seq;
                index = c;
            }

        function hasNext():Bool {
            getSequence();
            return index > 0;
        }

        function next():T {
            getSequence();
            return sortedSequence.sure()[--index];
        }

        return fromFns(hasNext, next);

    }

    /**
        Returns a Sequence sorted ascending numerically.
    **/
    public macro function sortAsc(ethis:ExprOf<Sequence<T>>):ExprOf<Sequence<T>>
        return macro {
            $e{ethis}.sort((a, b) -> b - a);
        };

    /**
        Returns a Sequence sorted descending numerically.
    **/
    public macro function sortDesc(ethis:ExprOf<Sequence<T>>):ExprOf<Sequence<T>>
        return macro {
            $e{ethis}.sort((a, b) -> a - b);
        };

    /**
        Returns a Sequence of Sequences, with elements grouped according to the return value of `grouper`.

        For example, `[1, 2, 3, 4, 5].group(x -> x % 2)` results in `[[1, 3, 5], [2, 4]]`
    **/
    public function group<M>(grouper:T->M):Sequence<Sequence<T>> {

        var categories:Array<M> = [];
        var buckets:Array<Array<T>> = [];
        var nextVal:Null<T> = null;
        var readIndex:Int = 0;

        function categorizeNext():Bool {
            nextVal = get(readIndex++);
            if (nextVal == null) {
                return false;
            } else {
                var value = nextVal.sure();
                var cat = grouper(value);
                var catIndex = categories.indexOf(cat);
                if (catIndex == -1) {
                    categories.push(cat);
                    buckets.push([value]);
                } else {
                    buckets[catIndex].push(value);
                }
                return true;
            }
        }

        function getNth(nth:Int, index:Int):Null<T> {

            while (nth >= buckets.length || index >= buckets[nth].length)
                if (!categorizeNext())
                    return null;

            return buckets[nth][index];

        }

        function getSequence(nth:Int):Null<Sequence<T>> {

            if (getNth(nth, 0) == null)
                return null;

            var index = 0;
            var nextVal:Null<T> = null;

            function getVal():Void
                if (nextVal == null)
                    nextVal = getNth(nth, index++);

            function hasNext():Bool {
                getVal();
                return nextVal != null;
            }

            function next():T {
                getVal();
                if (nextVal == null)
                    throw new Exception("attempt to read from empty Iterator");
                var val = nextVal.sure();
                nextVal = null;
                return val;
            }

            return fromFns(hasNext, next);

        }

        var groupIndex = 0;
        var nextGroup:Null<Sequence<T>> = null;

        function getGroup():Void
            if (nextGroup == null)
                nextGroup = getSequence(groupIndex++);

        function hasNext():Bool {
            getGroup();
            return nextGroup != null;
        }

        function next():Sequence<T> {
            getGroup();
            if (nextGroup == null)
                throw new Exception("attempt to read from empty Iterator");
            var seq = nextGroup.sure();
            nextGroup = null;
            return seq;
        }

        return fromFns(hasNext, next);

    }
    // public function replace():Sequence<T> {
    //     return null;
    // }
    // public function replaceEach():Sequence<T> {
    //     return null;
    // }
    // public function set():Sequence<T> {
    //     return null;
    // }
    // public function setEach():Sequence<T> {
    //     return null;
    // }
    // public function update():Sequence<T> {
    //     return null;
    // }
    // public function updateEach():Sequence<T> {
    //     return null;
    // }

    // /**
    //     Returns `len` elements (all elements if len is null) from the Sequence,
    //     starting at and including `pos`.

    //     If `pos` is negative, its value is calculated from the end of the Sequence.

    //     If `pos` >= length, an empty Sequence is returned.

    //     If `len` elements cannot be copied, this function copies as many elements 
    //     as possible and returns them.
    // **/
    // public function splice(pos:Int, ?len:Int):Sequence<T> {
        
    //     // if (pos < 0) {
    //     //     var length = count();
    //     //     while (pos < 0)
    //     //         pos += length;
    //     // }

    //     // if (len == null)
    //     //     len = -1;

    //     // var nextVal

    //     // function getVal() {

    //     // }

    //     // var result = [];
    //     // for (i in pos...pos+len) {
    //     //     if (i >= length) break;
    //     //     result.push(getValue(i));
    //     // }
    //     // return fromArray(result);

    //     return null;
    // }

    // /**
    //     Returns elements starting from and including `pos`, ending at but not including `end`.

    //     If `pos` is negative, its value is calculated from the end of the Sequence.

    //     If `end` is less than `pos` or is null, it defaults to `this.length`.

    //     If `len` elements cannot be copied, this function copies as many elements 
    //     as possible and returns them.
    // **/
    // public function slice(pos:Int, ?end:Int):Sequence<T> {

    //     // while (pos < 0) pos += length;
    //     // if (end == null || end < pos) end = length;

    //     // var result = [];
    //     // for (i in pos...end) {
    //     //     if (i >= length) break;
    //     //     result.push(getValue(i));
    //     // }
    //     // return fromArray(result);

    //     return null;

    // }

    // public function drop():Sequence<T> {
    //     return null;
    // }
    // public function dropLast():Sequence<T> {
    //     return null;
    // }
    // public function dropWhile():Sequence<T> {
    //     return null;
    // }
    // public function dropUntil():Sequence<T> {
    //     return null;
    // }

    /**
        Returns a Sequence containing only the first `num` values.
    **/
    public function take(num:Int):Sequence<T> {
        
        var index = 0;
        var nextVal : Null<T> = null;

        function getVal()
            if (nextVal == null && index < num)
                nextVal = get(index++);

        function hasNext() {
            getVal();
            return nextVal != null;
        }

        function next() {
            getVal();
            if (nextVal == null)
                throw new Exception("attempt to read from empty Iterator");
            var val = nextVal.sure();
            nextVal = null;
            return val;
        }

        return fromFns(hasNext, next);

    }

    // /**
    //     Returns a Sequence containing only the last `num` values.
    // **/
    // public function takeLast():Sequence<T> {
    //     return null;
    // }
    // public function takeWhile():Sequence<T> {
    //     return null;
    // }
    // public function takeUntil():Sequence<T> {
    //     return null;
    // }
    // public function concat():Sequence<T> {
    //     return null;
    // }
    // public function concatEach():Sequence<T> {
    //     return null;
    // }
    // public function reduce():Sequence<T> {
    //     return null;
    // }
    // public function reduceRight():Sequence<T> {
    //     return null;
    // }
    // public function equals():Sequence<T> {
    //     return null;
    // }
    // public function every():Sequence<T> {
    //     return null;
    // }
    // public function some():Sequence<T> {
    //     return null;
    // }

    /**
        Returns true if this Sequence is empty.
    **/
    public function empty():Bool {
        return get(0) == null;
    }

    /**
        Counts the number of elements in the Sequence. This iterates over and caches
        every value in the Sequence.
    **/
    public function count():Int {
        if (cacheComplete)
            return _cacheLength();

        var i = 0, result = get(i);
        while (result != null) result = get(++i);
        return i;
    }

    // public function find() {
    //     return null;
    // }
    // public function findWhere() {
    //     return null;
    // }
    // public function has() {
    //     return null;
    // }
    // public function toArray():Sequence<T> {
    //     return null;
    // }
    // public function toMap():Sequence<T> {
    //     return null;
    // }
    // public function toOrderedMap():Sequence<T> {
    //     return null;
    // }
    // public function toSet():Sequence<T> {
    //     return null;
    // }
    // public function toOrderedSet():Sequence<T> {
    //     return null;
    // }
    // public function toList():Sequence<T> {
    //     return null;
    // }
    // public function toStack():Sequence<T> {
    //     return null;
    // }
    // public function entries():Sequence<Pair<Int,T>> {
    //     return null;
    // }
    public function iterator():Iterator<T> {

        var index : Int = 0;
        var nextVal : Null<T> = null;

        function getNext():Void
            if (nextVal == null)
                nextVal = get(index++);

        function hasNext():Bool {
            getNext();
            return nextVal != null;
        }

        function next():T {
            getNext();
            if (nextVal == null) throw new Exception("attempt to read from empty Iterator");
            var val = nextVal.sure();
            nextVal = null;
            return val; 
        }

        return { hasNext: hasNext, next: next };

    }

}
