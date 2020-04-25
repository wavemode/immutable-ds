package wavemode.immutable._internal;

class FunctionalIterator<T> {
    public inline function hasNext()
        return _hn();
    public inline function next()
        return _n();
    private var _hn:()->Bool;
    private var _n:()->T;
    public inline function new(hn, n) {
        _hn = hn;
        _n = n;
    }
}