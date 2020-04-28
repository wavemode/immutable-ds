
import wavemode.immutable.Stack;
import wavemode.immutable.Sequence;

class Main {
    static function main() {
        Sys.println(new Stack(Sequence.make(1, 2, 3, 4)).toSequence().equals([4, 3, 2, 1]));
    }
}
