import wavemode.immutable.Sequence;

class Main {
    static function main() {
        var seq = Sequence.from([1, 2, 3, 4]);
        Sys.println(seq.equals([1, 2, 3, 4]));
        Sys.println(seq);
    }
}