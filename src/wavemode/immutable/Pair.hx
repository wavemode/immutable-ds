package wavemode.immutable;

// TODO: document & test
// TODO: swap

class Pair<A, B> {

    public inline function new(a:A, b:B) {
        this.a = a;
        this.b = b;
    }

    public var a(default, null) : A;
    public var b(default, null) : B;

    public inline function setA<M>(value:M):Pair<M, B> {
        return new Pair(value, b);
    }

    public inline function setB<M>(value:M):Pair<A, M> {
        return new Pair(a, value);
    }
    public inline function updateA<M>(updater:A->M):Pair<M, B> {
        return new Pair(updater(a), b);
    }
    public inline function updateB<M>(updater:B->M):Pair<A, M> {
        return new Pair(a, updater(b));
    }

}