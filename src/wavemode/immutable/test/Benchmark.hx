package wavemode.immutable.test;

import haxe.macro.Context;
#if macro
import haxe.macro.Expr;
#end

import haxe.Timer;

class Benchmark {
    static function main() {
        bench("Array.push",
            var arr = [],
            arr.push(10));
        bench("Map.set",
            var map = new haxe.ds.Map(),
            map.set(__i__, __i__));
        bench("Vector.push",
            var vec = new Vector(),
            vec = vec.push(10));
        bench("Sequence.push",
            var vec = new Sequence(),
            vec = vec.push(10)
        );
        bench("Map.set", 
            var map = new Map(),
            map = map.set(__i__, __i__)
        );
        bench("OrderedMap.set", 
            var map = new OrderedMap(),
            map = map.set(__i__, __i__)
        );
        bench("Set.add", 
            var set = new Set(),
            set = set.add(__i__)
        );
        bench("OrderedSet.add", 
            var set = new OrderedSet(),
            set = set.add(__i__)
        );
    }

    static macro function bench(label:String, setup:Expr, expr:Expr):Expr {
        return macro {
            final MAX_TIME:Float = 3.0;
            var before:Float = 0.0;
            var diff:Float = 0.0;
            var rounds = ["10", "100", "1K", "10K", "100K", "1M", "10M"];
            for (i in 0...7) {
                var DNF:Bool = false;
                var times = switch i {
                    case 0:
                        10;
                    case 1:
                        100;
                    case 2:
                        1000;
                    case 3:
                        10000;
                    case 4:
                        100000;
                    case 5:
                        1000000;
                    case 6:
                        10000000;
                    default:
                        0;
                }
                var timesLabel = rounds[i];

                Sys.print($v{label} + " (" + timesLabel + "): ");
                var __i__ = 0;
                {
                    $e{setup};
                    before = Timer.stamp();
                    while (__i__++ < times) {
                        $e{expr};
                        if (Timer.stamp() - before > MAX_TIME) {
                            Sys.println("DNF");
                            DNF = true;
                            break;
                        }
                    }
                }
                var diff = Timer.stamp() - before;
                diff *= 1000000.0;
                if (!DNF)
                    Sys.println(diff + " us (" + diff / times + " us per op)");

            }
                
        };

    }

}