package;

import wavemode.immutable.Sequence;

class Main {

    static function main() {
        var seq = Sequence.from(([1, 2, 3, 4, 5, 6, null, null, null] : Array<Null<Int>>))
            .map(x -> x * 2)
            .group(x -> x < 7)
            .getValue(0)
            .take(3);

        Sys.println(seq);

    }
}