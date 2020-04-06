package;

import wavemode.immutable.Sequence;

class Main {
    static function main() {
        var list = [1, 2, 3, 4, 5, 6, 7, 8, 9];
        var seq = Sequence.from(list);
        Sys.println(seq.map(x -> x * 3));
        Sys.println(seq.flatMap(x -> [x*1, x*2, x*3, x*4]).filter(x -> x >= 20).reverse().reverse());
        Sys.println(list);
    }
}