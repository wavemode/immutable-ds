package wavemode.immutable;

import wavemode.immutable._internal.FunctionalIterator;
using wavemode.immutable._internal.Functional;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
#end

class Stack<T> {
    
    /**
        Create a new empty Stack, or a clone of the given iterable.
    **/
    public function new(?values:Sequence<T>) {
        if (values != null) {
            var result = new Stack().pushEach(values);
            this.value = result.value;
            this.next = result.next;
        }
    }

    /**
        Macro to create a new Stack from any number of values.
    **/
    public static macro function make<T>(values:Array<ExprOf<T>>):ExprOf<Stack<T>>
        return macro @:pos(Context.currentPos()) new Stack().pushEach([$a{values}]);

    /**
        Returns the value on top of the Stack, or null if the Stack is empty.
    **/
    public inline function peek():Null<T>
        return value;

    /**
        Return a new Stack with the given value pushed on top.
    **/
    public inline function push(value:T):Stack<T> {
        var result = new Stack();
        result.value = value;
        result.next = this;
        return result;
    }

    /**
        Return a new Stack with the given values each pushed on top.
    **/
    public inline function pushEach(values:Sequence<T>):Stack<T> {
        var result = this;
        for (v in values)
            result = result.push(v);
        return result;
    }

    /**
        Return a new stack with the top value removed.
    **/
    public inline function pop():Stack<T>
        if (next != null)
            return next.unsafe();
        else
            return this;

    /**
        Iterator of each value from the top of the Stack to the bottom.
    **/
    public function iterator():Iterator<T> {
        var node:Null<Stack<T>> = this;
        function hn():Bool
            return node.unsafe().value != null;
        function n():T {
            var val = node.unsafe().value;
            node = node.unsafe().next;
            return val.unsafe();
        }
        return new FunctionalIterator(hn, n);
    }

    /**
        Sequence of this Stack's values.
    **/
    public inline function toSequence():Sequence<T>
        return iterator();

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
}