/**
*  Copyright (c) 2020-present, Chukwudi Okechukwu
*
*  This source code is licensed under the MIT license found in the
*  LICENSE file in the root directory of this source tree.
*
*/

package;

import buddy.BuddySuite;
import haxe.ds.Option;
using buddy.Should;

import wavemode.immutable.Stack;
import wavemode.immutable.Sequence;

class StackTest extends BuddySuite {
    
    public function new() {

        describe("new", {

            it("should create a new empty Stack", {

                new Stack().toSequence().equals([]).should.be(true);

            });

            it("should create a reversed clone of a sequence of values", {

                new Stack(Sequence.make(1, 2, 3, 4)).toSequence().equals([4, 3, 2, 1]).should.be(true);

            });

        });
        
        describe("make", {

            it("should create a Stack from any number of values", {

                Stack.make(1, 2, 3, 4).toSequence().equals([4, 3, 2, 1]).should.be(true);

            });

            it("should behave normally with an empty input", {

                Stack.make().toSequence().equals([]).should.be(true);

            });

        });
        
        describe("peek", {

            it("should return the top value of the Stack", {
               
                Stack.make(1, 2, 3).peek().should.be(3);

            });

            it("should return null with an empty Stack", {
               
                new Stack<Int>().peek().should.be(null);

            });

        });

        describe("push", {

            it("should return a new stack with the given value pushed on top", {

                Stack.make(1, 2, 3).push(66).toSequence().equals([66, 3, 2, 1]).should.be(true);

            });

            it("should behave normally with an empty Stack", {

                new Stack().push(66).toSequence().equals([66]).should.be(true);

            });



        });

        describe("pushEach", {

            it("should return a new stack with the given values pushed on top", {

                Stack.make(1, 2, 3).pushEach([66, 67]).toSequence().equals([67, 66, 3, 2, 1]).should.be(true);

            });

            it("should behave normally with an empty Stack", {

                new Stack().pushEach([66, 67]).toSequence().equals([67, 66]).should.be(true);

            });

            it("should behave normally with an empty input", {

                Stack.make(1, 2, 3).pushEach([]).toSequence().equals([3, 2, 1]).should.be(true);

            });

        });

        describe("pop", {

            it("should return a new Stack with the top value removed", {

                Stack.make(1, 2, 3).pop().toSequence().equals([2, 1]).should.be(true);

            });

            it("should behave normally with an empty Stack", {

                new Stack().pop().toSequence().equals([]).should.be(true);

            });

        });

        describe("iterator", {

            it("should iterate over each value from top to bottom", {

                var values = [1, 2, 3, 4];
                var stack = new Stack().pushEach(values);
                var i = 4;
                for (v in stack)
                    values[--i].should.be(v);

            });

            it("should behave normally with an empty Stack", {

                var stack = new Stack();
                for (v in stack)
                    throw "never";
                true.should.be(true);

            });

        });

        describe("toSequence", {

            it("should create an equivalent Sequence in reverse order", {

                Stack.make(1, 2, 3, 4).toSequence().equals([4, 3, 2, 1]).should.be(true);

            });

        });

        describe("reverse", {

            it("should return a new Stack in reverse order", {

                Stack.make(1, 2, 3, 4).reverse().toSequence().equals([1, 2, 3, 4]).should.be(true);

            });

        });

    }
}
