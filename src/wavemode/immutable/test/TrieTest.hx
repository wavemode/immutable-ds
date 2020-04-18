package wavemode.immutable.test;

import wavemode.immutable.util.Trie;
import buddy.BuddySuite;
import haxe.ds.Option;
using buddy.Should;

using StringTools;
using stdlib.StringTools;

class TrieTest extends BuddySuite {
    public function new() {

        function hashPath(n1 = 0, n2 = 0, n3 = 0, n4 = 0, n5 = 0, n6 = 0) {
            return
                (n1 << (5 * 0)) +
                (n2 << (5 * 1)) +
                (n3 << (5 * 2)) +
                (n4 << (5 * 3)) +
                (n5 << (5 * 4)) +
                (n6 << (5 * 5));
        }

        describe("insert", {

            it("should work", {

                var t1 = new Trie();
                t1.insert(hashPath(11, 12, 13, 14, 15, 16), "first value");

                t1.value.should.be("first value");

                t1.insert(hashPath(11, 12, 13, 14, 15, 16), "first value");

                t1.value.should.be("first value");
                t1.array.should.be(null);

                t1.insert(hashPath(11, 13), "second value");

                t1.value.should.be(null);
                t1.array[11].array[12].value.should.be("first value");
                t1.array[11].array[13].value.should.be("second value");

                t1.insert(hashPath(11, 12, 13, 30), "third value");

                t1.array[11].array[12].value.should.be(null);
                t1.array[11].array[12].array[13].array[14].value.should.be("first value");
                t1.array[11].array[12].array[13].array[30].value.should.be("third value");

                t1.insert(hashPath(11, 12, 13, 14, 15, 16), "fourth value");
                t1.insert(hashPath(11, 12, 13, 14, 15, 16), "fourth value");
                t1.insert(hashPath(11, 12, 13, 14, 15, 16), "fifth value");
                t1.insert(hashPath(11, 12, 13, 14, 15, 16), "fifth value");
                t1.insert(hashPath(11, 12, 13, 14, 15, 16), "sixth value");
                t1.insert(hashPath(11, 12, 13, 14, 15, 16), "sixth value");

                t1.array[11].array[12].array[13].array[14].value.should.be(null);
                t1.array[11].array[12].array[13].array[14].array[15].array[16].value.should.be("first value");
                t1.array[11].array[12].array[13].array[14].array[15].array[16].chain[0].should.be("fourth value");
                t1.array[11].array[12].array[13].array[14].array[15].array[16].chain[1].should.be("fifth value");
                t1.array[11].array[12].array[13].array[14].array[15].array[16].chain[2].should.be("sixth value");

            });

        });

        describe("copyInsert", {

            it("should work without modifying the original trie", {

                var t1 = new Trie();
                t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), "first value");

                t1.value.should.be(null);
                t1.array.should.be(null);

                t1 = t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), "first value");

                t1.value.should.be("first value");
                t1.array.should.be(null);

                t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), "first value");

                t1.value.should.be("first value");
                t1.array.should.be(null);

                t1 = t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), "first value");

                t1.value.should.be("first value");
                t1.array.should.be(null);

                t1.copyInsert(hashPath(11, 13), "second value");

                t1.value.should.be("first value");
                t1.array.should.be(null);

                t1 = t1.copyInsert(hashPath(11, 13), "second value");

                t1.value.should.be(null);
                t1.array[11].array[12].value.should.be("first value");
                t1.array[11].array[13].value.should.be("second value");

                t1.copyInsert(hashPath(11, 12, 13, 30), "third value");

                t1.value.should.be(null);
                t1.array[11].array[12].value.should.be("first value");
                t1.array[11].array[13].value.should.be("second value");

                t1 = t1.copyInsert(hashPath(11, 12, 13, 30), "third value");

                t1.array[11].array[12].value.should.be(null);
                t1.array[11].array[12].array[13].array[14].value.should.be("first value");
                t1.array[11].array[12].array[13].array[30].value.should.be("third value");

                t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), "fourth value");
                t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), "fourth value");
                t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), "fifth value");
                t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), "fifth value");
                t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), "sixth value");
                t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), "sixth value");

                t1.array[11].array[12].value.should.be(null);
                t1.array[11].array[12].array[13].array[14].value.should.be("first value");
                t1.array[11].array[12].array[13].array[30].value.should.be("third value");

                t1 = t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), "fourth value");
                t1 = t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), "fourth value");
                t1 = t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), "fifth value");
                t1 = t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), "fifth value");
                t1 = t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), "sixth value");
                t1 = t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), "sixth value");

                t1.array[11].array[12].array[13].array[14].value.should.be(null);
                t1.array[11].array[12].array[13].array[14].array[15].array[16].value.should.be("first value");
                t1.array[11].array[12].array[13].array[14].array[15].array[16].chain[0].should.be("fourth value");
                t1.array[11].array[12].array[13].array[14].array[15].array[16].chain[1].should.be("fifth value");
                t1.array[11].array[12].array[13].array[14].array[15].array[16].chain[2].should.be("sixth value");

            });

        });

    }
}