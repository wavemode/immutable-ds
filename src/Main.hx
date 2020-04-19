import haxe.display.JsonModuleTypes.JsonAbstract;
import wavemode.immutable.Sequence;
import wavemode.immutable.Map;

class Main {
    static function main() {
        var map = new Map();
        map = map.setEach(["hello", "cool", "goodbye", "hello", "mountain"], ["world", "beans", "world", "cat"]);
        map = map.updateEach(["hello", "cool", "elephant"], x -> x + x);
        map = map.replaceEach(["catcat", "beansbeans"], ["dogdogdog", "refried", "carrot"]);
        map = map.deleteEach(["hello", "goodbye"]);

        var map = Map.make({a: 5, b: 6, c: 7}).merge(Map.make({b: 10, c: 11, d: 12}), (a, b) -> a + b);
        Sys.println(map.reduce((a,b) -> a + b));
    }
}