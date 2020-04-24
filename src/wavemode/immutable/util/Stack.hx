package wavemode.immutable.util;

class Stack<T> {
    public function new() {}
    public inline function push(value:T):Stack<T> {
        var result = new Stack();
        result.value = value;
        result.next = this;
        result.empty = false;
        return result;
    }
    public inline function pop():Null<Stack<T>>
        return next;
    public inline function top():Null<T>
        return next.value;
    public function iterator() {
        var node = this;
        function hn()
            return node != null && !node.empty;
        function n() {
            var val = node.value;
            node = node.next;
            return val;
        }
        return new FunctionalIterator(hn, n);
    }
    public function reverse():Stack<T> {
        var result = new Stack();
        for (v in this)
            result = result.push(v);
        return result;
    }
    public var value(default, null):Null<T>;
    public var next(default, null):Null<Stack<T>>;
    private var empty:Bool = true;
}