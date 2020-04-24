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

        bench("Vector.push", 
            var vec = new Vector(),
            vec = vec.push(__i__));

        // bench("Vector.get (100K elements)", 
        //     var vec = new Vector().pushEach(Sequence.step().take(100001)),
        //     vec.get(__i__%100000));

        // bench("Vector.push (1K elements)", 
        //     var vec = new Vector().pushEach(Sequence.step().take(1001)),
        //     vec.push(__i__));

        // bench("Vector.get (1K elements)", 
        //     var vec = new Vector().pushEach(Sequence.step().take(1001)),
        //     vec.get(__i__%1000));


        // var bigintmap = new Map().setEach(Sequence.step().take(100000), Sequence.step().take(100000));

        // var smallintmap = new Map().setEach(Sequence.step().take(1000), Sequence.step().take(1000));

        // var bigmap = new Map(), smallmap = new Map();
        // var file = File.read("words.txt");
        // var count = 0;
        // var words = [];
        // while (true) {
        //     var line;
        //     try {
        //         line = file.readLine();
        //     } catch (e:Any) break;
        //     bigmap = bigmap.set(line, line);
        //     if (count < 1000)
        //         smallmap = smallmap.set(line, line);
        //     words.push(line);
        //     ++count;
        // }

        // bench("StringMap.set (1K word dictionary)", 
        //     null,
        //     smallmap.set(words[__i__ % count], words[__i__ % count]));

        // bench("StringMap.get (1K word dictionary)", 
        //     null,
        //     smallmap.get(words[__i__ % count]));

        // bench("StringMap.set (479K word dictionary)", 
        //     null,
        //     bigmap.set(words[__i__ % count], words[__i__ % count]));

        // bench("StringMap.get (479K word dictionary)", 
        //     null,
        //     bigmap.get(words[__i__ % count]));

        // bench("Map.set (100K numbers)", 
        //     null,
        //     bigintmap.set(__i__, __i__));

        // bench("Map.get (100K numbers)", 
        //     null,
        //     bigintmap.get(__i__));

        // bench("Map.set (1K numbers)", 
        //     null,
        //     smallintmap.set(__i__, __i__));

        // bench("Map.get (1K numbers)", 
        //     null,
        //     smallintmap.get(__i__));

    }

    static macro function bench(label:String, setup:Expr, expr:Expr):Expr {
        return macro {
            var total:Float = 0.0;
            var before:Float = 0.0;
            var diff:Float = 0.0;
            var timesLabel = "1M";
            var times = 1000000;
            var trials = 100;
            for (TRIAL in 0...trials) {

                var __i__ = 0;
                $e{setup};
                Sys.print("(trial " + (TRIAL+1) + ") " + $v{label} + " (" + timesLabel + "): ");
                before = Timer.stamp();
                while (__i__ < times) {
                    $e{expr};
                    ++__i__;
                }
                var diff = Timer.stamp() - before;
                Sys.println((diff * 1000000.0) + " us (" + (diff * 1000000.0) / times + " us per op) (" + (times / diff) + " ops per sec)");
                total += diff;
            }
            Sys.println("Average time: " + (total/trials * 1000000.0/times) + " us per op");
            Sys.println("Average speed: " + (times/(total/trials)) + " ops/sec");
        };

    }

}