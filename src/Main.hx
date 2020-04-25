
import wavemode.immutable.Sequence;
import wavemode.immutable.util.Trie;
import wavemode.immutable.Vector;
using wavemode.immutable.Functional;

class Main {
    static function main() {
        var seq = new Sequence();
        for (x in 0...1000)
            seq = seq.push(5).push(6).pop();
        trace(seq);
    }
}

