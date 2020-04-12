/**
 *  Copyright (c) 2020-present, Chukwudi Okechukwu
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the root directory of this source tree.
 *
 */

package wavemode.immutable;

using wavemode.immutable.Functional;
import stdlib.Exception;

#if macro
import haxe.macro.Expr;
#end

@:forward
abstract Stack<T>(StackObject<T>) from StackObject<T> to StackObject<T> {

    /**
        Create a new empty Stack, or a clone of the values in `object`
    **/
    public inline function new(?object:Sequence<T>)
        if (object != null)
            this = fromSequence(object);
        else
            this = new StackObject<T>();

    /**
        Creates a new Stack from the values in `arr`.
    **/
    public static inline function fromSequence<T>(arr:Sequence<T>):Stack<T>
        return new Stack().pushEach(arr);

    /**
        Macro to create a new Stack from any number of values.
    **/
    public static macro function make<T>(exprs:Array<ExprOf<T>>):ExprOf<Stack<T>>
        return macro Stack.fromSequence([$a{exprs}]);

}

private class StackObject<T> {

    /**
        Returns a new Stack with the given `value` added to the top.
    **/
    public function push(value:T):Stack<T> {
        var stack = new Stack();
        stack.data = Node(value, data);
        return stack;
    }

    /**
        Returns a new Stack with the given `values` added to the top.
    **/
    public function pushEach(values:Sequence<T>):Stack<T> {
        var stack = this;
        for (v in values) stack = stack.push(v);
        return stack;
    }

    /**
        Returns a new Stack with the top value removed.
    **/
    public function pop():Stack<T> {
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
        Returns true if the Stack is empty.
    **/
    public function empty():Bool
        return data.equals(Empty);

    /**
        Returns the element on top of the Stack, or null if it is empty.
    **/
    public function peek():Null<T> {
        switch data {
            case Node(elem, _):
                return elem;
            case Empty:
                return null;
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
                throw new Exception("attempt to peek empty Stack");
        };
    }

    /**
        Returns an empty Stack.
    **/
    public inline function clear() : Stack<T>
        return new Stack();

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
        Returns true if this Stack and `other` have identical values
    **/
    public function equals(other:Sequence<T>):Bool {
        var iter = other.iterator(), thisIter = iterator();
        while(iter.hasNext() && thisIter.hasNext())
            if (iter.next() != thisIter.next()) return false;
        return !(iter.hasNext() || thisIter.hasNext());
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
    public inline function values():Iterator<T>
        return iterator();

    /**
        Convert this Stack into an Array<T>
    **/
    public inline function toArray():Array<T>
        return [for (v in this) v];

    /**
        Returns a new Vector with the values in this Stack.
    **/
    public inline function toVector():Vector<T>
        return Vector.fromSequence(values());

    /**
        Convert this Stack to its String representation.
    **/
    public function toString():String {
        var result = "Stack {";
        var cut = false;

        for (v in this) {
            cut = true;
            result += ' $v,';
        }

        if (cut)
            result = result.substr(0, result.length - 1);
        return result + " }";
    }

    /**
        Returns a Sequence of the values in this Stack.
    **/
    public inline function toSequence():Sequence<T>
        return toVector().toSequence();

    public function new() data = Empty;
    private var data: LinkedList<T>;

}

private enum LinkedList<T> {
    Empty;
    Node(elem:T, next:LinkedList<T>);
}