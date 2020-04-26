
import wavemode.immutable.Sequence;

class Main {
    static function main() {
        var seq = Sequence.fromChars("hello, 🍞❤🍞🍞🍞 world").reverse();
        Sys.println(seq.toChars());
    }
}
