import haxe.display.JsonModuleTypes.JsonAbstract;
import wavemode.immutable.Sequence;
import wavemode.immutable.Map;

class Main {
    static function main() {
        var map = new Map();
        map = map.setEach(["hello", "cool", "goodbye", "hello", "mountain"], ["world", "beans", "world", "cat"]);
        map = map.updateEach(["hello", "cool", "elephant"], x -> x + x);
        // map = map.set("cool", "beans");
        // map = map.set("goodbye", "world");
        // map = map.set("hello", "cat");
        @:privateAccess {
            var seq = Sequence.fromIterable(map.data);
            Sys.println(seq);
        }
    }
}