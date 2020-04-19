package wavemode.immutable.test;

import wavemode.immutable.util.LinkedList;

import buddy.BuddySuite;
using buddy.Should;

// TODO: test entire API

class LinkedListTest extends BuddySuite {
    public function new() {

        describe("new", {

            it("should create an empty list", {

                new LinkedList().equals([]).should.be(true);

            });

        });

        describe("push", {

            it("should add a new value to the next of the list", {

                var list = new LinkedList();
                list.push(1);
                list.push(2);
                list.push(3);
                list.push(4);

                list.equals([1, 2, 3, 4]).should.be(true);

            });

        });

        describe("remove", {

            it("should remove the first occurrence of an element", {

                var list = new LinkedList();
                list.push(1);
                list.push(2);
                list.push(3);
                list.push(4);

                list.remove(3);
                list.equals([1, 2, 4]).should.be(true);
                list.remove(1);
                list.remove(2);
                list.remove(4);

                list.empty().should.be(true);
                list.equals([]).should.be(true);

            });

        });

        describe("removeNth", {

            it("should remove the given index from the list", {
                var list = new LinkedList();
                list.push(1);
                list.push(2);
                list.push(3);
                list.push(4);

                list.removeNth(4);
                list.equals([1, 2, 3, 4]).should.be(true);
                list.removeNth(3);
                list.equals([1, 2, 3]).should.be(true);
                list.removeNth(0);
                list.equals([2, 3]).should.be(true);
                list.removeNth(1);
                list.removeNth(0);
                list.equals([]).should.be(true);
                list.empty().should.be(true);
            });
        });

    }
}