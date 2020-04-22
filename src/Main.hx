
import wavemode.immutable.Vector;

class Main {
    static function main() {
        var vec = Vector.make(1, 2, 3, 4, 5, 6);
        Sys.print("[ ");
        for (i in vec)
            Sys.print('$i ');
        Sys.println("]");
        vec = vec.insertEach(2, [99, 100, 101]).reverse().flatMap(x -> [1, 2, 3]);
        Sys.print("[ ");
        for (i in vec)
            Sys.print('$i ');
        Sys.println("]");
    }
}

