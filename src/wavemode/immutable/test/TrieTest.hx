package wavemode.immutable.test;

import wavemode.immutable.util.Trie;
import buddy.BuddySuite;
using buddy.Should;

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
                
                t1.insert(hashPath(11, 12, 13, 14, 15, 16), new Pair("first value","first value"));

                t1.pair.value.should.be("first value");

                t1.insert(hashPath(11, 12, 13, 14, 15, 16), new Pair("first value","first value"));

                t1.pair.value.should.be("first value");
                t1.array.should.be(null);

                t1.insert(hashPath(11, 13), new Pair("second value","second value"));

                t1.pair.should.be(null);
                t1.array[11].array[12].pair.value.should.be("first value");
                t1.array[11].array[13].pair.value.should.be("second value");

                t1.insert(hashPath(11, 12, 13, 30), new Pair("third value","third value"));

                t1.array[11].array[12].pair.should.be(null);
                t1.array[11].array[12].array[13].array[14].pair.value.should.be("first value");
                t1.array[11].array[12].array[13].array[30].pair.value.should.be("third value");

                t1.insert(hashPath(11, 12, 13, 14, 15, 16), new Pair("fourth value","fourth value"));
                t1.insert(hashPath(11, 12, 13, 14, 15, 16), new Pair("fourth value","fourth value"));
                t1.insert(hashPath(11, 12, 13, 14, 15, 16), new Pair("fifth value","fifth value"));
                t1.insert(hashPath(11, 12, 13, 14, 15, 16), new Pair("fifth value","fifth value"));
                t1.insert(hashPath(11, 12, 13, 14, 15, 16), new Pair("sixth value","sixth value"));
                t1.insert(hashPath(11, 12, 13, 14, 15, 16), new Pair("sixth value","sixth value"));

                t1.array[11].array[12].array[13].array[14].pair.should.be(null);
                t1.array[11].array[12].array[13].array[14].array[15].array[16].pair.value.should.be("first value");
                t1.array[11].array[12].array[13].array[14].array[15].array[16].chain[0].value.should.be("fourth value");
                t1.array[11].array[12].array[13].array[14].array[15].array[16].chain[1].value.should.be("fifth value");
                t1.array[11].array[12].array[13].array[14].array[15].array[16].chain[2].value.should.be("sixth value");

            });

        });

        describe("copyInsert", {

            it("should work without modifying the original trie", {

                var t1 = new Trie();
                t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), new Pair("first value", "first value"));

                t1.count().should.be(0);
                t1.pair.should.be(null);
                t1.array.should.be(null);

                t1 = t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), new Pair("first value", "first value"));

                t1.count().should.be(1);
                t1.pair.value.should.be("first value");
                t1.array.should.be(null);

                t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), new Pair("first value", "first value"));

                t1.count().should.be(1);
                t1.pair.value.should.be("first value");
                t1.array.should.be(null);

                t1 = t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), new Pair("first value", "first value"));

                t1.count().should.be(1);
                t1.pair.value.should.be("first value");
                t1.array.should.be(null);


                t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), new Pair("first value", "first value updated"));

                t1.count().should.be(1);
                t1.pair.value.should.be("first value");
                t1.array.should.be(null);

                var t2 = t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), new Pair("first value", "first value updated"));

                t2.count().should.be(1);
                t2.pair.value.should.be("first value updated");
                t2.array.should.be(null);

                t1.copyInsert(hashPath(11, 13), new Pair("second value", "second value"));

                t1.count().should.be(1);
                t1.pair.value.should.be("first value");
                t1.array.should.be(null);

                t1 = t1.copyInsert(hashPath(11, 13), new Pair("second value", "second value"));

                t1.count().should.be(2);
                t1.pair.should.be(null);
                t1.array[11].array[12].pair.value.should.be("first value");
                t1.array[11].array[13].pair.value.should.be("second value");

                t1.copyInsert(hashPath(11, 12, 13, 30), new Pair("third value", "third value"));

                t1.count().should.be(2);
                t1.pair.should.be(null);
                t1.array[11].array[12].pair.value.should.be("first value");
                t1.array[11].array[13].pair.value.should.be("second value");

                t1 = t1.copyInsert(hashPath(11, 12, 13, 30), new Pair("third value", "third value"));

                t1.count().should.be(3);
                t1.array[11].array[12].pair.should.be(null);
                t1.array[11].array[12].array[13].array[14].pair.value.should.be("first value");
                t1.array[11].array[12].array[13].array[30].pair.value.should.be("third value");

                t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), new Pair("fourth value", "fourth value"));
                t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), new Pair("fourth value", "fourth value"));
                t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), new Pair("fifth value", "fifth value"));
                t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), new Pair("fifth value", "fifth value"));
                t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), new Pair("sixth value", "sixth value"));
                t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), new Pair("sixth value", "sixth value"));

                t1.count().should.be(3);
                t1.array[11].array[12].pair.should.be(null);
                t1.array[11].array[12].array[13].array[14].pair.value.should.be("first value");
                t1.array[11].array[12].array[13].array[30].pair.value.should.be("third value");

                t1 = t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), new Pair("fourth value", "fourth value"));
                t1 = t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), new Pair("fourth value", "fourth value"));
                t1 = t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), new Pair("fifth value", "fifth value"));
                t1 = t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), new Pair("fifth value", "fifth value"));
                t1 = t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), new Pair("sixth value", "sixth value"));
                t1 = t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), new Pair("sixth value", "sixth value"));

                t1.count().should.be(6);
                t1.array[11].array[12].array[13].array[14].pair.should.be(null);
                t1.array[11].array[12].array[13].array[14].array[15].array[16].pair.value.should.be("first value");
                t1.array[11].array[12].array[13].array[14].array[15].array[16].chain[0].value.should.be("fourth value");
                t1.array[11].array[12].array[13].array[14].array[15].array[16].chain[1].value.should.be("fifth value");
                t1.array[11].array[12].array[13].array[14].array[15].array[16].chain[2].value.should.be("sixth value");

                t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), new Pair("fourth value", "fourth value updated"));
                t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), new Pair("fifth value", "fifth value updated"));
                t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), new Pair("sixth value", "sixth value updated"));

                t1.array[11].array[12].array[13].array[14].array[15].array[16].chain[0].value.should.be("fourth value");
                t1.array[11].array[12].array[13].array[14].array[15].array[16].chain[1].value.should.be("fifth value");
                t1.array[11].array[12].array[13].array[14].array[15].array[16].chain[2].value.should.be("sixth value");

                t1 = t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), new Pair("fourth value", "fourth value updated"));
                t1 = t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), new Pair("fifth value", "fifth value updated"));
                t1 = t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), new Pair("sixth value", "sixth value updated"));

                t1.array[11].array[12].array[13].array[14].array[15].array[16].chain[0].value.should.be("fourth value updated");
                t1.array[11].array[12].array[13].array[14].array[15].array[16].chain[1].value.should.be("fifth value updated");
                t1.array[11].array[12].array[13].array[14].array[15].array[16].chain[2].value.should.be("sixth value updated");

            });

        });

        describe("retrieve", {

            it("should work with insert", {

                var t1 = new Trie();

                t1.count().should.be(0);
                
                t1.insert(hashPath(11, 12, 13, 14, 15, 16), Pair.set("first value"));

                t1.retrieve(hashPath(11, 12, 13, 14, 15, 16), "first value").should.be("first value");
                t1.count().should.be(1);

                t1.insert(hashPath(11, 12, 13, 14, 15, 16), new Pair("first value", "first value updated"));

                t1.retrieve(hashPath(11, 12, 13, 14, 15, 16), "first value").should.be("first value updated");
                t1.count().should.be(1);

                t1.insert(hashPath(11, 12, 13, 14, 15, 16), Pair.set("first value"));

                t1.retrieve(hashPath(11, 12, 13, 14, 15, 16), "first value").should.be("first value");
                t1.count().should.be(1);

                t1.insert(hashPath(11, 13), Pair.set("second value"));

                t1.retrieve(hashPath(11, 13), "second value").should.be("second value");
                t1.count().should.be(2);

                t1.insert(hashPath(11, 13), new Pair("second value", "second value updated"));

                t1.retrieve(hashPath(11, 13), "second value").should.be("second value updated");
                t1.count().should.be(2);

                t1.insert(hashPath(11, 12, 13, 30), Pair.set("third value"));

                t1.retrieve(hashPath(11, 12, 13, 14, 15, 16), "first value").should.be("first value");
                t1.retrieve(hashPath(11, 12, 13, 30), "third value").should.be("third value");
                t1.count().should.be(3);

                t1.insert(hashPath(11, 12, 13, 14, 15, 16), Pair.set("fourth value"));
                t1.insert(hashPath(11, 12, 13, 14, 15, 16), Pair.set("fourth value"));
                t1.insert(hashPath(11, 12, 13, 14, 15, 16), Pair.set("fifth value"));
                t1.insert(hashPath(11, 12, 13, 14, 15, 16), Pair.set("fifth value"));
                t1.insert(hashPath(11, 12, 13, 14, 15, 16), Pair.set("sixth value"));
                t1.insert(hashPath(11, 12, 13, 14, 15, 16), Pair.set("sixth value"));

                t1.count().should.be(6);
                t1.retrieve(hashPath(11, 12, 13, 14, 15, 16), "first value").should.be("first value");
                t1.retrieve(hashPath(11, 12, 13, 14, 15, 16), "fourth value").should.be("fourth value");
                t1.retrieve(hashPath(11, 12, 13, 14, 15, 16), "fifth value").should.be("fifth value");
                t1.retrieve(hashPath(11, 12, 13, 14, 15, 16), "sixth value").should.be("sixth value");

                t1.insert(hashPath(11, 12, 13, 14, 15, 16), new Pair("sixth value", "sixth value updated"));

                t1.retrieve(hashPath(11, 12, 13, 14, 15, 16), "sixth value").should.be("sixth value updated");
                t1.count().should.be(6);

            });


            it("should work with copyInsert", {

                var t1 = new Trie();

                t1.count().should.be(0);
                
                t1 = t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), Pair.set("first value"));

                t1.retrieve(hashPath(11, 12, 13, 14, 15, 16), "first value").should.be("first value");
                t1.count().should.be(1);

                t1 = t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), Pair.set("first value"));

                t1.retrieve(hashPath(11, 12, 13, 14, 15, 16), "first value").should.be("first value");
                t1.count().should.be(1);

                t1 = t1.copyInsert(hashPath(11, 13), Pair.set("second value"));

                t1.retrieve(hashPath(11, 13), "second value").should.be("second value");
                t1.count().should.be(2);

                t1 = t1.copyInsert(hashPath(11, 12, 13, 30), Pair.set("third value"));

                t1.retrieve(hashPath(11, 12, 13, 14, 15, 16), "first value").should.be("first value");
                t1.retrieve(hashPath(11, 12, 13, 30), "third value").should.be("third value");
                t1.count().should.be(3);

                t1 = t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), Pair.set("fourth value"));
                t1 = t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), Pair.set("fourth value"));
                t1 = t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), Pair.set("fifth value"));
                t1 = t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), Pair.set("fifth value"));
                t1 = t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), Pair.set("sixth value"));
                t1 = t1.copyInsert(hashPath(11, 12, 13, 14, 15, 16), Pair.set("sixth value"));

                t1.count().should.be(6);
                t1.retrieve(hashPath(11, 12, 13, 14, 15, 16), "first value").should.be("first value");
                t1.retrieve(hashPath(11, 12, 13, 14, 15, 16), "fourth value").should.be("fourth value");
                t1.retrieve(hashPath(11, 12, 13, 14, 15, 16), "fifth value").should.be("fifth value");
                t1.retrieve(hashPath(11, 12, 13, 14, 15, 16), "sixth value").should.be("sixth value");

            });

        });

        describe("delete", {

            it("should work with insert", {

                var t1 = new Trie();
                t1.insert(hashPath(11, 12, 13, 14, 15, 16), Pair.set("first value"));
                t1.delete(hashPath(11, 12, 13, 14, 15, 16), "other value");
                t1.retrieve(hashPath(11, 12, 13, 14, 15, 16), "first value").should.be("first value");
                t1.delete(hashPath(11, 12, 13, 14, 15, 16), "first value");
                t1.retrieve(hashPath(11, 12, 13, 14, 15, 16), "first value").should.be(null);
                t1.insert(hashPath(11, 12, 13, 14, 15, 16), Pair.set("first value"));
                t1.retrieve(hashPath(11, 12, 13, 14, 15, 16), "first value").should.be("first value");
                t1.insert(hashPath(11, 13), Pair.set("second value"));
                t1.retrieve(hashPath(11, 13), "second value").should.be("second value");
                t1.delete(hashPath(11, 13), "second value");
                t1.retrieve(hashPath(11, 13), "second value").should.be(null);

                t1.insert(hashPath(11, 12, 13, 14, 15, 16), Pair.set("fourth value"));
                t1.insert(hashPath(11, 12, 13, 14, 15, 16), Pair.set("fourth value"));
                t1.insert(hashPath(11, 12, 13, 14, 15, 16), Pair.set("fifth value"));
                t1.insert(hashPath(11, 12, 13, 14, 15, 16), Pair.set("fifth value"));
                t1.insert(hashPath(11, 12, 13, 14, 15, 16), Pair.set("sixth value"));
                t1.insert(hashPath(11, 12, 13, 14, 15, 16), Pair.set("sixth value"));

                t1.delete(hashPath(11, 12, 13, 14, 15, 16), "fourth value");
                t1.delete(hashPath(11, 12, 13, 14, 15, 16), "fifth value");
                t1.delete(hashPath(11, 12, 13, 14, 15, 16), "sixth value");

                t1.retrieve(hashPath(11, 12, 13, 14, 15, 16), "first value").should.be("first value");
                t1.retrieve(hashPath(11, 12, 13, 14, 15, 16), "fourth value").should.be(null);
                t1.retrieve(hashPath(11, 12, 13, 14, 15, 16), "fifth value").should.be(null);
                t1.retrieve(hashPath(11, 12, 13, 14, 15, 16), "sixth value").should.be(null);

            });

        });

        describe("copyDelete", {

            it("should work without changing the oringial", {

                var t1 = new Trie();
                t1.insert(hashPath(11, 12, 13, 14, 15, 16), Pair.set("first value"));

                t1.copyDelete(hashPath(11, 12, 13, 14, 15, 16), "other value");
                t1.retrieve(hashPath(11, 12, 13, 14, 15, 16), "first value").should.be("first value");
                t1 = t1.copyDelete(hashPath(11, 12, 13, 14, 15, 16), "other value");
                t1.retrieve(hashPath(11, 12, 13, 14, 15, 16), "first value").should.be("first value");

                t1.copyDelete(hashPath(11, 12, 13, 14, 15, 16), "first value");
                t1.retrieve(hashPath(11, 12, 13, 14, 15, 16), "first value").should.be("first value");
                t1 = t1.copyDelete(hashPath(11, 12, 13, 14, 15, 16), "first value");
                t1.retrieve(hashPath(11, 12, 13, 14, 15, 16), "first value").should.be(null);

                t1.insert(hashPath(11, 12, 13, 14, 15, 16), Pair.set("first value"));
                t1.retrieve(hashPath(11, 12, 13, 14, 15, 16), "first value").should.be("first value");
                t1.insert(hashPath(11, 13), Pair.set("second value"));
                t1.retrieve(hashPath(11, 13), "second value").should.be("second value");
                
                t1.copyDelete(hashPath(11, 13), "second value");
                t1.retrieve(hashPath(11, 13), "second value").should.be("second value");

                t1.retrieve(hashPath(11, 12, 13, 14, 15, 16), "first value").should.be("first value");

                t1 = t1.copyDelete(hashPath(11, 13), "second value");
                t1.retrieve(hashPath(11, 13), "second value").should.be(null);

                t1.retrieve(hashPath(11, 12, 13, 14, 15, 16), "first value").should.be("first value");

                t1.insert(hashPath(11, 12, 13, 14, 15, 16), Pair.set("fourth value"));
                t1.insert(hashPath(11, 12, 13, 14, 15, 16), Pair.set("fourth value"));
                t1.insert(hashPath(11, 12, 13, 14, 15, 16), Pair.set("fifth value"));
                t1.insert(hashPath(11, 12, 13, 14, 15, 16), Pair.set("fifth value"));
                t1.insert(hashPath(11, 12, 13, 14, 15, 16), Pair.set("sixth value"));
                t1.insert(hashPath(11, 12, 13, 14, 15, 16), Pair.set("sixth value"));

                t1.copyDelete(hashPath(11, 12, 13, 14, 15, 16), "fourth value");
                t1.copyDelete(hashPath(11, 12, 13, 14, 15, 16), "fifth value");
                t1.copyDelete(hashPath(11, 12, 13, 14, 15, 16), "sixth value");

                t1.retrieve(hashPath(11, 12, 13, 14, 15, 16), "first value").should.be("first value");
                t1.retrieve(hashPath(11, 12, 13, 14, 15, 16), "fourth value").should.be("fourth value");
                t1.retrieve(hashPath(11, 12, 13, 14, 15, 16), "fifth value").should.be("fifth value");
                t1.retrieve(hashPath(11, 12, 13, 14, 15, 16), "sixth value").should.be("sixth value");

                t1 = t1.copyDelete(hashPath(11, 12, 13, 14, 15, 16), "fourth value");

                t1.retrieve(hashPath(11, 12, 13, 14, 15, 16), "fourth value").should.be(null);
                t1.retrieve(hashPath(11, 12, 13, 14, 15, 16), "fifth value").should.be("fifth value");

                t1 = t1.copyDelete(hashPath(11, 12, 13, 14, 15, 16), "fifth value");
                t1 = t1.copyDelete(hashPath(11, 12, 13, 14, 15, 16), "sixth value");
                
                t1.retrieve(hashPath(11, 12, 13, 14, 15, 16), "fifth value").should.be(null);
                t1.retrieve(hashPath(11, 12, 13, 14, 15, 16), "sixth value").should.be(null);

            });

        });

    }
}