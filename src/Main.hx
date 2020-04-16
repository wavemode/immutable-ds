import wavemode.immutable.Struct;
import wavemode.immutable.Sequence;

class Main {
    static function main() {
        var x = new Struct<{a:Int, b:String}>(5, "hello");
        var y = new Struct<{b:String, a:Int}>(5, "hello");
        var z = new Struct<MyInfo>(5, "whatwhat");
        y = x;
        z = y;

        var t = new Struct<MyClass>(99, "99");
        var u = new Struct<OtherName>(87, "76");

        Sys.println(x.set_a(10));
        Sys.println(y.set_b("Goodbye"));
        Sys.println(t.set_b("Goodbye").b);
        Sys.println(t.b);
        u = t;
        Sys.println(u.b);
    }
}

class MyClass {
    public function new() {}
    public var a:Int = 0;
    public var b:String = "";
}

typedef OtherName = MyClass;
typedef MyInfo = Struct<{a:Int, b:String}>;
