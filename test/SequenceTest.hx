/**
 *  Copyright (c) 2020-present, Chukwudi Okechukwu
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the root directory of this source tree.
 *
 */

package;

import haxe.Exception;
import buddy.BuddySuite;
using buddy.Should;

import wavemode.immutable.Sequence;
import wavemode.immutable.List;

class SequenceTest extends BuddySuite {
    public function new() {
     
        describe("new", {

            it("should create an empty sequence", {

                var seq = new Sequence();
                seq.equals([]).should.be(true);
                seq.count().should.be(0);

            });

            it("should create a clone of another iterable", {

                new Sequence([1, 2, 3, 4]).equals([1, 2, 3, 4]).should.be(true);
                new Sequence(new List().pushEach([1, 2, 3, 4])).equals([1, 2, 3, 4]).should.be(true);

            });

        });

        describe("fromIterable", {

            it("should contain same values as the original iterable", {

                var list = [1, 2, 3];
                Sequence.fromIterable(list).equals([1, 2, 3]).should.be(true);
    
            });

            it("should behave normally for an empty input", {

                Sequence.fromIterable([]).equals([]).should.be(true);
                Sequence.fromIterable([]).count().should.be(0);

            });

        });

        describe("make", {

            it("should allow for variadic Sequence creation", {

                Sequence.make(1, 2, 3).equals([1, 2, 3]).should.be(true);

            });

            it("should behave normally for an empty input", {

                Sequence.make().equals([]).should.be(true);

            });

        });

        describe("fromIterator", {

            it("should turn an Iterator into an equivalent sequence", {

                var i = 0;
                function hn() return i < 5;
                function n() return i++;

                Sequence.fromIterator({hasNext: hn, next: n}).equals([0, 1, 2, 3, 4]).should.be(true);

            });

            it("should behave normally for an empty Iterator", {

                function hn() return false;
                function n() throw new Exception("this should not be called");

                Sequence.fromIterator({hasNext: hn, next: n}).equals([]).should.be(true);

            });

        });

        describe("constant", {

            it("should create an infinite Sequence of a repeating value", {

                // how do we test for infinity? let's say, 100
                Sequence.constant(4).take(100).equals([for (i in 0...100) 4]).should.be(true);

            });

            it("should behave normally with a null value", {

                // how do we test for infinity? let's say, 100
                Sequence.constant(null).take(100).equals([for (i in 0...100) null]).should.be(true);

            });

        });

        describe("range", {

            it("should create an inclusive sequence of numbers", {

                Sequence.range(0, 10).equals([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]).should.be(true);

            });

            it("should behave normally for negative sequences", {

                Sequence.range(0, -10).equals([0, -1, -2, -3, -4, -5, -6, -7, -8, -9, -10]).should.be(true);

            });

            it("should behave normally for single values", {

                Sequence.range(10, 10).equals([10]).should.be(true);

            });

        });

        describe("iterate", {

            it("should create an infinite sequence of repeated iterations", {

                // how do we test for infinity? let's say, 100
                Sequence.iterate(0, x -> x + 3).take(100).equals([for (i in 0...100) i * 3]).should.be(true);

            });

        });

        describe("step", {

            it("should create an infinite sequence of steps", {

                // how do we test for infinity? let's say, 100
                Sequence.step(0, 2).take(100).equals([for (i in 0...100) i * 2]).should.be(true);

            });

            it("the default step value should be 1", {

                // how do we test for infinity? let's say, 100
                Sequence.step(0).take(100).equals([for (i in 0...100) i]).should.be(true);

            });

        });

        describe("join", {

            it("should concat the sequences with a separator between", {

                Sequence.join([[1, 2], [4, 6], [7, 8]], 999).equals([1, 2, 999, 4, 6, 999, 7, 8]).should.be(true);

            });

            it("should handle empty sequences within the input sequence", {

                Sequence.join([[], [4, 5], [], [], [9]], 100).equals([100, 4, 5, 100, 100, 100, 9]).should.be(true);

            });

            it("should handle an empty input sequence", {

                Sequence.join([], 10).equals(new Sequence()).should.be(true);

            });

        });

        describe("@:from List", {

            it("should be equivalent to the original list", {

                var vec = List.fromArray([1, 2, 3, 4, 5]);
                var seq:Sequence<Int> = vec;

                seq.equals([1, 2, 3, 4, 5]).should.be(true);

            });


        });

        describe("@:from Iterator", {

            it("should implicitly convert from any Iterator", {

                var i = 0;
                var hn = () -> true;
                var n = () -> i++;
                var seq:Sequence<Int> = { hasNext: hn, next: n };
                
                seq.take(5).equals([0, 1, 2, 3, 4]).should.be(true);

            });

        });

        describe("@:from Iterable", {

            it("should implicitly convert from any Iterable", {

                var i = 0;
                var hn = () -> true;
                var n = () -> i++;
                var it = { hasNext: hn, next: n };
                var seq:Sequence<Int> = { iterator: () -> it };

                seq.take(5).equals([0, 1, 2, 3, 4]).should.be(true);

            });

        });

        describe("fromChars / toChars", {

            it("should convert a string to a sequence of strings", {

                Sequence.fromChars("Hello, world").toChars().should.be("Hello, world");
                Sequence.fromChars("Hello, world").count().should.be(12);
                Sequence.fromChars("Hello, world").get(2).should.be("l");

            });

            it("should properly handle unicode strings", {

                Sequence.fromChars("🍞❤😊").count().should.be(3);
                Sequence.fromChars("🍞❤😊").get(2).should.be("😊");
                Sequence.fromChars("🍞❤😊").reverse().toChars().should.be("😊❤🍞");

            });

        });

        describe("get", {

            it("should return the value at the given index", {

                Sequence.make(1, 2, 3, 4).get(3).should.be(4);

            });

            it("should return null for out-of-bounds access", {

                (Sequence.make(1, 2, 3, 4).get(4) == null).should.be(true);

            });

        });

        describe("[index] / getValue", {

            it("should be indexable with array access", {

                Sequence.make(1, 2, 3, 4)[3].should.be(4);

            });

            it("should throw an exception for out-of-bounds access", {

                (() -> Sequence.make(1, 2, 3, 4)[4]).should.throwAnything();

            });

        });

        describe("empty", {

            it("should be true when a Sequence is empty", {

                new Sequence().empty().should.be(true);
                Sequence.fromIterable([]).empty().should.be(true);
                new Sequence().empty().should.be(true);
                Sequence.make(1, 2, 3).clear().empty().should.be(true);

            });

            it("should be true when a Sequence is not empty", {

                new Sequence().push(1).empty().should.be(false);

            });

        });

        describe("clear", {

            it("should result in an empty Sequence", {

                Sequence.make(1, 2, 3).clear().equals([]).should.be(true);

            });

        });

        describe("reverse", {

            it("should result in a reversed Sequence", {

                Sequence.make(1, 2, 3, 4).reverse().equals([4, 3, 2, 1]).should.be(true);

            });

        });

        describe("sort", {

            it("should result in a sorted Sequence", {

                Sequence.make(1, 3, 6, 2, 7).sort((a, b) -> a - b).equals([1, 2, 3, 6, 7]).should.be(true);

            });

        });

        describe("sortAsc", {

            it("should sort an integer Sequence in ascending order", {

                Sequence.make(1, 3, 6, 2, 7).sortAsc().equals([1, 2, 3, 6, 7]).should.be(true);
            
            });

            it("should work for Floats as well", {

                var seq = Sequence.make(1.0, 3.0, 6.0, 2.0, 7.0);
                seq.sortAsc().equals([1.0, 2.0, 3.0, 6.0, 7.0]).should.be(true);
            
            });

        });

        describe("sortDesc", {

            it("should sort an integer Sequence in ascending order", {

                Sequence.make(1, 3, 6, 2, 7).sortDesc().equals([7, 6, 3, 2, 1]).should.be(true);
            
            });

            it("should work for Floats as well", {

                Sequence.make(1.0, 3.0, 6.0, 2.0, 7.0).sortDesc().equals([7.0, 6.0, 3.0, 2.0, 1.0]).should.be(true);
            
            });

        });

        describe("force", {

            /**
                How do we test that a sequence has been forced? Well, we hackishly test if its cache is complete.
            **/
            it("should force cacheComplete in a cached sequence", {

                var seq = Sequence.make(1, 2, 3, 4).map(x -> x).force();
                @:privateAccess seq._this.cacheComplete.should.be(true);
                seq.equals([1, 2, 3, 4]).should.be(true);
            });

            it("should return the exact same sequence it was called on", {

                // here we are testing for identity (memory address), not equality

                var seq = Sequence.make(1, 2, 3, 4).map(x -> x);
                (seq == seq.force()).should.be(true);

                var seq2 = Sequence.make(1, 2, 3, 4).reverse();
                (seq2 == seq2.force()).should.be(true);

            });

        });

        describe("slice", {

            it("should return values from pos to end", {

                Sequence.make(1, 2, 3, 4).slice(2).equals([3, 4]).should.be(true);

            });

            it ("should return values from pos up to but not including end", {

                Sequence.make(1, 2, 3, 4).slice(1, 3).equals([2, 3]).should.be(true);

            });

            it("should calculate from the end if pos is negative", {

                Sequence.make(1, 2, 3).slice(-2).equals([2, 3]).should.be(true);

            });

            it("should calculate from the end if end is negative", {

                Sequence.make(1, 2, 3).slice(-2, -1).equals([2]).should.be(true);

            });

        });

        describe("splice", {

            it("should return values from pos to end", {

                Sequence.make(1, 2, 3, 4).splice(2).equals([3, 4]).should.be(true);

            });

            it ("should return len values starting from pos", {

                Sequence.make(1, 2, 3, 4).splice(1, 3).equals([2, 3, 4]).should.be(true);

            });

            it("should calculate from the end if pos is negative", {

                Sequence.make(1, 2, 3, 4).splice(-3, 2).equals([2, 3]).should.be(true);

            });

        });

        describe("filter", {

            it("should remove values for which the predicate is false", {

                Sequence.make(1, 2, 3, 4, 5).filter(x -> x % 2 == 0).equals([2, 4]).should.be(true);

            });

            it("should work normally for an empty sequence", {

                new Sequence().filter(x -> x % 2 == 0).equals([]).should.be(true);

            });

        });

        describe("remove", {

            it("should remove values which equal the given value", {

                trace(Sequence.make(1, 4, 3, 4, 5).remove(4));
                Sequence.make(1, 4, 3, 4, 5).remove(4).equals([1, 3, 5]).should.be(true);

            });

            it("should work normally for null values", {

                Sequence.fromIterable(([1, null, 3, null, 5] : Array<Null<Int>>)).remove(cast null).equals([1, 3, 5]).should.be(true);

            });

            it("should work normally for an empty sequence", {

                new Sequence().remove(null).equals([]).should.be(true);

            });

        });

        describe("removeEach", {

            it("should remove values which equal any of the given values", {

                Sequence.make(1, 4, 3, 4, 5).removeEach([4, 1]).equals([3, 5]).should.be(true);

            });

            it("should work normally for null values", {

                Sequence.fromIterable(([1, null, 3, null, 5] : Array<Null<Int>>)).removeEach(([null, 1] : Array<Null<Int>>)).equals([3, 5]).should.be(true);

            });

            it("should work normally for an empty sequence", {

                new Sequence().removeEach(([null, 1] : Array<Null<Int>>)).equals([]).should.be(true);

            });

            it("should evaluate the removal values lazily", {

                Sequence.make(2, 2, 2).removeEach(Sequence.constant(2)).equals([]).should.be(true);

            });

        });

        describe("delete", {

            it("should remove the value at the given index", {

                Sequence.make(1, 4, 3, 5).delete(1).equals([1, 3, 5]).should.be(true);

            });

            it("should work normally for null values", {

                Sequence.fromIterable(([1, null, 3, 5] : Array<Null<Int>>)).delete(1).equals([1, 3, 5]).should.be(true);

            });

            it("should work normally for an empty sequence", {

                new Sequence().delete(0).equals([]).should.be(true);

            });

            it("optimization: should return the same identical sequence if the index is negative, or if the sequence has a complete cache and the index is known to be out of bounds", {

                // here we are testing for identity (memory address), not equality

                var seq = Sequence.make(1, 2, 3, 4);

                (seq.delete(0) == seq).should.be(false);
                (seq.delete(30) == seq).should.be(false);
                (seq.delete(-30) == seq).should.be(true);

                seq.force();

                (seq.delete(0) == seq).should.be(false);
                (seq.delete(30) == seq).should.be(true);
                (seq.delete(-30) == seq).should.be(true);

            });

        });

        describe("deleteEach", {

            it("should delete indices which equal any of the given indices", {

                Sequence.make(1, 4, 3, 4, 5).deleteEach([1, 3]).equals([1, 3, 5]).should.be(true);

            });

            it("should work normally for null values", {

                Sequence.fromIterable(([1, null, 3, null, 5] : Array<Null<Int>>)).deleteEach([1, 3]).equals([1, 3, 5]).should.be(true);

            });

            it("should work normally for an empty sequence", {

                new Sequence().deleteEach([1, 3]).equals([]).should.be(true);

            });

            it("should evaluate the removal indices lazily", {

                Sequence.make(2, 2, 2).deleteEach(Sequence.step(0, 1)).equals([]).should.be(true);

            });

        });
        
        describe("take", {

            it("should take the first num values of the sequence", {

                Sequence.make(1, 2, 3, 4).take(2).equals([1, 2]).should.be(true);

            });

            it("should take as many values as it can", {

                Sequence.make(1, 2, 3, 4, 5).take(10).equals([1, 2, 3, 4, 5]).should.be(true);

            });

            it("should work normally for an empty sequence", {

                new Sequence().take(10).equals([]).should.be(true);

            });

        });

        describe("takeLast", {

            it("should take the last num values of the sequence", {

                Sequence.make(1, 2, 3, 4).takeLast(2).equals([3, 4]).should.be(true);

            });

            it("should take as many values as it can", {

                Sequence.make(1, 2, 3, 4, 5).takeLast(10).equals([1, 2, 3, 4, 5]).should.be(true);

            });

            it("should work normally for an empty sequence", {

                new Sequence().takeLast(10).equals([]).should.be(true);

            });

        });

        describe("takeWhile", {

            it("should take values until the predicate returns false", {

                Sequence.make(1, 2, 3, 4, 5).takeWhile(i -> i < 3).equals([1, 2]).should.be(true);

            });

            it("should return the whole sequence if the predicate never returns false", {

                Sequence.make(1, 2, 3, 4, 5).takeWhile(i -> i > 0).equals([1, 2, 3, 4, 5]).should.be(true);

            });

            it("should work normally for an empty sequence", {

                new Sequence().takeWhile(i -> i > 0).equals([]).should.be(true);

            });

        });

        describe("takeUntil", {
            
            it("should take values until the predicate returns true", {

                Sequence.make(1, 2, 3, 4, 5).takeUntil(i -> i >= 3).equals([1, 2]).should.be(true);

            });

            it("should return the whole sequence if the predicate never returns true", {

                Sequence.make(1, 2, 3, 4, 5).takeUntil(i -> i < 0).equals([1, 2, 3, 4, 5]).should.be(true);

            });

            it("should work normally for an empty sequence", {

                new Sequence().takeUntil(i -> i < 0).equals([]).should.be(true);

            });

        });

        describe("drop", {

            it("should remove the first num values of the sequence", {

                Sequence.make(1, 2, 3, 4).drop(2).equals([3, 4]).should.be(true);

            });

            it("should drop as many values as it can", {

                Sequence.make(1, 2, 3, 4, 5).drop(10).equals([]).should.be(true);

            });

            it("should work normally for an empty sequence", {

                new Sequence().drop(10).equals([]).should.be(true);

            });

        });

        describe("dropLast", {

            it("should remove the last num values of the sequence", {

               Sequence.make(1, 2, 3, 4).dropLast(2).equals([1, 2]).should.be(true);

            });

            it("should drop as many values as it can", {

                Sequence.make(1, 2, 3, 4, 5).dropLast(10).equals([]).should.be(true);

            });

            it("should work normally for an empty sequence", {

                new Sequence().dropLast(10).equals([]).should.be(true);

            });

        });

        describe("dropWhile", {

            it("should drop values until the predicate returns false", {

                Sequence.make(1, 2, 3, 4, 5).dropWhile(i -> i < 3).equals([3, 4, 5]).should.be(true);

            });

            it("should drop the whole sequence if the predicate never returns false", {

                Sequence.make(1, 2, 3, 4, 5).dropWhile(i -> i > 0).equals([]).should.be(true);

            });

            it("should work normally for an empty sequence", {

                new Sequence().dropWhile(i -> i > 0).equals([]).should.be(true);

            });


        });

        describe("dropUntil", {
            
            it("should drop values until the predicate returns true", {

                Sequence.make(1, 2, 3, 4, 5).dropUntil(i -> i >= 3).equals([3, 4, 5]).should.be(true);

            });

            it("should drop the whole sequence if the predicate never returns true", {

                Sequence.make(1, 2, 3, 4, 5).dropUntil(i -> i < 0).equals([]).should.be(true);

            });

            it("should work normally for an empty sequence", {

                new Sequence().dropUntil(i -> i < 0).equals([]).should.be(true);

            });

        });

        describe("map", {

            it("should pass each value through the mapper function", {

                Sequence.make(1, 2, 3, 4).map(x -> x * 2).equals([2, 4, 6, 8]).should.be(true);

            });

            it("should work normally for an empty Sequence", {

                new Sequence().map(x -> x * 2).equals([]).should.be(true);

            });

            it("should never call the mapper function twice for a given index", {

                var i = 0;
                var seq = Sequence.make(1, 2, 3, 4).map(x -> {
                    ++i;
                    x * 2;
                });
                seq.force();
                seq.force();
                i.should.be(4);

            });

        });

        describe("mapIndex", {

            it("should pass each index and value through the mapper function", {

                Sequence.make(1, 2, 3, 4).mapIndex((k, v) -> k * 2).equals([0, 2, 4, 6]).should.be(true);

            });

            it("should work normally for an empty Sequence", {

                new Sequence().mapIndex((k, v) -> k * 2).equals([]).should.be(true);

            });

            it("should never call the mapper function twice for a given index", {

                var i = 0;
                var seq = Sequence.make(1, 2, 3, 4).mapIndex((k, v) -> {
                    ++i;
                    k * 2;
                });
                seq.force();
                seq.force();
                i.should.be(4);

            });


        });

        describe("flatMap", {

            it("should properly flatten its results", {

                Sequence.make(1, 2, 3, 4).flatMap(x -> [x, x*2]).equals([1, 2, 2, 4, 3, 6, 4, 8]).should.be(true);

            });

            it("should consume its results lazily", {

                var seq = Sequence.make(1, 2, 3, 4)
                    .flatMap(x -> if (x == 1) [x, x*2] else [null, null])
                    .map(x -> x*2);

                seq.take(2).equals([2, 4]).should.be(true);
                (() -> seq.take(3).force()).should.throwAnything();

            });

        });

        describe("set", {

            it("should set the given index to the given value", {

                Sequence.make(1, 2, 3, 4).set(0, 99).equals([99, 2, 3, 4]).should.be(true);

            });

            it("should work normally for an empty sequence", {

                new Sequence().set(0, 99).equals([]).should.be(true);

            });

            it("optimization: should return the same identical sequence if the index is negative, or if the sequence has a complete cache and the index is known to be out of bounds", {

                // here we are testing for identity (memory address), not equality

                var seq = Sequence.make(1, 2, 3, 4);

                (seq.set(0, 30) == seq).should.be(false);
                (seq.set(30, 30) == seq).should.be(false);
                (seq.set(-30, 30) == seq).should.be(true);

                seq.force();

                (seq.set(0, 30) == seq).should.be(false);
                (seq.set(30, 30) == seq).should.be(true);
                (seq.set(-30, 30) == seq).should.be(true);

            });

        });

        describe("setEach", {

            it("should set the given indices to the given value", {

                Sequence.make(1, 2, 3, 4).setEach([0, 1], [99, 99]).equals([99, 99, 3, 4]).should.be(true);

            });

            it("should work normally for an empty sequence", {

                new Sequence().setEach([0, 1], [99, 99]).equals([]).should.be(true);

            });

            it("should evaluate the indices lazily", {
                
                Sequence.make(1, 2, 3, 4).setEach(Sequence.step(0, 1), Sequence.constant(0)).equals([0, 0, 0, 0]).should.be(true);

            });

        });

        describe("update", {

            it("should pass the value at the given index through the updater function", {

                Sequence.make(1, 2, 3, 4).update(0, x -> x + 10).equals([11, 2, 3, 4]).should.be(true);

            });

            it("should work normally for an empty sequence", {

                new Sequence().update(0, x -> x + 10).equals([]).should.be(true);

            });

            it("optimization: should return the same identical sequence if the index is negative, or if the sequence has a complete cache and the index is known to be out of bounds", {

                // here we are testing for identity (memory address), not equality

                var seq = Sequence.make(1, 2, 3, 4);

                (seq.update(0, x -> x + 10) == seq).should.be(false);
                (seq.update(30, x -> x + 10) == seq).should.be(false);
                (seq.update(-30, x -> x + 10) == seq).should.be(true);

                seq.force();

                (seq.update(0, x -> x + 10) == seq).should.be(false);
                (seq.update(30, x -> x + 10) == seq).should.be(true);
                (seq.update(-30, x -> x + 10) == seq).should.be(true);

            });


        });

        describe("updateEach", {

            it("should pass the given indices through the updater function", {

                Sequence.make(1, 2, 3, 4).updateEach([0, 1], x -> x + 10).equals([11, 12, 3, 4]).should.be(true);

            });

            it("should work normally for an empty sequence", {

                new Sequence().updateEach([0, 1], x -> x + 10).equals([]).should.be(true);

            });

            it("should evaluate the indices lazily", {

                Sequence.make(1, 2, 3, 4).updateEach(Sequence.step(0, 1), x -> x + 10).equals([11, 12, 13, 14]).should.be(true);

            });

        });

        describe("replace", {

            it("should replace all instances of the given value", {

                Sequence.make(1, 2, 3, 1).replace(1, 10).equals([10, 2, 3, 10]).should.be(true);

            });

            it("should do nothing if the value does not exist", {

                var seq = Sequence.make(1, 2, 3, 4);
                seq.replace(9, 10).equals(seq).should.be(true);

            });

            it("should work normally for an empty sequence", {

                new Sequence().replace(1, 10).equals([]).should.be(true);

            });

        });

        describe("replaceEach", {

            it("should replace all instances of all given values", {

                Sequence.make(1, 2, 3, 1).replaceEach([1, 2], [10, 11]).equals([10, 11, 3, 10]).should.be(true);

            });

            it("should do nothing if the values do not exist", {

                var seq = Sequence.make(1, 2, 3, 4);
                seq.replaceEach([11, 12], [10, 11]).equals(seq).should.be(true);

            });

            it("should work normally for an empty sequence", {

                new Sequence().replaceEach([1, 2], [10, 11]).equals([]).should.be(true);

            });

            it("should evaluate its replacements lazily", {

                Sequence.make(1, 2, 3, 4).replaceEach(Sequence.step(1, 1), Sequence.constant(0)).equals([0, 0, 0, 0]).should.be(true);

            });

        });

        describe("group", {

            it("should categorize each value", {

                var seq = Sequence.make(1, 2, 3, 4, 5, 6, 7).group(x -> x % 2);
                seq[0].equals([1, 3, 5, 7]).should.be(true);
                seq[1].equals([2, 4, 6]).should.be(true);

            });

            it("should be deeply lazy", {

                Sequence.fromIterable(([1, 2, 3, null, null, null] : Array<Null<Int>>))
                    .map(x -> x * 2) // this map should never execute for the null values, so we don't crash
                    .group(x -> x < 7)
                    .get(0)
                    .take(3).equals([2, 4, 6]).should.be(true);

            });

        });

        describe("reduce", {

            it("should accumulate values according to the reducer function", {

                Sequence.make(1, 2, 3, 4).reduce((a, b) -> a - b).should.be(-8);

            });

            it("should return the sole value if the sequence has only one, without executing reducer", {

                Sequence.make(10).reduce((_, _) -> throw "never").should.be(10);

            });

            it("should throw an exception if used on an empty sequence", {

                (() -> new Sequence().reduce((a, b) -> a - b)).should.throwAnything();

            });


        });

        describe("reduceRight", {

            it("should accumulate values according to the reducer function, in reverse order", {

                Sequence.make(1, 2, 3, 4).reduceRight((a, b) -> a - b).should.be(-2);

            });

            it("should return the sole value if the sequence has only one, without executing reducer", {

                Sequence.make(10).reduceRight((_, _) -> throw "never").should.be(10);

            });

            it("should throw an exception if used on an empty sequence", {

                (() -> new Sequence().reduceRight((a, b) -> a - b)).should.throwAnything();

            });

        });

        describe("fold", {

            it("should accumulate values according to the foldFn function", {

                Sequence.make(1, 2, 3, 4).fold((a, b) -> a - b, 0).should.be(-10);

            });

            it("should return initialValue if the sequence is empty, without executing foldFn", {

                new Sequence().fold((_, _) -> throw "never", 10).should.be(10);

            });

        });

        describe("foldRight", {

            it("should accumulate values according to the foldFn function, in reverse order", {

                Sequence.make(1, 2, 3, 4).foldRight((a, b) -> a - b, 0).should.be(-10);

            });

            it("should return initialValue if the sequence is empty, without executing foldFn", {

                new Sequence().foldRight((_, _) -> throw "never", 10).should.be(10);

            });

        });

        describe("has", {

            it("should return true if the index exists", {

                Sequence.make(1, 2, 3, 4).has(3).should.be(true);

            });

            it("should return false if the index is out of bounds", {

                var seq = Sequence.make(1, 2, 3, 4).force();
                
                seq.has(-1).should.be(false);
                seq.has(4).should.be(false);

            });

        });

        describe("contains", {

            it("should return true if the value exists", {

                Sequence.make(1, 2, 3, 4).contains(4).should.be(true);

            });

            it("should return false if the value does not exist", {

                var seq = Sequence.make(1, 2, 3, 4).force();
            
                seq.contains(0).should.be(false);

            });

        });

        describe("first", {

            it("should return the first value in the sequence", {

                Sequence.make(1, 2, 3, 4).first().should.be(1);

            });

            it("should return null if the sequence is empty", {

                (new Sequence().first() == null).should.be(true);

            });

        });

        describe("last", {

            it("should return the last value in the sequence", {

                Sequence.make(1, 2, 3, 4).last().should.be(4);

            });

            it("should return null if the sequence is empty", {

                (new Sequence().last() == null).should.be(true);

            });

        });

        describe("count", {

            it("should return the number of elements in the sequence", {

                Sequence.make(1, 2, 3, 4).count().should.be(4);

            });

            it("should work normally for an empty sequence", {

                new Sequence().count().should.be(0);

            });

        });

        describe("every", {

            it("should return true if every value satisfies the predicate", {

                Sequence.make(1, 2, 3, 4).every(x -> x < 5).should.be(true);

            });

            it("should return false if any value does not satisfy the predicate, and stop execution early", {

                // (null < 5) should never be executed, so our program should not crash
                Sequence.fromIterable(([1, 2, 6, 4, null] : Array<Null<Int>>)).every(x -> x < 5).should.be(false);

            });

            it("should return true for the empty sequence without executing the predicate", {

                new Sequence().every(_ -> throw "never").should.be(true);

            });

        });

        describe("some", {

            it("should return true if any value satisfies the predicate, and stop execution early", {

                // (null < 5) should never be executed, so our program should not crash
                Sequence.fromIterable(([1, null, null, null] : Array<Null<Int>>)).some(x -> x < 5).should.be(true);

            });

            it("should return false if every value fails to satisfy the predicate", {

                Sequence.make(7, 8, 9, 10).some(x -> x < 5).should.be(false);

            });

            it("should return false for the empty sequence without executing the predicate", {

                new Sequence().some(_ -> throw "never").should.be(false);

            });


        });

        describe("equals", {

            it("should return true if the other sequence is identical", {

                Sequence.make(1, 2, 3).equals(Sequence.make(1, 2, 3)).should.be(true);

            });

            it("should return false if there is any difference", {

                Sequence.make(1, 2, 3).equals(Sequence.make(1, 2, 3, 4)).should.be(false);
                Sequence.make(1, 2, 3).equals(Sequence.make(1, 2)).should.be(false);
                Sequence.fromIterable(([1, 2, 3] : Array<Null<Int>>)).equals(Sequence.make(null)).should.be(false);

            });

            it("should behave normally for the empty sequence", {

                new Sequence().equals(new Sequence()).should.be(true);
                new Sequence().equals(Sequence.make(1)).should.be(false);
                Sequence.make(1).equals(new Sequence()).should.be(false);

            });

            it("should compare nested subsequences only if the 'deep' flag is true", {

                var seq1 = Sequence.make(Sequence.make(1, 2), Sequence.make(3, 4));
                var seq2 = Sequence.make(Sequence.make(1, 2), Sequence.make(3, 4));

                seq1.equals(seq2).should.be(false);
                seq1.equals(seq2, true).should.be(true);

            });

        });

        describe("find / indexOf", {

            it("should return the first index of the given value", {

                Sequence.make(1, 2, 2, 3).find(2).should.be(1);
                Sequence.make(1, 2, 2, 3).indexOf(2).should.be(1);

            });

            it("should return -1 if the value does not exist", {

                Sequence.make(1, 2, 2, 3).find(12).should.be(-1);
                Sequence.make(1, 2, 2, 3).indexOf(12).should.be(-1);

            });

            it("should begin searching from the given start index", {

                Sequence.make(1, 2, 2, 3).find(2, 2).should.be(2);
                Sequence.make(1, 2, 2, 3).indexOf(2, 2).should.be(2);

                Sequence.make(1, 2, 2, 3).find(2, 3).should.be(-1);
                Sequence.make(1, 2, 2, 3).indexOf(2, 3).should.be(-1);

            });

            it("should work normally for an empty sequence", {

                new Sequence().find(4).should.be(-1);
                new Sequence().indexOf(4).should.be(-1);

            });

            it("should evaluate the sequence lazily", {

                // null * 2 should never execute, so our program should not crash
                Sequence.fromIterable(([1, 2, null, 4] : Array<Null<Int>>)).map(x -> x * 2).find(4).should.be(1);
                Sequence.fromIterable(([1, 2, null, 4] : Array<Null<Int>>)).map(x -> x * 2).indexOf(4).should.be(1);

            });

            it("should work normally if the start index is out of bounds", {

                Sequence.make(1, 2, 2, 3).find(2, 30).should.be(-1);
                Sequence.make(1, 2, 2, 3).indexOf(2, 30).should.be(-1);

            });

        });

        describe("findWhere", {

            it("should return the first index at which the predicate returns true", {

                Sequence.make(1, 2, 2, 3).findWhere(x -> x % 2 == 0).should.be(1);

            });

            it("should return -1 if the predicate never returns true", {

                Sequence.make(1, 2, 2, 3).findWhere(x -> x > 12).should.be(-1);

            });

            it("should begin searching from the given start index", {

                Sequence.make(1, 2, 2, 3).findWhere(x -> x % 2 == 0, 2).should.be(2);

                Sequence.make(1, 2, 2, 3).findWhere(x -> x % 2 == 0, 3).should.be(-1);

            });

            it("should work normally for an empty sequence", {

                new Sequence().findWhere(x -> x % 2 == 0).should.be(-1);

            });

            it("should evaluate the sequence lazily", {

                // null * 2 should never execute, so our program should not crash
                Sequence.fromIterable(([1, 2, null, 4] : Array<Null<Int>>)).map(x -> x * 2).findWhere(x -> x % 2 == 0).should.be(0);

            });

            it("should work normally if the start index is out of bounds", {

                Sequence.make(1, 2, 2, 3).findWhere(x -> x % 2 == 0, 30).should.be(-1);

            });

            
        });

        describe("max", {

            it("should return the numerical maximum of the Sequence", {

                Sequence.make(1, 2, 3, 4).max().should.be(4);

            });

            it("should work normally for floats", {

                Sequence.make(1.0, 2.0, 3.0, 4.0).max().should.be(4.0);

            });

            it("should throw an exception if the sequence is empty", {

                (() -> new Sequence().max()).should.throwAnything();

            });

        });

        describe("min", {

            it("should return the numerical minimum of the Sequence", {

                Sequence.make(1, 2, 3, 4).min().should.be(1);

            });

            it("should work normally for floats", {

                Sequence.make(1.0, 2.0, 3.0, 4.0).min().should.be(1.0);

            });

            it("should throw an exception if the sequence is empty", {

                (() -> new Sequence().min()).should.throwAnything();

            });

        });

        describe("sum", {

            it("should return the sum of each value in the sequence", {

                Sequence.make(1, 2, 3, 4).sum().should.be(10);

            });


            it("should work normally for floats", {

                Sequence.make(1.0, 2.0, 3.0, 4.0).sum().should.be(10.0);

            });

            it("should work normally for strings", {

                Sequence.make("1", "2", "3", "4").sum().should.be("1234");

            });

        });

        describe("product", {

            it("should return the product of each value in the sequence", {

                Sequence.make(1, 2, 3, 4).product().should.be(24);

            });

            it("should work normally for floats", {

                Sequence.make(1.0, 2.0, 3.0, 4.0).product().should.be(24.0);

            });

        });

        describe("forEach", {

            it("should execute the side effect for every value in the sequence", {

                var i = 0;
                Sequence.make(1, 2, 3, 4).forEach(x -> i += x);
                i.should.be(10);

            });

            it("should work normally for an empty sequence", {

                var i = 0;
                Sequence.make().forEach(x -> i += x);
                i.should.be(0);

            });

        });

        describe("forWhile", {

            it("should execute the side effect for every value in the sequence", {

                var i = 0;
                var c = Sequence.make(1, 2, 3, 4).forWhile(x -> { i += x; true; });
                i.should.be(10);
                c.should.be(4);

            });

            it("should stop execution after the side effect returns false", {

                var i = 0;
                var c = Sequence.make(1, 2, 3, 4).forWhile(x -> { i += x; i < 3; });
                i.should.be(3);
                c.should.be(2);

            });

            it("should work normally for an empty sequence", {

                var i = 0;
                var c = Sequence.make().forWhile(x -> { i += x; i < 3; });
                i.should.be(0);
                c.should.be(0);

            });

        });

        describe("push", {

            it("should add the given value to the end of the sequence", {

                trace(Sequence.make(1, 2, 3, 4).push(5));
                Sequence.make(1, 2, 3, 4).push(5).equals([1, 2, 3, 4, 5]).should.be(true);

            });

            it("should behave normally for an empty sequence", {

                new Sequence().push(4).equals([4]).should.be(true);

            });

        });

        describe("pushEach", {

            it("should add the given values to the end of the sequence", {

                Sequence.make(1, 2, 3, 4).pushEach([5, 6, 7, 8]).equals([1, 2, 3, 4, 5, 6, 7, 8]).should.be(true);

            });

            it("should behave normally for an empty sequence", {

                new Sequence().pushEach([4, 5, 6]).equals([4, 5, 6]).should.be(true);

            });

        });

        describe("pop", {

            it("should remove one value from the end of the sequence", {

                Sequence.make(1, 2, 3).pop().equals([1, 2]).should.be(true);

            });

            it("should do nothing for an empty sequence", {

                new Sequence().pop().equals(new Sequence()).should.be(true);

            });

        });

        describe("unshift", {

            it("should prepend a value to the front of the sequence", {

                Sequence.make(1, 2, 3, 4).unshift(5).equals([5, 1, 2, 3, 4]).should.be(true);

            });

            it("should work normally for an empty sequence", {

                new Sequence().unshift(5).equals([5]).should.be(true);

            });

        });

        describe("shift", {

            it("should remove the first value of the sequence", {

                Sequence.make(1, 2, 3, 4).shift().equals([2, 3, 4]).should.be(true);

            });

            it("should do nothing for an empty sequence", {

                new Sequence().shift().equals(new Sequence()).should.be(true);

            });

        });

        describe("insert", {

            it("should insert the given value at the given index", {

                Sequence.make(1, 2, 3, 4).insert(2, 99).equals([1, 2, 99, 3, 4]).should.be(true);

            });

            it("should grow the sequence if and only if index <= count()", {

                Sequence.make(1, 2, 3, 4).insert(4, 5).equals([1, 2, 3, 4, 5]).should.be(true);
                Sequence.make(1, 2, 3, 4).insert(5, 5).equals([1, 2, 3, 4]).should.be(true);
                Sequence.make(1, 2, 3, 4).insert(-1, 5).equals([1, 2, 3, 4]).should.be(true);

            });

            it("should behave normally for an empty sequence", {

                new Sequence().insert(0, 10).equals([10]).should.be(true);

            });

            it("optimization: should return the same identical sequence if the index is negative, or if the sequence has a complete cache and the index is known to be out of bounds", {

                // here we are testing for identity (memory address), not equality

                var seq = Sequence.make(1, 2, 3, 4);

                (seq.insert(0, 10) == seq).should.be(false);
                (seq.insert(30, 10) == seq).should.be(false);
                (seq.insert(-30, 10) == seq).should.be(true);

                seq.force();

                (seq.insert(0, 10) == seq).should.be(false);
                (seq.insert(30, 10) == seq).should.be(true);
                (seq.insert(-30, 10) == seq).should.be(true);

            });

        });
        
        describe("insertEach", {

            it("should insert the given values at the given index", {

                Sequence.make(1, 2, 3, 4).insertEach(2, [99, 99, 99]).equals([1, 2, 99, 99, 99, 3, 4]).should.be(true);

            });

            it("should grow the sequence if and only if index <= count()", {

                Sequence.make(1, 2, 3, 4).insertEach(4, [5, 6]).equals([1, 2, 3, 4, 5, 6]).should.be(true);
                Sequence.make(1, 2, 3, 4).insertEach(5, [5, 6]).equals([1, 2, 3, 4]).should.be(true);
                Sequence.make(1, 2, 3, 4).insertEach(-1, [5, 6]).equals([1, 2, 3, 4]).should.be(true);

            });

            it("should behave normally for an empty sequence", {

                new Sequence().insertEach(0, [10, 11, 12]).equals([10, 11, 12]).should.be(true);

            });

            it("optimization: should return the same identical sequence if the index is negative, or if the sequence has a complete cache and the index is known to be out of bounds", {

                // here we are testing for identity (memory address), not equality

                var seq = Sequence.make(1, 2, 3, 4);

                (seq.insertEach(0, [10]) == seq).should.be(false);
                (seq.insertEach(30, [10]) == seq).should.be(false);
                (seq.insertEach(-30, [10]) == seq).should.be(true);

                seq.force();

                (seq.insertEach(0, [10]) == seq).should.be(false);
                (seq.insertEach(30, [10]) == seq).should.be(true);
                (seq.insertEach(-30, [10]) == seq).should.be(true);

            });

        });

        describe("concat", {

            it("should add the given values to the end of the sequence", {

                Sequence.make(1, 2, 3, 4).concat([5, 6, 7, 8]).equals([1, 2, 3, 4, 5, 6, 7, 8]).should.be(true);

            });

            it("should behave normally for an empty sequence", {

                new Sequence().concat([4, 5, 6]).equals([4, 5, 6]).should.be(true);

            });

        });
        
        describe("concatEach", {

            it("should add the given sequences to the end of the sequence", {

                Sequence.make(1, 2, 3, 4).concatEach([[5, 6], [7, 8]]).equals([1, 2, 3, 4, 5, 6, 7, 8]).should.be(true);

            });

            it("should correctly skip empty sequences", {

                Sequence.make(1, 2, 3, 4).concatEach([[], [5, 6], [], [], [7, 8], []]).equals([1, 2, 3, 4, 5, 6, 7, 8]).should.be(true);

            });

            it("should behave normally for an empty sequence", {

                new Sequence().concat([4, 5, 6]).equals([4, 5, 6]).should.be(true);

            });  

        });

        describe("zip", {

            it("should zip the other sequence into this one", {

                var seq = Sequence.make(1, 1, 1, 1).zip([9, 9, 9, 9]);
                for (s in seq)
                    s.equals([1, 9]).should.be(true);

            });

            it("should handle mismatched lengths", {

                var seq = Sequence.make(1, 1).zip([9, 9, 9, 9]);
                seq.count().should.be(2);
                for (s in seq)
                    s.equals([1, 9]).should.be(true);

            });

            it("should work normally for an empty sequence", {

                var seq = Sequence.make(1, 1, 1, 1).zip([]);
                seq.equals([]).should.be(true);

            });

        });

        describe("zipEach", {

            it("should zip each of the other sequences into this one", {

                var seq = Sequence.make(1, 1, 1, 1).zipEach([[9, 9, 9, 9], [10, 10, 10, 10]]);
                for (s in seq)
                    s.equals([1, 9, 10]).should.be(true);

            });

            it("should handle mismatched lengths", {

                var seq = Sequence.make(1, 1).zipEach([[9, 9], [10, 10, 10]]);
                seq.count().should.be(2);
                for (s in seq)
                    s.equals([1, 9, 10]).should.be(true);

            });

            it("should work normally for an empty sequence", {

                var seq = Sequence.make(1, 1, 1, 1).zipEach([[9, 9], []]);
                seq.equals([]).should.be(true);

            });

        });

        describe("separate", {

            it("should interpose the separator between each element", {
               
                Sequence.make(1, 2, 3, 4).separate(0).equals([1, 0, 2, 0, 3, 0, 4]).should.be(true);

            });

            it("should do nothing for a sequence with 1 element", {

                Sequence.make(1).separate(0).equals([1]).should.be(true);

            });

            it("should do nothing for a sequence with 0 elements", {

                new Sequence().separate(0).equals([]).should.be(true);

            });

        });

        describe("interleave", {

            it("should interweave the elements of the other sequence between this one", {

                Sequence.make(1, 2, 3, 4).interleave([9, 8, 7, 6]).equals([1, 9, 2, 8, 3, 7, 4, 6]).should.be(true);

            });

            it("should handle mismatched lengths", {

                Sequence.make(1, 2, 3, 4).interleave([9, 8]).equals([1, 9, 2, 8, 3, 4]).should.be(true);
                Sequence.make(1, 2).interleave([9, 8, 7, 6]).equals([1, 9, 2, 8, 7, 6]).should.be(true);

            });

            it("should handle empty sequences", {

                Sequence.make(1, 2, 3, 4).interleave(new Sequence()).equals([1, 2, 3, 4]).should.be(true);
                new Sequence().interleave([9, 8, 7, 6]).equals([9, 8, 7, 6]).should.be(true);

            });

        });

        describe("split", {

            it("should split the sequence into subsequences divided by the given element", {

                var seq = Sequence.make(1, 2, 3, 4, 5, 4, 6, 7).split(4);
                seq.toString().should.be("Sequence { Sequence { 1, 2, 3 }, Sequence { 5 }, Sequence { 6, 7 } }");

            });

            it("should handle empty regions", {

                var seq = Sequence.make(4, 3, 4, 4, 6, 7, 4).split(4);
                seq.toString().should.be("Sequence { Sequence { }, Sequence { 3 }, Sequence { }, Sequence { 6, 7 }, Sequence { } }");

            });

        });

        describe("splitWhere", {

            it("should split the sequence into subsequences divided where the predicate is true", {

                var seq = Sequence.make(1, 1, 3, 4, 5, 2, 7, 7).splitWhere(x -> x % 2 == 0);
                seq.toString().should.be("Sequence { Sequence { 1, 1, 3 }, Sequence { 5 }, Sequence { 7, 7 } }");

            });

            it("should handle empty regions", {

                var seq = Sequence.make(2, 3, 4, 8, 7, 7, 4).splitWhere(x -> x % 2 == 0);
                seq.toString().should.be("Sequence { Sequence { }, Sequence { 3 }, Sequence { }, Sequence { 7, 7 }, Sequence { } }");

            });

        });

        describe("partition", {

            it("should divide the sequence along the given indices", {

                Sequence.make(1, 2, 3, 4, 5, 6).partition([4, 2]).equals([[1, 2], [3, 4], [5, 6]], true).should.be(true);

            });

            it("should handle empty partitions", {

                Sequence.make(1, 2, 3, 4, 5).partition([7, 5, 0, 1, 1]).equals([[], [1], [], [2, 3, 4, 5], []], true).should.be(true);

            });

            it("should handle extra indices", {

                Sequence.make(1, 2, 3, 4).partition([2, 9, 10, 11, 12]).equals([[1, 2], [3, 4]], true).should.be(true);

            });

            it("should handle zero indices", {

                Sequence.make(1, 2, 3, 4).partition([]).equals([[1, 2, 3, 4]], true).should.be(true);

            });

            it("should handle empty input", {

                new Sequence().partition([1, 2, 3]).equals([[]], true).should.be(true);

            });

        });

        describe("repeat", {

            it("should create a Sequence repeated num times", {
				
                Sequence.make(1, 2, 3).repeat(3).equals([1, 2, 3, 1, 2, 3, 1, 2, 3]).should.be(true);

            });

            it("should behave normally with an empty Sequence", {

                new Sequence<Int>().repeat(3).equals([]).should.be(true);

            });

            it("should behave normally with 0 or fewer repetitions", {

                Sequence.make(1, 2, 3).repeat(0).equals([]).should.be(true);
                Sequence.make(1, 2, 3).repeat(-10).equals([]).should.be(true);

            });

        });

        describe("shuffle", {

            // this test is disabled because it could occasionally fail...

            /*
            it("should rearrange the order of the elements", {

                var seq = Sequence.make(1, 2, 3, 4);
                seq.equals(seq.shuffle()).should.be(false);

            });
            */

        });

        describe("iterator", {

            it("should iterate over each value in the sequence", {

                var i = 0;
                for (v in Sequence.make(1, 2, 3, 4))
                    i += v;
                i.should.be(10);

            });


            it("should work normally for an empty sequence", {

                var i = 0;
                for (v in new Sequence())
                    i += v;
                i.should.be(0);

            });

        });

        describe("keyValueIterator", {

            it("should iterate over each index and value in the sequence", {

                var i = 0;
                for (k => v in Sequence.make(1, 2, 3, 4))
                    i += k + v;
                i.should.be(16);

            });

            it("should work normally for an empty seequence", {

                var i = 0;
                for (k => v in new Sequence())
                    i += k + v;
                i.should.be(0);

            });

        });

        describe("indices", {

            it("should iterate over each index in the sequence", {

                var i = 0;
                for (k in Sequence.make(1, 2, 3, 4).indices())
                    i += k;
                i.should.be(6);

            });

            it("should work normally for an empty sequence", {

                var i = 0;
                for (k in new Sequence().indices())
                    i += k;
                i.should.be(0);

            });

        });

        describe("values", {

            it("should iterate over each value in the sequence", {

                var i = 0;
                for (v in Sequence.make(1, 2, 3, 4).values())
                    i += v;
                i.should.be(10);

            });


            it("should work normally for an empty sequence", {

                var i = 0;
                for (v in new Sequence().values())
                    i += v;
                i.should.be(0);

            });

        });

        describe("entries", {

            it("should iterate over each index-value pair in the sequence", {

                var i = 0;
                for (pair in Sequence.make(1, 2, 3, 4).entries())
                    i += pair.key + pair.value;
                i.should.be(16);

            });

            it("should work normally for an empty seequence", {


                var i = 0;
                for (pair in new Sequence().entries())
                    i += pair.key + pair.value;
                i.should.be(0);

            }); 

        });

        describe("toArray", {

            it("should convert a sequence to an equivalent array", {

                var arr = Sequence.make(1, 2, 3, 4).toArray();
                arr.length.should.be(4);
                for (i in 0...arr.length)
                    arr[i].should.be(Sequence.make(1, 2, 3, 4)[i]);

            });

        });

        describe("toMap", {

            it("should convert a sequence to an equivalent Map", {

                var map = Sequence.make(1, 2, 3, 4).toMap();
                map.length.should.be(4);
                for (k in map.keys())
                    map.get(k).should.be(Sequence.make(1, 2, 3, 4)[k]);

            });

        });

        describe("toOrderedMap", {

            it("should convert a sequence to an equivalent OrderedMap", {

                var map = Sequence.make(1, 2, 3, 4).toOrderedMap();
                map.length.should.be(4);
                var i = 0;
                for (k => v in map)
                    Sequence.make(1, 2, 3, 4)[i++].should.be(v);

            });

        });

        describe("toSet", {

            it("should convert a sequence to an equivalent Set", {

                var set = Sequence.make(1, 2, 3, 3, 4).toSet();
                set.length.should.be(4);
                for (v in Sequence.make(1, 2, 3, 3, 4))
                    set.has(v).should.be(true);

            });

        });

        describe("toOrderedSet", {

            it("should convert a sequence to an equivalent OrderedSet", {

                var set = Sequence.make(1, 2, 3, 3, 4).toOrderedSet();
                set.length.should.be(4);
                var i = 0;
                for (v in set)
                    Sequence.make(1, 2, 3, 4)[i++].should.be(v);

            });

        });

        describe("toList", {

            it("should convert a sequence to an equivalent List", {

                var vec = Sequence.make(1, 2, 3, 4).toList();
                vec.length.should.be(4);
                var i = 0;
                for (v in vec)
                    Sequence.make(1, 2, 3, 4)[i++].should.be(v);

            });

        });

        describe("toStack", {

            it("should convert a sequence to an equivalent reversed Stack", {

                var stack = Sequence.make(1, 2, 3, 4).toStack();
                var i = 0;
                for (v in stack)
                    Sequence.make(1, 2, 3, 4).reverse()[i++].should.be(v);

            });

        });

        describe("toString", {

            it("should convert a sequence to its string representation", {

                Sequence.make(1, 2, 3, 4).toString().should.be("Sequence { 1, 2, 3, 4 }");

            });

            it("should handle the empty sequence", {

                new Sequence().toString().should.be("Sequence { }");

            });

            it("should handle nested sequences", {

                Sequence.make(Sequence.make(1, 2), Sequence.make(3, 4))
                    .toString().should.be("Sequence { Sequence { 1, 2 }, Sequence { 3, 4 } }");

            });

        });

    }
}
