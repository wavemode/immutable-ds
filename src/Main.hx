
import wavemode.immutable.util.Trie;
import wavemode.immutable.Vector;
using wavemode.immutable.Functional;

class Main {
    static function main() {
        @:privateAccess {

            function hashPath(n1 = 0, n2 = 0, n3 = 0, n4 = 0, n5 = 0, n6 = 0) {
                return
                    (n1 << (5 * 0)) +
                    (n2 << (5 * 1)) +
                    (n3 << (5 * 2)) +
                    (n4 << (5 * 3)) +
                    (n5 << (5 * 4)) +
                    (n6 << (5 * 5));
            }
            var trie = new Trie(hashPath(1, 2, 3), "hello", "world");
            var t2 = trie.insert(hashPath(1, 2, 3, 4, 5, 6), "goodbye", "world");
            t2 = t2.insert(hashPath(1, 2, 3, 4, 5, 6), "wow", "world");
            t2 = t2.insert(hashPath(1, 2, 3, 4, 5, 6), "what a", "world");
            t2 = t2.insert(hashPath(1, 2, 4), "jello", "jorld");
            
            for (k => v in t2)
                trace(k + ": " + v);
        }
    }
}

