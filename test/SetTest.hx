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

using StringTools;

import wavemode.immutable.Set;
import wavemode.immutable.OrderedSet;

class SetTest extends BuddySuite {
	public function new() {

		describe("new", {

			it("should create a new empty Set", {

				new Set().equals([]).should.be(true);

			});

			it("should make a clone of another sequence", {

				new Set([1, 2, 3, 4]).equals([1, 2, 3, 4]).should.be(true);

			});

		});

		describe("fromSequence", {
			var one, two, three;

			beforeEach({
				one = [1, 1, 1, 1, 2, 3, 4, 5, 5, 5];
				two = Set.fromSequence(one);
				three = Set.fromSequence([]);
			});

			it("should remove duplicate values", {
				two.equals(Set.fromSequence([1, 2, 3, 4, 5])).should.be(true);
			});

			it("should behave normally for an empty array", {
				three.equals(new Set()).should.be(true);
			});
		});

		describe("make", {

			it("should allow for variadic Set creation", {

				Set.make(1, 2, 2, 3, 3, 4).equals([1, 2, 3, 4]).should.be(true);

			});

			it("should work normally for an empty input", {

				Set.make().equals([]).should.be(true);

			});

		});


		describe("add", {
			var one, two, three;

			beforeEach({
				one = Set.fromSequence([1, 2, 3, 4, 5]);
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
				one = Set.fromSequence([1, 2, 3, 4, 5]);
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

		describe("replace", {
			var one, two;

			beforeEach({
				one = Set.fromSequence([1, 2, 3, 4, 5]);
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
				one = Set.fromSequence([1, 2, 3, 4, 5]);
				two = one.replaceEach([2, 3], [8, 9]);
			});

			it("should remove existing values", {
				two.equals([5, 4, 9, 8, 1]).should.be(true);
			});

			it("should not modify the original", {
				one.equals([1, 2, 3, 4, 5]).should.be(true);
			});
		});

		describe("has / contains", {
			var one, two;

			beforeEach({
				one = Set.fromSequence([1, 2, 3, 4, 5]);
				two = Set.fromSequence([3, 7, 8, 9, 10]);
			});

			it("should return true for existing values", {
				one.has(1).should.be(true);
				one.contains(1).should.be(true);
			});

			it("should return false for nonexistant values", {
				two.has(1).should.be(false);
				two.contains(1).should.be(false);
			});
		});

		describe("empty", {
			it("should be true when the set is empty", {
				new Set().empty().should.be(true);
			});

			it("should be false when the set is not empty", {
				new Set().add(1).empty().should.be(false);
			});
		});

		describe("filter", {
			var one, two;

			beforeEach({
				one = Set.fromSequence([1, 2, 3, 4, 5]);
				two = one.filter(x -> x < 3);
			});

			it("should only include values satisfying the predicate", {
				two.equals([1, 2]).should.be(true);
			});

			it("should not modify the original", {
				one.equals([1, 2, 3, 4, 5]).should.be(true);
			});
		});

		describe("remove", {
			var one, two;

			beforeEach({
				one = Set.fromSequence([1, 2, 3, 4, 5]);
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
				one = Set.fromSequence([1, 2, 3, 4, 5]);
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
				one = Set.fromSequence([1, 2, 3, 4, 5]);
				two = one.clear();
			});

			it("should remove all values", {
				two.equals([]).should.be(true);
			});

			it("should not modify the original", {
				one.equals([1, 2, 3, 4, 5]).should.be(true);
			});
		});

		describe("union / +", {
			var one, two, three, four, five, six, seven;

			beforeEach({
				one = Set.fromSequence([1, 2, 3, 4, 5]);
				two = Set.fromSequence([6, 7, 8, 9, 10]);
				three = Set.fromSequence([4, 5, 6, 7]);
				four = one.union(two);
				five = one.union(three);
				six = one + two;
				seven = one + three;
			});

			it("should add new values to the set", {
				four.equals([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]).should.be(true);
				six.equals([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]).should.be(true);
			});

			it("should not add duplicate values", {
				five.equals([1, 2, 3, 4, 5, 6, 7]).should.be(true);
				seven.equals([1, 2, 3, 4, 5, 6, 7]).should.be(true);
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
				one = Set.fromSequence([1, 2, 3]);
				two = Set.fromSequence([6, 7, 8]);
				three = Set.fromSequence([4, 5, 6]);
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

		describe("subtract / -", {
			var one, two, three, four, five;

			beforeEach({
				one = Set.fromSequence([1, 2, 3, 4, 5]);
				two = Set.fromSequence([6, 7, 8, 9, 10]);
				three = Set.fromSequence([4, 5, 6, 7]);
				four = one.subtract(three);
				five = one - three;
			});

			it("should only include values not in the second set", {
				four.equals([1, 2, 3]).should.be(true);
				five.equals([1, 2, 3]).should.be(true);
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
				one = Set.fromSequence([1, 2, 3, 4, 5]);
				two = Set.fromSequence([3, 7, 8, 9, 10]);
				three = Set.fromSequence([4, 5, 6, 7]);
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
				one = Set.fromSequence([1, 2, 3, 4, 5]);
				two = one.map(Std.string);
			});

			it("should pass each value through the mapper function", {
				two.equals(["1", "2", "3", "4", "5"]).should.be(true);
			});

			it("should not modify the original", {
				one.equals([1, 2, 3, 4, 5]).should.be(true);
			});
		});

		describe("intersect", {
			var one, two, three, four, five;

			beforeEach({
				one = Set.fromSequence([1, 2, 3, 4, 5]);
				two = Set.fromSequence([6, 7, 8, 9, 10]);
				three = Set.fromSequence([4, 5, 6, 7]);
				four = one.intersect(two);
				five = one.intersect(three);
			});

			it("should only include values from both sets", {
				four.empty().should.be(true);
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
				one = Set.fromSequence([1, 2, 3, 4, 5]);
				two = Set.fromSequence([4, 6, 7, 8, 9, 10]);
				three = Set.fromSequence([4, 5, 6, 7]);
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

		describe("fold", {

			it("should accumulate the values according to foldFn", {

				Set.make(4, 5, 6).fold((a, b) -> a + b, 0).should.be(15);

			});

			it("should work normally for an empty Set", {

				new Set().fold((a, b) -> a + b, 10).should.be(10);

			});

		});

		describe("reduce", {

			it("should accumulate the values according to foldFn", {

				Set.make(4, 5, 6).reduce((a, b) -> a + b).should.be(15);

			});

			it("should throw an exception for an empty Set", {

				(() -> new Set().reduce((a, b) -> a + b)).should.throwAnything();

			});

		});

		describe("length", {
			var one, two;

			beforeEach({
				one = [1, 2, 3, 4, 5];
				two = Set.fromSequence(one);
			});

			it("should contain the number of elements in the set", {
				two.length.should.be(5);
			});
		});

		describe("every", {

			it("should return true if the predicate is true for all values", {

				Set.make(2, 4, 6).every(x -> x % 2 == 0).should.be(true);

			});

			it("should return false if the predicate is false for any value", {

				Set.make(2, 4, 7).every(x -> x % 2 == 0).should.be(false);

			});

			it("should return true for an empty Set", {

				new Set().every(x -> x % 2 == 0).should.be(true);

			});

		});

		describe("some", {

			it("should return true if the predicate is true for any value", {

				Set.make(3, 3, 6).some(x -> x % 2 == 0).should.be(true);

			});

			it("should return false if the predicate is false for all values", {

				Set.make(3, 5, 7).some(x -> x % 2 == 0).should.be(false);

			});

			it("should return false for an empty Set", {

				new Set().some(x -> x % 2 == 0).should.be(false);

			});

		});

		describe("equals", {
			var one, two, three, four;

			beforeEach({
				one = Set.fromSequence([1, 2, 3, 4, 5]);
				two = Set.fromSequence([3, 7, 8, 9, 10]);
				three = Set.fromSequence([4, 5, 6, 7]);
			});

			it("should work for comparing ordered sets", {
				one.equals(OrderedSet.fromSequence([1, 2, 3, 4, 5])).should.be(true);
				two.equals(OrderedSet.fromSequence([3, 7, 8, 9, 10])).should.be(true);
				three.equals(OrderedSet.fromSequence([4, 5, 6, 7])).should.be(true);
				one.equals(OrderedSet.fromSequence([1, 2])).should.be(false);
				two.equals(OrderedSet.fromSequence([3, 7])).should.be(false);
				three.equals(OrderedSet.fromSequence([4, 5])).should.be(false);
			});

			it("should work for comparing unordered sets", {
				one.equals(Set.fromSequence([1, 2, 3, 4, 5])).should.be(true);
				two.equals(Set.fromSequence([3, 7, 8, 9, 10])).should.be(true);
				three.equals(Set.fromSequence([4, 5, 6, 7])).should.be(true);
				one.equals(Set.fromSequence([1, 2])).should.be(false);
				two.equals(Set.fromSequence([3, 7])).should.be(false);
				three.equals(Set.fromSequence([4, 5])).should.be(false);
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

		describe("supersetOf", {

			it("should return true if every value in other is in this Set", {

				Set.make(1, 2, 3, 4).supersetOf([3, 2, 1]).should.be(true);

			});

			it("should return false if any value in other is not in this Set", {

				Set.make(1, 2, 3, 4).supersetOf([3, 2, 1, 0]).should.be(false);

			});

			it("should work normally for an empty Set", {

				Set.make().supersetOf([]).should.be(true);
				Set.make().supersetOf([1]).should.be(false);

			});

		});

		describe("subsetOf", {

			it("should return true if every value in this Set is in other", {

				Set.make(1, 2, 3).subsetOf([4, 3, 2, 1]).should.be(true);

			});

			it("should return false if any value in this Set is not in other", {

				Set.make(1, 2, 3, 4).subsetOf([3, 2, 1, 0]).should.be(false);

			});

			it("should work normally for an empty input", {

				Set.make().subsetOf([]).should.be(true);
				Set.make(1).subsetOf([]).should.be(false);

			});

		});

		describe("forEach", {
			var one, i;

			beforeEach({
				one = Set.fromSequence([1, 2, 3, 4, 5]);
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

		describe("iterator", {
			var one, two;

			beforeEach({
				one = [1, 2, 3, 4, 5];
				two = Set.fromSequence(one);
			});

			it("should iterate over all values in any order", {
				two.length.should.be(one.length);
				for (v in two)
					one.indexOf(v).should.not.be(-1);
			});
		});

		describe("values", {
			var one, two;

			beforeEach({
				one = [1, 2, 3, 4, 5];
				two = Set.fromSequence(one);
			});

			it("should iterate over all values in any order", {
				two.length.should.be(one.length);
				for (v in two.values())
					one.indexOf(v).should.not.be(-1);
			});
		});

		describe("toArray", {

			it("should convert to an equivalent Array", {

				var set = Set.make(1, 2, 3, 4);
				var arrIter = set.toArray().iterator();

				for (v in set)
					v.should.be(arrIter.next());

			});

		});

		describe("toOrderedSet", {

			it("should convert to an equivalent OrderedSet", {

				var set = Set.make(1, 2, 3, 4);
				set.equals(set.toOrderedSet()).should.be(true);

			});

		});

		describe("toString", {

			it("should convert to an equivalent String representation", {

				// this test is tricky, since iteration order is unspecified...
				var str = Set.make(1, 2, 3, 4).toString();
				str.startsWith("Set (").should.be(true);
				str.endsWith(")").should.be(true);
				str.contains("1").should.be(true);
				str.contains("2").should.be(true);
				str.contains("3").should.be(true);
				str.contains("4").should.be(true);


			});

			it("should work normally for an empty Set", {

				Set.make().toString().should.be("Set ( )");

			});

		});

		describe("toList", {

			it("should convert to an equivalent List", {

				var set = Set.make(1, 2, 3, 4);
				var vecIter = set.toList().iterator();

				for (v in set)
					v.should.be(vecIter.next());

			});

		});


		describe("toSequence", {

			it("should convert to an equivalent Sequence", {

				var set = Set.make(1, 2, 3, 4);
				var seqIter = set.toSequence().iterator();

				for (v in set)
					v.should.be(seqIter.next());

			});

		});
		
	}
}
