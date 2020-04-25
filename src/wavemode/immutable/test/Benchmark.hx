package wavemode.immutable.test;

import haxe.macro.Context;
#if macro
import haxe.macro.Expr;
#end

import haxe.Timer;

class Benchmark {
    static function main() {

        {
            bench("Vector.push (1M elements)", 
                var vec = new Vector(),
                vec = vec.push(__i__));
        }
        {
            var bigvec = new Vector().pushEach(Sequence.step().take(1000000));
            bench("Vector.get (1M elements)", 
                var vec = bigvec,
                vec.get(__i__));
        }
        {
            var tinyintmap = new Map().setEach(Sequence.step().take(10), Sequence.step().take(10));

            bench("Map.set (10 numbers)", 
                var map = tinyintmap,
                map = map.set(__i__ % 10, __i__));

            bench("Map.get (10 numbers)", 
                var map = tinyintmap,
                map.get(__i__ % 10));
        }
        {
            var smallintmap = new Map().setEach(Sequence.step().take(1000), Sequence.step().take(1000));

            bench("Map.set (1K numbers)", 
                var map = smallintmap,
                map = map.set(__i__ % 1000, __i__));

            bench("Map.get (1K numbers)", 
                var map = smallintmap,
                map.get(__i__ % 1000));
        }
        {
            var bigintmap = new Map().setEach(Sequence.step().take(100000), Sequence.step().take(100000));

            bench("Map.set (100K numbers)", 
                var map = bigintmap,
                map = map.set(__i__ % 100000, __i__));

            bench("Map.get (100K numbers)", 
                var map = bigintmap,
                map.get(__i__ % 100000));
        }
        {
            var numbers = Sequence.step().map(Std.string).take(10);
            var tinymap = new Map().setEach(numbers, numbers);

            bench("Map.set (10 strings)", 
                var map = tinymap,
                map = map.set(numbers[__i__ % 10], numbers[__i__ % 10]));

            bench("Map.get (10 strings)", 
                var map = tinymap,
                map.get(numbers[__i__ % 10]));

        }
        {
            var numbers = Sequence.step().map(Std.string).take(1000);
            var smallmap = new Map().setEach(numbers, numbers);

            bench("Map.set (1K strings)", 
                var map = smallmap,
                map = map.set(numbers[__i__ % 1000], numbers[__i__ % 1000]));

            bench("Map.get (1K strings)", 
                var map = smallmap,
                map.get(numbers[__i__ % 1000]));

        }
        {
            var numbers = Sequence.step().map(Std.string).take(100000);
            var bigmap = new Map().setEach(numbers, numbers);

            bench("Map.set (100K strings)", 
                var map = bigmap,
                map = map.set(numbers[__i__ % 100000], numbers[__i__ % 100000]));

            bench("Map.get (100K strings)", 
                var map = bigmap,
                map.get(numbers[__i__ % 100000]));
        }

    }

    static macro function bench(label:String, setup:Expr, expr:Expr):Expr {
        return macro {
            var total:Float = 0.0;
            var before:Float = 0.0;
            var diff:Float = 0.0;
            var timesLabel = "1M";
            var times = 1000000;
            var trials = 100;
            Sys.println($v{label} + " (" + timesLabel + " iterations) (" + trials + " trials)");
            for (TRIAL in 0...trials) {

                var __i__ = 0;
                $e{setup};
                // Sys.print("(trial " + (TRIAL+1) + ") " + $v{label} + " (" + timesLabel + "): ");
                before = Timer.stamp();
                while (__i__ < times) {
                    $e{expr};
                    ++__i__;
                }
                var diff = Timer.stamp() - before;
                // Sys.println((diff * 1000000000.0) + " ns (" + (diff * 1000000000.0) / times + " ns per op) (" + (times / diff) + " ops per sec)");
                Sys.print(".");
                total += diff;
            }
            Sys.println("\nAverage time: " + (total/trials * 1000000000.0/times) + " ns per op");
            Sys.println("Average speed: " + (times/(total/trials)) + " ops/sec\n");
        };

    }

}