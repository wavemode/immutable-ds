package;

import wavemode.immutable.Sequence;


class Main {

    static function test() {
        var seq = Sequence.step(40, -2);
        for (i in 0...100)
            seq.get(i);
        Sys.println("acquired cache...");
        return seq;
    }

    static function main() {

        var seq = Sequence.from([1, 2, 3, null, null, null])
                    .map(x -> x * 2)
                    .group(x -> x < 7)
                    .get(0)
                    .take(3)
                    .set(0, 3)
                    .sortDesc()
                    .pushEach([1, 2, 3, 4])
                    .pop()
                    .unshift(999)
                    .splice(-2)
                    .pushEach([1, 2, 3, 4])
                    .deleteEach([0, 2, 4])
                    .shift()
                    .insert(1, 99)
                    .concat([4, 5, 6, 7])
                    .concatEach([[1, 2, 3], [], [5, 6]])
                    .clear().push(5).push(7)
                    .separate(1234)
                    .force()
                    .interleave([0, 0, 0]);
            
        Sys.println(seq);

        for (k => v in seq)
            Sys.println('$k => $v');

    }

}