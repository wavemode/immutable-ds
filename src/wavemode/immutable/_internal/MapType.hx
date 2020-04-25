package wavemode.immutable._internal;

interface MapType<K, V> {
    public function has(k:K):Bool;
    public function get(k:K):Null<V>;
    public var length(get, never):Int;
}