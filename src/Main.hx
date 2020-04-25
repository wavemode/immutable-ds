
import wavemode.immutable.Sequence;
import wavemode.immutable._internal.Trie;
import wavemode.immutable.Vector;
using wavemode.immutable.Functional;

class Main {
    static function main() {
        var seq = new Sequence();
        for (x in 0...1000)
            seq = seq.push(5).push(6).pop();
        iterate(seq);
    }
    static function iterate(it:Iterable<Int>):Void {
        trace([for (v in it) v]);
    }
}
