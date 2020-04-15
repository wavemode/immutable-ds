import wavemode.immutable.Sequence;

class Main {
    static function main() {
        var seq = Sequence.make(1, 2, 3, 4, 5, 6, 7, 8).shuffle();
        Sys.println(seq);
    }
}