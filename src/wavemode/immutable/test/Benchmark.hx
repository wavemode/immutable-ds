package wavemode.immutable.test;

import haxe.macro.Context;
#if macro
import haxe.macro.Expr;
#end

import haxe.Timer;

class Benchmark {
    static function main() {
        // bench("Array.push",
        //     var arr = [],
        //     arr.push(10));
        // bench("haxe.ds.Map.set",
        //     var map = new haxe.ds.Map(),
        //     map.set(__i__, __i__));
        // bench("Map.set", 
        //     var map = new Map(),
        //     map = map.set(__i__, __i__));
        bench("Map.get",
            var map = new Map().setEach(Sequence.step().take(1000000), Sequence.step().take(1000000)),
            var val = map.get(__i__));
        // bench("Vector.push",
        //     var vec = new Vector(),
        //     vec = vec.push(10));
        // bench("Sequence.push",
        //     var vec = new Sequence(),
        //     vec = vec.push(10)
        // );
        // bench("OrderedMap.set", 
        //     var map = new OrderedMap(),
        //     map = map.set(__i__, __i__)
        // );
        // bench("Set.add", 
        //     var set = new Set(),
        //     set = set.add(__i__)
        // );
        // bench("OrderedSet.add", 
        //     var set = new OrderedSet(),
        //     set = set.add(__i__)
        // );
    }

    static macro function bench(label:String, setup:Expr, expr:Expr):Expr {
        return macro {
            var before:Float = 0.0;
            var diff:Float = 0.0;
            var timesLabel = "1M";
            var times = 1000000;

            var __i__ = 0;
            $e{setup};
            Sys.print($v{label} + " (" + timesLabel + "): ");
            before = Timer.stamp();
            while (__i__ < times) {
                $e{expr};
                ++__i__;
            }
            var diff = Timer.stamp() - before;
            Sys.println((diff * 1000000.0) + " us (" + (diff * 1000000.0) / times + " us per op) (" + (times / diff) + " ops per sec)");
                
        };

    }

}