package wavemode.immutable.test;

import haxe.macro.Context;
#if macro
import haxe.macro.Expr;
#end

import haxe.Timer;

class Benchmark {
    static inline final NUM_TRIALS = 10;

    static function main() {
        for (i in 0...NUM_TRIALS) {
            Sys.print('(trial ${i+1}) ');
            bench("Vector.get (1K elements)", 
                var vec = new Vector().pushEach(Sequence.step().take(1000)),
                vec.get(__i__%1000));
        }
        for (i in 0...NUM_TRIALS) {
            Sys.print('(trial ${i+1}) ');
            bench("Vector.get (100K elements)", 
                var vec = new Vector().pushEach(Sequence.step().take(1000000)),
                vec.get(__i__%1000000));
        }
        for (i in 0...NUM_TRIALS) {
            Sys.print('(trial ${i+1}) ');
            bench("Vector.push (1K elements)", 
                var vec = new Vector().pushEach(Sequence.step().take(1000)),
                vec.push(__i__));
        }
        for (i in 0...NUM_TRIALS) {
            Sys.print('(trial ${i+1}) ');
            bench("Vector.push (100K elements)", 
                var vec = new Vector().pushEach(Sequence.step().take(1000000)),
                vec.push(__i__));
        }
        for (i in 0...NUM_TRIALS) {
            Sys.print('(trial ${i+1}) ');
            bench("Map.get (1K elements)", 
                var map = new Map().setEach(Sequence.step().take(1000), Sequence.step().take(1000)),
                map.get(__i__));
        }
        for (i in 0...NUM_TRIALS) {
            Sys.print('(trial ${i+1}) ');
            bench("Map.get (100K elements)", 
                var map = new Map().setEach(Sequence.step().take(100000), Sequence.step().take(100000)),
                map.get(__i__));
        }
        for (i in 0...NUM_TRIALS) {
            Sys.print('(trial ${i+1}) ');
            bench("Map.set (1K elements)", 
                var map = new Map().setEach(Sequence.step().take(1000), Sequence.step().take(1000)),
                map.set(__i__, __i__));
        }
        for (i in 0...NUM_TRIALS) {
            Sys.print('(trial ${i+1}) ');
            bench("Map.set (100K elements)", 
                var map = new Map().setEach(Sequence.step().take(100000), Sequence.step().take(100000)),
                map.set(__i__, __i__));
        }
        for (i in 0...NUM_TRIALS) {
            Sys.print('(trial ${i+1}) ');
            bench("StringMap.get (1K elements)", 
                var map = new Map().setEach(Sequence.step().take(1000).map(Std.string), Sequence.step().take(1000).map(Std.string)),
                map.get(Std.string(__i__)));
        }
        for (i in 0...NUM_TRIALS) {
            Sys.print('(trial ${i+1}) ');
            bench("StringMap.get (100K elements)", 
                var map = new Map().setEach(Sequence.step().take(100000).map(Std.string), Sequence.step().take(100000).map(Std.string)),
                map.get(Std.string(__i__)));
        }
        for (i in 0...NUM_TRIALS) {
            Sys.print('(trial ${i+1}) ');
            bench("StringMap.set (1K elements)", 
                var map = new Map().setEach(Sequence.step().take(1000).map(Std.string), Sequence.step().take(1000).map(Std.string)),
                map.set(Std.string(__i__), Std.string(__i__)));
        }
        for (i in 0...NUM_TRIALS) {
            Sys.print('(trial ${i+1}) ');
            bench("StringMap.set (100K elements)", 
                var map = new Map().setEach(Sequence.step().take(100000).map(Std.string), Sequence.step().take(100000).map(Std.string)),
                map.set(Std.string(__i__), Std.string(__i__)));
        }
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