package wavemode.immutable;

@:forward abstract Hash(Int) to Int {

    @:from public static inline function fromString(s : String) : Hash {
        return null;
    }

    @:from public static inline function fromInt(s : Int) : Hash {
        return null;
    }

    @:from public static inline function fromFloat(s : Float) : Hash {
        return null;
    }

    @:from public static inline function fromObject<T:{function hashCode() : Int;}>(s : T) : Hash {
        return null;
    }

    public inline function get() return this;

}
