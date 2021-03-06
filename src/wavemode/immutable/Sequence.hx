/**
 *  Copyright (c) 2020-present, Chukwudi Okechukwu
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the root directory of this source tree.
 *
 */

package wavemode.immutable;

import haxe.iterators.StringIteratorUnicode;
#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
#end

import haxe.Exception;
import wavemode.immutable._internal.FunctionalIterator;
import wavemode.immutable.Stack;
using wavemode.immutable._internal.Functional;

abstract Sequence<T>(SequenceObject<T>) from SequenceObject<T> to SequenceObject<T> {

    /**
        Create a new empty Sequence, or a clone of another object.
    **/
    public inline function new(?seq:Sequence<T>)
        if (seq != null)
            this = seq.unsafe()._this;
        else
            this = new SequenceObject();

    /**
        Create a new Sequence from an immutable List.
    **/
    @:from public static inline function fromVector<T>(vec:List<T>):Sequence<T>
        return fromIdx(0, vec.has, vec.get, true);

    /**
        Create a new Sequence from an Iterable.
    **/
    @:from public static inline function fromIterable<T, U:Iterable<T>>(iter:U):Sequence<T> {
        var it = iter.iterator();
        return fromIt(0, it.hasNext, it.next, iter.iterator);
    }

    /**
        Create a new Sequence from the characters of a given Unicode string.
    **/
    public static function fromChars(str:String):Sequence<String>
        return new StringIteratorUnicode(str).seq().map(String.fromCharCode);

    /**
        Merge the strings of a sequence into one combined String.
    **/
    public macro function toChars(ethis:ExprOf<Sequence<String>>):ExprOf<String> {
        return macro {
            var buf = new StringBuf();
            for (v in $e{ethis})
                buf.add(v);
            buf.toString();
        };
    }

    /**
        Macro to create a new Sequence from any number of values.
    **/
    public static macro function make<T>(values:Array<ExprOf<T>>):ExprOf<Sequence<T>>
        return macro @:pos(Context.currentPos()) new Sequence().pushEach([$a{values}]);

    /**
        Create a new Sequence from an Iterator.
    **/
    @:from public static inline function fromIterator<T, U:Iterator<T>>(it:U):Sequence<T>
        return fromIt(0, it.hasNext, it.next);

    /**
        Create an infinite sequence of a repeating `value`.
    **/
    public static function constant<T>(value:T):Sequence<T>
        return fromIdx(0, _->true, _->value, true);

    /**
        Create a Sequence representing numbers from `start` to `end`, inclusive.
    **/
    public static function range(start:Int, end:Int) {

        function h(index:Int):Bool
            if (start < end)
                return start + index <= end;
            else
                return start - index >= end;

        function g(index:Int):Int
            if (start < end)
                return start + index;
            else
                return start - index;

        return fromIdx(0, h, g, true);

    }

    /**
        Create a Sequence representing `len` values starting with `start` and
        repeatedly passed through the `iterator` function.
    **/
    public static function iterate<T>(start:T, iterator:T->T) {
        function r():Iterator<T> {
            var s = start;
            function hn()
                return true;
            function n() {
                var val = s;
                s = iterator(s);
                return val;
            }
            return new FunctionalIterator(hn, n);
        }
        var it = r();
        return fromIt(0, it.hasNext, it.next, r);
    }

    /**
        Create an infinite Sequence representing values starting at `start`
        and incremented by `step` each time.

        `step` is 1 by default. `start` is 0 by default.
    **/
    public static function step(start:Int = 0, step:Int = 1)
        return fromIdx(0, _->true, i->start+step*i, true);
    
    /**
        Create a Sequence with each of the given `sequences` concatenated together,
        separated by `separator`
    **/
    public static function join<T>(sequences:Sequence<Sequence<T>>, separator:T):Sequence<T> {

        var gindex:Int = 0;
        var nextVal:T;
        var valid:Bool = false;

        function gv():Void
            if (!valid) {
                var index:Int = gindex++;
                var seqIndex:Int = 0;
                while (sequences._has(seqIndex)) {
                    var seq = sequences._get(seqIndex);
                    var c:Int = seq.count();
                    if (index < c) {
                        nextVal = seq.cacheGet(index);
                        valid = true;
                        ++index;
                        return;
                    } else if (index == c && sequences._has(seqIndex + 1)) {
                        nextVal = separator;
                        valid = true;
                        ++index;
                        return;
                    } else {
                        ++seqIndex;
                        index -= (c + 1);
                    }
                }
            }

        function hn():Bool {
            gv();
            return valid;
        }

        function n():T {
            gv();
            valid = false;
            return nextVal;
        }

        return fromIt(0, hn, n);

    }


    /**
        Returns the value at position `index` in this Sequence, or null if the
        index is out of bounds.

        Calls to `get()` are cached internally, as the data in the underlying
        iterator is expected to be immutable.
    **/
    public inline function get(index:Int):Null<T> {
        collapseTail();
        if (has(index))
            return cacheGet(index);
        else
            return null;
    }

    /**
        Unsafe variant of `get()`. Returns the value at position `index` in
        this Sequence, or throws an Exception if the index is out of bounds.

        Calls to `getValue()` are cached internally, as the data in the
        underlying iterator is expected to be immutable.

        This function is callable with array access (`[]`) syntax.
    **/
    @:arrayAccess
    public function getValue(index:Int):T
        if (has(index))
            return cacheGet(index);
        else
            throw new Exception('index $index out of bounds for Sequence');

    /**
        Returns true if this Sequence is empty.
    **/
    public inline function empty():Bool
        return !_has(0);

    /**
        Returns an empty Sequence.
    **/
    public inline function clear():Sequence<T>
        return new Sequence();

    /**
        Returns a new Sequence in reverse order.
    **/
    public function reverse():Sequence<T> {

        var length:Int = -1;

        function getCount():Void
            if (length == -1)
                length = count();

        function h(index:Int):Bool {
            getCount();
            return index < length;
        }

        function g(index:Int):T {
            getCount();
            return _get(length-index-1);
        }

        return fromIdx(this._stackSize, h, g, true);

    }

    /**
        Returns a sorted Sequence according to the comparison function `f`, where
        `f(x,y)` returns a negative integer if `x` should be before `y`, a positive
        integer if `y` should be before `x`, and zero if the values are equivalent.

        For example, `[5, 4, 3, 2, 1].sort((x, y) -> x - y)` returns `[1, 2, 3, 4, 5]`
    **/
    public function sort(f:(T,T)->Int):Sequence<T> {

        var seq:Array<T>;
        var valid = false;

        function gv():Void {
            var c = count();
            seq = [];
            for (i in 0...c)
                seq.push(_get(i));
            seq.sort(f);
            valid = true;
        }

        function h(i:Int):Bool {
            if (!valid)
                gv();
            return i < count();
        }

        function g(i:Int):T {
            if (!valid)
                gv();
            return seq[i];
        }

        return fromIdx(this._stackSize, h, g, true);

    }


    /**
        Returns elements starting from and including `pos`, ending at but not including `end`.

        If `pos` or `end` are negative, their value is calculated from the end of the Sequence.
    **/
    public function slice(pos:Int, ?end:Int):Sequence<T> {

        var valid:Bool = false;

        function gv() {
            valid = true;
            while (pos < 0)
                if (count() == 0)
                    return;
                else
                    pos += count();
            if (end != null)
                while (end.unsafe() < 0)
                    if (count() == 0)
                        return;
                    else
                        end = end.unsafe() + count();
        }

        function h(index:Int):Bool {
            if (!valid)
                gv();
            if (end == null)
                return _has(pos+index);
            else
                return (pos+index)<end.unsafe() && _has(pos+index); 
        }

        function g(index:Int):T {
            if (!valid)
                gv();
            return _get(pos+index);
        }

        return fromIdx(this._stackSize, h, g);

    }

    /**
        Returns a new Sequence containing `len` elements (all elements if len is null)
        from this Sequence, starting at and including `pos`.

        If `pos` is negative, its value is calculated from the end of the Sequence.
    **/
    public function splice(pos:Int, ?len:Int):Sequence<T> {
        
        var valid:Bool = false;

        function gv() {
            valid = true;
            while (pos < 0)
                if (count() == 0)
                    return;
                else
                    pos += count();
        }

        function h(index:Int):Bool {
            if (!valid)
                gv();
            if (len == null)
                return _has(pos+index);
            else
                return index<len.unsafe() && _has(pos+index); 
        }

        function g(index:Int):T {
            if (!valid)
                gv();
            return _get(pos+index);
        }

        return fromIdx(this._stackSize, h, g);

    }

    /**
        Returns a new Sequence with values not satisfying `predicate` removed.
    **/
    public function filter(predicate:T->Bool):Sequence<T> {

        var index:Int = 0;
        var nextVal:T;
        var valid:Bool = false;

        function gv():Void
            while (true)
                if (!valid) {
                    if (!_has(index))
                        return;
                    nextVal = _get(index++);
                    valid = predicate(nextVal);
                } else break;

        function hn():Bool {
            gv();
            return valid;
        }

        function n():T {
            gv();
            valid = false;
            return nextVal;
        }

        return fromIt(this._stackSize, hn, n);

    }

    /**
        Returns a new Sequence with all intances of the given value removed.
    **/
    public function remove(value:T):Sequence<T> {

        var index:Int = 0;
        var nextVal:T;
        var valid:Bool = false;

        function gv():Void
            while (true)
                if (!valid) {
                    if (!_has(index))
                        return;
                    nextVal = _get(index++);
                    valid = nextVal != value;
                } else break;

        function hn():Bool {
            gv();
            return valid;
        }

        function n():T {
            gv();
            valid = false;
            return nextVal;
        }

        return fromIt(this._stackSize, hn, n);

    }

    /**
        Returns a new Sequence with all intances of each of the given `values` removed.

        Equivalent to calling `remove()` for each value individually, but potentially
        more efficient.
    **/
    public function removeEach(values:Sequence<T>):Sequence<T> {

        var index:Int = 0;
        var nextVal:T;
        var valid:Bool = false;

        function gv():Void
            while (true)
                if (!valid) {
                    if (!_has(index))
                        return;
                    nextVal = _get(index++);
                    valid = values.find(nextVal) == -1;
                } else break;

        function hn():Bool {
            gv();
            return valid;
        }

        function n():T {
            gv();
            valid = false;
            return nextVal;
        }

        return fromIt(this._stackSize, hn, n);

    }

    /**
        Returns a new Sequence with the given index deleted.
    **/
    public function delete(index:Int):Sequence<T> {

        if (index < 0 || (this.cacheComplete && this.cache.length <= index))
            return this;

        function h(i:Int):Bool {
            if (i < index)
                return _has(i);
            else
                return _has(i+1);
        }

        function g(i:Int) {
            if (i < index)
                return _get(i);
            else
                return _get(i+1);
        }

        return fromIdx(this._stackSize, h, g);

    }

    /**
        Returns a new Sequence with all of the given `indices` deleted.

        Equivalent to calling `delete()` for each index individually, but
        potentially more efficient.
    **/
    public function deleteEach(indices:Sequence<Int>):Sequence<T> {

        var index:Int = 0;
        var nextVal:T;
        var valid:Bool = false;

        function gv():Void
            while (true)
                if (!valid) {
                    if (!_has(index))
                        return;
                    else if (indices.find(index) != -1) {
                        ++index;
                        continue;
                    }
                    nextVal = _get(index++);
                    valid = true;
                } else break;

        function hn():Bool {
            gv();
            return valid;
        }

        function n():T {
            gv();
            valid = false;
            return nextVal;
        }

        return fromIt(this._stackSize, hn, n);

    }

    /**
        Returns a Sequence containing only the first `num` values.
    **/
    public inline function take(num:Int):Sequence<T>
        return slice(0, num);

    /**
        Returns a Sequence containing only the last `num` values.
    **/
    public function takeLast(num:Int):Sequence<T> {

        var start:Int = -1;

        function getStart():Void
            if (start == -1)
                start = {
                    var s = count() - num;
                    if (s > 0) s else 0;
                };


        function h(index:Int):Bool {
            getStart();
            return _has(index+start);
        }

        function g(index:Int):T {
            getStart();
            return _get(index+start);
        }

        return fromIdx(this._stackSize, h, g);

    }

    /**
        Returns a Sequence with every value removed after
        `predicate` returns false.
    **/
    public function takeWhile(predicate:T->Bool):Sequence<T> {

        function h(index:Int):Bool
            return _has(index) && predicate(_get(index));

        return fromIdx(this._stackSize, h, _get);

    }

    /**
        Returns a Sequence with every value removed after
        `predicate` returns true.
    **/
    public function takeUntil(predicate:T->Bool):Sequence<T> {

        function h(index:Int):Bool
            return _has(index) && !predicate(_get(index));

        return fromIdx(this._stackSize, h, _get);

    }

    /**
        Returns a Sequence with the first `num` values removed.
    **/
    public inline function drop(num:Int):Sequence<T>
        return slice(num);

    /**
        Returns a Sequence with the last `num` values removed.
    **/
    public inline function dropLast(num:Int):Sequence<T>
        return slice(0, -num);

    /**
        Returns a Sequence with every value dropped as long as
        `predicate` returns true.
    **/
    public function dropWhile(predicate:T->Bool):Sequence<T> {
        
        var start:Int = -1;

        function getStart():Void
            if (start == -1) {
                start = 0;
                while (_has(start) && predicate(_get(start)))
                    ++start;
            }


        function h(index:Int):Bool {
            getStart();
            return _has(index+start);
        }

        function g(index:Int):T {
            getStart();
            return _get(index+start);
        }

        return fromIdx(this._stackSize, h, g);

    }

    /**
        Returns a Sequence with every value dropped as long as
        `predicate` returns false.
    **/
    public function dropUntil(predicate:T->Bool):Sequence<T> {

        var start:Int = -1;

        function getStart():Void
            if (start == -1) {
                start = 0;
                while (_has(start) && !predicate(_get(start)))
                    ++start;
            }


        function h(index:Int):Bool {
            getStart();
            return _has(index+start);
        }

        function g(index:Int):T {
            getStart();
            return _get(index+start);
        }

        return fromIdx(this._stackSize, h, g);

    }


    //////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////// MAPPINGS ////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////


    /**
        Returns a new Sequence with each element passed through `mapper`.
    **/
    public function map<M>(mapper:T->M):Sequence<M>
        return fromIdx(this._stackSize, _has, i->mapper(_get(i)));

    /**
        Returns a new Sequence with each index and corresponding element passed
        through `mapper`.
    **/
    public function mapIndex<M>(mapper:(Int,T)->M):Sequence<M> {
        
        var index:Int = 0;
        var valid:Bool = false;
        var nextVal:M;

        function gv():Void
            if (!valid)
                if (!_has(index))
                    return;
                else {
                    nextVal = mapper(index, _get(index));
                    ++index;
                    valid = true;
                }

        function hn():Bool {
            gv();
            return valid;
        }

        function n():M {
            gv();
            valid = false;
            return nextVal;
        }

        return fromIt(this._stackSize, hn, n);

    }

    /**
        `mapper` is a function that returns an Iterable type (e.g. Array)
            
        `flatMap` creates a new Sequence with each value passed through the
        `mapper` function, then flattened. 

        For example, `[1, 2, 3].flatMap(x -> [x*2, x*10])` returns
        `[2, 10, 4, 20, 6, 30]`
    **/
    public function flatMap<N, M:Iterable<N>>(mapper:T->M):Sequence<N> {

        var index : Int = 0;
        var nextIter:Iterator<N>;
        var nextElement:N;
        var iterValid:Bool = false;
        var valid:Bool = false;

        function gv():Void
            while (true) {
                if (!iterValid) {
                    if (!_has(index))
                        return;
                    nextIter = mapper(_get(index++)).iterator();
                    iterValid = true;
                }
                if (!nextIter.hasNext()) {
                    iterValid = false;
                    continue;
                }
                if (!valid) {
                    nextElement = nextIter.next();
                    valid = true;
                } else break;
            }

        function hn():Bool {
            gv();
            return valid;
        }

        function n():N {
            gv();
            valid = false;
            return nextElement;
        }

        return fromIt(this._stackSize, hn, n);

    }

    /**
        Returns a new Sequence with the `nth` value replaced by `value`.
    **/
    public function set(nth:Int, value:T):Sequence<T> {
        if (nth < 0 || (this.cacheComplete && this.cache.length <= nth))
            return this;
        return fromIdx(this._stackSize, _has, i -> if (i == nth) value else _get(i));
    }

    /**
        Returns a new sequence with each index in `indices` replaced by the respective
        value in `values`.

        Equivalent to calling `set()` for each index individually, but potentially more
        efficient.
    **/
    public function setEach(indices:Sequence<Int>, values:Sequence<T>):Sequence<T> {

        function g(i:Int):T {
            var rpl = indices.find(i);
            if (rpl != -1 && values._has(rpl))
                return values._get(rpl);
            else
                return _get(i);
        }

        return fromIdx(this._stackSize, _has, g);

    }

    /**
        Returns a new Sequence with the `nth` element passed through the
        `updater` function.
    **/
    public function update(nth:Int, updater:T->T):Sequence<T> {
        
        if (nth < 0 || (this.cacheComplete && this.cache.length <= nth))
            return this;

        var index:Int = 0;
        var valid:Bool = false;
        var nextVal:T;

        function gv():Void
            if (!valid) {
                if (!_has(index))
                    return;
                nextVal = _get(index);
                if (nth == index)
                    nextVal = (updater(nextVal));
                ++index;
                valid = true;
            }

        function hn():Bool {
            gv();
            return valid;
        }

        function n():T {
            gv();
            valid = false;
            return nextVal;
        }

        return fromIt(this._stackSize, hn, n);

    }

    /**
        Returns a new Sequence with the elements at positions in `indices` passed through
        the `updater` function.

        Equivalent to calling `update()` for each index individually, but potentially more
        efficient.
    **/
    public function updateEach(indices:Sequence<Int>, updater:T->T):Sequence<T> {

        var index:Int = 0;
        var valid:Bool = false;
        var nextVal:T;

        function gv():Void
            if (!valid) {
                if (!_has(index))
                    return;
                nextVal = _get(index);
                var nth = indices.find(index);
                if (nth != -1)
                    nextVal = (updater(nextVal));
                ++index;
                valid = true;
            }

        function hn():Bool {
            gv();
            return valid;
        }

        function n():T {
            gv();
            valid = false;
            return nextVal;
        }

        return fromIt(this._stackSize, hn, n);

    }

    /**
        Returns a new Sequence with all instances of `oldVal` replaced by `newVal`.
    **/
    public inline function replace(oldVal:T, newVal:T):Sequence<T>
        return fromIdx(this._stackSize, _has, i -> {
            var value = _get(i);
            if (value == oldVal)
                newVal;
            else
                value;
        });

    /**
        Returns a new Sequence with all instances of values in `oldVals` replaced by
        the corresponding value in `newVal`.

        Equivalent to calling `replace` for each value individually, but potentially
        more efficient.
    **/
    public function replaceEach(oldVals:Sequence<T>, newVals:Sequence<T>):Sequence<T> {

        return fromIdx(this._stackSize, _has, i -> {
            var value = _get(i);
            var index = oldVals.find(value);
            if (index != -1 && newVals._has(index))
                newVals._get(index);
            else
                value;
        });

    }

    /**
        Returns a Sequence of Sequences, with elements grouped according to the return
        value of `grouper`.

        For example, `[1, 2, 3, 4, 5].group(x -> x % 2)` results in `[[1, 3, 5], [2, 4]]`
    **/
    public function group<M>(grouper:T->M):Sequence<Sequence<T>> {

        /*
            This function returns a fully lazy sequence that itself returns fully
            lazy sequences.

            For example, given the following:
            
            var seq = Sequence.fromIterable([1, 2, 3, null, null, null])
                        .map(x -> x * 2)
                        .group(x -> x < 7)
                        .get(0)
                        .take(3);
            
            Sys.println(seq);

            We see printed "Sequence { 2, 4, 6 }", because we're only asking for the first
            three values for which N*2 is less than 7. The program does not crash from trying
            to perform null * 2, because the mappings of those null values are never evaluated.
        */

        var categories:Array<M> = [];
        var buckets:Array<Array<T>> = [];
        var readIndex:Int = 0;

        function categorizeNext():Bool
            if (!_has(readIndex)) {
                return false;
            } else {
                var value = _get(readIndex++);
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

            function gv():Void
                if (nextVal == null)
                    nextVal = getNth(nth, index++);

            function hn():Bool {
                gv();
                return nextVal != null;
            }

            function n():T {
                gv();
                var val = nextVal.unsafe();
                nextVal = null;
                return val;
            }

            return fromIt(this._stackSize, hn, n);

        }

        var groupIndex = 0;
        var nextGroup:Null<Sequence<T>> = null;

        function getGroup():Void
            if (nextGroup == null)
                nextGroup = getSequence(groupIndex++);

        function hn():Bool {
            getGroup();
            return nextGroup != null;
        }

        function n():Sequence<T> {
            getGroup();
            var seq = nextGroup.unsafe();
            nextGroup = null;
            return seq;
        }

        return fromIt(this._stackSize, hn, n);

    }


    /**
        Returns the accumulation of this Sequence according to `foldFn`, beginning with
        `initialValue`.

        For example, `[1, 2, 3].fold((a, b) -> a - b, 0)` evaluates `0 - 1 - 2 - 3 = -6`
    **/
    public function fold<R>(foldFn:(R,T)->R, initialValue:R):R {

        var index:Int = 0;

        while (has(index))
            initialValue = foldFn(initialValue, cacheGet(index++));

        return initialValue;

    }

    /**
        Returns the accumulation of this Sequence according to `foldFn`, beginning with
        `initialValue`. Identical to `fold()`, except iterating in reverse.

        For example, `[1, 2, 3].foldRight((a, b) -> a - b, 0)` evaluates `0 - 3 - 2 - 1 = -6`
    **/
    public function foldRight<R>(foldFn:(R,T)->R, initialValue:R):R {

        var index:Int = 0;

        while (has(index))
            initialValue = foldFn(initialValue, cacheGet(index++));

        return initialValue;

    }

    /**
        A simpler form of `fold()`
		
        Returns the accumulation of this Sequence according to `reducer`.

        For example, `[1, 2, 3, 4].reduce((a, b) -> a + b)` returns `10`

        Throws an Exception if the Sequence is empty.
    **/
    public function reduce(reducer:(T,T)->T):T {

        if (empty())
            throw new Exception("attempt to reduce empty Sequence");

        var index:Int = 1;
        var value:T = _get(0);

        while (has(index))
            value = reducer(value, cacheGet(index++));

        return value;

    }

    /**
        A simpler form of `foldRight()`
			
        Returns the accumulation of this Sequence according to `reducer`. Identical
        to `reduce()` except iterating in reverse.

        For example, `[1, 2, 3, 4].reduceRight((a, b) -> a + b)` returns `10`

        Throws an Exception if the Sequence is empty.
    **/
    public function reduceRight(reducer:(T,T)->T):T {

        if (empty())
            throw new Exception("attempt to reduce empty Sequence");

        var c:Int = count();
        var index:Int = c - 2;
        var value:T = cacheGet(c - 1);

        while (has(index))
            value = reducer(value, cacheGet(index--));

        return value;

    }

    /**
        Returns the numerical maximum of the Sequence.
    **/
    public macro function max<T>(ethis:ExprOf<Sequence<T>>):ExprOf<T>
        return macro $e{ethis}.reduce((a, b) -> if (a > b) a else b);

    /**
        Returns the numerical minimum of the Sequence.
    **/
    public macro function min<T>(ethis:ExprOf<Sequence<T>>):ExprOf<T>
        return macro $e{ethis}.reduce((a, b) -> if (a < b) a else b);

    /**
        Returns the sum of the elements in the Sequence.
    **/
    public macro function sum<T>(ethis:ExprOf<Sequence<T>>):ExprOf<T>
        return macro $e{ethis}.reduce((a, b) -> a + b);

    /**
        Returns the product of the elements in the Sequence.
    **/
    public macro function product<T>(ethis:ExprOf<Sequence<T>>):ExprOf<T>
        return macro $e{ethis}.reduce((a, b) -> a * b);
    
    /**
        Returns a Sequence sorted ascending numerically.
    **/
    public macro function sortAsc<T>(ethis:ExprOf<Sequence<T>>):ExprOf<Sequence<T>>
        return macro $e{ethis}.sort((a, b) -> if (a > b) 1 else if (a < b) -1 else 0);

    /**
        Returns a Sequence sorted descending numerically.
    **/
    public macro function sortDesc<T>(ethis:ExprOf<Sequence<T>>):ExprOf<Sequence<T>>
        return macro $e{ethis}.sort((a, b) -> if (a > b) -1 else if (a < b) 1 else 0);

    /**
        Returns true if the given `index` exists in this Sequence.
    **/
    public inline function has(index:Int):Bool {
        collapseTail();
        return cacheExpand(index);
    }

    /**
        Returns the first element of the Sequence, or null if the Sequence is empty.
    **/
    public inline function first():Null<T>
        return get(0);

    /**
        Returns the last element of the Sequence, or null if the Sequence is empty.
    **/
    public inline function last():Null<T>
        return get(count() - 1);

    /**
        Counts the number of elements in the Sequence.
    **/
    public inline function count():Int {

        if (this.cacheComplete)
            return this.cache.length;

        var i = this.cache.length;
        while (has(i))
            ++i;

        return i;

    }

    /**
        Returns true if the given `predicate` is true for every value in the Sequence.
    **/
    public function every(predicate:T->Bool):Bool {

        var index:Int = 0;

        while (has(index))
            if (!predicate(cacheGet(index++)))
                return false;

        return true;

    }

    /**
        Returns true if the given `predicate` is true for any value in the Sequence.
    **/
    public function some(predicate:T->Bool):Bool {

        var index:Int = 0;

        while (has(index))
            if (predicate(cacheGet(index++)))
                return true;

        return false;

    }

    /**
        Returns true if this Sequence and the given `sequence` contain identical values.

        If `deep` is true, the sequences are compared by their string representations,
        which will properly handle deeply nested subsequences and many other edge cases,
        but will incorrectly classify non-printable objects like functions.
    **/
    public function equals(sequence:Sequence<T>, ?deep:Bool):Bool {
        
        if (deep != null && deep.unsafe())
            return toString() == sequence.toString();

        var index:Int = 0;
        var it:Iterator<T> = sequence.iterator();

        while (has(index) && it.hasNext()) {
            if (cacheGet(index) != it.next())
                return false;
            ++index;
        }

        return !has(index) && !it.hasNext();

    }

    /**
        Returns the first index of the given `value` in the Sequence, or -1 if
        it does not exist.
        
        Starts searching from `start`, or from 0 if start is null.
    **/
    public function find(value:T, ?start:Int):Int {

        var index:Int;

        if (start == null)
            index = 0;
        else
            index = start;

        while (has(index)) {
            if (cacheGet(index) == value)
                return index;
            ++index;
        }

        return -1;

    }

    /**
        Alias of `find()`

        Returns the first index of the given `value` in the Sequence, or -1 if
        it does not exist.
        
        Starts searching from `start`, or from 0 if start is null.
    **/
    public inline function indexOf(value:T, ?start:Int):Int
        return find(value, start);

    /**
        Returns true if the given value in in this Sequence.
    **/
    public inline function contains(value:T):Bool
        return find(value) != -1;

    /**
        Returns the first index at which the given `predicate` returns true, or -1 if
        it never does.

        Starts searching from `start`, or from 0 if start is null.
    **/
    public function findWhere(predicate:T->Bool, ?start:Int):Int {

        var index:Int;

        if (start == null)
            index = 0;
        else
            index = start;

        while (has(index)) {
            if (predicate(cacheGet(index)))
                return index;
            ++index;
        }

        return -1;

    }

    /**
        `sideEffect` is executed on every value in the Sequence.
    **/
    public function forEach(sideEffect:T->Void):Void {
        var index:Int = 0;
        while (has(index))
            sideEffect(cacheGet(index++));
    }

    /**
        A function is executed on each value in the Sequence until it returns false.

        This function returns the number of times `sideEffect` was executed.
    **/
    public function forWhile(sideEffect:T->Bool):Int {
        var index:Int = 0;

        while (has(index))
            if (!sideEffect(cacheGet(index++)))
                break;

        return index;
    }


    /**
        Returns a new Sequence with the given value appended to the end.
    **/
    public function push(value:T):Sequence<T> {
        var result = clone();
        if (result.tail == null)
            result.tail = [];
        result.tail.unsafe().push(value);
        ++result.tailLength;
        return result;
    }

    /**
        Alias for `concat()`

        Returns a new Sequence with the given `values` appended to the end.
    **/
    public inline function pushEach(values:Sequence<T>):Sequence<T>
        return concat(values);

    /**
        Returns a new Sequence with the last value removed.
    **/
    public inline function pop():Sequence<T>
        return fromIdx(this._stackSize, i -> _has(i) && _has(i+1), _get);

    /**
        Returns a new Sequence with a given `value` prepended to the front.
    **/
    public function unshift(value:T):Sequence<T> {

        function h(index:Int):Bool
            return index == 0 || _has(index-1);

        function g(index:Int):T
            if (index == 0)
                return value;
            else
                return _get(index-1);

        return fromIdx(this._stackSize, h, g);

    }

    /**
        Returns a new Sequence with the first item removed.
    **/
    public inline function shift():Sequence<T>
        return slice(1);

    /**
        Returns a new Sequence with the given `value` inserted at `index`.

        The Sequence will be unmodified if index < 0 or index > count()
    **/
    public function insert(index:Int, value:T):Sequence<T> {

        if (index < 0 || (this.cacheComplete && this.cache.length < index))
            return this;

        function h(i:Int):Bool
            if (i < index)
                return _has(i);
            else if (i > index)
                return _has(i-1);
            else
                return true;
        
        function g(i:Int):T
            if (i < index)
                return _get(i);
            else if (i > index)
                return _get(i-1);
            else
                return value;

        return fromIdx(this._stackSize, h, g);

    }

    /**
        Returns a new sequence with the given `values` inserted at `index`.

        The Sequence will be unmodified if index < 0 or index > count()
    **/
    public function insertEach(index:Int, values:Sequence<T>):Sequence<T> {

        if (index < 0 || (this.cacheComplete && this.cache.length < index))
            return this;

        function h(i:Int):Bool
            if (i < index)
                return _has(i);
            else if (values._has(i - index))
                return true;
            else
                return _has(i - values.count());
        
        function g(i:Int):T
            if (i < index)
                return _get(i);
            else if (values._has(i - index))
                return values[i - index];
            else
                return _get(i - values.count());

        return fromIdx(this._stackSize, h, g);

    }

    /**
        Returns a new Sequence with the given `values` appended to the end.
    **/
    public function concat(values:Sequence<T>):Sequence<T> {

        var it1 = iterator(), it2 = values.iterator();
        var nextValue;
        var valid = false, done1 = false, done2 = false;

        function gv() {
            if (!valid && !done1) {
                if (it1.hasNext()) {
                    nextValue = it1.next();
                    valid = true;
                } else {
                    done1 = true;
                }
            }
            if (!valid && !done2) {
                if (it2.hasNext()) {
                    nextValue = it2.next();
                    valid = true;
                } else {
                    done2 = true;
                }
            }
        }

        function hn() {
            gv();
            return valid;
        }

        function n() {
            gv();
            valid = false;
            return nextValue;
        }

        return fromIt(this._stackSize, hn, n);

    }


    /**
        Returns a new Sequence with the given `sequences` each appended to the end.

        Equivalent to calling `concat()` for each sequence individually, but potentially
        more efficient.
    **/
    public function concatEach(sequences:Sequence<Sequence<T>>):Sequence<T> {

        var index:Int = 0;
        var seqIndex:Int = -1;

        var nextVal:T;
        var valid = false;

        function gv():Void
            while (true)
                if (!valid) {
                    if (seqIndex == -1) {
                        if (!_has(index)) {
                            ++seqIndex;
                            index = 0;
                        } else {
                            nextVal = _get(index);
                            valid = true;
                            ++index;
                        }
                    } else {
                        if (!sequences._has(seqIndex))
                            return;
                        var seq = sequences.getValue(seqIndex);
                        if (!seq._has(index)) {
                            ++seqIndex;
                            index = 0;
                        } else {
                            nextVal = seq._get(index);
                            valid = true;
                            ++index;
                        }
                    }
                } else return;

        function hn():Bool {
            gv();
            return valid;
        }

        function n():T {
            gv();
            valid = false;
            return nextVal;
        }

        return fromIt(this._stackSize, hn, n);

    }

    /**
        Takes Sequence A and Sequence B and creates a new Sequence where the i'th element
        is the sequence [A[i], B[i]]

        For example, `[1, 2, 3].zip([4, 5, 6])` results in `[[1, 4], [2, 5], [3, 6]]`
    **/
    public function zip(other:Sequence<T>):Sequence<Sequence<T>> {

        function h(index:Int):Bool
            return _has(index) && other._has(index);

        function g(index:Int):Sequence<T>
            return fromIdx(this._stackSize, i -> i < 2, i -> if (i == 0) _get(index) else other._get(index));

        return fromIdx(this._stackSize, h, g);

    }

    /**
        Zips each sequence with this sequence.

        For example, `[1, 2, 3].zipAll([[4, 5, 6], [7, 8, 9]])` results in
        `[[1, 4, 7], [2, 5, 8], [3, 6, 9]]`
    **/
    public function zipEach(others:Sequence<Sequence<T>>):Sequence<Sequence<T>> {

        function h(index:Int):Bool
            return others.every(s -> s._has(index));

        function g(index:Int):Sequence<T>
            return others.map(s -> s._get(index)).unshift(_get(index));

        return fromIdx(this._stackSize, h, g);

    }

    /**
        Returns a new Sequence with the given `separator` interposed between each element.
    **/
    public function separate(separator:T):Sequence<T> {

        function h(index:Int):Bool
            if (index % 2 == 0)
                return _has(Std.int(index / 2));
            else
                return _has(Std.int((index + 1) / 2));

        function g(index:Int):T
            if (index % 2 == 0)
                return _get(Std.int(index / 2));
            else
                return separator;

        return fromIdx(this._stackSize, h, g);

    }

    /**
        Returns a new Sequence with the values of `other` interleaved with the elements of this
        Sequence.

        For example, `[1, 2, 3, 4].interleave([9, 9, 9, 9])` returns `[1, 9, 2, 9, 3, 9, 4, 9]`
    **/
    public function interleave(other:Sequence<T>):Sequence<T> {

        var index:Int = 0;
        var valid:Bool = false;
        var nextVal:T;

        var thisLength:Null<Int>;
        var otherLength:Null<Int>;

        function gv():Void
            while (true)
                if (!valid) {
                    if (thisLength != null) {
                        var len:Int = thisLength.unsafe(), i = index - len;
                        if (!other._has(i))
                            return;
                        nextVal = other._get(i);
                        valid = true;
                        ++index;
                    } else if (otherLength != null) {
                        var len:Int = otherLength.unsafe(), i = index - len;
                        if (!_has(i))
                            return;
                        nextVal = _get(i);
                        valid = true;
                        ++index;
                    } else if (index % 2 == 0) {
                        var i = Std.int(index / 2);
                        if (!_has(i)) {
                            thisLength = i;
                            continue;
                        }
                        nextVal = _get(i);
                        valid = true;
                        ++index;
                    } else {
                        var i = Std.int((index - 1) / 2);
                        if (!other._has(i)) {
                            otherLength = i;
                            continue;
                        }
                        nextVal = other._get(i);
                        valid = true;
                        ++index;
                    }
                } else return;

        function hn():Bool {
            gv();
            return valid;
        }

        function n():T {
            gv();
            valid = false;
            return nextVal;
        }

        return fromIt(this._stackSize, hn, n);

    }

    /**
        Create a Sequence of Sequences, split by occurrences of `element`.
    **/
    public function split(element:T):Sequence<Sequence<T>> {

        var index:Int = 0;
        var seqIndex:Int = 0;
        var nextSeq:Sequence<T>;
        var valid:Bool = false;
        var done:Bool = false;

        function gv():Void
            while (true)
                if (!valid) {
                    if (done) {
                        return;
                    } else if (_has(index)) {
                        var value = _get(index);
                        if (value == element) {
                            nextSeq = slice(seqIndex, index);
                            valid = true;
                            seqIndex = index + 1;
                            ++index;
                        } else {
                            ++index;
                            continue;
                        }
                    } else {
                        nextSeq = slice(seqIndex, index);
                        valid = true;
                        done = true;
                    }
                } else return;

        function hn():Bool {
            gv();
            return valid;
        }

        function n():Sequence<T> {
            gv();
            valid = false;
            return nextSeq;
        }

        return fromIt(this._stackSize, hn, n);

    }

    /**
        Create a Sequence of Sequences, split by occurrences where elements satisfy `predicate`.
    **/
    public function splitWhere(predicate:T->Bool):Sequence<Sequence<T>> {

        var index:Int = 0;
        var seqIndex:Int = 0;
        var nextSeq:Sequence<T>;
        var valid:Bool = false;
        var done:Bool = false;

        function gv():Void
            while (true)
                if (!valid) {
                    if (done) {
                        return;
                    } else if (_has(index)) {
                        var value = _get(index);
                        if (predicate(value)) {
                            nextSeq = slice(seqIndex, index);
                            valid = true;
                            seqIndex = index + 1;
                            ++index;
                        } else {
                            ++index;
                            continue;
                        }
                    } else {
                        nextSeq = slice(seqIndex, index);
                        valid = true;
                        done = true;
                    }
                } else return;

        function hn():Bool {
            gv();
            return valid;
        }

        function n():Sequence<T> {
            gv();
            valid = false;
            return nextSeq;
        }

        return fromIt(this._stackSize, hn, n);

    }

    /**
        Partition this Sequence into a Sequence of Sequences, divided along the given `indices`
    **/
    public function partition(indices:Sequence<Int>):Sequence<Sequence<T>> {

        var sortedIndices:Sequence<Int> = indices.sort((a, b) -> a - b);
        var seqIndex:Int = 0;
        var lastIndex:Int = 0;
        var nextIndex:Int;
        var valid:Bool = false;
        var done:Bool = false;

        function gv()
            if (!valid) {
                if (done) {
                    return;
                } else if (sortedIndices._has(seqIndex)) {
                    var index = sortedIndices[seqIndex];
                    if (_has(index) || _has(index - 1)) {
                        nextIndex = index;
                        valid = true;
                    } else {
                        nextIndex = -1;
                        valid = true;
                        done = true;
                    }
                } else {
                    nextIndex = -1;
                    valid = true;
                    done = true;
                }
                ++seqIndex;
            }

        function hn():Bool {
            gv();
            return valid;
        }

        function n():Sequence<T> {
            gv();
            valid = false;
            var result:Sequence<T>;
            if (nextIndex == -1)
                result = slice(lastIndex);
            else
                result = slice(lastIndex, nextIndex);
            lastIndex = nextIndex;
            return result;
        }
        
        return fromIt(this._stackSize, hn, n);

    }

    /**
        Returns a new Sequence with values repeated `num` times.

        For example, `[1, 2, 3].repeat(3)` returns `[1, 2, 3, 1, 2, 3, 1, 2, 3]`
    **/
    public function repeat(num:Int):Sequence<T> {
        var seq = new Sequence();
        for (i in 0...num)
            seq = seq.concat(this);
        return seq;
    }

    /**
        Returns a new Sequence with the values lazily shuffled to be in a random order.
    **/
    public function shuffle():Sequence<T> {

        var index:Int = 0;
        var seq:Sequence<T> = this;

        function n():T {
            var newIndex = index + Std.random(count() - index);
            var temp = seq._get(index);
            seq = seq.set(index, seq._get(newIndex));
            seq = seq.set(newIndex, temp);
            return seq._get(index++);
        }

        return fromIt(this._stackSize, ()->_has(index), n);

    }

    /**
        An iterator over all of this Sequence's elements.
    **/
    public inline function iterator():Iterator<T>
        if (this._r != null)
            return this._r();
        else
            return new SequenceIterator(this);

    /**
        An iterator over all of this Sequence's index-value pairs.
    **/
    public inline function keyValueIterator():KeyValueIterator<Int,T>
        return new SequenceKeyValueIterator(this);

    /**
        Sequence containing each index of this Sequence.
    **/
    public inline function indices():Iterator<Int>
        return 0.below(count());

    /**
        Iterator over each value in the Sequence. Equivalent to `iterator()`
    **/
    public inline function values():Iterator<T>
        return iterator();

    /**
        Iterator over each index-value pair in the Sequence. Equivalent to `keyValueIterator()`
    **/
    public inline function entries():KeyValueIterator<Int,T>
        return keyValueIterator();

    /**
        Convert this Sequence to an Array.
    **/
    public inline function toArray():Array<T>
        return [for (v in self) v];

    /**
        Convert this Sequence to an immutable Map of index-value pairs.
    **/
    public inline function toMap():Map<Int,T>
        return new Map().setEach(indices(), values());

    /**
        Convert this Sequence to an immutable OrderedMap of index-value pairs.
    **/
    public inline function toOrderedMap():OrderedMap<Int,T>
        return new OrderedMap().setEach(indices(), values());

    /**
        Convert this Sequence to an immutable Set of its values.
    **/
    public inline function toSet():Set<T>
        return new Set().addEach(values());

    /**
        Convert this Sequence to an OrderedSet of its values.
    **/
    public inline function toOrderedSet():OrderedSet<T>
        return new OrderedSet().addEach(values());

    /**
        Convert this Sequence to an immutable List of its values.
    **/
    public inline function toList():List<T>
        return new List().pushEach(self);

    /**
        Convert this Sequence to an immutable Stack of its values.
    **/
    public inline function toStack():Stack<T> {
        var result = new Stack();
        for (v in this)
            result = result.push(v);
        return result;
    }

    /**
        Retrieve a string representation of the Sequence.
    **/
    public inline function toString():String {
        var result = new StringBuf();
        result.add("Sequence {");
        var cut = false;

        var index:Int = 0;
        while (has(index)) {
            cut = true;
            result.add(' ${cacheGet(index++)},');
        }

        return
            (if (cut)
                result.toString().substr(0, result.length - 1)
            else
                result.toString())
            + " }";
    }

    /**
        Evaluates and caches every value in the Sequence.
    **/
    public function force():Sequence<T> {
        count();
        return this;
    }

    private inline function cacheExpand(index:Int):Bool {

        if (index < 0 || this._hn == null)
            return false;

        if (this.cacheComplete)
            return this.cache.length > index;

        while (this.cache.length <= index && 
            if (this._hn()) {
                true;
            } else {
                this._hn = () -> false;
                this._n = null;
                this._g = null;
                this._h = null;
                this._r = null;
                this.cacheComplete = true;
                this._stackSize = 0;
                false;
            })
        {
            this.cache.unsafe().push(this._n.unsafe()());
        }

        return this.cache.length > index;

    }

    private inline function cacheGet(index:Int):T
        return this.cache[index];

    private static function fromIt<T>(s:Int, hn:()->Bool, n:()->T, ?r:()->Iterator<T>):Sequence<T> {
        // create a sequence from iterator functions hasNext (hn) and next (n)
        var seq = new SequenceObject();
        seq._hn = hn;
        seq._n = n;

        // r is a function to retrieve the original iterator, so that calls to
        // iterator() can return the original iterator rather than generating a
        // cache on this sequence.
        seq._r = r;

        // prevent stack overflows in a deeply nested sequence
        seq._stackSize = s + 1;
        if (s > STACK_LIMIT)
            return (seq:Sequence<T>).force();
        else
            return seq;
    }

    private static function fromIdx<T>(s:Int, h:Int->Bool, g:Int->T, retrievable:Bool = false):Sequence<T> {
        // create a sequence from indexed functions has (h) and get (g), optionally
        // with a specified length so that calls to count() are not expensive.
        var seq = new SequenceObject();
        var index:Int = 0;
        function hn()
            return h(index);
        function n()
            return g(index++);
        seq._hn = hn;
        seq._n = n;
        seq._g = g;
        seq._h = h;

        // if retrievable is true, we generate a function to retrieve an iterator
        // so that calls to iterator() are cheaper and do not generate a cache.
        if (retrievable) {
            seq._r = () -> {
                var i = 0;
                return new FunctionalIterator(() -> seq._h(i), () -> seq._g(i++));
            }
        }

        // prevent stack overflows in a deeply nested sequence
        seq._stackSize = s + 2;
        if (s > STACK_LIMIT)
            return (seq:Sequence<T>).force();
        else
            return seq;
    }

    // check if the sequence has the given index.
    // try to avoid generating a cache by using _h, which is cacheless
    private inline function _has(index:Int) {
        collapseTail();
        if (this._h != null)
            return this._h.unsafe()(index);
        else
            return has(index);
    }

    // retrieve the element at the given index
    // try to avoid generating a cache by using _g, which is cacheless
    private inline function _get(index:Int) {
        collapseTail();
        if (this._g != null)
            return this._g.unsafe()(index);
        else
            return getValue(index);
    }

    private var self(get, never):Sequence<T>;
    private inline function get_self() return this;

    private var _this(get, never):SequenceObject<T>;
    private inline function get__this() return this;

    private static inline final STACK_LIMIT = 256;

    private function clone():SequenceObject<T> {
        var result = new SequenceObject();
        result.cache = this.cache;
        result._hn = this._hn;
        result._n = this._n;
        result._g = this._g;
        result._r = this._r;
        result._stackSize = this._stackSize;
        result.tail = this.tail;
        result.tailLength = this.tailLength;
        result.cacheComplete = this.cacheComplete;
        return result;
    }

    private function collapseTail():Void {
        if (this.tailLength == 0)
            return;
        var arr = this.tail.unsafe(), len = this.tailLength;
        this.tail = null;
        this.tailLength = 0;
        var result:Sequence<T> = clone(), index = 0, done = false;

        function hn():Bool {
            if (!done) {
                if (result._has(index))
                    return true;
                else {
                    done = true;
                    index = 0;
                }
            }
            if (done) {
                return index < len;
            }
            return false;
        }

        function n():T
            if (!done)
                return result.getValue(index++);
            else
                return arr[index++];

        this._hn = hn;
        this._n = n;
        this.cacheComplete = false;
        this._g = null;
        this._h = null;
        this._r = null;
        this.cache = [];

    }

}

