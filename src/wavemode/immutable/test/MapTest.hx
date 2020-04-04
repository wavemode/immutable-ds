/**
 *  Copyright (c) 2020-present, Chukwudi Okechukwu
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the root directory of this source tree.
 *
 */

package wavemode.immutable.test;

import haxe.ds.Option;
import buddy.BuddySuite;

using buddy.Should;
import buddy.CompilationShould;

class MapTest extends BuddySuite {
	public function new() {

        // TODO: failure for unhashable types
        // TODO: success for hashable types
        // TODO: proper conversion testing

		describe("from", {
			it("should allow for creation of a map from an object literal", {
				var map = Map.from({a: "foo", b: "bar", c: "baz"});
				map.get("a").should.equal(Some("foo"));
				map.get("b").should.equal(Some("bar"));
				map.get("c").should.equal(Some("baz"));
			});
		});

		describe("fromMap", {
			it("should create an equivalent Map from a haxe.ds.Map", {

				var hxMap = [4 => "foo", 5 => "bar", 6 => "baz"];
				var map = Map.fromMap(hxMap);

				map.get(4).should.equal(Some("foo"));
				map.get(5).should.equal(Some("bar"));
				map.get(6).should.equal(Some("baz"));
				map.get(7).should.equal(None);

			});
		});

		describe("iterator", {

            var values, map;

            beforeEach({
                values = ["foo", "bar", "baz"];
            });

            it("should iterate in any order", {

                map = new Map().set("a", "foo").set("b", "bar").set("c", "baz");

				for (value in map) {
                    values.indexOf(value).should.not.beLessThan(0);
				}

            });

		});

		describe("keyValueIterator", {

            var values, keys, map;

            beforeEach({
                values = ["foo", "bar", "baz"];
                keys = ["a", "b", "c"];
            });

            it("should iterate in any order", {

                map = new Map().set("a", "foo").set("b", "bar").set("c", "baz");

				for (key => value in map) {
                    var index = keys.indexOf(key);
                    index.should.not.beLessThan(0);
                    var indexValue = values[index];
                    indexValue.should.be(value);
				}

            });

		});

		describe("length", {

			it("should be equal to the number of key-value pairs in the map", {

				var hxMap = [4 => "foo", 5 => "bar", 6 => "baz"];
				var map = Map.fromMap(hxMap);

				map.length.should.be(3);

			});

		});

		describe("set", {

			var one, two;

			beforeEach({

				one = Map.from({a: 5, b: 6});
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

				one.equals(Map.from({b: 6, a: 5})).should.be(true);

			});

		});

		describe("setAll", {

			var one, two;

			beforeEach({

				one = Map.from({a: 4, b: 5, c: 6});
				two = one.setAll(["c", "d"], [7, 8]);

			});

			it("should create new keys", {

				two.get("d").should.equal(Some(8));

			});

			it("should update existing keys", {

				two.get("c").should.equal(Some(7));

			});

			it("should not modify the original", {

				one.equals(Map.from({a: 4, b: 5, c: 6})).should.be(true);

			});

		});

		describe("remove", {

			var one, two;

			beforeEach({

				one = Map.from({a: 4, b: 5, c: 6});
				two = one.remove("a");

			});

			it("should remove a key", {

				two.equals(Map.from({b: 5, c: 6})).should.be(true);

			});

			it("should not modify the original", {

				one.equals(Map.from({b: 5, c: 6, a: 4})).should.be(true);

			});

		});

		describe("removeValue", {

			var one, two;

			beforeEach({

				one = Map.from({a: 4, b: 5, c: 6});
				two = one.removeValue(5);

			});

			it("should remove a value", {

				two.equals(Map.from({a: 4, c: 6})).should.be(true);

			});

			it("should not modify the original", {

				one.equals(Map.from({a: 4, b: 5, c: 6})).should.be(true);

			});

		});

		describe("removeAll", {

			var one, two;

			beforeEach({

				one = Map.from({a: 4, b: 5, c: 6});
				two = one.removeAll(["a", "c"]);

			});

			it("should remove each key", {

				two.equals(Map.from({b: 5})).should.be(true);

			});

			it("should not modify the original", {

				one.equals(Map.from({a: 4, b: 5, c: 6})).should.be(true);

			});

		});

		describe("removeAllValues", {

			var one, two;

			beforeEach({

				one = Map.from({a: 4, b: 5, c: 6});
				two = one.removeAllValues([4, 5]);

			});
			
			it("should remove each value", {

				two.equals(Map.from({c: 6})).should.be(true);

			});

			it("should not modify the original", {

				one.equals(Map.from({a: 4, b: 5, c: 6})).should.be(true);

			});

		});


		describe("clear", {

            var one, two;

            beforeEach({
                one = Map.from({a: 4, b: 5, c: 6});
                two = one.clear();
            });

            it("should make the map empty", {

                two.equals(new Map()).should.be(true);

            });

            it("should not modify the original", {

                one.equals(Map.from({a: 4, b: 5, c: 6})).should.be(true);

            });

        });

		describe("update", {

            var one, two, three;

            beforeEach({
                one = Map.from({a: 4, b: 5, c: 6});
                two = one.update("a", (x) -> x * 2);
                three = one.update("d", (x) -> x * 2);
            });

            it("should update the value of the key", {

                two.equals(Map.from({a: 8, b: 5, c: 6})).should.be(true);

            });

            it("should not modify the original", {

                one.equals(Map.from({a: 4, b: 5, c: 6})).should.be(true);

            });

            it("should do nothing if the key does not exist", {

                three.equals(one).should.be(true);

            });

        });

		describe("merge", {

            var one, two, three, four;

            beforeEach({
                
                one = Map.fromMap(["a" => 10.0, "b" => 20.0, "c" => 30.0 ]);
                two = Map.fromMap(["b" => 40.0, "a" => 50.0, "d" => 60.0 ]);
                three = one.merge(two);
                four = one.merge(two, (oldVal, newVal) -> oldVal / newVal);
            
            });

            it("should merge keys from the other map onto this map", {

                three.equals(Map.from({ a: 50.0, b: 40.0, c: 30.0, d: 60.0 })).should.be(true);

            });

            it("should use merge function to resolve conflicts", {

                four.equals(Map.from({ a: 0.2, b: 0.5, c: 30.0, d: 60.0 })).should.be(true);

            });

            it("should not modify the original", {

                one.equals(Map.fromMap(["a" => 10.0, "b" => 20.0, "c" => 30.0 ])).should.be(true);
                two.equals(Map.fromMap(["b" => 40.0, "a" => 50.0, "d" => 60.0 ])).should.be(true);

            });

        });

		describe("mergeAll", {

            var one, two, three, four, five;

            beforeEach({


                one = Map.from({a: 10, b: 20, c: 30 });
                two = Map.from({b: 40, a: 50, d: 60 });
                three = Map.from({d: 80, e: 70, f:100 });
                four = one.mergeAll([two, three]);
                five = one.mergeAll([two, three], (oldVal, newVal) -> oldVal + newVal);

            });

            it("should merge keys from each map", {

                four.equals(Map.from({ a: 50, b: 40, c: 30, d: 80, e: 70, f: 100 })).should.be(true);

            });

            it("should use merge function to resolve conflicts", {

                five.equals(Map.from({ a: 60, b: 60, c: 30, d: 140, e: 70, f: 100 })).should.be(true);

            });

            it("should not modify the original", {

                one.equals(Map.from({a: 10, b: 20, c: 30 })).should.be(true);
                two.equals(Map.from({b: 40, a: 50, d: 60 })).should.be(true);
                three.equals(Map.from({d: 80, e: 70, f:100 })).should.be(true);

            });

        });

		describe("map", {

            var one, two;
            
            beforeEach({

                one = Map.from({a: 10, b: 20, c: 30 });
                two = one.map(Std.string);

            });
            
            it("should modify each value", {

                two.equals(Map.from({a: "10", b: "20", c: "30" })).should.be(true);

            });

            it("should not modify the original", {

                one.equals(Map.from({a: 10, b: 20, c: 30 })).should.be(true);

            });

        });

		describe("mapWithKey", {

            var one, two;
            
            beforeEach({

                one = Map.from({a: 10, b: 20, c: 30 });
                two = one.mapWithKey((k, v) -> k + v);

            });
            
            it("should modify each value", {

                two.equals(Map.from({a: "a10", b: "b20", c: "c30" })).should.be(true);

            });

            it("should not modify the original", {

                one.equals(Map.from({a: 10, b: 20, c: 30 })).should.be(true);

            });

        });

        describe("mapKeys", {

            var one, two;

            beforeEach({


                one = Map.from({a: 1, b: 2 });
                two = one.mapKeys((k, v) -> k + "a");

            });

            it("should modify each key", {

                two.equals(Map.from({ aa: 1, ba: 2 })).should.be(true);

            });

            it("should not modify the original", {

                one.equals(Map.from({a: 1, b: 2 })).should.be(true);

            });

        });
        
		describe("mapEntries", {

            var one, two;

            beforeEach({

                one = Map.from({a: "g", b: "h" });
                two = one.mapEntries((k, v) -> {key: v, value: k});

            });

            it("should modify each key", {

                two.equals(Map.from({ h: "b", g: "a" })).should.be(true);

            });

            it("should not modify the original", {

                one.equals(Map.from({a: "g", b: "h" })).should.be(true);

            });

        });

        describe("filter", {

            var one, two;
            
            beforeEach({

                one = Map.from({a: 10, b: 20, c: 30 });
                two = one.filter(x -> x % 3 == 0);

            });
            
            it("should remove values not satisfying predicate", {

                two.equals( Map.from({c: 30})).should.be(true);

            });

            it("should not modify the original", {

                one.equals(Map.from({a: 10, b: 20, c: 30 })).should.be(true);

            });

        });
        

        describe("filterWithKey", {

            var one, two;
            
            beforeEach({

                one = Map.from({a: 10, b: 20, c: 30 });
                two = one.filterWithKey((k, x) -> x % 3 == 0);

            });
            
            it("should remove values not satisfying predicate", {

                two.equals(Map.from({c: 30})).should.be(true);

            });

            it("should not modify the original", {

                one.equals(Map.from({a: 10, b: 20, c: 30 })).should.be(true);

            });

        });
        

        describe("flip", {

            var one, two;

            beforeEach({

                one = Map.from({a: "g", b: "h" });
                two = one.flip();

            });

            it("should swap keys and values", {

                two.equals(Map.from({ h: "b", g: "a" })).should.be(true);

            });

            it("should not modify the original", {

                one.equals(Map.from({a: "g", b: "h" })).should.be(true);

            });

        });
        

        describe("toArray", {

            var one, two;

            beforeEach({

                one = Map.from({a: 10, b: 20, c: 30 });
                two = one.toArray();

            });

            it("should convert to array in any order", {

                for (v in one)
                    two.indexOf(v).should.not.beLessThan(0);

            });

            it("should not modify the original", {

                one.equals(Map.from({a: 10, b: 20, c: 30 })).should.be(true);

            });

        });
        

        describe("toArrayKV", {

            var one, two, keys, values;

            beforeEach({

                one = OrderedMap.from({a: 10, b: 20, c: 30 });
                two = one.toArrayKV();
                keys = ["a", "b", "c"];
                values = [10, 20, 30];

            });

            it("should convert to equivalent key-value array in any order", {

                for (pair in two) {
                    keys.indexOf(pair.key).should.not.beLessThan(0);
                    values.indexOf(pair.value).should.not.beLessThan(0);
                }

            });
            
        });
        
		describe("equals", {

            var one, two, three;

            beforeEach({


                one = Map.from({a: 10, b: 20, c: 30 });
                two = Map.from({b: 40, a: 50, d: 60 });
                three = Map.from({a: 10, c: 30, b:20 });

            });

            it("should test for key-value equality", {

                one.equals(two).should.be(false);
                two.equals(one).should.be(false);
                one.equals(three).should.be(true);
                three.equals(one).should.be(true);
                one.equals(one).should.be(true);

            });

            it("should behave normally for empty maps", {

                new Map().equals(new Map()).should.be(true);
                new Map().equals(one).should.be(false);

            });

        });

        describe("get", {

            var one;

            beforeEach({


                one = Map.from({a: 10, b: 20, c: 30 });

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

                one = Map.from({a: 10, b: 20, c: 30 });

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

                one = Map.from({a: 10, b: 20, c: 30 });

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

                one = Map.from({a: 10, b: 20, c: 30 });
                keys = ["a", "b", "c"];
                iter = keys.iterator();

            });

            it("should iterate over each key in any order", {

                for (k in one.keys())
                    keys.indexOf(k).should.not.beLessThan(0);

            });

        });

        describe("values", {

            var values, map;

            beforeEach({
                values = ["foo", "bar", "baz"];
            });

            it("should iterate in any order", {

                map = new Map().set("a", "foo").set("b", "bar").set("c", "baz");

				for (value in map.values()) {
                    values.indexOf(value).should.not.beLessThan(0);
				}

            });

        });
        
        describe("entries", {

            var values, keys, map;

            beforeEach({
                values = ["foo", "bar", "baz"];
                keys = ["a", "b", "c"];
            });

            it("should iterate in any order", {

                map = new Map().set("a", "foo").set("b", "bar").set("c", "baz");

				for (pair in map.entries()) {
                    var index = keys.indexOf(pair.key);
                    index.should.not.beLessThan(0);
                    var indexValue = values[index];
                    indexValue.should.be(pair.value);
				}

            });

        });
        

        describe("forEach", {

            var one;

            beforeEach({

                one = Map.from({a: 10, b: 20, c: 30 });

            });

            it("should execute function for each entry", {

                var i = 0;
                one.forEach((k, v) -> ++i);
                i.should.be(3);

            });

            it("should behave normally for the empty map", {

                var i = 0;
                new Map().forEach((k, v) -> ++i);
                i.should.be(0);

            });

        });
        

		describe("forWhile", {

            var one;

            beforeEach({

                one = Map.from({a: 10, b: 20, c: 30 });

            });

            it("should execute function for each entry", {

                var i = 0;
                one.forWhile((k, v) -> { ++i; true; });
                i.should.be(3);

            });

            it("should stop execution when function returns false", {

                var i = 0;
                one.forWhile((k, v) -> ++i < 2);
                i.should.be(2);

            });

            it("should behave normally for the empty map", {

                var i = 0;
                new Map().forWhile((k, v) -> ++i < 2);
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
