import wavemode.immutable.Sequence;
import wavemode.immutable.Map;
import wavemode.immutable.List;

class StressTest {
    public static function main() {
        function assert(bool:Bool) {
            if (!bool)
                throw " FAILED";
        }
        {
            Sys.print("Sequence stress test: ");
            var seq = new Sequence(), i = 0;
            while (i < 10000) {
                seq = seq.push(i);
                assert(seq[i] == i);
                ++i;
            }
            Sys.print(".");
            while (i > 0) {
                seq = seq.pop();
                assert(seq.get(--i) == null);
            }
            Sys.print(".");
            while (i < 10000) {
                seq = seq.push(i);
                assert(seq[i] == i);
                ++i;
            }
            Sys.print(".");
            while (i > 0) {
                seq = seq.pop();
                assert(seq.get(--i) == null);
            }
            Sys.print(".");
            Sys.println(" PASSED");
        }
        {
            Sys.print("List stress test: ");
            var list = new List(), i = 0;
            while (i < 1000000) {
                list = list.push(i);
                assert(list[i] == i);
                ++i;
            }
            Sys.print(".");
            while (i > 0) {
                list = list.pop();
                @:privateAccess assert(list._this.data.retrieve(--i) == null);
            }
            Sys.print(".");
            while (i < 1000000) {
                list = list.push(i);
                assert(list[i] == i);
                ++i;
            }
            Sys.print(".");
            while (i > 0) {
                list = list.pop();
                @:privateAccess assert(list._this.data.retrieve(--i) == null);
            }
            Sys.print(".");
            Sys.println(" PASSED");
        }
        {
            Sys.print("Map stress test: ");
            var map = new Map(), i = 0;
            while (i < 1000000) {
                map = map.set(i, i);
                assert(map[i] == i);
                ++i;
            }
            Sys.print(".");
            while (i > 0) {
                map = map.delete(--i);
                assert(map[i] == null);
            }
            Sys.print(".");
            while (i < 1000000) {
                map = map.set(i, i);
                assert(map[i] == i);
                ++i;
            }
            Sys.print(".");
            while (i > 0) {
                map = map.delete(--i);
                assert(map[i] == null);
            }
            Sys.print(".");
            Sys.println(" PASSED");
        }
    }
}