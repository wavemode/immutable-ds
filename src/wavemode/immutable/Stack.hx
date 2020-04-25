package wavemode.immutable;

import wavemode.immutable._internal.FunctionalIterator;
using wavemode.immutable.Functional;

// TODO: stack test suite

class Stack<T> {
    
    /**
        Create a new empty Stack.
    **/
    public function new() {}

    /**
        Return a new Stack with the given value pushed on top.
    **/
    public inline function push(value:T):Stack<T> {
        var result = new Stack();
        result.value = value;
        result.next = this;
        result.empty = false;
        return result;
    }

    /**
        Return a new stack with the top value removed.
    **/
    public inline function pop():Stack<T>
        if (next == null)
            return this;
        else
            return next.unsafe();

    /**
        Iterator of each value from the top of the Stack to the bottom.
    **/
    public function iterator():Iterator<T> {
        var node:Null<Stack<T>> = this;
        function hn():Bool
            return node != null && !node.unsafe().empty;
        function n():T {
            var val = node.unsafe().value;
            node = node.unsafe().next;
            return val.unsafe();
        }
        return new FunctionalIterator(hn, n);
    }

    /**
        Returns a new Stack with the values in reverse order.
    **/
    public function reverse():Stack<T> {
        var result = new Stack<T>();
        for (v in this)
            result = result.push(v);
        return result;
    }

    private var value:Null<T>;
    private var next:Null<Stack<T>>;
    private var empty:Bool = true;
}