package wavemode.immutable.util;

// TODO: expand LinkedList API

class LinkedList<T> {
    
    public function new() {}

    public function toString():String {
        var result = new StringBuf();
        result.add("LinkedList {");
        var cut = false;

        var node = head;
        while (node != null) {
            cut = true;
            result.add(' ${node.value},');
            node = node.next;
        }

        return
            (if (cut)
                result.toString().substr(0, result.length - 1)
            else
                result.toString())
            + " }";
    }

    public function iterator():Iterator<T> {
        var node = head;
        function hn()
            return node != null;
        function n() {
            var value = node.value;
            node = node.next;
            return value;
        }
        return new FunctionalIterator(hn, n);
    }

    public function keyValueIterator():KeyValueIterator<Int, T> {
        var node = head, index = 0;
        function hn()
            return node != null;
        function n() {
            var value = node.value;
            node = node.next;
            return { key: index++, value: value };
        }
        return new FunctionalIterator(hn, n);
    }

    public function shift():Void {
        if (head != null) {
            head = head.next;
            if (head != null)
                head.prev = null;
        }
    }

    public function pop():Void {
        if (tail != null) {
            tail = tail.prev;
            if (tail != null)
                tail.next = null;
        }
    }

    public function push(value:T):Void {
        if (tail != null)
            tail = tail.next = new Node(value, null, tail);
        else
            head = tail = new Node(value);
    }

    public function unshift(value:T):Void {
        if (head != null)
            head = head.next = new Node(value, head);
        else
            head = tail = new Node(value);
    }

    public function remove(value:T):Bool {
        var node = head;
        while (node != null) {
            if (node.value == value) {
                if (node == head) {
                    shift();
                } else if (node == tail) {
                    pop();
                } else {
                    node.prev.next = node.next;
                    node.next.prev = node.prev;
                }
                return true;
            }
            node = node.next;
        }
        return false;
    }

    public function nth(index:Int):Null<T> {
        var node = head;
        while (node != null) {
            if (index-- == 0) {
                return node.value;
            }
            node = node.next;
        }
        return null;
    }

    public function removeNth(index:Int):Void {
        var node = head;
        while (node != null) {
            if (index-- == 0) {
                if (node == head) {
                    shift();
                } else if (node == tail) {
                    pop();
                } else {
                    node.prev.next = node.next;
                    node.next.prev = node.prev;
                }
                return;
            }
            node = node.next;
        }
    }

    public function equals(other:Iterable<T>):Bool {
        var node = head;
        var it:Iterator<T> = other.iterator();

        while (node != null && it.hasNext()) {
            if (node.value != it.next())
                return false;
            node = node.next;
        }

        return node == null && !it.hasNext();
    }

    public inline function empty()
        return head == null;

    private var head:Null<Node<T>>;
    private var tail:Null<Node<T>>;
}

class Node<T> {
    public inline function new(v, ?n, ?p) {
        value = v;
        next = n;
        prev = p;
    }
    public var value:T;
    public var next:Null<Node<T>>;
    public var prev:Null<Node<T>>;
}