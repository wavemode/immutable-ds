package wavemode.immutable.util;

class Stack<T> {
    public function new(?v, ?n) {
        value = v;
        next = n;
    }
    public inline function push(value:T):Stack<T>
        return new Stack(value, this);
    public inline function pop():Null<Stack<T>>
        return next;
    public inline function top():Null<T>
        return next.value;
    public function iterator() {
        var node = this;
        function hn()
            return node != null;
        function n() {
            var val = node.value;
            node = node.next;
            return val;
        }
        return new FunctionalIterator(hn, n);
    }
    private var value:Null<T>;
    private var next:Null<Stack<T>>;
}