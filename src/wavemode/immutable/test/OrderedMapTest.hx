/**
 *  Copyright (c) 2020-present, Chukwudi Okechukwu
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the root directory of this source tree.
 *
 */

package wavemode.immutable.test;

class OrderedMapTest extends BuddySuite {
	public function new() {

        // TODO: failure for unhashable types
        // TODO: success for hashable types
        // TODO: proper conversion testing

		describe("from", {
			it("should allow for creation of a map from an object literal", {
				var map = OrderedMap.from({a: "foo", b: "bar", c: "baz"});
				map.get("a").should.equal(Some("foo"));
				map.get("b").should.equal(Some("bar"));
				map.get("c").should.equal(Some("baz"));
			});
		});

		describe("fromMap", {
			it("should create an equivalent OrderedMap from a haxe.ds.Map", {

				var hxMap = [4 => "foo", 5 => "bar", 6 => "baz"];
				var map = OrderedMap.fromMap(hxMap);

				map.get(4).should.equal(Some("foo"));
				map.get(5).should.equal(Some("bar"));
				map.get(6).should.equal(Some("baz"));
				map.get(7).should.equal(None);

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

                map = OrderedMap.from({a: "foo", b: "bar", c: "baz"});

				for (value in map) {
					var pair = iter.next();
					value.should.be(pair.value);
				}
			});

		});

		describe("keyValueIterator", {

			it("should iterate in struct declaration order", {

				var pairs = [{key: "a", value: "foo"}, {key: "b", value: "bar"}, {key: "c", value: "baz"}];
				var map = OrderedMap.from({a: "foo", b: "bar", c: "baz"});

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

				for (pair in pairs) map = map.set(pair.key, pair.value);

				var it = pairs.iterator();

				for (key => value in map) {
					var pair = it.next();
					key.should.be(pair.key);
					value.should.be(pair.value);
				}

			});

		});

		describe("length", {

			it("should be equal to the number of key-value pairs in the map", {

				var hxMap = [4 => "foo", 5 => "bar", 6 => "baz"];
				var map = OrderedMap.fromMap(hxMap);

				map.length.should.be(3);

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

		describe("set", {

			var one, two;

			beforeEach({

				one = OrderedMap.from({a: 5, b: 6});
				two = one.set("c", 7).set("d", 8).set("b", 10);

			});

			it("should add a new key", {

				two.get("c").should.equal(Some(7));
				two.get("d").should.equal(Some(8));

			});
			
			it("should update existing keys", {

				two.get("b").should.equal(Some(10));

			});

			it("should not modify the original", {

				one.equals(OrderedMap.from({b: 6, a: 5})).should.be(true);

			});

		});

		describe("setEach", {

			var one, two;

			beforeEach({

				one = OrderedMap.from({a: 4, b: 5, c: 6});
				two = one.setEach(["c", "d"], [7, 8]);

			});

			it("should create new keys", {

				two.get("d").should.equal(Some(8));

			});

			it("should update existing keys", {

				two.get("c").should.equal(Some(7));

			});

			it("should not modify the original", {

				one.equals(OrderedMap.from({a: 4, b: 5, c: 6})).should.be(true);

			});

		});

		describe("remove", {

			var one, two;

			beforeEach({

				one = OrderedMap.from({a: 4, b: 5, c: 6});
				two = one.remove("a");

			});

			it("should remove a key", {

				two.equals(OrderedMap.from({b: 5, c: 6})).should.be(true);

			});

			it("should not modify the original", {

				one.equals(OrderedMap.from({b: 5, c: 6, a: 4})).should.be(true);

			});

		});

		describe("removeValue", {

			var one, two;

			beforeEach({

				one = OrderedMap.from({a: 4, b: 5, c: 6});
				two = one.removeValue(5);

			});

			it("should remove a value", {

				two.equals(OrderedMap.from({a: 4, c: 6})).should.be(true);

			});

			it("should not modify the original", {

				one.equals(OrderedMap.from({a: 4, b: 5, c: 6})).should.be(true);

			});

		});

		describe("removeEach", {

			var one, two;

			beforeEach({

				one = OrderedMap.from({a: 4, b: 5, c: 6});
				two = one.removeEach(["a", "c"]);

			});

			it("should remove each key", {

				two.equals(OrderedMap.from({b: 5})).should.be(true);

			});

			it("should not modify the original", {

				one.equals(OrderedMap.from({a: 4, b: 5, c: 6})).should.be(true);

			});

		});

		describe("removeEachValue", {

			var one, two;

			beforeEach({

				one = OrderedMap.from({a: 4, b: 5, c: 6});
				two = one.removeEachValue([4, 5]);

			});
			
			it("should remove each value", {

				two.equals(OrderedMap.from({c: 6})).should.be(true);

			});

			it("should not modify the original", {

				one.equals(OrderedMap.from({a: 4, b: 5, c: 6})).should.be(true);

			});

		});


		describe("clear", {

            var one, two;

            beforeEach({
                one = OrderedMap.from({a: 4, b: 5, c: 6});
                two = one.clear();
            });

            it("should make the map empty", {

                two.equals(new OrderedMap()).should.be(true);

            });

            it("should not modify the original", {

                one.equals(OrderedMap.from({a: 4, b: 5, c: 6})).should.be(true);

            });

        });

		describe("update", {

            var one, two, three;

            beforeEach({
                one = OrderedMap.from({a: 4, b: 5, c: 6});
                two = one.update("a", (x) -> x * 2);
                three = one.update("d", (x) -> x * 2);
            });

            it("should update the value of the key", {

                two.equals(OrderedMap.from({a: 8, b: 5, c: 6})).should.be(true);

            });

            it("should not modify the original", {

                one.equals(OrderedMap.from({a: 4, b: 5, c: 6})).should.be(true);

            });

            it("should do nothing if the key does not exist", {

                three.equals(one).should.be(true);

            });

        });

		describe("updateEach", {

            var one, two, three;

            beforeEach({
                one = OrderedMap.from({a: 4, b: 5, c: 6});
                two = one.updateEach(["a", "b"], (x) -> x * 2);
                three = one.updateEach(["d", "e"], (x) -> x * 2);
            });

            it("should update the value of the keys", {

                two.equals(OrderedMap.from({a: 8, b: 10, c: 6})).should.be(true);

            });

            it("should not modify the original", {

                one.equals(OrderedMap.from({a: 4, b: 5, c: 6})).should.be(true);

            });

            it("should do nothing if the key does not exist", {

                three.equals(one).should.be(true);

            });

        });
        
		describe("replace", {

            var one, two, three;

            beforeEach({
                one = OrderedMap.from({a: 4, b: 5, c: 4});
                two = one.replace(4, 10);
                three = one.replace(9, 10);
            });

            it("should replace every occurrence of the given value", {

                two.equals(OrderedMap.from({a: 10, b: 5, c: 10})).should.be(true);

            });

            it("should not modify the original", {

                one.equals(OrderedMap.from({a: 4, b: 5, c: 4})).should.be(true);

            });

            it("should do nothing if the value does not exist", {

                three.equals(one).should.be(true);

            });

        });
        
		describe("replaceEach", {

            var one, two, three;

            beforeEach({
                one = OrderedMap.from({a: 4, b: 5, c: 4});
                two = one.replaceEach([4, 5], [5, 10]);
                three = one.replaceEach([9, 10], [10, 11]);
            });

            it("should replace every occurrence of the given values", {

                two.equals(OrderedMap.from({a: 5, b: 10, c: 5})).should.be(true);

            });

            it("should not modify the original", {

                one.equals(OrderedMap.from({a: 4, b: 5, c: 4})).should.be(true);

            });

            it("should do nothing if the values do not exist", {

                three.equals(one).should.be(true);

            });

        });

        describe("keyOf", {

            var one;

            beforeEach({
                one = OrderedMap.from({a: 4, b: 5, c: 4});
            });

            it("should return the key of the given value", {

                one.keyOf(4).should.equal(Some("a"));

            });

            it("should return None for nonexistent values", {

                one.keyOf(20).should.equal(None);

            });

        });

		describe("merge", {

            var one, two, three, four;

            beforeEach({
                
                one = OrderedMap.fromMap(["a" => 10.0, "b" => 20.0, "c" => 30.0 ]);
                two = OrderedMap.fromMap(["b" => 40.0, "a" => 50.0, "d" => 60.0 ]);
                three = one.merge(two);
                four = one.merge(two, (oldVal, newVal) -> oldVal / newVal);
            
            });

            it("should merge keys from the other map onto this map", {

                three.equals(OrderedMap.from({ a: 50.0, b: 40.0, c: 30.0, d: 60.0 })).should.be(true);

            });

            it("should use merge function to resolve conflicts", {

                four.equals(OrderedMap.from({ a: 0.2, b: 0.5, c: 30.0, d: 60.0 })).should.be(true);

            });

            it("should not modify the original", {

                one.equals(OrderedMap.fromMap(["a" => 10.0, "b" => 20.0, "c" => 30.0 ])).should.be(true);
                two.equals(OrderedMap.fromMap(["b" => 40.0, "a" => 50.0, "d" => 60.0 ])).should.be(true);

            });

        });

		describe("mergeEach", {

            var one, two, three, four, five;

            beforeEach({


                one = OrderedMap.from({a: 10, b: 20, c: 30 });
                two = OrderedMap.from({b: 40, a: 50, d: 60 });
                three = OrderedMap.from({d: 80, e: 70, f:100 });
                four = one.mergeEach([two, three]);
                five = one.mergeEach([two, three], (oldVal, newVal) -> oldVal + newVal);

            });

            it("should merge keys from each map", {

                four.equals(OrderedMap.from({ a: 50, b: 40, c: 30, d: 80, e: 70, f: 100 })).should.be(true);

            });

            it("should use merge function to resolve conflicts", {

                five.equals(OrderedMap.from({ a: 60, b: 60, c: 30, d: 140, e: 70, f: 100 })).should.be(true);

            });

            it("should not modify the original", {

                one.equals(OrderedMap.from({a: 10, b: 20, c: 30 })).should.be(true);
                two.equals(OrderedMap.from({b: 40, a: 50, d: 60 })).should.be(true);
                three.equals(OrderedMap.from({d: 80, e: 70, f:100 })).should.be(true);

            });

        });

		describe("map", {

            var one, two;
            
            beforeEach({

                one = OrderedMap.from({a: 10, b: 20, c: 30 });
                two = one.map(Std.string);

            });
            
            it("should modify each value", {

                two.equals(OrderedMap.from({a: "10", b: "20", c: "30" })).should.be(true);

            });

            it("should not modify the original", {

                one.equals(OrderedMap.from({a: 10, b: 20, c: 30 })).should.be(true);

            });

        });

		describe("mapWithKey", {

            var one, two;
            
            beforeEach({

                one = OrderedMap.from({a: 10, b: 20, c: 30 });
                two = one.mapWithKey((k, v) -> k + v);

            });
            
            it("should modify each value", {

                two.equals(OrderedMap.from({a: "a10", b: "b20", c: "c30" })).should.be(true);

            });

            it("should not modify the original", {

                one.equals(OrderedMap.from({a: 10, b: 20, c: 30 })).should.be(true);

            });

        });

        describe("mapKeys", {

            var one, two;

            beforeEach({


                one = OrderedMap.from({a: 1, b: 2 });
                two = one.mapKeys((k, v) -> k + "a");

            });

            it("should modify each key", {

                two.equals(OrderedMap.from({ aa: 1, ba: 2 })).should.be(true);

            });

            it("should not modify the original", {

                one.equals(OrderedMap.from({a: 1, b: 2 })).should.be(true);

            });

        });
        
		describe("mapEntries", {

            var one, two;

            beforeEach({

                one = OrderedMap.from({a: "g", b: "h" });
                two = one.mapEntries((k, v) -> {key: v, value: k});

            });

            it("should modify each key", {

                two.equals(OrderedMap.from({ h: "b", g: "a" })).should.be(true);

            });

            it("should not modify the original", {

                one.equals(OrderedMap.from({a: "g", b: "h" })).should.be(true);

            });

        });

        describe("filter", {

            var one, two;
            
            beforeEach({

                one = OrderedMap.from({a: 10, b: 20, c: 30 });
                two = one.filter(x -> x % 3 == 0);

            });
            
            it("should remove values not satisfying predicate", {

                two.equals( OrderedMap.from({c: 30})).should.be(true);

            });

            it("should not modify the original", {

                one.equals(OrderedMap.from({a: 10, b: 20, c: 30 })).should.be(true);

            });

        });
        

        describe("filterWithKey", {

            var one, two;
            
            beforeEach({

                one = OrderedMap.from({a: 10, b: 20, c: 30 });
                two = one.filterWithKey((k, x) -> x % 3 == 0);

            });
            
            it("should remove values not satisfying predicate", {

                two.equals(OrderedMap.from({c: 30})).should.be(true);

            });

            it("should not modify the original", {

                one.equals(OrderedMap.from({a: 10, b: 20, c: 30 })).should.be(true);

            });

        });
        

        describe("flip", {

            var one, two;

            beforeEach({

                one = OrderedMap.from({a: "g", b: "h" });
                two = one.flip();

            });

            it("should swap keys and values", {

                two.equals(OrderedMap.from({ h: "b", g: "a" })).should.be(true);

            });

            it("should not modify the original", {

                one.equals(OrderedMap.from({a: "g", b: "h" })).should.be(true);

            });

        });
        

        describe("toArray", {

            var one, two;

            beforeEach({

                one = OrderedMap.from({a: 10, b: 20, c: 30 });
                two = one.toArray();

            });

            it("should convert to equivalent array", {

                for (i in 0...two.length) {
                    two[i].should.be([10, 20, 30][i]);
                }

            });

            it("should not modify the original", {

                one.equals(OrderedMap.from({a: 10, b: 20, c: 30 })).should.be(true);

            });

        });
        

        describe("toArrayKV", {

            var one, two, pairs;

            beforeEach({

                one = OrderedMap.from({a: 10, b: 20, c: 30 });
                two = one.toArrayKV();
                pairs = [{key: "a", value: 10},{key: "b", value: 20},{key: "c", value: 30}];

            });

            it("should convert to equivalent key-value array", {

                for (i in 0...two.length) {
                    two[i].key.should.be(pairs[i].key);
                    two[i].value.should.be(pairs[i].value);
                }

            });

            it("should not modify the original", {

                one.equals(OrderedMap.from({a: 10, b: 20, c: 30 })).should.be(true);

            });

        });
        
		describe("equals", {

            var one, two, three;

            beforeEach({


                one = OrderedMap.from({a: 10, b: 20, c: 30 });
                two = OrderedMap.from({b: 40, a: 50, d: 60 });
                three = OrderedMap.from({a: 10, c: 30, b:20 });

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

        describe("get", {

            var one;

            beforeEach({


                one = OrderedMap.from({a: 10, b: 20, c: 30 });

            });

            it("should retrieve existing keys", {

                one.get("a").should.equal(Some(10));

            });

            it("should return None for nonexisting keys", {

                one.get("d").should.equal(None);

            });

        });
        

        describe("has", {

            var one;

            beforeEach({

                one = OrderedMap.from({a: 10, b: 20, c: 30 });

            });

            it("should return true for existing keys", {

                one.has("a").should.be(true);

            });

            it("should return false for nonexisting keys", {

                one.has("d").should.be(false);

            });
        });
        

        describe("hasValue", {

            var one;

            beforeEach({

                one = OrderedMap.from({a: 10, b: 20, c: 30 });

            });

            it("should return true for existing values", {

                one.hasValue(10).should.be(true);

            });

            it("should return false for nonexisting values", {

                one.hasValue(101).should.be(false);

            });

        });
        
		describe("keys", {

            var one, keys, iter;

            beforeEach({

                one = OrderedMap.from({a: 10, b: 20, c: 30 });
                keys = ["a", "b", "c"];
                iter = keys.iterator();

            });

            it("should iterate over each key in order", {

                for (k in one.keys())
                    iter.next().should.be(k);

            });

        });

        describe("values", {

            var one, values, iter;

            beforeEach({

                one = OrderedMap.from({a: 10, b: 20, c: 30 });
                values = [10, 20, 30];
                iter = values.iterator();

            });

            it("should iterate over each value in order", {

                for (_ => v in one)
                    iter.next().should.be(v);

            });

        });
        
        describe("entries", {

            var one, entries, iter;

            beforeEach({

                one = OrderedMap.from({a: 10, b: 20, c: 30 });
                entries = [{key: "a", value: 10},{key: "b", value: 20}, {key: "c", value: 30}];
                iter = entries.iterator();

            });

            it("should iterate over each value in order", {

                for (k => v in one) {
                    var pair = iter.next();
                    pair.key.should.be(k);
                    pair.value.should.be(v);
                }

            });

        });
        

        describe("forEach", {

            var one;

            beforeEach({

                one = OrderedMap.from({a: 10, b: 20, c: 30 });

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
        

		describe("forWhile", {

            var one;

            beforeEach({

                one = OrderedMap.from({a: 10, b: 20, c: 30 });

            });

            it("should execute function for each entry", {

                var i = 0;
                one.forWhile((k, v) -> { ++i; true; });
                i.should.be(3);

            });

            it("should stop execution when function returns false", {

                var i = 0;
                one.forWhile((k, v) -> ++i < 2).should.be(2);
                i.should.be(2);

            });

            it("should behave normally for the empty map", {

                var i = 0;
                new OrderedMap().forWhile((k, v) -> ++i < 2).should.be(0);
                i.should.be(0);

            });


        });
        
		describe("toMap", {});
		describe("toSet", {});
		describe("toOrderedSet", {});
		describe("toList", {});
		describe("toStack", {});
		describe("toSequenceKeys", {});
		describe("toSequence", {});
		describe("toSequenceKV", {});

	}
}