private class SequenceObject<T> {

    public inline function new() cache = [];

    public var cacheComplete:Bool = false;

    public var cache:Array<T>;
    public var _hn:Null<()->Bool>;
    public var _n:Null<()->T>;
    public var _h:Null<Int->Bool>;
    public var _g:Null<Int->T>;
    public var _r:Null<()->Iterator<T>>;
    public var _stackSize:Int = 0;

    public var tail:Null<Array<T>>;
    public var tailLength:Int = 0;

    public function toString():String
        return (this:Sequence<T>).toString();

    public function iterator():Iterator<T>
        return new SequenceIterator(this);

    public function keyValueIterator():KeyValueIterator<Int,T>
        return new SequenceKeyValueIterator(this);

}

private class SequenceIterator<T> {

    var index:Int;
    var sequence:Sequence<T>;

    public inline function new(seq:Sequence<T>) {
        index = 0;
        sequence = seq;
    }

    public inline function hasNext():Bool
        return sequence.has(index);

    public inline function next():T
        return sequence.getValue(index++); 

}

private class SequenceKeyValueIterator<T> {

    var index:Int;
    var sequence:Sequence<T>;

    public inline function new(seq:Sequence<T>) {
        index = 0;
        sequence = seq;
    }

    public function hasNext():Bool
        return sequence.has(index);

    public function next()
        if (!sequence.has(index))
            throw new Exception("attempt to read from empty Iterator");
        else
            return { key: index, value: sequence.getValue(index++) }; 

}
