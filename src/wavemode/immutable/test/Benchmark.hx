package wavemode.immutable.test;

import wavemode.immutable.util.Trie;
import sys.io.File;
import haxe.macro.Context;
#if macro
import haxe.macro.Expr;
#end

import haxe.Timer;

class Benchmark {
    static function main() {

        bench("Vector.push (1M elements)", 
            var vec = new Vector(),
            vec = vec.push(__i__));

        bench("Vector.get (1M elements)", 
            var vec = new Vector().pushEach(Sequence.step().take(1000000)),
            vec.get(__i__));

        var bigintmap = new Map().setEach(Sequence.step().take(100000), Sequence.step().take(100000));
        var smallintmap = new Map().setEach(Sequence.step().take(1000), Sequence.step().take(1000));
        
        bench("IntMap.set (1K numbers)", 
            null,
            smallintmap = smallintmap.set(__i__, __i__));

        bench("IntMap.get (1K numbers)", 
            null,
            smallintmap.get(__i__));

        bench("IntMap.set (100K numbers)", 
            null,
            bigintmap = bigintmap.set(__i__, __i__));

        bench("IntMap.get (100K numbers)", 
            null,
            bigintmap.get(__i__));

        var numbers = Sequence.step().map(Std.string).take(100000);
        var bigmap = new Map().setEach(numbers, numbers);
        var smallmap = new Map().setEach(numbers.take(1000), numbers.take(1000));

        bench("StringMap.set (1K strings)", 
            null,
            smallmap = smallmap.set(numbers[__i__ % 1000], numbers[__i__ % 1000]));

        bench("StringMap.get (1K strings)", 
            null,
            smallmap.get(numbers[__i__ % 1000]));

        bench("StringMap.set (100K strings)", 
            null,
            bigmap = bigmap.set(numbers[__i__ % 100000], numbers[__i__ % 100000]));

        bench("StringMap.get (100K strings)", 
            null,
            bigmap.get(numbers[__i__ % 100000]));

    }

    static macro function bench(label:String, setup:Expr, expr:Expr):Expr {
        return macro {
            var total:Float = 0.0;
            var before:Float = 0.0;
            var diff:Float = 0.0;
            var timesLabel = "1M";
            var times = 1000000;
            var trials = 100;
            Sys.println($v{label} + " (" + trials + " trials)");
            for (TRIAL in 0...trials) {

                var __i__ = 0;
                $e{setup};
                //Sys.print("(trial " + (TRIAL+1) + ") " + $v{label} + " (" + timesLabel + "): ");
                before = Timer.stamp();
                while (__i__ < times) {
                    $e{expr};
                    ++__i__;
                }
                var diff = Timer.stamp() - before;
                //Sys.println((diff * 1000000.0) + " us (" + (diff * 1000000.0) / times + " us per op) (" + (times / diff) + " ops per sec)");
                total += diff;
            }
            Sys.println("Average time: " + (total/trials * 1000000.0/times) + " us per op");
            Sys.println("Average speed: " + (times/(total/trials)) + " ops/sec\n");
        };

    }

}