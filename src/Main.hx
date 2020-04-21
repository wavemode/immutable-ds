
import wavemode.immutable.Map;

class Main {
    static function main() {
        var m = new Map().setEach([1, 2, 3], [4, 5, 6]);
        for (k => v in m) {
            trace(k + v);
        }
    }
}