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

class OrderedMapTest extends BuddySuite {
	public function new() {
		// TODO: failure for unhashable types
		// TODO: success for hashable types

		describe("new", {

			it("should create a blank map", {

				new OrderedMap().empty().should.be(true);

			});

			it("should create a copy of another OrderedMap", {

				new OrderedMap(OrderedMap.make({a: 1, b: 2, c: 3}))
					.equals(OrderedMap.make({a: 1, b: 2, c: 3})).should.be(true);

			});

		});

		describe("fromMap", {
			it("should create an equivalent OrderedMap from a haxe.ds.Map", {
				var hxMap = [4 => "foo", 5 => "bar", 6 => "baz"];
				var map = OrderedMap.fromMap(hxMap);

				map.get(4).should.be("foo");
				map.get(5).should.be("bar");
				map.get(6).should.be("baz");
				map.get(7).should.be(null);
			});
		});

		describe("make", {
			it("should allow for creation of a map from an object literal", {
				var map = OrderedMap.make({a: "foo", b: "bar", c: "baz"});
				map.get("a").should.be("foo");
				map.get("b").should.be("bar");
				map.get("c").should.be("baz");
			});
		});

		describe("set", {
			var one, two;

			beforeEach({
				one = OrderedMap.make({a: 5, b: 6});
				two = one.set("c", 7).set("d", 8).set("b", 10);
			});

			it("should add a new key", {
				two.get("c").should.be(7);
				two.get("d").should.be(8);
			});

			it("should update existing keys", {
				two.get("b").should.be(10);
			});

			it("should not modify the original", {
				one.equals(OrderedMap.make({b: 6, a: 5})).should.be(true);
			});
		});

		describe("setEach", {
			var one, two;

			beforeEach({
				one = OrderedMap.make({a: 4, b: 5, c: 6});
				two = one.setEach(["c", "d"], [7, 8]);
			});

			it("should create new keys", {
				two.get("d").should.be(8);
			});

			it("should update existing keys", {
				two.get("c").should.be(7);
			});

			it("should not modify the original", {
				one.equals(OrderedMap.make({a: 4, b: 5, c: 6})).should.be(true);
			});
		});

		describe("update", {
			var one, two, three;

			beforeEach({
				one = OrderedMap.make({a: 4, b: 5, c: 6});
				two = one.update("a", (x) -> x * 2);
				three = one.update("d", (x) -> x * 2);
			});

			it("should update the value of the key", {
				two.equals(OrderedMap.make({a: 8, b: 5, c: 6})).should.be(true);
			});

			it("should not modify the original", {
				one.equals(OrderedMap.make({a: 4, b: 5, c: 6})).should.be(true);
			});

			it("should do nothing if the key does not exist", {
				three.equals(one).should.be(true);
			});
		});

		describe("updateEach", {
			var one, two, three;

			beforeEach({
				one = OrderedMap.make({a: 4, b: 5, c: 6});
				two = one.updateEach(["a", "b"], (x) -> x * 2);
				three = one.updateEach(["d", "e"], (x) -> x * 2);
			});

			it("should update the value of the keys", {
				two.equals(OrderedMap.make({a: 8, b: 10, c: 6})).should.be(true);
			});

			it("should not modify the original", {
				one.equals(OrderedMap.make({a: 4, b: 5, c: 6})).should.be(true);
			});

			it("should do nothing if the key does not exist", {
				three.equals(one).should.be(true);
			});
		});

		describe("replace", {
			var one, two, three;

			beforeEach({
				one = OrderedMap.make({a: 4, b: 5, c: 4});
				two = one.replace(4, 10);
				three = one.replace(9, 10);
			});

			it("should replace every occurrence of the given value", {
				two.equals(OrderedMap.make({a: 10, b: 5, c: 10})).should.be(true);
			});

			it("should not modify the original", {
				one.equals(OrderedMap.make({a: 4, b: 5, c: 4})).should.be(true);
			});

			it("should do nothing if the value does not exist", {
				three.equals(one).should.be(true);
			});
		});

		describe("replaceEach", {
			var one, two, three;

			beforeEach({
				one = OrderedMap.make({a: 4, b: 5, c: 4});
				two = one.replaceEach([4, 5], [5, 10]);
				three = one.replaceEach([9, 10], [10, 11]);
			});

			it("should replace every occurrence of the given values", {
				two.equals(OrderedMap.make({a: 5, b: 10, c: 5})).should.be(true);
			});

			it("should not modify the original", {
				one.equals(OrderedMap.make({a: 4, b: 5, c: 4})).should.be(true);
			});

			it("should do nothing if the values do not exist", {
				three.equals(one).should.be(true);
			});
		});

		describe("get", {
			var one;

			beforeEach({
				one = OrderedMap.make({a: 10, b: 20, c: 30});
			});

			it("should retrieve existing keys", {
				one.get("a").should.be(10);
			});

			it("should return null for nonexisting keys", {
				one.get("d").should.be(null);
			});
		});
		

		describe("getValue [index]", {
			var one;

			beforeEach({
				one = OrderedMap.make({a: 10, b: 20, c: 30});
			});

			it("should retrieve existing keys", {
				one.getValue("a").should.be(10);
				one["a"].should.be(10);
			});

			it("should throw an exception for nonexisting keys", {
				(() -> one.getValue("d")).should.throwAnything();
				(() -> one["d"]).should.throwAnything();
			});
		});
		
		describe("has", {
			var one;

			beforeEach({
				one = OrderedMap.make({a: 10, b: 20, c: 30});
			});

			it("should return true for existing keys", {
				one.has("a").should.be(true);
			});

			it("should return false for nonexisting keys", {
				one.has("d").should.be(false);
			});
		});

		describe("empty", {
			it("should be true when the map is empty", {
				new OrderedMap().empty().should.be(true);
			});

			it("should be false when the map is not empty", {
				new OrderedMap().set(1, 2).empty().should.be(false);
			});
		});

		describe("find", {
			var one;

			beforeEach({
				one = OrderedMap.make({a: 4, b: 5, c: 4});
			});

			it("should return the key of the given value", {
				one.find(4).should.be("a");
			});

			it("should return null for nonexistent values", {
				one.find(20).should.be(null);
			});
		});

		describe("findWhere", {
			var one;

			beforeEach({
				one = OrderedMap.make({a: 4, b: 5, c: 4});
			});

			it("should return the first key where the predicate is satisfied", {
				one.findWhere(x -> x == 4).should.be("a");
			});

			it("should return null if the predicate never returns true", {
				one.findWhere(x -> x == 20).should.be(null);
			});
		});

		describe("filter", {
			var one, two;

			beforeEach({
				one = OrderedMap.make({a: 10, b: 20, c: 30});
				two = one.filter((k, x) -> x % 3 == 0);
			});

			it("should remove values not satisfying predicate", {
				two.equals(OrderedMap.make({c: 30})).should.be(true);
			});

			it("should not modify the original", {
				one.equals(OrderedMap.make({a: 10, b: 20, c: 30})).should.be(true);
			});
		});


		describe("remove", {
			var one, two;

			beforeEach({
				one = OrderedMap.make({a: 4, b: 5, c: 5});
				two = one.remove(5);
			});

			it("should remove every instance of a value", {
				two.equals(OrderedMap.make({a: 4})).should.be(true);
			});

			it("should not modify the original", {
				one.equals(OrderedMap.make({a: 4, b: 5, c: 5})).should.be(true);
			});
		});

		describe("removeEach", {
			var one, two;

			beforeEach({
				one = OrderedMap.make({a: 4, b: 5, c: 6});
				two = one.removeEach([4, 5]);
			});

			it("should remove each value", {
				two.equals(OrderedMap.make({c: 6})).should.be(true);
			});

			it("should not modify the original", {
				one.equals(OrderedMap.make({a: 4, b: 5, c: 6})).should.be(true);
			});
		});

		describe("delete", {
			var one, two;

			beforeEach({
				one = OrderedMap.make({a: 4, b: 5, c: 6});
				two = one.delete("a");
			});

			it("should remove a key", {
				two.equals(OrderedMap.make({b: 5, c: 6})).should.be(true);
			});

			it("should not modify the original", {
				one.equals(OrderedMap.make({b: 5, c: 6, a: 4})).should.be(true);
			});
		});

		describe("deleteEach", {
			var one, two;

			beforeEach({
				one = OrderedMap.make({a: 4, b: 5, c: 6});
				two = one.deleteEach(["a", "c"]);
			});

			it("should remove each key", {
				two.equals(OrderedMap.make({b: 5})).should.be(true);
			});

			it("should not modify the original", {
				one.equals(OrderedMap.make({a: 4, b: 5, c: 6})).should.be(true);
			});
		});

		describe("clear", {
			var one, two;

			beforeEach({
				one = OrderedMap.make({a: 4, b: 5, c: 6});
				two = one.clear();
			});

			it("should make the map empty", {
				two.equals(new OrderedMap()).should.be(true);
			});

			it("should not modify the original", {
				one.equals(OrderedMap.make({a: 4, b: 5, c: 6})).should.be(true);
			});
		});

		describe("merge", {
			var one, two, three, four;

			beforeEach({
				one = OrderedMap.fromMap(["a" => 10.0, "b" => 20.0, "c" => 30.0]);
				two = OrderedMap.fromMap(["b" => 40.0, "a" => 50.0, "d" => 60.0]);
				three = one.merge(two);
				four = one.merge(two, (oldVal, newVal) -> oldVal / newVal);
			});

			it("should merge keys from the other map onto this map", {
				three.equals(OrderedMap.make({
					a: 50.0,
					b: 40.0,
					c: 30.0,
					d: 60.0
				})).should.be(true);
			});

			it("should use merge function to resolve conflicts", {
				four.equals(OrderedMap.make({
					a: 0.2,
					b: 0.5,
					c: 30.0,
					d: 60.0
				})).should.be(true);
			});

			it("should not modify the original", {
				one.equals(OrderedMap.fromMap(["a" => 10.0, "b" => 20.0, "c" => 30.0])).should.be(true);
				two.equals(OrderedMap.fromMap(["b" => 40.0, "a" => 50.0, "d" => 60.0])).should.be(true);
			});
		});

		describe("mergeEach", {
			var one, two, three, four, five;

			beforeEach({
				one = OrderedMap.make({a: 10, b: 20, c: 30});
				two = OrderedMap.make({b: 40, a: 50, d: 60});
				three = OrderedMap.make({d: 80, e: 70, f: 100});
				four = one.mergeEach([two, three]);
				five = one.mergeEach([two, three], (oldVal, newVal) -> oldVal + newVal);
			});

			it("should merge keys from each map", {
				four.equals(OrderedMap.make({
					a: 50,
					b: 40,
					c: 30,
					d: 80,
					e: 70,
					f: 100
				})).should.be(true);
			});

			it("should use merge function to resolve conflicts", {
				five.equals(OrderedMap.make({
					a: 60,
					b: 60,
					c: 30,
					d: 140,
					e: 70,
					f: 100
				})).should.be(true);
			});

			it("should not modify the original", {
				one.equals(OrderedMap.make({a: 10, b: 20, c: 30})).should.be(true);
				two.equals(OrderedMap.make({b: 40, a: 50, d: 60})).should.be(true);
				three.equals(OrderedMap.make({d: 80, e: 70, f: 100})).should.be(true);
			});
		});

		describe("map", {
			var one, two;

			beforeEach({
				one = OrderedMap.make({a: 10, b: 20, c: 30});
				two = one.map((k, v) -> Std.string(v));
			});

			it("should modify each value", {
				two.equals(OrderedMap.make({a: "10", b: "20", c: "30"})).should.be(true);
			});

			it("should not modify the original", {
				one.equals(OrderedMap.make({a: 10, b: 20, c: 30})).should.be(true);
			});
		});

		describe("mapKeys", {
			var one, two;

			beforeEach({
				one = OrderedMap.make({a: 1, b: 2});
				two = one.mapKeys((k, v) -> k + "a");
			});

			it("should modify each key", {
				two.equals(OrderedMap.make({aa: 1, ba: 2})).should.be(true);
			});

			it("should not modify the original", {
				one.equals(OrderedMap.make({a: 1, b: 2})).should.be(true);
			});
		});

		describe("fold", {

			it("should accumulate the values according to foldFn", {

				OrderedMap.make({a: 4, b: 5, c: 6}).fold((a, b) -> a + b, 0).should.be(15);

			});

			it("should work normally for an empty Map", {

				new OrderedMap().fold((a, b) -> a + b, 10).should.be(10);

			});

		});

		describe("reduce", {

			it("should accumulate the values according to foldFn", {

				OrderedMap.make({a: 4, b: 5, c: 6}).reduce((a, b) -> a + b).should.be(15);

			});

			it("should throw an exception for an empty Map", {

				(() -> new OrderedMap().reduce((a, b) -> a + b)).should.throwAnything();

			});

		});

		describe("length", {
			it("should be equal to the number of key-value pairs in the map", {
				var hxMap = [4 => "foo", 5 => "bar", 6 => "baz"];
				var map = OrderedMap.fromMap(hxMap);

				map.length.should.be(3);
			});
		});

		describe("every", {

			it("should return true if the predicate is true for all values", {

				OrderedMap.make({a: 2, b: 4, c: 6}).every(x -> x % 2 == 0).should.be(true);

			});

			it("should return false if the predicate is false for any value", {

				OrderedMap.make({a: 2, b: 4, c: 7}).every(x -> x % 2 == 0).should.be(false);

			});

			it("should return true for an empty Map", {

				new OrderedMap().every(x -> x % 2 == 0).should.be(true);

			});

		});

		describe("some", {

			it("should return true if the predicate is true for any value", {

				OrderedMap.make({a: 3, b: 3, c: 4}).some(x -> x % 2 == 0).should.be(true);

			});

			it("should return false if the predicate is false for all values", {

				OrderedMap.make({a: 3, b: 5, c: 7}).some(x -> x % 2 == 0).should.be(false);

			});

			it("should return false for an empty Map", {

				new OrderedMap().some(x -> x % 2 == 0).should.be(false);

			});

		});

		describe("equals", {
			var one, two, three;

			beforeEach({
				one = OrderedMap.make({a: 10, b: 20, c: 30});
				two = OrderedMap.make({b: 40, a: 50, d: 60});
				three = OrderedMap.make({a: 10, c: 30, b: 20});
			});

			it("should test for key-value equality", {
				one.equals(two).should.be(false);
				two.equals(one).should.be(false);
				one.equals(three).should.be(true);
				three.equals(one).should.be(true);
				one.equals(one).should.be(true);
			});

			it("should behave normally for empty maps", {
				new OrderedMap().equals(new OrderedMap()).should.be(true);
				new OrderedMap().equals(one).should.be(false);
			});
		});

		describe("forEach", {
			var one;

			beforeEach({
				one = OrderedMap.make({a: 10, b: 20, c: 30});
			});

			it("should execute function for each entry", {
				var i = 0;
				one.forEach((k, v) -> ++i);
				i.should.be(3);
			});

			it("should behave normally for the empty map", {
				var i = 0;
				new OrderedMap().forEach((k, v) -> ++i);
				i.should.be(0);
			});
		});

		describe("iterator", {
			var pairs, map, iter;

			beforeEach({
				pairs = [{key: "a", value: "foo"}, {key: "b", value: "bar"}, {key: "c", value: "baz"}];
				iter = pairs.iterator();
			});

			it("should iterate in insertion order", {
				map = new OrderedMap().set("a", "foo").set("b", "bar").set("c", "baz");

				for (value in map) {
					var pair = iter.next();
					value.should.be(pair.value);
				}
			});

			it("should iterate in struct declaration order", {
				map = OrderedMap.make({a: "foo", b: "bar", c: "baz"});

				for (value in map) {
					var pair = iter.next();
					value.should.be(pair.value);
				}
			});
		});

		describe("keyValueIterator", {
			it("should iterate in struct declaration order", {
				var pairs = [{key: "a", value: "foo"}, {key: "b", value: "bar"}, {key: "c", value: "baz"}];
				var map = OrderedMap.make({a: "foo", b: "bar", c: "baz"});

				var it = pairs.iterator();

				for (key => value in map) {
					var pair = it.next();
					key.should.be(pair.key);
					value.should.be(pair.value);
				}
			});

			it("should iterate in insertion order", {
				var pairs = [{key: "a", value: "foo"}, {key: "b", value: "bar"}, {key: "c", value: "baz"}];
				var map = new OrderedMap();

				for (pair in pairs)
					map = map.set(pair.key, pair.value);

				var it = pairs.iterator();

				for (key => value in map) {
					var pair = it.next();
					key.should.be(pair.key);
					value.should.be(pair.value);
				}
			});
		});

		describe("keys", {
			var one, iter;

			beforeEach({
				one = OrderedMap.make({a: 10, b: 20, c: 30});
				iter = one.keys();
			});

			it("should iterate over each key in order", {
				for (k => v in one)
					iter.next().should.be(k);
			});
		});

		describe("values", {
			var one, iter;

			beforeEach({
				one = OrderedMap.make({a: 10, b: 20, c: 30});
				iter = one.values();
			});

			it("should iterate over each value in order", {
				for (_ => v in one)
					iter.next().should.be(v);
			});
		});

		describe("entries", {
			var one, iter;

			beforeEach({
				one = OrderedMap.make({a: 10, b: 20, c: 30});
				iter = one.entries();
			});

			it("should iterate over each value in order", {
				for (k => v in one) {
					var pair = iter.next();
					pair.key.should.be(k);
					pair.value.should.be(v);
				}
			});
		});

		describe("toArray", {
			var one, two;

			beforeEach({
				one = OrderedMap.make({a: 10, b: 20, c: 30});
				two = one.toArray();
			});

			it("should convert to equivalent array", {
				for (i in 0...two.length) {
					two[i].should.be([10, 20, 30][i]);
				}
			});

			it("should not modify the original", {
				one.equals(OrderedMap.make({a: 10, b: 20, c: 30})).should.be(true);
			});
		});

		describe("toMap", {

			it("should convert to an equivalent Map", {

				var one = OrderedMap.make({a: 10, b: 20, c: 30});
				var two = one.toMap();
				two.equals(OrderedMap.make({a: 10, b: 20, c: 30})).should.be(true);

			});

			it("should work normally for an empty map", {

				var one = new OrderedMap();
				var two = one.toMap();
				two.equals(new OrderedMap()).should.be(true);

			});

		});
		
		describe("toSet", {

			it("should convert to an equivalent Set", {

				var one = OrderedMap.make({a: 10, b: 20, c: 30});
				var set = one.toSet();

				set.has(10).should.be(true);
				set.has(20).should.be(true);
				set.has(30).should.be(true);
				set.length.should.be(3);

			});

		});

		describe("toOrderedSet", {

			it("should convert to an equivalent OrderedSet in the same order", {

				var one = OrderedMap.make({a: 10, b: 20, c: 30});
				var setIter = one.toOrderedSet().iterator();

				for (v in one)
					v.should.be(setIter.next());

			});

		});

		describe("toVector", {

			it("should convert to an equivalent Vector in the same order", {

				var one = OrderedMap.make({a: 10, b: 20, c: 30});
				var vecIter = one.toVector().iterator();

				for (v in one)
					v.should.be(vecIter.next());

			});

		});

		describe("toString", {

			it("should convert to an equivalent String representation", {

				OrderedMap.make({a: 10, b: 20, c: 30}).toString().should.be("OrderedMap { a: 10, b: 20, c: 30 }");

			});

		});

		describe("toSequence", {

			it("should convert to an equivalent Sequence in the same order", {

				var one = OrderedMap.make({a: 10, b: 20, c: 30});
				var seqIter = one.toSequence().iterator();

				for (v in one)
					v.should.be(seqIter.next());

			});

		});

	}
}
