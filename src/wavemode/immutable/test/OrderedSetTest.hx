/**
 *  Copyright (c) 2020-present, Chukwudi Okechukwu
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the root directory of this source tree.
 *
 */

package wavemode.immutable.test;

import buddy.BuddySuite;
import haxe.ds.Option;
using buddy.Should;

class OrderedSetTest extends BuddySuite {
	public function new() {
		// TODO: failure for unhashable types
		// TODO: success for hashable types
		// TODO: proper conversion testing

		describe("iterator", {
			var one, two, three, iter;

			beforeEach({
				one = [1, 2, 3, 4, 5];
				iter = one.iterator();
				two = OrderedSet.fromArray(one);
				three = new OrderedSet().add(one[0]).add(one[1]).add(one[2]).add(one[3]).add(one[4]);
			});

			it("should iterate in array order", {
				for (v in two)
					v.should.be(iter.next());
			});

			it("should iterate in insertion order", {
				for (v in three)
					v.should.be(iter.next());
			});
		});

		describe("fromArray", {
			var one, two, three;

			beforeEach({
				one = [1, 1, 1, 1, 2, 3, 4, 5, 5, 5];
				two = OrderedSet.fromArray(one);
				three = OrderedSet.fromArray([]);
			});

			it("should remove duplicate values", {
				two.equals(OrderedSet.fromArray([1, 2, 3, 4, 5])).should.be(true);
			});

			it("should behave normally for an empty array", {
				three.equals(new OrderedSet()).should.be(true);
			});
		});

		describe("length", {
			var one, two;

			beforeEach({
				one = [1, 2, 3, 4, 5];
				two = OrderedSet.fromArray(one);
			});

			it("should contain the number of elements in the set", {
				two.length.should.be(5);
			});
		});

		describe("empty", {
			it("should be true when the set is empty", {
				new OrderedSet() == null.should.be(true);
			});

			it("should be false when the set is not empty", {
				new OrderedSet().add(1) == null.should.be(false);
			});
		});

		describe("add", {
			var one, two, three;

			beforeEach({
				one = OrderedSet.fromArray([1, 2, 3, 4, 5]);
				two = one.add(6);
				three = one.add(5);
			});

			it("should add a new value", {
				two.equals([6, 5, 4, 3, 2, 1]).should.be(true);
			});

			it("should not add existing values", {
				three.equals(one).should.be(true);
			});

			it("should not modify the original", {
				one.equals([1, 2, 3, 4, 5]).should.be(true);
			});
		});

		describe("addEach", {
			var one, two, three;

			beforeEach({
				one = OrderedSet.fromArray([1, 2, 3, 4, 5]);
				two = one.addEach([6, 7]);
				three = one.addEach([4, 5]);
			});

			it("should add new values", {
				two.equals([6, 5, 7, 4, 3, 2, 1]).should.be(true);
			});

			it("should not add existing values", {
				three.equals(one).should.be(true);
			});

			it("should not modify the original", {
				one.equals([1, 2, 3, 4, 5]).should.be(true);
			});
		});

		describe("remove", {
			var one, two;

			beforeEach({
				one = OrderedSet.fromArray([1, 2, 3, 4, 5]);
				two = one.remove(2);
			});

			it("should remove existing values", {
				two.equals([5, 4, 3, 1]).should.be(true);
			});

			it("should not modify the original", {
				one.equals([1, 2, 3, 4, 5]).should.be(true);
			});
		});

		describe("removeEach", {
			var one, two;

			beforeEach({
				one = OrderedSet.fromArray([1, 2, 3, 4, 5]);
				two = one.removeEach([2, 1]);
			});

			it("should remove existing values", {
				two.equals([5, 4, 3]).should.be(true);
			});

			it("should not modify the original", {
				one.equals([1, 2, 3, 4, 5]).should.be(true);
			});
		});

		describe("clear", {
			var one, two;

			beforeEach({
				one = OrderedSet.fromArray([1, 2, 3, 4, 5]);
				two = one.clear();
			});

			it("should remove all values", {
				two.equals([]).should.be(true);
			});

			it("should not modify the original", {
				one.equals([1, 2, 3, 4, 5]).should.be(true);
			});
		});

		describe("replace", {
			var one, two;

			beforeEach({
				one = OrderedSet.fromArray([1, 2, 3, 4, 5]);
				two = one.replace(2, 8);
			});

			it("should remove existing values", {
				two.equals([5, 4, 3, 8, 1]).should.be(true);
			});

			it("should not modify the original", {
				one.equals([1, 2, 3, 4, 5]).should.be(true);
			});
		});

		describe("replaceEach", {
			var one, two;

			beforeEach({
				one = OrderedSet.fromArray([1, 2, 3, 4, 5]);
				two = one.replaceEach([2, 3], [8, 9]);
			});

			it("should remove existing values", {
				two.equals([5, 4, 9, 8, 1]).should.be(true);
			});

			it("should not modify the original", {
				one.equals([1, 2, 3, 4, 5]).should.be(true);
			});
		});

		describe("union", {
			var one, two, three, four, five;

			beforeEach({
				one = OrderedSet.fromArray([1, 2, 3, 4, 5]);
				two = OrderedSet.fromArray([6, 7, 8, 9, 10]);
				three = OrderedSet.fromArray([4, 5, 6, 7]);
				four = one.union(two);
				five = one.union(three);
			});

			it("should add new values to the set", {
				four.equals([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]).should.be(true);
			});

			it("should not add duplicate values", {
				five.equals([1, 2, 3, 4, 5, 6, 7]).should.be(true);
			});

			it("should not modify the original", {
				one.equals([1, 2, 3, 4, 5]).should.be(true);
				two.equals([6, 7, 8, 9, 10]).should.be(true);
				three.equals([4, 5, 6, 7]).should.be(true);
			});
		});

		describe("unionEach", {
			var one, two, three, four;

			beforeEach({
				one = OrderedSet.fromArray([1, 2, 3]);
				two = OrderedSet.fromArray([6, 7, 8]);
				three = OrderedSet.fromArray([4, 5, 6]);
				four = one.unionEach([two, three]);
			});

			it("should union each set without allowing duplicate values", {
				four.equals([1, 2, 3, 6, 7, 8, 4, 5]).should.be(true);
			});

			it("should not modify the originals", {
				one.equals([1, 2, 3]).should.be(true);
				two.equals([6, 7, 8]).should.be(true);
				three.equals([4, 5, 6]).should.be(true);
			});
		});

		describe("intersect", {
			var one, two, three, four, five;

			beforeEach({
				one = OrderedSet.fromArray([1, 2, 3, 4, 5]);
				two = OrderedSet.fromArray([6, 7, 8, 9, 10]);
				three = OrderedSet.fromArray([4, 5, 6, 7]);
				four = one.intersect(two);
				five = one.intersect(three);
			});

			it("should only include values from both sets", {
				four == null.should.be(true);
				five.equals([4, 5]).should.be(true);
			});

			it("should not modify the original", {
				one.equals([1, 2, 3, 4, 5]).should.be(true);
				two.equals([6, 7, 8, 9, 10]).should.be(true);
				three.equals([4, 5, 6, 7]).should.be(true);
			});
		});

		describe("intersectEach", {
			var one, two, three, four, five;

			beforeEach({
				one = OrderedSet.fromArray([1, 2, 3, 4, 5]);
				two = OrderedSet.fromArray([4, 6, 7, 8, 9, 10]);
				three = OrderedSet.fromArray([4, 5, 6, 7]);
				four = one.intersectEach([two, three]);
				five = one.intersectEach([]);
			});

			it("should only include values from all sets", {
				four.equals([4]).should.be(true);
			});

			it("should do nothing if the iterable is empty", {
				five.equals(one).should.be(true);
			});

			it("should not modify the original", {
				one.equals([1, 2, 3, 4, 5]).should.be(true);
				two.equals([4, 6, 7, 8, 9, 10]).should.be(true);
				three.equals([4, 5, 6, 7]).should.be(true);
			});
		});

		describe("subtract", {
			var one, two, three, four;

			beforeEach({
				one = OrderedSet.fromArray([1, 2, 3, 4, 5]);
				two = OrderedSet.fromArray([6, 7, 8, 9, 10]);
				three = OrderedSet.fromArray([4, 5, 6, 7]);
				four = one.subtract(three);
			});

			it("should only include values not in the second set", {
				four.equals([1, 2, 3]).should.be(true);
			});

			it("should not modify the original", {
				one.equals([1, 2, 3, 4, 5]).should.be(true);
				two.equals([6, 7, 8, 9, 10]).should.be(true);
				three.equals([4, 5, 6, 7]).should.be(true);
			});
		});

		describe("subtractEach", {
			var one, two, three, four;

			beforeEach({
				one = OrderedSet.fromArray([1, 2, 3, 4, 5]);
				two = OrderedSet.fromArray([3, 7, 8, 9, 10]);
				three = OrderedSet.fromArray([4, 5, 6, 7]);
				four = one.subtractEach([two, three]);
			});

			it("should only include values not in any of the subtracted sets", {
				four.equals([1, 2]).should.be(true);
			});

			it("should not modify the original", {
				one.equals([1, 2, 3, 4, 5]).should.be(true);
				two.equals([3, 7, 8, 9, 10]).should.be(true);
				three.equals([4, 5, 6, 7]).should.be(true);
			});
		});

		describe("map", {
			var one, two;

			beforeEach({
				one = OrderedSet.fromArray([1, 2, 3, 4, 5]);
				two = one.map(Std.string);
			});

			it("should pass each value through the mapper function", {
				two.equals(["1", "2", "3", "4", "5"]).should.be(true);
			});

			it("should not modify the original", {
				one.equals([1, 2, 3, 4, 5]).should.be(true);
			});
		});

		describe("filter", {
			var one, two;

			beforeEach({
				one = OrderedSet.fromArray([1, 2, 3, 4, 5]);
				two = one.filter(x -> x < 3);
			});

			it("should only include values satisfying the predicate", {
				two.equals([1, 2]).should.be(true);
			});

			it("should not modify the original", {
				one.equals([1, 2, 3, 4, 5]).should.be(true);
			});
		});

		describe("values", {
			var one, two, three, iter;

			beforeEach({
				one = [1, 2, 3, 4, 5];
				iter = one.iterator();
				two = OrderedSet.fromArray(one);
				three = new OrderedSet().add(one[0]).add(one[1]).add(one[2]).add(one[3]).add(one[4]);
			});

			it("should iterate in array order", {
				for (v in two.values())
					v.should.be(iter.next());
			});

			it("should iterate in insertion order", {
				for (v in three.values())
					v.should.be(iter.next());
			});
		});

		describe("equals", {
			var one, two, three, four;

			beforeEach({
				one = OrderedSet.fromArray([1, 2, 3, 4, 5]);
				two = OrderedSet.fromArray([3, 7, 8, 9, 10]);
				three = OrderedSet.fromArray([4, 5, 6, 7]);
			});

			it("should work for comparing ordered sets", {
				one.equals(OrderedSet.fromArray([1, 2, 3, 4, 5])).should.be(true);
				two.equals(OrderedSet.fromArray([3, 7, 8, 9, 10])).should.be(true);
				three.equals(OrderedSet.fromArray([4, 5, 6, 7])).should.be(true);
				one.equals(OrderedSet.fromArray([1, 2])).should.be(false);
				two.equals(OrderedSet.fromArray([3, 7])).should.be(false);
				three.equals(OrderedSet.fromArray([4, 5])).should.be(false);
			});

			it("should work for comparing unordered sets", {
				one.equals(Set.fromArray([1, 2, 3, 4, 5])).should.be(true);
				two.equals(Set.fromArray([3, 7, 8, 9, 10])).should.be(true);
				three.equals(Set.fromArray([4, 5, 6, 7])).should.be(true);
				one.equals(Set.fromArray([1, 2])).should.be(false);
				two.equals(Set.fromArray([3, 7])).should.be(false);
				three.equals(Set.fromArray([4, 5])).should.be(false);
			});

			it("should work for comparing with arrays", {
				one.equals([1, 2, 3, 4, 5]).should.be(true);
				two.equals([3, 7, 8, 9, 10]).should.be(true);
				three.equals([4, 5, 6, 7]).should.be(true);
				one.equals([1, 2]).should.be(false);
				two.equals([3, 7]).should.be(false);
				three.equals([4, 5]).should.be(false);
			});

			it("should work for comparing with self", {
				one.equals(one).should.be(true);
				two.equals(two).should.be(true);
				three.equals(three).should.be(true);
				one.equals(two).should.be(false);
				two.equals(three).should.be(false);
				three.equals(one).should.be(false);
			});
		});

		describe("has", {
			var one, two;

			beforeEach({
				one = OrderedSet.fromArray([1, 2, 3, 4, 5]);
				two = OrderedSet.fromArray([3, 7, 8, 9, 10]);
			});

			it("should return true for existing values", {
				one.has(1).should.be(true);
			});

			it("should return false for nonexistant values", {
				two.has(1).should.be(false);
			});
		});

		describe("forEach", {
			var one, i;

			beforeEach({
				one = OrderedSet.fromArray([1, 2, 3, 4, 5]);
				i = 0;
			});

			it("should execute sideEffect for each value", {
				one.forEach(x -> i += x);
				i.should.be(15);
			});

			it("should not modify the set", {
				one.equals([1, 2, 3, 4, 5]).should.be(true);
			});
		});

		describe("forWhile", {
			var one, i;

			beforeEach({
				one = OrderedSet.fromArray([1, 2, 3, 4, 5]);
				i = 0;
			});

			it("should execute sideEffect for each value", {
				one.forWhile(x -> {
					i += x;
					true;
				});
				i.should.be(15);
			});

			it("should stop executing when sideEffect returns false", {
				one.forWhile(x -> {
					i += x;
					i < 10;
				}).should.be(4);
				i.should.be(10);
			});

			it("should not modify the set", {
				one.equals([1, 2, 3, 4, 5]).should.be(true);
			});
		});

		describe("toArray", {});
		describe("toSequence", {});
		describe("toSet", {});
		describe("toVector", {});
		describe("toStack", {});
	}
}
