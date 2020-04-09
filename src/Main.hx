import wavemode.immutable.Sequence;

class Main {
    static function main() {
        Sys.println(Sequence.make(1, 2, 3, 4));
        Sys.println(Sequence.make(1, 2, 3, 4).slice(12));
        Sys.println(Sequence.make(1, 2, 3, 4).slice(-12, -1));
        Sys.println(Sequence.make(1, 2, 3, 4).splice(12));
        Sys.println(Sequence.make(1, 2, 3, 4).splice(-12, -1));
    }
}