import haxe.display.JsonModuleTypes.JsonAbstract;
import wavemode.immutable.Sequence;
import wavemode.immutable.Map;

class Main {
    static function main() {
        var map = new Map();
        for (i in 0...1999)
            map = map.set(i, i);
        // @:privateAccess {
        //     var seq = Sequence.fromIterable(map.data);
        //     Sys.println(seq);
        // }
    }
}