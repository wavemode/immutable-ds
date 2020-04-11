/**
 *  Copyright (c) 2020-present, Chukwudi Okechukwu
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the root directory of this source tree.
 *
 */

package wavemode.immutable.test;

import buddy.BuddySuite;
using buddy.Should;

class VectorTest extends BuddySuite {
	public function new() {

		describe("new", {

			it("should create an empty vector", {

				var vec = new Vector();
				vec.equals([]).should.be(true);
				vec.length.should.be(0);

			});

			it("should create a clone of another iterable", {

				new Vector([1, 2, 3, 4]).equals([1, 2, 3, 4]).should.be(true);
				new Vector(new Vector().pushEach([1, 2, 3, 4])).equals([1, 2, 3, 4]).should.be(true);

			});

		});

		describe("fromSequence", {

			it("should contain same values as the original iterable", {

				var list = [1, 2, 3];
				Vector.fromSequence(list).equals([1, 2, 3]).should.be(true);
    
			});

			it("should behave normally for an empty input", {

				Vector.fromSequence([]).equals([]).should.be(true);
				Vector.fromSequence([]).length.should.be(0);

			});

		});

		describe("make", {

			it("should allow for variadic vector creation", {

				Vector.make(1, 2, 3).equals([1, 2, 3]).should.be(true);

			});

			it("should behave normally for an empty input", {

				Vector.make().equals([]).should.be(true);

			});

		});

			
		describe("repeat", {

			it("should create an infinite Vector of a repeating value", {

				Vector.repeat(4, 0).equals([0, 0, 0, 0]).should.be(true);

			});

			it("should behave normally with a null value", {

				Vector.repeat(4, null).equals([null, null, null, null]).should.be(true);

			});

		});

		describe("range", {

			it("should create an inclusive vecuence of numbers", {

				Vector.range(0, 10).equals([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]).should.be(true);

			});

			it("should behave normally for negative vecuences", {

				Vector.range(0, -10).equals([0, -1, -2, -3, -4, -5, -6, -7, -8, -9, -10]).should.be(true);

			});

			it("should behave normally for single values", {

				Vector.range(10, 10).equals([10]).should.be(true);

			});

		});

		describe("iterate", {

			it("should create a vector of repeated iterations", {

				Vector.iterate(100, 0, x -> x + 3).equals([for (i in 0...100) i * 3]).should.be(true);

			});

		});

		describe("step", {

			it("should create an infinite vecuence of steps", {

				Vector.step(100, 0, 2).take(100).equals([for (i in 0...100) i * 2]).should.be(true);

			});

			it("the default step value should be 1", {

				Vector.step(100, 0).take(100).equals([for (i in 0...100) i]).should.be(true);

			});

		});

		describe("join", {

			it("should concat the vecuences with a separator between", {

				Vector.join([[1, 2], [4, 6], [7, 8]], 999).equals([1, 2, 999, 4, 6, 999, 7, 8]).should.be(true);

			});

			it("should handle empty vecuences within the input vector", {

				Vector.join([[], [4, 5], [], [], [9]], 100).equals([100, 4, 5, 100, 100, 100, 9]).should.be(true);

			});

			it("should handle an empty input vecuence", {

				Vector.join([], 10).equals(new Vector()).should.be(true);

			});

		});

		describe("@:from Array", {

			it("should be equivalent to the original array", {

				var arr:Array<Int> = [1, 2, 3, 4, 5];
				var vec:Vector<Int> = arr;

				vec.equals([1, 2, 3, 4, 5]).should.be(true);

			});

		});


		describe("push", {

			it("should add the given value to the end of the vector", {

				Vector.make(1, 2, 3, 4).push(5).equals([1, 2, 3, 4, 5]).should.be(true);

			});

			it("should behave normally for an empty vector", {

				new Vector().push(4).equals([4]).should.be(true);

			});

		});

		describe("pushEach", {

			it("should add the given values to the end of the vector", {

				Vector.make(1, 2, 3, 4).pushEach([5, 6, 7, 8]).equals([1, 2, 3, 4, 5, 6, 7, 8]).should.be(true);

			});

			it("should behave normally for an empty vector", {

				new Vector().pushEach([4, 5, 6]).equals([4, 5, 6]).should.be(true);

			});

		});

		describe("pop", {

			it("should remove one value from the end of the Vector", {

				Vector.make(1, 2, 3).pop().equals([1, 2]).should.be(true);

			});

			it("should do nothing for an empty Vector", {

				new Vector().pop().equals(new Vector()).should.be(true);

			});

		});

		describe("unshift", {

			it("should prepend a value to the front of the Vector", {

				Vector.make(1, 2, 3, 4).unshift(5).equals([5, 1, 2, 3, 4]).should.be(true);

			});

			it("should work normally for an empty Vector", {

				new Vector().unshift(5).equals([5]).should.be(true);

			});

		});

		describe("shift", {

			it("should remove the first value of the Vector", {

				Vector.make(1, 2, 3, 4).shift().equals([2, 3, 4]).should.be(true);

			});

			it("should do nothing for an empty Vector", {

				new Vector().shift().equals(new Vector()).should.be(true);

			});

		});

		describe("insert", {

			it("should insert the given value at the given index", {

				Vector.make(1, 2, 3, 4).insert(2, 99).equals([1, 2, 99, 3, 4]).should.be(true);

			});

			it("should grow the vector if and only if index <= count()", {

				Vector.make(1, 2, 3, 4).insert(4, 5).equals([1, 2, 3, 4, 5]).should.be(true);
				Vector.make(1, 2, 3, 4).insert(5, 5).equals([1, 2, 3, 4]).should.be(true);
				Vector.make(1, 2, 3, 4).insert(-1, 5).equals([1, 2, 3, 4]).should.be(true);

			});

			it("should behave normally for an empty vector", {

				new Vector().insert(0, 10).equals([10]).should.be(true);

			});

			it("optimization: should return the same identical vector if the index is out of bounds", {

				// here we are testing for identity (memory address), not equality

				var vec = Vector.make(1, 2, 3, 4);

				(vec.insert(0, 10) == vec).should.be(false);
				(vec.insert(30, 10) == vec).should.be(true);
				(vec.insert(-30, 10) == vec).should.be(true);

			});

		});

		describe("insertEach", {

			it("should insert the given values at the given index", {

				Vector.make(1, 2, 3, 4).insertEach(2, [99, 99, 99]).equals([1, 2, 99, 99, 99, 3, 4]).should.be(true);

			});

			it("should grow the Vector if and only if index <= count()", {

				Vector.make(1, 2, 3, 4).insertEach(4, [5, 6]).equals([1, 2, 3, 4, 5, 6]).should.be(true);
				Vector.make(1, 2, 3, 4).insertEach(5, [5, 6]).equals([1, 2, 3, 4]).should.be(true);
				Vector.make(1, 2, 3, 4).insertEach(-1, [5, 6]).equals([1, 2, 3, 4]).should.be(true);

			});

			it("should behave normally for an empty Vector", {

				new Vector().insertEach(0, [10, 11, 12]).equals([10, 11, 12]).should.be(true);

			});

			it("optimization: should return the same identical Vector if the index is out of bounds", {


				var vec = Vector.make(1, 2, 3, 4);

				// here we are testing for identity (memory address), not equality
				(vec.insertEach(0, [10]) == vec).should.be(false);
				(vec.insertEach(30, [10]) == vec).should.be(true);
				(vec.insertEach(-30, [10]) == vec).should.be(true);

			});

		});

		describe("set", {

			it("should set the given index to the given value", {

				Vector.make(1, 2, 3, 4).set(0, 99).equals([99, 2, 3, 4]).should.be(true);

			});

			it("should work normally for an empty Vector", {

				new Vector().set(0, 99).equals([]).should.be(true);

			});

			it("optimization: should return the same identical Vector if the index is out of bounds", {


				var vec = Vector.make(1, 2, 3, 4);

				// here we are testing for identity (memory address), not equality
				(vec.set(0, 30) == vec).should.be(false);
				(vec.set(30, 30) == vec).should.be(true);
				(vec.set(-30, 30) == vec).should.be(true);

			});

		});

		describe("setEach", {

			it("should set the given indices to the given value", {

				Vector.make(1, 2, 3, 4).setEach([0, 1], [99, 99]).equals([99, 99, 3, 4]).should.be(true);

			});

			it("should work normally for an empty vector", {

				new Vector().setEach([0, 1], [99, 99]).equals([]).should.be(true);

			});

		});

		describe("update", {

			it("should pass the value at the given index through the updater function", {

				Vector.make(1, 2, 3, 4).update(0, x -> x + 10).equals([11, 2, 3, 4]).should.be(true);

			});

			it("should work normally for an empty vector", {

				new Vector().update(0, x -> x + 10).equals([]).should.be(true);

			});

			it("optimization: should return the same identical vector if the index is out of bounds", {


				var vec = Vector.make(1, 2, 3, 4);

				// here we are testing for identity (memory address), not equality
				(vec.update(0, x -> x + 10) == vec).should.be(false);
				(vec.update(30, x -> x + 10) == vec).should.be(true);
				(vec.update(-30, x -> x + 10) == vec).should.be(true);

			});


		});

		describe("updateEach", {

			it("should pass the given indices through the updater function", {

				Vector.make(1, 2, 3, 4).updateEach([0, 1], x -> x + 10).equals([11, 12, 3, 4]).should.be(true);

			});

			it("should work normally for an empty Vector", {

				new Vector().updateEach([0, 1], x -> x + 10).equals([]).should.be(true);

			});

		});

		describe("replace", {

			it("should replace all instances of the given value", {

				Vector.make(1, 2, 3, 1).replace(1, 10).equals([10, 2, 3, 10]).should.be(true);

			});

			it("should do nothing if the value does not exist", {

				var vec = Vector.make(1, 2, 3, 4);
				vec.replace(9, 10).equals(vec).should.be(true);

			});

			it("should work normally for an empty Vector", {

				new Vector().replace(1, 10).equals([]).should.be(true);

			});

		});

		describe("replaceEach", {

			it("should replace all instances of all given values", {

				Vector.make(1, 2, 3, 1).replaceEach([1, 2], [10, 11]).equals([10, 11, 3, 10]).should.be(true);

			});

			it("should do nothing if the values do not exist", {

				var vec = Vector.make(1, 2, 3, 4);
				vec.replaceEach([11, 12], [10, 11]).equals(vec).should.be(true);

			});

			it("should work normally for an empty Vector", {

				new Vector().replaceEach([1, 2], [10, 11]).equals([]).should.be(true);

			});

		});

		describe("get", {

			it("should return the value at the given index", {

				Vector.make(1, 2, 3, 4).get(3).should.be(4);

			});

			it("should return null for out-of-bounds access", {

				Vector.make(1, 2, 3, 4).get(4).should.be(null);

			});

		});

		describe("[index] / getValue", {

			it("should be indexable with array access", {

				Vector.make(1, 2, 3, 4)[3].should.be(4);

			});

			it("should throw an exception for out-of-bounds access", {

				(() -> Vector.make(1, 2, 3, 4)[4]).should.throwAnything();

			});

		});

		describe("has", {

			it("should return true if the index exists", {

				Vector.make(1, 2, 3, 4).has(3).should.be(true);

			});

			it("should return false if the index is out of bounds", {

				var vec = Vector.make(1, 2, 3, 4);
                
				vec.has(-1).should.be(false);
				vec.has(4).should.be(false);

			});

		});


		describe("empty", {

			it("should be true when a Vector is empty", {

				new Vector().empty().should.be(true);
				Vector.fromArray([]).empty().should.be(true);

			});

			it("should be true when a Vector is not empty", {

				new Vector().push(1).empty().should.be(false);

			});

		});



		describe("find / indexOf", {

			it("should return the first index of the given value", {

				Vector.make(1, 2, 2, 3).find(2).should.be(1);
				Vector.make(1, 2, 2, 3).indexOf(2).should.be(1);

			});

			it("should return -1 if the value does not exist", {

				Vector.make(1, 2, 2, 3).find(12).should.be(-1);
				Vector.make(1, 2, 2, 3).indexOf(12).should.be(-1);

			});

			it("should begin searching from the given start index", {

				Vector.make(1, 2, 2, 3).find(2, 2).should.be(2);
				Vector.make(1, 2, 2, 3).indexOf(2, 2).should.be(2);

				Vector.make(1, 2, 2, 3).find(2, 3).should.be(-1);
				Vector.make(1, 2, 2, 3).indexOf(2, 3).should.be(-1);

			});

			it("should work normally for an empty vector", {

				new Vector().find(4).should.be(-1);
				new Vector().indexOf(4).should.be(-1);

			});

			it("should work normally if the start index is out of bounds", {

				Vector.make(1, 2, 2, 3).find(2, 30).should.be(-1);
				Vector.make(1, 2, 2, 3).indexOf(2, 30).should.be(-1);

			});

		});

		describe("findWhere", {

			it("should return the first index at which the predicate returns true", {

				Vector.make(1, 2, 2, 3).findWhere(x -> x % 2 == 0).should.be(1);

			});

			it("should return -1 if the predicate never returns true", {

				Vector.make(1, 2, 2, 3).findWhere(x -> x > 12).should.be(-1);

			});

			it("should begin searching from the given start index", {

				Vector.make(1, 2, 2, 3).findWhere(x -> x % 2 == 0, 2).should.be(2);

				Vector.make(1, 2, 2, 3).findWhere(x -> x % 2 == 0, 3).should.be(-1);

			});

			it("should work normally for an empty vector", {

				new Vector().findWhere(x -> x % 2 == 0).should.be(-1);

			});

			it("should work normally if the start index is out of bounds", {

				Vector.make(1, 2, 2, 3).findWhere(x -> x % 2 == 0, 30).should.be(-1);

			});

            
		});

		describe("first", {

			it("should return the first value in the Vector", {

				Vector.make(1, 2, 3, 4).first().should.be(1);

			});

			it("should return null if the Vector is empty", {

				(new Vector().first() == null).should.be(true);

			});

		});

		describe("last", {

			it("should return the last value in the Vector", {

				Vector.make(1, 2, 3, 4).last().should.be(4);

			});

			it("should return null if the Vector is empty", {

				(new Vector().last() == null).should.be(true);

			});

		});


		describe("filter", {

			it("should remove values for which the predicate is false", {

				Vector.make(1, 2, 3, 4, 5).filter(x -> x % 2 == 0).equals([2, 4]).should.be(true);

			});

			it("should work normally for an empty Vector", {

				new Vector().filter(x -> x % 2 == 0).equals([]).should.be(true);

			});

		});

		describe("remove", {

			it("should remove values which equal the given value", {

				Vector.make(1, 4, 3, 4, 5).remove(4).equals([1, 3, 5]).should.be(true);

			});

			it("should work normally for null values", {

				Vector.fromArray(([1, null, 3, null, 5] : Array<Null<Int>>)).remove(null).equals([1, 3, 5]).should.be(true);

			});

			it("should work normally for an empty Vector", {

				new Vector().remove(null).equals([]).should.be(true);

			});

		});

		describe("removeEach", {

			it("should remove values which equal any of the given values", {

				Vector.make(1, 4, 3, 4, 5).removeEach([4, 1]).equals([3, 5]).should.be(true);

			});

			it("should work normally for null values", {

				Vector.fromArray(([1, null, 3, null, 5] : Array<Null<Int>>)).removeEach(([null, 1] : Array<Null<Int>>)).equals([3, 5]).should.be(true);

			});

			it("should work normally for an empty Vector", {

				new Vector().removeEach(([null, 1] : Array<Null<Int>>)).equals([]).should.be(true);

			});

		});

		describe("delete", {

			it("should remove the value at the given index", {

				Vector.make(1, 4, 3, 5).delete(1).equals([1, 3, 5]).should.be(true);

			});

			it("should work normally for null values", {

				Vector.fromArray(([1, null, 3, 5] : Array<Null<Int>>)).delete(1).equals([1, 3, 5]).should.be(true);

			});

			it("should work normally for an empty Vector", {

				new Vector().delete(0).equals([]).should.be(true);

			});

			it("optimization: should return the same identical Vector if the index is out of bounds", {


				var vec = Vector.make(1, 2, 3, 4);

				// here we are testing for identity (memory address), not equality
				(vec.delete(0) == vec).should.be(false);
				(vec.delete(30) == vec).should.be(true);
				(vec.delete(-30) == vec).should.be(true);

			});

		});

		describe("deleteEach", {

			it("should delete indices which equal any of the given indices", {

				Vector.make(1, 4, 3, 4, 5).deleteEach([1, 3]).equals([1, 3, 5]).should.be(true);

			});

			it("should work normally for null values", {

				Vector.fromArray(([1, null, 3, null, 5] : Array<Null<Int>>)).deleteEach([1, 3]).equals([1, 3, 5]).should.be(true);

			});

			it("should work normally for an empty Vector", {

				new Vector().deleteEach([1, 3]).equals([]).should.be(true);

			});

		});

		describe("clear", {

			it("should result in an empty Vector", {

				Vector.make(1, 2, 3).clear().equals([]).should.be(true);

			});

		});

		describe("reverse", {

			it("should result in a reversed Vector", {

				Vector.make(1, 2, 3, 4).reverse().equals([4, 3, 2, 1]).should.be(true);

			});

		});

		describe("sort", {

			it("should result in a sorted Vector", {

				Vector.make(1, 3, 6, 2, 7).sort((a, b) -> a - b).equals([1, 2, 3, 6, 7]).should.be(true);

			});

		});

		describe("sortAsc", {

			it("should sort an integer Vector in ascending order", {

				Vector.make(1, 3, 6, 2, 7).sortAsc().equals([1, 2, 3, 6, 7]).should.be(true);
            
			});

			it("should work for Floats as well", {

				var seq = Vector.make(1.0, 3.0, 6.0, 2.0, 7.0);
				seq.sortAsc().equals([1.0, 2.0, 3.0, 6.0, 7.0]).should.be(true);
            
			});

		});

		describe("sortDesc", {

			it("should sort an integer Vector in ascending order", {

				Vector.make(1, 3, 6, 2, 7).sortDesc().equals([7, 6, 3, 2, 1]).should.be(true);
            
			});

			it("should work for Floats as well", {

				Vector.make(1.0, 3.0, 6.0, 2.0, 7.0).sortDesc().equals([7.0, 6.0, 3.0, 2.0, 1.0]).should.be(true);
            
			});

		});

		describe("concat", {

			it("should add the given values to the end of the Vector", {

				Vector.make(1, 2, 3, 4).concat([5, 6, 7, 8]).equals([1, 2, 3, 4, 5, 6, 7, 8]).should.be(true);

			});

			it("should behave normally for an empty Vector", {

				new Vector().concat([4, 5, 6]).equals([4, 5, 6]).should.be(true);

			});

		});
        
		describe("concatEach", {

			it("should add the given sequences to the end of the Vector", {

				Vector.make(1, 2, 3, 4).concatEach([[5, 6], [7, 8]]).equals([1, 2, 3, 4, 5, 6, 7, 8]).should.be(true);

			});

			it("should correctly skip empty sequences", {

				Vector.make(1, 2, 3, 4).concatEach([[], [5, 6], [], [], [7, 8], []]).equals([1, 2, 3, 4, 5, 6, 7, 8]).should.be(true);

			});

			it("should behave normally for an empty Vector", {

				new Vector().concat([4, 5, 6]).equals([4, 5, 6]).should.be(true);

			});  

		});


		describe("separate", {

			it("should interpose the separator between each element", {
               
				Vector.make(1, 2, 3, 4).separate(0).equals([1, 0, 2, 0, 3, 0, 4]).should.be(true);

			});

			it("should do nothing for a Vector with 1 element", {

				Vector.make(1).separate(0).equals([1]).should.be(true);

			});

			it("should do nothing for a Vector with 0 elements", {

				new Vector().separate(0).equals([]).should.be(true);

			});

		});

		describe("interleave", {

			it("should interweave the elements of the other Vector between this one", {

				Vector.make(1, 2, 3, 4).interleave([9, 8, 7, 6]).equals([1, 9, 2, 8, 3, 7, 4, 6]).should.be(true);

			});

			it("should handle mismatched lengths", {

				Vector.make(1, 2, 3, 4).interleave([9, 8]).equals([1, 9, 2, 8, 3, 4]).should.be(true);
				Vector.make(1, 2).interleave([9, 8, 7, 6]).equals([1, 9, 2, 8, 7, 6]).should.be(true);

			});

			it("should handle empty sequences", {

				Vector.make(1, 2, 3, 4).interleave(new Vector()).equals([1, 2, 3, 4]).should.be(true);
				new Vector().interleave([9, 8, 7, 6]).equals([9, 8, 7, 6]).should.be(true);

			});

		});

		describe("split", {

			it("should split the Vector into subvectors divided by the given element", {

				var vec = Vector.make(1, 2, 3, 4, 5, 4, 6, 7).split(4);
				vec.toString().should.be("Vector [ Vector [ 1, 2, 3 ], Vector [ 5 ], Vector [ 6, 7 ] ]");

			});

			it("should handle empty regions", {

				var vec = Vector.make(4, 3, 4, 4, 6, 7, 4).split(4);
				vec.toString().should.be("Vector [ Vector [ ], Vector [ 3 ], Vector [ ], Vector [ 6, 7 ], Vector [ ] ]");

			});

		});

		describe("splitWhere", {

			it("should split the vector into subvectors divided where the predicate is true", {

				var vec = Vector.make(1, 1, 3, 4, 5, 2, 7, 7).splitWhere(x -> x % 2 == 0);
				vec.toString().should.be("Vector [ Vector [ 1, 1, 3 ], Vector [ 5 ], Vector [ 7, 7 ] ]");

			});

			it("should handle empty regions", {

				var vec = Vector.make(2, 3, 4, 8, 7, 7, 4).splitWhere(x -> x % 2 == 0);
				vec.toString().should.be("Vector [ Vector [ ], Vector [ 3 ], Vector [ ], Vector [ 7, 7 ], Vector [ ] ]");

			});

		});

		describe("partition", {

			it("should divide the sequence along the given indices", {

				Vector.make(1, 2, 3, 4, 5, 6).partition([4, 2]).equals([[1, 2], [3, 4], [5, 6]], true).should.be(true);

			});

			it("should handle empty partitions", {

				Vector.make(1, 2, 3, 4, 5).partition([7, 5, 0, 1, 1]).equals([[], [1], [], [2, 3, 4, 5], []], true).should.be(true);

			});

			it("should handle extra indices", {

				Vector.make(1, 2, 3, 4).partition([2, 9, 10, 11, 12]).equals([[1, 2], [3, 4]], true).should.be(true);

			});

			it("should handle zero indices", {

				Vector.make(1, 2, 3, 4).partition([]).equals([[1, 2, 3, 4]], true).should.be(true);

			});

			it("should handle empty input", {

				new Vector().partition([1, 2, 3]).equals([[]], true).should.be(true);

			});

		});


		describe("slice", {

			it("should return values from pos to end", {

				Vector.make(1, 2, 3, 4).slice(2).equals([3, 4]).should.be(true);

			});

			it ("should return values from pos up to but not including end", {

				Vector.make(1, 2, 3, 4).slice(1, 3).equals([2, 3]).should.be(true);

			});

			it("should calculate from the end if pos is negative", {

				Vector.make(1, 2, 3).slice(-2).equals([2, 3]).should.be(true);

			});

			it("should calculate from the end if end is negative", {

				Vector.make(1, 2, 3).slice(-2, -1).equals([2]).should.be(true);

			});

		});

		describe("splice", {

			it("should return values from pos to end", {

				Vector.make(1, 2, 3, 4).splice(2).equals([3, 4]).should.be(true);

			});

			it ("should return len values starting from pos", {

				Vector.make(1, 2, 3, 4).splice(1, 3).equals([2, 3, 4]).should.be(true);

			});

			it("should calculate from the end if pos is negative", {

				Vector.make(1, 2, 3, 4).splice(-3, 2).equals([2, 3]).should.be(true);

			});

		});

        
		describe("take", {

			it("should take the first num values of the Vector", {

				Vector.make(1, 2, 3, 4).take(2).equals([1, 2]).should.be(true);

			});

			it("should take as many values as it can", {

				Vector.make(1, 2, 3, 4, 5).take(10).equals([1, 2, 3, 4, 5]).should.be(true);

			});

			it("should work normally for an empty Vector", {

				new Vector().take(10).equals([]).should.be(true);

			});

		});

		describe("takeLast", {

			it("should take the last num values of the Vector", {

				Vector.make(1, 2, 3, 4).takeLast(2).equals([3, 4]).should.be(true);

			});

			it("should take as many values as it can", {

				Vector.make(1, 2, 3, 4, 5).takeLast(10).equals([1, 2, 3, 4, 5]).should.be(true);

			});

			it("should work normally for an empty Vector", {

				new Vector().takeLast(10).equals([]).should.be(true);

			});

		});

		describe("takeWhile", {

			it("should take values until the predicate returns false", {

				Vector.make(1, 2, 3, 4, 5).takeWhile(i -> i < 3).equals([1, 2]).should.be(true);

			});

			it("should return the whole Vector if the predicate never returns false", {

				Vector.make(1, 2, 3, 4, 5).takeWhile(i -> i > 0).equals([1, 2, 3, 4, 5]).should.be(true);

			});

			it("should work normally for an empty Vector", {

				new Vector().takeWhile(i -> i > 0).equals([]).should.be(true);

			});

		});

		describe("takeUntil", {
            
			it("should take values until the predicate returns true", {

				Vector.make(1, 2, 3, 4, 5).takeUntil(i -> i >= 3).equals([1, 2]).should.be(true);

			});

			it("should return the whole Vector if the predicate never returns true", {

				Vector.make(1, 2, 3, 4, 5).takeUntil(i -> i < 0).equals([1, 2, 3, 4, 5]).should.be(true);

			});

			it("should work normally for an empty Vector", {

				new Vector().takeUntil(i -> i < 0).equals([]).should.be(true);

			});

		});

		describe("drop", {

			it("should remove the first num values of the Vector", {

				Vector.make(1, 2, 3, 4).drop(2).equals([3, 4]).should.be(true);

			});

			it("should drop as many values as it can", {

				Vector.make(1, 2, 3, 4, 5).drop(10).equals([]).should.be(true);

			});

			it("should work normally for an empty Vector", {

				new Vector().drop(10).equals([]).should.be(true);

			});

		});

		describe("dropLast", {

			it("should remove the last num values of the Vector", {

			Vector.make(1, 2, 3, 4).dropLast(2).equals([1, 2]).should.be(true);

			});

			it("should drop as many values as it can", {

				Vector.make(1, 2, 3, 4, 5).dropLast(10).equals([]).should.be(true);

			});

			it("should work normally for an empty Vector", {

				new Vector().dropLast(10).equals([]).should.be(true);

			});

		});

		describe("dropWhile", {

			it("should drop values until the predicate returns false", {

				Vector.make(1, 2, 3, 4, 5).dropWhile(i -> i < 3).equals([3, 4, 5]).should.be(true);

			});

			it("should drop the whole Vector if the predicate never returns false", {

				Vector.make(1, 2, 3, 4, 5).dropWhile(i -> i > 0).equals([]).should.be(true);

			});

			it("should work normally for an empty Vector", {

				new Vector().dropWhile(i -> i > 0).equals([]).should.be(true);

			});


		});

		describe("dropUntil", {
            
			it("should drop values until the predicate returns true", {

				Vector.make(1, 2, 3, 4, 5).dropUntil(i -> i >= 3).equals([3, 4, 5]).should.be(true);

			});

			it("should drop the whole Vector if the predicate never returns true", {

				Vector.make(1, 2, 3, 4, 5).dropUntil(i -> i < 0).equals([]).should.be(true);

			});

			it("should work normally for an empty Vector", {

				new Vector().dropUntil(i -> i < 0).equals([]).should.be(true);

			});

		});


		describe("map", {

			it("should pass each value through the mapper function", {

				Vector.make(1, 2, 3, 4).map(x -> x * 2).equals([2, 4, 6, 8]).should.be(true);

			});

			it("should work normally for an empty Vector", {

				new Vector().map(x -> x * 2).equals([]).should.be(true);

			});

		});

		describe("mapIndex", {

			it("should pass each index and value through the mapper function", {

				Vector.make(1, 2, 3, 4).mapIndex((k, v) -> k * 2).equals([0, 2, 4, 6]).should.be(true);

			});

			it("should work normally for an empty Vector", {

				new Vector().mapIndex((k, v) -> k * 2).equals([]).should.be(true);

			});


		});

		describe("flatMap", {

			it("should properly flatten its results", {

				Vector.make(1, 2, 3, 4).flatMap(x -> [x, x*2]).equals([1, 2, 2, 4, 3, 6, 4, 8]).should.be(true);

			});

		});


		describe("group", {

			it("should categorize each value", {

				var vec = Vector.make(1, 2, 3, 4, 5, 6, 7).group(x -> x % 2);
				vec[0].equals([1, 3, 5, 7]).should.be(true);
				vec[1].equals([2, 4, 6]).should.be(true);

			});

		});


		describe("zip", {

			it("should zip the other sequence into this vector", {

				var vec = Vector.make(1, 1, 1, 1).zip([9, 9, 9, 9]);
				for (v in vec)
					v.equals([1, 9]).should.be(true);

			});

			it("should handle mismatched lengths", {

				var vec = Vector.make(1, 1).zip([9, 9, 9, 9]);
				vec.length.should.be(2);
				for (v in vec)
					v.equals([1, 9]).should.be(true);

			});

			it("should work normally for an empty vector", {

				var vec = Vector.make(1, 1, 1, 1).zip([]);
				vec.equals([]).should.be(true);

			});

		});

		describe("zipEach", {

			it("should zip each of the other sequences into this vector", {

				var vec = Vector.make(1, 1, 1, 1).zipEach([[9, 9, 9, 9], [10, 10, 10, 10]]);
				for (v in vec)
					v.equals([1, 9, 10]).should.be(true);

			});

			it("should handle mismatched lengths", {

				var vec = Vector.make(1, 1).zipEach([[9, 9], [10, 10, 10]]);
				vec.length.should.be(2);
				for (v in vec)
					v.equals([1, 9, 10]).should.be(true);

			});

			it("should work normally for an empty vector", {

				var vec = Vector.make(1, 1, 1, 1).zipEach([[9, 9], []]);
				vec.equals([]).should.be(true);

			});

		});

		describe("fold", {

			it("should accumulate values according to the foldFn function", {

				Vector.make(1, 2, 3, 4).fold((a, b) -> a - b, 0).should.be(-10);

			});

			it("should return initialValue if the vector is empty, without executing foldFn", {

				new Vector().fold((_, _) -> throw "never", 10).should.be(10);

			});

		});

		describe("foldRight", {

			it("should accumulate values according to the foldFn function, in reverse order", {

				Vector.make(1, 2, 3, 4).foldRight((a, b) -> a - b, 0).should.be(-10);

			});

			it("should return initialValue if the vector is empty, without executing foldFn", {

				new Vector().foldRight((_, _) -> throw "never", 10).should.be(10);

			});

		});


		describe("reduce", {

			it("should accumulate values according to the reducer function", {

				Vector.make(1, 2, 3, 4).reduce((a, b) -> a - b).should.be(-8);

			});

			it("should return the sole value if the Vector has only one, without executing reducer", {

				Vector.make(10).reduce((_, _) -> throw "never").should.be(10);

			});

			it("should throw an exception if used on an empty Vector", {

				(() -> new Vector().reduce((a, b) -> a - b)).should.throwAnything();

			});


		});

		describe("reduceRight", {

			it("should accumulate values according to the reducer function, in reverse order", {

				Vector.make(1, 2, 3, 4).reduceRight((a, b) -> a - b).should.be(-2);

			});

			it("should return the sole value if the Vector has only one, without executing reducer", {

				Vector.make(10).reduceRight((_, _) -> throw "never").should.be(10);

			});

			it("should throw an exception if used on an empty Vector", {

				(() -> new Vector().reduceRight((a, b) -> a - b)).should.throwAnything();

			});

		});

		describe("length", {

			it("should return the number of elements in the Vector", {

				Vector.make(1, 2, 3, 4).length.should.be(4);

			});

			it("should work normally for an empty Vector", {

				new Vector().length.should.be(0);

			});

		});

		describe("every", {

			it("should return true if every value satisfies the predicate", {

				Vector.make(1, 2, 3, 4).every(x -> x < 5).should.be(true);

			});

			it("should return false if any value does not satisfy the predicate, and stop execution early", {

				// (null < 5) should never be executed, so our program should not crash
				Vector.fromArray(([1, 2, 6, 4, null] : Array<Null<Int>>)).every(x -> x < 5).should.be(false);

			});

			it("should return true for the empty Vector without executing the predicate", {

				new Vector().every(_ -> throw "never").should.be(true);

			});

		});

		describe("some", {

			it("should return true if any value satisfies the predicate, and stop execution early", {

				// (null < 5) should never be executed, so our program should not crash
				Vector.fromArray(([1, null, null, null] : Array<Null<Int>>)).some(x -> x < 5).should.be(true);

			});

			it("should return false if every value fails to satisfy the predicate", {

				Vector.make(7, 8, 9, 10).some(x -> x < 5).should.be(false);

			});

			it("should return false for the empty Vector without executing the predicate", {

				new Vector().some(_ -> throw "never").should.be(false);

			});


		});

		describe("equals", {

			it("should return true if the other Vector is identical", {

				Vector.make(1, 2, 3).equals(Vector.make(1, 2, 3)).should.be(true);

			});

			it("should return false if there is any difference", {

				Vector.make(1, 2, 3).equals(Vector.make(1, 2, 3, 4)).should.be(false);
				Vector.make(1, 2, 3).equals(Vector.make(1, 2)).should.be(false);
				Vector.fromArray(([1, 2, 3] : Array<Null<Int>>)).equals(Vector.make(null)).should.be(false);

			});

			it("should behave normally for the empty Vector", {

				new Vector().equals(new Vector()).should.be(true);
				new Vector().equals(Vector.make(1)).should.be(false);
				Vector.make(1).equals(new Vector()).should.be(false);

			});

			it("should compare nested subvectors only if the 'deep' flag is true", {

				var vec1 = Vector.make(Vector.make(1, 2), Vector.make(3, 4));
				var vec2 = Vector.make(Vector.make(1, 2), Vector.make(3, 4));

				vec1.equals(vec2).should.be(false);
				vec1.equals(vec2, true).should.be(true);

			});

		});

		describe("max", {

			it("should return the numerical maximum of the Vector", {

				Vector.make(1, 2, 3, 4).max().should.be(4);

			});

			it("should work normally for floats", {

				Vector.make(1.0, 2.0, 3.0, 4.0).max().should.be(4.0);

			});

			it("should throw an exception if the Vector is empty", {

				(() -> new Vector().max()).should.throwAnything();

			});

		});

		describe("min", {

			it("should return the numerical minimum of the Vector", {

				Vector.make(1, 2, 3, 4).min().should.be(1);

			});

			it("should work normally for floats", {

				Vector.make(1.0, 2.0, 3.0, 4.0).min().should.be(1.0);

			});

			it("should throw an exception if the Vector is empty", {

				(() -> new Vector().min()).should.throwAnything();

			});

		});

		describe("sum", {

			it("should return the sum of each value in the Vector", {

				Vector.make(1, 2, 3, 4).sum().should.be(10);

			});


			it("should work normally for floats", {

				Vector.make(1.0, 2.0, 3.0, 4.0).sum().should.be(10.0);

			});

			it("should work normally for strings", {

				Vector.make("1", "2", "3", "4").sum().should.be("1234");

			});

		});

		describe("product", {

			it("should return the product of each value in the Vector", {

				Vector.make(1, 2, 3, 4).product().should.be(24);

			});

			it("should work normally for floats", {

				Vector.make(1.0, 2.0, 3.0, 4.0).product().should.be(24.0);

			});

		});

		describe("forEach", {

			it("should execute the side effect for every value in the Vector", {

				var i = 0;
				Vector.make(1, 2, 3, 4).forEach(x -> i += x);
				i.should.be(10);

			});

			it("should work normally for an empty Vector", {

				var i = 0;
				Vector.make().forEach(x -> i += x);
				i.should.be(0);

			});

		});

		describe("forWhile", {

			it("should execute the side effect for every value in the Vector", {

				var i = 0;
				var c = Vector.make(1, 2, 3, 4).forWhile(x -> { i += x; true; });
				i.should.be(10);
				c.should.be(4);

			});

			it("should stop execution after the side effect returns false", {

				var i = 0;
				var c = Vector.make(1, 2, 3, 4).forWhile(x -> { i += x; i < 3; });
				i.should.be(3);
				c.should.be(2);

			});

			it("should work normally for an empty Vector", {

				var i = 0;
				var c = Vector.make().forWhile(x -> { i += x; i < 3; });
				i.should.be(0);
				c.should.be(0);

			});

		});


		describe("iterator", {

			it("should iterate over each value in the Vector", {

				var i = 0;
				for (v in Vector.make(1, 2, 3, 4))
					i += v;
				i.should.be(10);

			});


			it("should work normally for an empty Vector", {

				var i = 0;
				for (v in new Vector())
					i += v;
				i.should.be(0);

			});

		});

		describe("keyValueIterator", {

			it("should iterate over each index and value in the Vector", {

				var i = 0;
				for (k => v in Vector.make(1, 2, 3, 4))
					i += k + v;
				i.should.be(16);

			});

			it("should work normally for an empty Vector", {

				var i = 0;
				for (k => v in new Vector())
					i += k + v;
				i.should.be(0);

			});

		});

		describe("indices", {

			it("should iterate over each index in the Vector", {

				var i = 0;
				for (k in Vector.make(1, 2, 3, 4).indices())
					i += k;
				i.should.be(6);

			});

			it("should work normally for an empty Vector", {

				var i = 0;
				for (k in new Vector().indices())
					i += k;
				i.should.be(0);

			});

		});

		describe("values", {

			it("should iterate over each value in the Vector", {

				var i = 0;
				for (v in Vector.make(1, 2, 3, 4).values())
					i += v;
				i.should.be(10);

			});


			it("should work normally for an empty Vector", {

				var i = 0;
				for (v in new Vector().values())
					i += v;
				i.should.be(0);

			});

		});

		describe("entries", {

			it("should iterate over each index-value pair in the Vector", {

				var i = 0;
				for (pair in Vector.make(1, 2, 3, 4).entries())
					i += pair.key + pair.value;
				i.should.be(16);

			});

			it("should work normally for an empty Vector", {


				var i = 0;
				for (pair in new Vector().entries())
					i += pair.key + pair.value;
				i.should.be(0);

			}); 

		});

		describe("toArray", {

			it("should convert a Vector to an equivalent array", {

				var arr = Vector.make(1, 2, 3, 4).toArray();
				arr.length.should.be(4);
				for (i in 0...arr.length)
					arr[i].should.be(Vector.make(1, 2, 3, 4)[i]);

			});

		});

		describe("toMap", {

			it("should convert a Vector to an equivalent Map", {

				var map = Vector.make(1, 2, 3, 4).toMap();
				map.length.should.be(4);
				for (k in map.keys())
					map.get(k).should.be(Vector.make(1, 2, 3, 4)[k]);

			});

		});

		describe("toOrderedMap", {

			it("should convert a Vector to an equivalent OrderedMap", {

				var map = Vector.make(1, 2, 3, 4).toOrderedMap();
				map.length.should.be(4);
				var i = 0;
				for (k => v in map)
					Vector.make(1, 2, 3, 4)[i++].should.be(v);

			});

		});

		describe("toSet", {

			it("should convert a Vector to an equivalent Set", {

				var set = Vector.make(1, 2, 3, 3, 4).toSet();
				set.length.should.be(4);
				for (v in Vector.make(1, 2, 3, 3, 4))
					set.has(v).should.be(true);

			});

		});

		describe("toOrderedSet", {

			it("should convert a Vector to an equivalent OrderedSet", {

				var set = Vector.make(1, 2, 3, 3, 4).toOrderedSet();
				set.length.should.be(4);
				var i = 0;
				for (v in set)
					Vector.make(1, 2, 3, 4)[i++].should.be(v);

			});

		});

		describe("toStack", {

			it("should convert a Vector to an equivalent (reversed) Stack", {

				var stack = Vector.make(1, 2, 3, 4).toStack();
				stack.count().should.be(4);
				var i = 0;
				for (v in stack)
					Vector.make(1, 2, 3, 4).reverse()[i++].should.be(v);

			});

		});

		describe("toString", {

			it("should convert a Vector to its string representation", {

				Vector.make(1, 2, 3, 4).toString().should.be("Vector [ 1, 2, 3, 4 ]");

			});

			it("should handle the empty Vector", {

				new Vector().toString().should.be("Vector [ ]");

			});

			it("should handle nested Vector", {

				Vector.make(Vector.make(1, 2), Vector.make(3, 4))
					.toString().should.be("Vector [ Vector [ 1, 2 ], Vector [ 3, 4 ] ]");

			});

		});


		describe("toSequence", {

			it("should convert a Vector to an equivalent Sequence", {

				var vec = Vector.make(1, 2, 3, 4);
				vec.length.should.be(4);
				var i = 0;
				for (v in vec)
					Sequence.make(1, 2, 3, 4)[i++].should.be(v);

			});

		});

	}
}
