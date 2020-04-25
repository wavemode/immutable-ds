package wavemode.immutable._internal;

class Pair<K,V> {
    public static function set<T>(value:T) return new Pair(value, value);
    public function new(k, v) {
        key = k;
        value = v;
    }
    public var key: K;
    public var value: V;
    public function toString():String
        return 'Pair($key,$value)';
}
