/**
 *  Copyright (c) 2020-present, Chukwudi Okechukwu
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the root directory of this source tree.
 *
 */

package wavemode.immutable;

#if macro
import haxe.macro.Expr;
#end

import stdlib.Exception;

using wavemode.immutable.Functional;

@:using(wavemode.immutable.Macros.SequenceMacros)
abstract Sequence<T>(SequenceObject<T>) from SequenceObject<T> {


    //////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////// CREATION ////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////


    /**
        Create a new empty Sequence.
    **/
    public inline function new()
        this = new SequenceObject();

    /**
        Create a new Sequence from an immutable List.
    **/
    @:from public static function fromList<T>(list:List<T>):Sequence<T>
        return fromIdx(i->i<list.length, i->list.getValue(i), list.length);

    /**
        Create a new Sequence from an Iterable.
    **/
    @:from public static inline function from<T>(iter:Iterable<T>):Sequence<T> {
        var it = iter.iterator();
        return fromIt(it.hasNext, it.next);
    }

    /**
        Create a new Sequence from any number of values.
    **/
    public static macro function make<T>(values:Array<Expr>):ExprOf<Sequence<T>>
        return macro Sequence.from([$a{values}]);

    /**
        Create a new Sequence from an Iterator.
    **/
    @:from public static inline function fromIterator<T>(it:Iterator<T>):Sequence<T>
        return fromIt(it.hasNext, it.next);

    /**
        Create an infinite sequence of a repeating `value`.
    **/
    public static function repeat<T>(value:T):Sequence<T>
        return fromIdx(_->true, _->value);

    /**
        Create a Sequence representing numbers from `start` to `end`, inclusive.
    **/
    public static function range(start:Int, end:Int) {
        function h(index:Int)
            if (start < end)
                return start + index <= end;
            else
                return start - index >= end;

        function g(index:Int)
            if (start < end)
                return start + index;
            else
                return start - index;

        var l =
            if (start < end)
                end - start + 1;
            else
                start - end + 1;

        return fromIdx(h, g, l);

    }

    /**
        Create an infinite Sequence representing values starting at `start` and
        repeatedly passed through the `iterator` function.
    **/
    public static function iterate<T>(start:T, iterator:T->T)
        return fromIt(()->true,()->{
            var val = start;
            start = iterator(start);
            return val;
        });

    /**
        Create an infinite Sequence representing values starting at `start`
        and incremented by `step` each time.
    **/
    public static function step(start:Float, step:Float)
        return fromIdx(_->true, i->start+step*i);
    

    //////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////// OPERATIONS ///////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////


    /**
        Returns the value at position `index` in this Sequence, or null if the
        index is out of bounds.

        Calls to `get()` are cached internally, as the data in the underlying
        iterator is expected to be immutable.
    **/
    public function get(index:Int):Null<T>
        if (has(index))
            return cacheGet(index);
        else
            return null;

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
    public function empty():Bool
        return !has(0);

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
            if (index >= length)
                throw new Exception('index $index out of bounds for Sequence');
            return getValue(length-index);
        }

        return fromIdx(h, g);

    }

    /**
        Returns a sorted Sequence according to the comparison function `f`, where
        `f(x,y)` returns a negative integer if `x` should be before `y`, a positive
        integer if `y` should be before `x`, and zero if the values are equivalent.

        For example, `[5, 4, 3, 2, 1].sort((x, y) -> x - y)` returns `[1, 2, 3, 4, 5]`
    **/
    public function sort(f:(T,T)->Int):Sequence<T> {

        var seq:Array<T>;
        var index = -1;

        function g():Void
            if (index == -1) {
                var c = count();
                seq = [];
                //seq.resize(c);
                for (i in 0...c)
                    seq.push(getValue(i));
                seq.sort(f);
                index = 0;
            }

        function hn():Bool {
            g();
            return index < seq.length;
        }

        function n():T {
            g();
            return seq[index++];
        }

        return fromIt(hn, n);

    }

    /**
        Evaluates and caches every value in the Sequence.
    **/
    public inline function force():Sequence<T> {
        if (isIterating())
            count();
        else {
            // this will turn a cacheless sequence into a cached one
            this.cache = [];
            var index:Int = 0;
            while (has(index))
                this.cache.sure().push(getValue(index++));
            this._len = index;
            this._g = null;
            this._h = null;
            this._hn = () -> false;
        }
        return this;
    }


    //////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////// SLICES /////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////


    /**
        Returns elements starting from and including `pos`, ending at but not including `end`.

        If `pos` is negative, its value is calculated from the end of the Sequence.
    **/
    public function slice(pos:Int, ?end:Int):Sequence<T> {
        
        while (pos < 0)
            pos += count();

        function h(index:Int):Bool
            if (end == null)
                return has(pos+index);
            else
                return (pos+index)<end.sure() && has(pos+index); 

        function g(index:Int):T
            return getValue(pos+index);

        return fromIdx(h, g);

    }

    /**
        Returns a new Sequence containing `len` elements (all elements if len is null)
        from this Sequence, starting at and including `pos`.

        If `pos` is negative, its value is calculated from the end of the Sequence.
    **/
    public function splice(pos:Int, ?len:Int):Sequence<T> {
        
        while (pos < 0)
            pos += count();

        function h(index:Int):Bool
            if (len == null)
                return has(pos+index);
            else
                return index<len.sure() && has(pos+index); 

        function g(index:Int):T
            return getValue(pos+index);

        return fromIdx(h, g);

    }

    /**
        Returns a new Sequence with values not satisfying `predicate` removed.
    **/
    public function filter(predicate:T->Bool):Sequence<T> {

        var index:Int = 0;
        var nextVal:T;
        var valid:Bool = false;

        function getNext():Void
            while (true)
                if (!valid) {
                    if (!has(index))
                        return;
                    nextVal = getValue(index++);
                    valid = predicate(nextVal);
                } else break;

        function hasNext():Bool {
            getNext();
            return valid;
        }

        function next():T {
            getNext();
            if (!valid)
                throw new Exception("attempt to read from empty Iterator");
            valid = false;
            return nextVal;
        }

        return fromIt(hasNext, next);

    }

    /**
        Returns a new Sequence with all intances of the given value removed.
    **/
    public function remove(value:T):Sequence<T> {

        var index:Int = 0;
        var nextVal:T;
        var valid:Bool = false;

        function getNext():Void
            while (true)
                if (!valid) {
                    if (!has(index))
                        return;
                    nextVal = getValue(index++);
                    valid = nextVal != value;
                } else break;

        function hasNext():Bool {
            getNext();
            return valid;
        }

        function next():T {
            getNext();
            if (!valid)
                throw new Exception("attempt to read from empty Iterator");
            valid = false;
            return nextVal;
        }

        return fromIt(hasNext, next);

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

        function getNext():Void
            while (true)
                if (!valid) {
                    if (!has(index))
                        return;
                    nextVal = getValue(index++);
                    valid = values.find(nextVal) == -1;
                } else break;

        function hasNext():Bool {
            getNext();
            return valid;
        }

        function next():T {
            getNext();
            if (!valid)
                throw new Exception("attempt to read from empty Iterator");
            valid = false;
            return nextVal;
        }

        return fromIt(hasNext, next);

    }

    /**
        Returns a new Sequence with the given index deleted.
    **/
    public function delete(index:Int):Sequence<T> {

        if (index < 0)
            return this;

        function h(i:Int):Bool {
            if (i < index)
                return has(i);
            else
                return has(i+1);
        }

        function g(i:Int) {
            if (i < index)
                return getValue(i);
            else
                return getValue(i+1);
        }

        return fromIdx(h, g);

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

        function getNext():Void
            while (true)
                if (!valid) {
                    if (!has(index))
                        return;
                    else if (indices.find(index) != -1) {
                        ++index;
                        continue;
                    }
                    nextVal = getValue(index++);
                    valid = true;
                } else break;

        function hasNext():Bool {
            getNext();
            return valid;
        }

        function next():T {
            getNext();
            if (!valid)
                throw new Exception("attempt to read from empty Iterator");
            valid = false;
            return nextVal;
        }

        return fromIt(hasNext, next);

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
                start = count() - num;


        function h(index:Int):Bool {
            getStart();
            return has(index+start);
        }

        function g(index:Int):T {
            getStart();
            return getValue(index+start);
        }

        return fromIdx(h, g);

    }

    /**
        Returns a Sequence with every value removed after
        `predicate` returns false.
    **/
    public function takeWhile(predicate:T->Bool):Sequence<T> {

        function h(index:Int):Bool
            return has(index) && predicate(getValue(index));

        return fromIdx(h, getValue);

    }

    /**
        Returns a Sequence with every value removed after
        `predicate` returns true.
    **/
    public function takeUntil(predicate:T->Bool):Sequence<T> {

        function h(index:Int):Bool
            return has(index) && !predicate(getValue(index));

        return fromIdx(h, getValue);

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
        return splice(0, num);

    /**
        Returns a Sequence with every value dropped as long as
        `predicate` returns true.
    **/
    public function dropWhile(predicate:T->Bool):Sequence<T> {
        
        var start:Int = -1;

        function getStart():Void
            if (start == -1) {
                start = 0;
                while (has(start) && predicate(getValue(start)))
                    ++start;
            }


        function h(index:Int):Bool {
            getStart();
            return has(index+start);
        }

        function g(index:Int):T {
            getStart();
            return getValue(index+start);
        }

        return fromIdx(h, g);

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
                while (has(start) && !predicate(getValue(start)))
                    ++start;
            }


        function h(index:Int):Bool {
            getStart();
            return has(index+start);
        }

        function g(index:Int):T {
            getStart();
            return getValue(index+start);
        }

        return fromIdx(h, g);

    }


    //////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////// MAPPINGS ////////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////


    /**
        Returns a new Sequence with each element passed through `mapper`.
    **/
    public function map<M>(mapper:T->M):Sequence<M> {
        var index:Int = 0;
        var valid:Bool = false;
        var nextVal:M;

        function getNext():Void
            if (!valid)
                if (!has(index))
                    return;
                else {
                    nextVal = mapper(getValue(index++));
                    valid = true;
                }

        function hasNext():Bool {
            getNext();
            return valid;
        }

        function next():M {
            getNext();
            if (!valid)
                throw new Exception("attempt to read from empty Iterator");
            valid = false;
            return nextVal;
        }

        return fromIt(hasNext, next);
    }

    /**
        Returns a new Sequence with each index and corresponding element passed
        through `mapper`.
    **/
    public function mapIndex<M>(mapper:(Int,T)->M):Sequence<M> {
        
        var index:Int = 0;
        var valid:Bool = false;
        var nextVal:M;

        function getNext():Void
            if (!valid)
                if (!has(index))
                    return;
                else {
                    nextVal = mapper(index, getValue(index));
                    ++index;
                    valid = true;
                }

        function hasNext():Bool {
            getNext();
            return valid;
        }

        function next():M {
            getNext();
            if (!valid)
                throw new Exception("attempt to read from empty Iterator");
            valid = false;
            return nextVal;
        }

        return fromIt(hasNext, next);

    }

    /**
        `mapper` is a function that returns an Iterable type (Array, List,
        Map, etc.)
            
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

        function getNextElement():Void
            while (true) {
                if (!iterValid) {
                    if (!has(index))
                        return;
                    nextIter = mapper(getValue(index++)).iterator();
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

        function hasNext():Bool {
            getNextElement();
            return valid;
        }

        function next():N {
            getNextElement();
            if (!valid)
                throw new Exception("attempt to read from empty Iterator");
            valid = false;
            return nextElement;
        }

        return fromIt(hasNext, next);

    }

    /**
        Returns a new Sequence with the `nth` value replaced by `value`.
    **/
    public function set(nth:Int, value:T):Sequence<T>
        return fromIdx(has, i -> if (i == nth) value else getValue(i), this._len);

    /**
        Returns a new sequence with each index in `indices` replaced by the respective
        value in `values`.

        Equivalent to calling `set()` for each index individually, but potentially more
        efficient.
    **/
    public function setEach(indices:Sequence<Int>, values:Sequence<T>):Sequence<T> {

        function g(i:Int):T {
            var rpl = indices.find(i);
            if (rpl != -1 && values.has(rpl))
                return values.getValue(rpl);
            else
                return getValue(i);
        }

        return fromIdx(has, g, this._len);

    }

    /**
        Returns a new Sequence with the `nth` element passed through the
        `updater` function.
    **/
    public function update(nth:Int, updater:T->T):Sequence<T> {

        var index:Int = 0;
        var valid:Bool = false;
        var nextVal:T;

        function gv():Void
            if (!valid) {
                if (!has(index))
                    return;
                nextVal = getValue(index);
                if (nth == index)
                    nextVal = (updater(nextVal));
                ++index;
                valid = true;
            }

        function hasNext():Bool {
            gv();
            return valid;
        }

        function next():T {
            gv();
            if (!valid)
                throw new Exception("attempt to read exmpty Iterator");
            valid = false;
            return nextVal;
        }

        return fromIt(hasNext, next);

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
                if (!has(index))
                    return;
                nextVal = getValue(index);
                var nth = indices.find(index);
                if (nth != -1)
                    nextVal = (updater(nextVal));
                ++index;
                valid = true;
            }

        function hasNext():Bool {
            gv();
            return valid;
        }

        function next():T {
            gv();
            if (!valid)
                throw new Exception("attempt to read exmpty Iterator");
            valid = false;
            return nextVal;
        }

        return fromIt(hasNext, next);

    }

    /**
        Returns a new Sequence with all instances of `oldVal` replaced by `newVal`.
    **/
    public inline function replace(oldVal:T, newVal:T):Sequence<T>
        return fromIdx(has, i -> {
            var value = getValue(i);
            if (value == oldVal)
                newVal;
            else
                value;
        }, this._len);

    /**
        Returns a new Sequence with all instances of values in `oldVals` replaced by
        the corresponding value in `newVal`.

        Equivalent to calling `replace` for each value individually, but potentially
        more efficient.
    **/
    public function replaceEach(oldVals:Sequence<T>, newVals:Sequence<T>):Sequence<T> {

        return fromIdx(has, i -> {
            var value = getValue(i);
            var index = oldVals.find(value);
            if (index != -1 && newVals.has(index))
                newVals.getValue(index);
            else
                value;
        }, this._len);

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
            
            var seq = Sequence.from([1, 2, 3, null, null, null])
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
            if (!has(readIndex)) {
                return false;
            } else {
                var value = getValue(readIndex++);
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

            if (getNth(nth, 0).empty())
                return null;

            var index = 0;
            var nextVal:Null<T> = null;

            function gv():Void
                if (nextVal.empty())
                    nextVal = getNth(nth, index++);

            function hasNext():Bool {
                gv();
                return !nextVal.empty();
            }

            function next():T {
                gv();
                if (nextVal.empty())
                    throw new Exception("attempt to read from empty Iterator");
                var val = nextVal.sure();
                nextVal = null;
                return val;
            }

            return fromIt(hasNext, next);

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

        return fromIt(hasNext, next);

    }


    //////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////// REDUCTIONS ///////////////////////////////////////
    //////////////////////////////////////////////////////////////////////////////////////////


    /**
        Returns the accumulation of this Sequence accourding to `reducer`.

        For example, `[1, 2, 3, 4].reduce((a, b) -> a + b)` returns `10`

        Throws an Exception if the Sequence is empty.
    **/
    public function reduce(reducer:(T,T)->T):T {

        if (!has(0))
            throw new Exception("attempt to reduce empty Sequence");

        var index:Int = 0;
        var value:T = getValue(0);

        while (has(index+1))
            value = reducer(value, getValue(++index));

        return value;

    }

    /**
        Returns the accumulation of this Sequence accourding to `reducer`.

        For example, `[1, 2, 3, 4].reduceRight((a, b) -> a + b)` returns `10`

        Throws an Exception if the Sequence is empty. Equivalent to `reduce()`,
        but iterating in reverse.
    **/
    public function reduceRight(reducer:(T,T)->T):T {

        var index:Int = count() - 1;

        if (!has(index))
            throw new Exception("attempt to reduce empty Sequence");

        var value:T = getValue(index);

        while (has(index-1))
            value = reducer(value, getValue(--index));

        return value;

    }

    /**
        Returns true if the given `index` exists in this Sequence.
    **/
    public inline function has(index:Int):Bool
        return cacheExpand(index);

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
    public function count():Int {

        if (this._len != null)
            return this._len.sure();

        var i = 0;
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
            if (!predicate(getValue(index++)))
                return false;

        return true;

    }

    /**
        Returns true if the given `predicate` is true for any value in the Sequence.
    **/
    public function some(predicate:T->Bool):Bool {

        var index:Int = 0;

        while (has(index))
            if (predicate(getValue(index++)))
                return true;

        return false;

    }

    /**
        Returns true if this Sequence and the given `object` contain identical values.
    **/
    public function equals(object:Iterable<T>):Bool {
        
        var index:Int = 0;
        var seq:Iterator<T> = object.iterator();

        while (has(index) && seq.hasNext()) {
            if (getValue(index) != seq.next())
                return false;
            ++index;
        }

        return !has(index) && !seq.hasNext();

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
            if (getValue(index) == value)
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
            if (predicate(getValue(index)))
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
            sideEffect(getValue(index++));
    }

    /**
        A function is executed on each value in the Sequence until it returns false.

        This function returns the number of times `sideEffect` was executed.
    **/
    public function forWhile(sideEffect:T->Bool):Int {
        var index:Int = 0;

        while (has(index))
            if (!sideEffect(getValue(index++)))
                break;

        return index;
    }


    ///////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////// MUTATIONS ////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////


    /**
        Returns a new Sequence with the given value appended to the end.
    **/
    public function push(value:T):Sequence<T> {

        var index:Int = 0;
        var nextVal:T;
        var valid = false;
        var done = false;

        function gv()
            if (!valid) {
                if (has(index)) {
                    nextVal = getValue(index);
                } else if (!done) {
                    nextVal = value;
                    done = true;
                } else return;
                ++index;
                valid = true;
            }

        function hn():Bool {
            gv();
            return valid;
        }

        function n():T {
            gv();
            if (!valid)
                throw new Exception("attempt to read from empty Iterator");
            valid = false;
            return nextVal;
        }

        return fromIt(hn, n);

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
    public function pop():Sequence<T> {

        var index:Int = 0;

        function hn():Bool
            return has(index) && has(index+1);

        function n():T
            return getValue(index++);

        return fromIt(hn, n);

    }

    /**
        Returns a new Sequence with a given `value` prepended to the front.
    **/
    public function unshift(value:T):Sequence<T> {

        function h(index:Int):Bool
            return index == 0 || has(index-1);

        function g(index:Int):T
            if (index == 0)
                return value;
            else
                return getValue(index-1);

        return fromIdx(h, g);

    }

    /**
        Returns a new Sequence with the first item removed.
    **/
    public inline function shift():Sequence<T>
        return slice(1);

    /**
        Returns a new Sequence with the given `value` inserted at `index`.
    **/
    public function insert(index:Int, value:T):Sequence<T> {

        if (index < 0)
            return this;

        function h(i:Int):Bool
            if (i < index)
                return has(i);
            else if (i > index)
                return has(i-1);
            else
                return true;
        
        function g(i:Int):T
            if (i < index)
                return getValue(i);
            else if (i > index)
                return getValue(i-1);
            else
                return value;

        return fromIdx(h, g);

    }

    /**
        Returns a new Sequence with the given `values` appended to the end.
    **/
    public function concat(values:Sequence<T>):Sequence<T> {

        var index:Int = 0;
        var nextVal:T;
        var valid = false;
        var done = false;

        function gv():Void
            if (!valid) {
                if (done || !has(index)) {
                    if (!done) {
                        done = true;
                        index = 0;
                    }
                    if (!values.has(index))
                        return;
                    nextVal = values.getValue(index++);
                } else {
                    if (!has(index))
                        return;
                    nextVal = getValue(index++);
                }
                valid = true;
            }

        function hn():Bool {
            gv();
            return valid;
        }

        function n():T {
            gv();
            if (!valid)
                throw new Exception("attempt to read from empty Iterator");
            valid = false;
            return nextVal;
        }

        return fromIt(hn, n);

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
                        if (!has(index)) {
                            ++seqIndex;
                            index = 0;
                        } else {
                            nextVal = getValue(index);
                            valid = true;
                            ++index;
                        }
                    } else {
                        if (!sequences.has(seqIndex))
                            return;
                        var seq = sequences.getValue(seqIndex);
                        if (!seq.has(index)) {
                            ++seqIndex;
                            index = 0;
                        } else {
                            nextVal = seq.getValue(index);
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
            if (!valid)
                throw new Exception("attempt to read from empty Iterator");
            valid = false;
            return nextVal;
        }

        return fromIt(hn, n);

    }

    /**
        Takes Sequence A and Sequence B and creates a new Sequence where the i'th element
        is the sequence [A[i], B[i]]

        For example, `[1, 2, 3].zip([4, 5, 6])` results in `[[1, 4], [2, 5], [3, 6]]`
    **/
    public function zip(other:Sequence<T>):Sequence<Sequence<T>> {

        function h(index:Int):Bool
            return has(index) && other.has(index);

        function g(index:Int):Sequence<T>
            return fromIdx(i -> i < 2, i -> if (i == 0) getValue(index) else other.getValue(index));

        return fromIdx(h, g);

    }

    /**
        Returns a new Sequence with the given `separator` interposed between each element.
    **/
    public function separate(separator:T):Sequence<T> {

        function h(index:Int):Bool
            if (index % 2 == 0)
                return has(Std.int(index / 2));
            else
                return has(Std.int((index + 1) / 2));

        function g(index:Int):T
            if (index % 2 == 0)
                return getValue(Std.int(index / 2));
            else
                return separator;

        return fromIdx(h, g);

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
                        var len:Int = thisLength.sure(), i = index - len;
                        if (!other.has(i))
                            return;
                        nextVal = other.getValue(i);
                        valid = true;
                        ++index;
                    } else if (otherLength != null) {
                        var len:Int = otherLength.sure(), i = index - len;
                        if (!has(i))
                            return;
                        nextVal = getValue(i);
                        valid = true;
                        ++index;
                    } else if (index % 2 == 0) {
                        var i = Std.int(index / 2);
                        if (!has(i)) {
                            thisLength = i;
                            continue;
                        }
                        nextVal = getValue(i);
                        valid = true;
                        ++index;
                    } else {
                        var i = Std.int((index - 1) / 2);
                        if (!other.has(i)) {
                            otherLength = i;
                            continue;
                        }
                        nextVal = other.getValue(i);
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
            if (!valid)
                throw new Exception("attempt to read from empty Iterator");
            valid = false;
            return nextVal;
        }

        return fromIt(hn, n);

    }


    /////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////// CONVERSIONS //////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////

    /**
        An iterator over all of this Sequence's elements.
    **/
    public inline function iterator():Iterator<T>
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
        Iterator oveer each index-value pair in the Sequence. Equivalent to `keyValueIterator()`
    **/
    public inline function entries():KeyValueIterator<Int,T>
        return keyValueIterator();

    /**
        Convert this Sequence to an Array.
    **/
    public inline function toArray():Array<T> {
        var result:Array<T> = [];
        var index:Int = 0;
        while (has(index))
            result.push(getValue(index++));
        return result;
    }

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
        return new List().pushEach(values());

    /**
        Convert this Sequence to an immutable Stack of its values.
    **/
    public inline function toStack():Stack<T>
        return new Stack().pushEach(values());

    /**
        Retrieve a string representation of the Sequence.
    **/
    public inline function toString():String {
        var result = "Sequence {";
        var cut = false;

        var index:Int = 0;
        while (has(index)) {
            cut = true;
            result += ' ${getValue(index++)},';
        }

        if (cut)
            result = result.substr(0, result.length - 1);
        return result + " }";
    }


    /////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////// INTERNALS ///////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////


    private inline function cacheExpand(index:Int):Bool {

        if (index < 0)
            return false;

        if (isIterating()) {
            if (this.cacheComplete)
                return cachedLength() > index;

            while (cachedLength() <= index && 
                if (this._hn()) {
                    true;
                } else {
                    this._hn = () -> false;
                    this._n = null;
                    this.cacheComplete = true;
                    this._len = cachedLength();
                    false;
                })
            {
                this.cache.sure().push(this._n.sure()());
            }

            return cachedLength() > index;

        } else if (isIndexed()) {

            return this._h(index);

        } else return false;

    }

    private inline function cachedLength():Int
        if (this._len != null)
            return this._len.sure();
        else 
            return this.cache.sure().length;

    private inline function cacheGet(index:Int):T
        if (isIterating())
            return this.cache.sure()[index];
        else
            return this._g.sure()(index);

    private inline function isIndexed():Bool
        return this._h != null;

    private inline function isIterating():Bool
        return this._hn != null;

    private static inline function fromIt<T>(hn:()->Bool, n:()->T):Sequence<T> {
        // create a cached sequence from an iterator
        var seq = new SequenceObject();
        seq._hn = hn;
        seq._n = n;
        seq.cache = [];
        return seq;
    }

    private static inline function fromIdx<T>(h:Int->Bool, g:Int->T, ?len:Int):Sequence<T> {
        // create a cacheless sequence
        var seq = new SequenceObject();
        seq._h = h;
        seq._g = g;
        seq._len = len;
        seq.cacheComplete = len != null;
        trace("fromIdx! len: " + len);
        return seq;
    }

    private var self(get, never):Sequence<T>;
    private inline function get_self() return this;

}

private class SequenceObject<T> {

    public inline function new() {}

    public var cacheComplete:Bool = false;

    public var cache:Null<Array<T>>;
    public var _hn:Null<()->Bool>;
    public var _n:Null<()->T>;
    public var _h:Null<Int->Bool>;
    public var _g:Null<Int->T>;

    public var _len:Null<Int>;

    public function toString():String
        return (this:Sequence<T>).toString();

}

private class SequenceIterator<T> {

    var index:Int;
    var sequence:Sequence<T>;

    public inline function new(seq:Sequence<T>) {
        index = 0;
        sequence = seq;
    }

    public function hasNext():Bool
        return sequence.has(index);

    public function next():T
        if (!sequence.has(index))
            throw new Exception("attempt to read from empty Iterator");
        else
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
