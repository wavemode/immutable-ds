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
import haxe.ds.List as LinkedList;
import stdlib.Exception;

class Stack<T> {

    private var data: LinkedList<T>;

    //////////////////////////////////////////////////////////////////////////////////////////////////////////
	////// API
	//////////////////////////////////////////////////////////////////////////////////////////////////////////

    /**
        Creates a new Stack from the values in `arr`.
    **/
    public static inline function from<T>(other:Iterable<T>) {
        return new Stack().pushEach(other);
    }

    /**
        Iterator over each value in the Stack.
    **/
    public function iterator():Iterator<T> {
        var d = data;
        return {
            hasNext: () -> !d.equals(Empty),
            next: () -> {
                switch d {
                    case Node(elem, next):
                        d = next;
                        elem;
                    default:
                        throw new Exception("attempted to read from empty Stack iterator");
                }
            }
        };
    }

    /**
        Iterator over each value in the Stack.

        Equivalent to `iterator()`
    **/
    public inline function values():Iterator<T> {
        return iterator();
    }

    /**
        Create an empty Stack.
    **/
    public function new() {
        data = Empty;
    }

    /**
        Returns an empty Stack.
    **/
    public inline function clear() : Stack<T> {
        return new Stack();
    }

    /**
        Returns the element on top of the Stack, or None if it is empty.
    **/
    public function peek() : Option<T> {
        switch data {
            case Node(elem, _):
                return Some(elem);
            case Empty:
                return None;
        };
    }
        
    /**
        Unsafe variant of `peek()`. Returns the element on top of the Stack,
        or throws an Exception if it is empty.
    **/
    public function peekValue():T {
        switch data {
            case Node(elem, _):
                return elem;
            case Empty:
                throw new Exception("Stack is empty");
        };
    }

    /**
        Returns true if the Stack is empty.
    **/
    public function empty() : Bool {
        return data.equals(Empty);
    }

    /**
        Returns a new Stack with the top value removed.
    **/
    public function pop() : Stack<T> {
        var stack = new Stack();
        switch data {
            case Node(elem, next):
                stack.data = next;
            case Empty:
                stack.data = Empty;
        }
        return stack;
    }

    /**
        Returns a new Stack with the given `value` added to the top.
    **/
    public function push(value:T) : Stack<T> {
        var stack = new Stack();
        stack.data = Node(value, data);
        return stack;
    }

    /**
        Returns a new Stack with the given `values` added to the top.
    **/
    public function pushEach(values:Iterable<T>) : Stack<T> {
        var stack = this;
        for (v in values) stack = stack.push(v);
        return stack;
    }

    /**
        Counts the number of elements in the Stack.
    **/
    public function count() {
        var i = 0, d = data;
        while (!d.equals(Empty)) {
            switch d {
                case Node(elem, next):
                    d = next;
                default:
            }
            ++i;
        }
        return i;
    }
    
    /**
        Returns a new Stack with the top value replace with the given `value`. 
    **/
    public function swap(value:T) : Stack<T> {
        var stack = new Stack(), d = data;
        switch d {
            case Node(elem, next):
                stack.data = Node(value, next);
            case Empty:
                stack.data = Empty;
        }
        return stack;
    }

    /**
        Returns a new List with the values in this Stack.
    **/
    public function toList():List<T> {
        return new List().pushEach(values().iterable());
    }

    /**
        Returns true if this Stack and `other` have identical values
    **/
    public function equals(other:Iterable<T>):Bool {
        var iter = other.iterator(), thisIter = iterator();
        while(iter.hasNext() && thisIter.hasNext())
            if (iter.next() != thisIter.next()) return false;
        return !(iter.hasNext() || thisIter.hasNext());
    }

    /**
        Returns a Sequence of the values in this Stack.
    **/
    public function toSequence():Sequence<T> {
        return null;
    }

    /**
        Convert this Stack into an Array<T>
    **/
    public function toArray():Array<T> {
        return [for (v in this) v];
    }

}

private enum LinkedList<T> {
    Empty;
    Node(elem:T, next:LinkedList<T>);
}