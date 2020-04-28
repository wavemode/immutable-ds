/**
 *  Copyright (c) 2020-present, Chukwudi Okechukwu
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the root directory of this source tree.
 *
 */

package;

import buddy.BuddySuite;
using buddy.Should;

import wavemode.immutable.List;
import wavemode.immutable.Sequence;

class ListTest extends BuddySuite {
	public function new() {

		describe("new", {

			it("should create an empty list", {

				var list = new List();
				list.equals([]).should.be(true);
				list.length.should.be(0);

			});

			it("should create a clone of another iterable", {

				new List([1, 2, 3, 4]).equals([1, 2, 3, 4]).should.be(true);
				new List(new List().pushEach([1, 2, 3, 4])).equals([1, 2, 3, 4]).should.be(true);

			});

		});

		describe("fromSequence", {

			it("should contain same values as the original iterable", {

				var list = [1, 2, 3];
				List.fromSequence(list).equals([1, 2, 3]).should.be(true);
    
			});

			it("should behave normally for an empty input", {

				List.fromSequence([]).equals([]).should.be(true);
				List.fromSequence([]).length.should.be(0);

			});

		});

		describe("make", {

			it("should allow for variadic list creation", {

				List.make(1, 2, 3).equals([1, 2, 3]).should.be(true);

			});

			it("should behave normally for an empty input", {

				List.make().equals([]).should.be(true);

			});

		});
			
		describe("constant", {

			it("should create a List of a repeating value", {

				List.constant(0, 4).equals([0, 0, 0, 0]).should.be(true);

			});

			it("should behave normally with a null value", {

				List.constant(null, 4).equals([null, null, null, null]).should.be(true);

			});

			it("should behave normally with 0 repetitions", {

				List.constant(0, 0).equals([]).should.be(true);

			});

		});

		describe("range", {

			it("should create an inclusive list of numbers", {

				List.range(0, 10).equals([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]).should.be(true);

			});

			it("should behave normally for negative lists", {

				List.range(0, -10).equals([0, -1, -2, -3, -4, -5, -6, -7, -8, -9, -10]).should.be(true);

			});

			it("should behave normally for single values", {

				List.range(10, 10).equals([10]).should.be(true);

			});

		});

		describe("iterate", {

			it("should create a list of repeated iterations", {

				List.iterate(100, 0, x -> x + 3).equals([for (i in 0...100) i * 3]).should.be(true);

			});

		});

		describe("step", {

			it("should create a list of num steps", {

				List.step(100, 0, 2).equals([for (i in 0...100) i * 2]).should.be(true);

			});

			it("the default step value should be 1", {

				List.step(100, 0).equals([for (i in 0...100) i]).should.be(true);

			});

			it("the default start value should be 0", {

				List.step(100).equals([for (i in 0...100) i]).should.be(true);

			});

		});

		describe("join", {

			it("should concat the lists with a separator between", {

				List.join([[1, 2], [4, 6], [7, 8]], 999).equals([1, 2, 999, 4, 6, 999, 7, 8]).should.be(true);

			});

			it("should handle empty lists within the input list", {

				List.join([[], [4, 5], [], [], [9]], 100).equals([100, 4, 5, 100, 100, 100, 9]).should.be(true);

			});

			it("should handle an empty input list", {

				List.join([], 10).equals(new List()).should.be(true);

			});

		});

		describe("@:from Array", {

			it("should be equivalent to the original array", {

				var arr:Array<Int> = [1, 2, 3, 4, 5];
				var list:List<Int> = arr;

				list.equals([1, 2, 3, 4, 5]).should.be(true);

			});

		});


		describe("push", {

			it("should add the given value to the end of the list", {

				List.make(1, 2, 3, 4).push(5).equals([1, 2, 3, 4, 5]).should.be(true);

			});

			it("should behave normally for an empty list", {

				new List().push(4).equals([4]).should.be(true);

			});

		});

		describe("pushEach", {

			it("should add the given values to the end of the list", {

				List.make(1, 2, 3, 4).pushEach([5, 6, 7, 8]).equals([1, 2, 3, 4, 5, 6, 7, 8]).should.be(true);

			});

			it("should behave normally for an empty list", {

				new List().pushEach([4, 5, 6]).equals([4, 5, 6]).should.be(true);

			});

		});

		describe("pop", {

			it("should remove one value from the end of the List", {

				List.make(1, 2, 3).pop().equals([1, 2]).should.be(true);

			});

			it("should do nothing for an empty List", {

				new List().pop().equals(new List()).should.be(true);

			});

		});

		describe("unshift", {

			it("should prepend a value to the front of the List", {

				List.make(1, 2, 3, 4).unshift(5).equals([5, 1, 2, 3, 4]).should.be(true);

			});

			it("should work normally for an empty List", {

				new List().unshift(5).equals([5]).should.be(true);

			});

		});

		describe("shift", {

			it("should remove the first value of the List", {

				List.make(1, 2, 3, 4).shift().equals([2, 3, 4]).should.be(true);

			});

			it("should do nothing for an empty List", {

				new List().shift().equals(new List()).should.be(true);

			});

		});

		describe("insert", {

			it("should insert the given value at the given index", {

				List.make(1, 2, 3, 4).insert(2, 99).equals([1, 2, 99, 3, 4]).should.be(true);

			});

			it("should grow the list if and only if index <= count()", {

				List.make(1, 2, 3, 4).insert(4, 5).equals([1, 2, 3, 4, 5]).should.be(true);
				List.make(1, 2, 3, 4).insert(5, 5).equals([1, 2, 3, 4]).should.be(true);
				List.make(1, 2, 3, 4).insert(-1, 5).equals([1, 2, 3, 4]).should.be(true);

			});

			it("should behave normally for an empty list", {

				new List().insert(0, 10).equals([10]).should.be(true);

			});

			it("optimization: should return the same identical list if the index is out of bounds", {

				// here we are testing for identity (memory address), not equality

				var list = List.make(1, 2, 3, 4);

				(list.insert(0, 10) == list).should.be(false);
				(list.insert(30, 10) == list).should.be(true);
				(list.insert(-30, 10) == list).should.be(true);

			});

		});

		describe("insertEach", {

			it("should insert the given values at the given index", {

				List.make(1, 2, 3, 4).insertEach(2, [99, 99, 99]).equals([1, 2, 99, 99, 99, 3, 4]).should.be(true);

			});

			it("should grow the List if and only if index <= count()", {

				List.make(1, 2, 3, 4).insertEach(4, [5, 6]).equals([1, 2, 3, 4, 5, 6]).should.be(true);
				List.make(1, 2, 3, 4).insertEach(5, [5, 6]).equals([1, 2, 3, 4]).should.be(true);
				List.make(1, 2, 3, 4).insertEach(-1, [5, 6]).equals([1, 2, 3, 4]).should.be(true);

			});

			it("should behave normally for an empty List", {

				new List().insertEach(0, [10, 11, 12]).equals([10, 11, 12]).should.be(true);

			});

			it("optimization: should return the same identical List if the index is out of bounds", {


				var list = List.make(1, 2, 3, 4);

				// here we are testing for identity (memory address), not equality
				(list.insertEach(0, [10]) == list).should.be(false);
				(list.insertEach(30, [10]) == list).should.be(true);
				(list.insertEach(-30, [10]) == list).should.be(true);

			});

		});

		describe("set", {

			it("should set the given index to the given value", {

				List.make(1, 2, 3, 4).set(0, 99).equals([99, 2, 3, 4]).should.be(true);

			});

			it("should work normally for an empty List", {

				new List().set(0, 99).equals([]).should.be(true);

			});

			it("optimization: should return the same identical List if the index is out of bounds", {


				var list = List.make(1, 2, 3, 4);

				// here we are testing for identity (memory address), not equality
				(list.set(0, 30) == list).should.be(false);
				(list.set(30, 30) == list).should.be(true);
				(list.set(-30, 30) == list).should.be(true);

			});

		});

		describe("setEach", {

			it("should set the given indices to the given value", {

				List.make(1, 2, 3, 4).setEach([0, 1], [99, 99]).equals([99, 99, 3, 4]).should.be(true);

			});

			it("should work normally for an empty list", {

				new List().setEach([0, 1], [99, 99]).equals([]).should.be(true);

			});

		});

		describe("update", {

			it("should pass the value at the given index through the updater function", {

				List.make(1, 2, 3, 4).update(0, x -> x + 10).equals([11, 2, 3, 4]).should.be(true);

			});

			it("should work normally for an empty list", {

				new List().update(0, x -> x + 10).equals([]).should.be(true);

			});

			it("optimization: should return the same identical list if the index is out of bounds", {


				var list = List.make(1, 2, 3, 4);

				// here we are testing for identity (memory address), not equality
				(list.update(0, x -> x + 10) == list).should.be(false);
				(list.update(30, x -> x + 10) == list).should.be(true);
				(list.update(-30, x -> x + 10) == list).should.be(true);

			});


		});

		describe("updateEach", {

			it("should pass the given indices through the updater function", {

				List.make(1, 2, 3, 4).updateEach([0, 1], x -> x + 10).equals([11, 12, 3, 4]).should.be(true);

			});

			it("should work normally for an empty List", {

				new List().updateEach([0, 1], x -> x + 10).equals([]).should.be(true);

			});

		});

		describe("replace", {

			it("should replace all instances of the given value", {

				List.make(1, 2, 3, 1).replace(1, 10).equals([10, 2, 3, 10]).should.be(true);

			});

			it("should do nothing if the value does not exist", {

				var list = List.make(1, 2, 3, 4);
				list.replace(9, 10).equals(list).should.be(true);

			});

			it("should work normally for an empty List", {

				new List().replace(1, 10).equals([]).should.be(true);

			});

		});

		describe("replaceEach", {

			it("should replace all instances of all given values", {

				List.make(1, 2, 3, 1).replaceEach([1, 2], [10, 11]).equals([10, 11, 3, 10]).should.be(true);

			});

			it("should do nothing if the values do not exist", {

				var list = List.make(1, 2, 3, 4);
				list.replaceEach([11, 12], [10, 11]).equals(list).should.be(true);

			});

			it("should work normally for an empty List", {

				new List().replaceEach([1, 2], [10, 11]).equals([]).should.be(true);

			});

		});

		describe("[index] / get", {

			it("should be indexable with array access", {

				List.make(1, 2, 3, 4).get(3).should.be(4);
				List.make(1, 2, 3, 4)[3].should.be(4);

			});

			it("should throw an exception for out-of-bounds access", {

				(() -> List.make(1, 2, 3, 4).get(4)).should.throwAnything();
				(() -> List.make(1, 2, 3, 4)[4]).should.throwAnything();

			});

		});

		describe("has", {

			it("should return true if the index exists", {

				List.make(1, 2, 3, 4).has(3).should.be(true);

			});

			it("should return false if the index is out of bounds", {

				var list = List.make(1, 2, 3, 4);
                
				list.has(-1).should.be(false);
				list.has(4).should.be(false);

			});

		});

		describe("contains", {

			it("should return true if the value exists", {

				List.make(1, 2, 3, 4).contains(4).should.be(true);

			});

			it("should return false if the value does not exist", {

				var list = List.make(1, 2, 3, 4);
            
				list.contains(0).should.be(false);

			});

		});

		describe("empty", {

			it("should be true when a List is empty", {

				new List().empty().should.be(true);
				List.fromArray([]).empty().should.be(true);

			});

			it("should be true when a List is not empty", {

				new List().push(1).empty().should.be(false);

			});

		});

		describe("find / indexOf", {

			it("should return the first index of the given value", {

				List.make(1, 2, 2, 3).find(2).should.be(1);
				List.make(1, 2, 2, 3).indexOf(2).should.be(1);

			});

			it("should return -1 if the value does not exist", {

				List.make(1, 2, 2, 3).find(12).should.be(-1);
				List.make(1, 2, 2, 3).indexOf(12).should.be(-1);

			});

			it("should begin searching from the given start index", {

				List.make(1, 2, 2, 3).find(2, 2).should.be(2);
				List.make(1, 2, 2, 3).indexOf(2, 2).should.be(2);

				List.make(1, 2, 2, 3).find(2, 3).should.be(-1);
				List.make(1, 2, 2, 3).indexOf(2, 3).should.be(-1);

			});

			it("should work normally for an empty list", {

				new List().find(4).should.be(-1);
				new List().indexOf(4).should.be(-1);

			});

			it("should work normally if the start index is out of bounds", {

				List.make(1, 2, 2, 3).find(2, 30).should.be(-1);
				List.make(1, 2, 2, 3).indexOf(2, 30).should.be(-1);

			});

		});

		describe("findWhere", {

			it("should return the first index at which the predicate returns true", {

				List.make(1, 2, 2, 3).findWhere(x -> x % 2 == 0).should.be(1);

			});

			it("should return -1 if the predicate never returns true", {

				List.make(1, 2, 2, 3).findWhere(x -> x > 12).should.be(-1);

			});

			it("should begin searching from the given start index", {

				List.make(1, 2, 2, 3).findWhere(x -> x % 2 == 0, 2).should.be(2);

				List.make(1, 2, 2, 3).findWhere(x -> x % 2 == 0, 3).should.be(-1);

			});

			it("should work normally for an empty list", {

				new List().findWhere(x -> x % 2 == 0).should.be(-1);

			});

			it("should work normally if the start index is out of bounds", {

				List.make(1, 2, 2, 3).findWhere(x -> x % 2 == 0, 30).should.be(-1);

			});

            
		});

		describe("first", {

			it("should return the first value in the List", {

				List.make(1, 2, 3, 4).first().should.be(1);

			});

			it("should throw if the List is empty", {

				(() -> new List().first()).should.throwAnything();

			});

		});

		describe("last", {

			it("should return the last value in the List", {

				List.make(1, 2, 3, 4).last().should.be(4);

			});

			it("should throw if the List is empty", {

				(() -> new List().last()).should.throwAnything();

			});

		});

		describe("filter", {

			it("should remove values for which the predicate is false", {

				List.make(1, 2, 3, 4, 5).filter(x -> x % 2 == 0).equals([2, 4]).should.be(true);

			});

			it("should work normally for an empty List", {

				new List().filter(x -> x % 2 == 0).equals([]).should.be(true);

			});

		});

		describe("remove", {

			it("should remove values which equal the given value", {

				List.make(1, 4, 3, 4, 5).remove(4).equals([1, 3, 5]).should.be(true);

			});

			it("should work normally for null values", {

				List.fromArray(([1, null, 3, null, 5] : Array<Null<Int>>)).remove(null).equals([1, 3, 5]).should.be(true);

			});

			it("should work normally for an empty List", {

				new List().remove(null).equals([]).should.be(true);

			});

		});

		describe("removeEach", {

			it("should remove values which equal any of the given values", {

				List.make(1, 4, 3, 4, 5).removeEach([4, 1]).equals([3, 5]).should.be(true);

			});

			it("should work normally for null values", {

				List.fromArray(([1, null, 3, null, 5] : Array<Null<Int>>)).removeEach(([null, 1] : Array<Null<Int>>)).equals([3, 5]).should.be(true);

			});

			it("should work normally for an empty List", {

				new List().removeEach(([null, 1] : Array<Null<Int>>)).equals([]).should.be(true);

			});

		});

		describe("delete", {

			it("should remove the value at the given index", {

				List.make(1, 4, 3, 5).delete(1).equals([1, 3, 5]).should.be(true);

			});

			it("should work normally for null values", {

				List.fromArray(([1, null, 3, 5] : Array<Null<Int>>)).delete(1).equals([1, 3, 5]).should.be(true);

			});

			it("should work normally for an empty List", {

				new List().delete(0).equals([]).should.be(true);

			});

			it("optimization: should return the same identical List if the index is out of bounds", {


				var list = List.make(1, 2, 3, 4);

				// here we are testing for identity (memory address), not equality
				(list.delete(0) == list).should.be(false);
				(list.delete(30) == list).should.be(true);
				(list.delete(-30) == list).should.be(true);

			});

		});

		describe("deleteEach", {

			it("should delete indices which equal any of the given indices", {

				List.make(1, 4, 3, 4, 5).deleteEach([1, 3]).equals([1, 3, 5]).should.be(true);

			});

			it("should work normally for null values", {

				List.fromArray(([1, null, 3, null, 5] : Array<Null<Int>>)).deleteEach([1, 3]).equals([1, 3, 5]).should.be(true);

			});

			it("should work normally for an empty List", {

				new List().deleteEach([1, 3]).equals([]).should.be(true);

			});

		});

		describe("clear", {

			it("should result in an empty List", {

				List.make(1, 2, 3).clear().equals([]).should.be(true);

			});

		});

		describe("reverse", {

			it("should result in a reversed List", {

				List.make(1, 2, 3, 4).reverse().equals([4, 3, 2, 1]).should.be(true);

			});

		});

		describe("sort", {

			it("should result in a sorted List", {

				List.make(1, 3, 6, 2, 7).sort((a, b) -> a - b).equals([1, 2, 3, 6, 7]).should.be(true);

			});

		});

		describe("sortAsc", {

			it("should sort an integer List in ascending order", {

				List.make(1, 3, 6, 2, 7).sortAsc().equals([1, 2, 3, 6, 7]).should.be(true);
            
			});

			it("should work for Floats as well", {

				var seq = List.make(1.0, 3.0, 6.0, 2.0, 7.0);
				seq.sortAsc().equals([1.0, 2.0, 3.0, 6.0, 7.0]).should.be(true);
            
			});

		});

		describe("sortDesc", {

			it("should sort an integer List in ascending order", {

				List.make(1, 3, 6, 2, 7).sortDesc().equals([7, 6, 3, 2, 1]).should.be(true);
            
			});

			it("should work for Floats as well", {

				List.make(1.0, 3.0, 6.0, 2.0, 7.0).sortDesc().equals([7.0, 6.0, 3.0, 2.0, 1.0]).should.be(true);
            
			});

		});

		describe("concat", {

			it("should add the given values to the end of the List", {

				List.make(1, 2, 3, 4).concat([5, 6, 7, 8]).equals([1, 2, 3, 4, 5, 6, 7, 8]).should.be(true);

			});

			it("should behave normally for an empty List", {

				new List().concat([4, 5, 6]).equals([4, 5, 6]).should.be(true);

			});

		});
        
		describe("concatEach", {

			it("should add the given sequences to the end of the List", {

				List.make(1, 2, 3, 4).concatEach([[5, 6], [7, 8]]).equals([1, 2, 3, 4, 5, 6, 7, 8]).should.be(true);

			});

			it("should correctly skip empty sequences", {

				List.make(1, 2, 3, 4).concatEach([[], [5, 6], [], [], [7, 8], []]).equals([1, 2, 3, 4, 5, 6, 7, 8]).should.be(true);

			});

			it("should behave normally for an empty List", {

				new List().concat([4, 5, 6]).equals([4, 5, 6]).should.be(true);

			});  

		});

		describe("separate", {

			it("should interpose the separator between each element", {
               
				List.make(1, 2, 3, 4).separate(0).equals([1, 0, 2, 0, 3, 0, 4]).should.be(true);

			});

			it("should do nothing for a List with 1 element", {

				List.make(1).separate(0).equals([1]).should.be(true);

			});

			it("should do nothing for a List with 0 elements", {

				new List().separate(0).equals([]).should.be(true);

			});

		});

		describe("interleave", {

			it("should interweave the elements of the other List between this one", {

				List.make(1, 2, 3, 4).interleave([9, 8, 7, 6]).equals([1, 9, 2, 8, 3, 7, 4, 6]).should.be(true);

			});

			it("should handle mismatched lengths", {

				List.make(1, 2, 3, 4).interleave([9, 8]).equals([1, 9, 2, 8, 3, 4]).should.be(true);
				List.make(1, 2).interleave([9, 8, 7, 6]).equals([1, 9, 2, 8, 7, 6]).should.be(true);

			});

			it("should handle empty sequences", {

				List.make(1, 2, 3, 4).interleave(new List()).equals([1, 2, 3, 4]).should.be(true);
				new List().interleave([9, 8, 7, 6]).equals([9, 8, 7, 6]).should.be(true);

			});

		});

		describe("split", {

			it("should split the List into sublists divided by the given element", {

				var list = List.make(1, 2, 3, 4, 5, 4, 6, 7).split(4);
				list.toString().should.be("List [ List [ 1, 2, 3 ], List [ 5 ], List [ 6, 7 ] ]");

			});

			it("should handle empty regions", {

				var list = List.make(4, 3, 4, 4, 6, 7, 4).split(4);
				list.toString().should.be("List [ List [ ], List [ 3 ], List [ ], List [ 6, 7 ], List [ ] ]");

			});

		});

		describe("splitWhere", {

			it("should split the list into sublists divided where the predicate is true", {

				var list = List.make(1, 1, 3, 4, 5, 2, 7, 7).splitWhere(x -> x % 2 == 0);
				list.toString().should.be("List [ List [ 1, 1, 3 ], List [ 5 ], List [ 7, 7 ] ]");

			});

			it("should handle empty regions", {

				var list = List.make(2, 3, 4, 8, 7, 7, 4).splitWhere(x -> x % 2 == 0);
				list.toString().should.be("List [ List [ ], List [ 3 ], List [ ], List [ 7, 7 ], List [ ] ]");

			});

		});

		describe("partition", {

			it("should divide the sequence along the given indices", {

				var x = List.make(1, 2, 3, 4, 5, 6).partition([4, 2]);
				x[0].equals([1, 2]).should.be(true);
				x[1].equals([3, 4]).should.be(true);
				x[2].equals([5, 6]).should.be(true);

			});

			it("should handle empty partitions", {

				var x = List.make(1, 2, 3, 4, 5).partition([7, 5, 0, 1, 1]);
				x[0].equals([]).should.be(true);
				x[1].equals([1]).should.be(true);
				x[2].equals([]).should.be(true);
				x[3].equals([2, 3, 4, 5]).should.be(true);
				x[4].equals([]).should.be(true);

			});

			it("should handle extra indices", {

				var x = List.make(1, 2, 3, 4).partition([2, 9, 10, 11, 12]);
				x[0].equals([1, 2]).should.be(true);
				x[1].equals([3, 4]).should.be(true);

			});

			it("should handle zero indices", {

				var x = List.make(1, 2, 3, 4).partition([]);
				x[0].equals([1, 2, 3, 4]).should.be(true);

			});

			it("should handle empty input", {

				var x = new List().partition([1, 2, 3]);
				x[0].equals([]).should.be(true);

			});

		});

		describe("repeat", {

			it("should create a List repeated num times", {
				
				List.make(1, 2, 3).repeat(3).equals([1, 2, 3, 1, 2, 3, 1, 2, 3]).should.be(true);

			});

			it("should behave normally with an empty list", {

				var list = new List<Int>();
				list.repeat(3).equals([]).should.be(true);

			});

			it("should behave normally with 0 or fewer repetitions", {

				List.make(1, 2, 3).repeat(0).equals([]).should.be(true);
				List.make(1, 2, 3).repeat(-10).equals([]).should.be(true);

			});

		});

		describe("shuffle", {

			// this test is disabled because it could occasionally fail...

			/*
			it("should rearrange the order of the elements", {

				var list = List.make(1, 2, 3, 4);
				list.equals(list.shuffle()).should.be(false);

			});
			*/

		});

		describe("slice", {

			it("should return values from pos to end", {

				List.make(1, 2, 3, 4).slice(2).equals([3, 4]).should.be(true);

			});

			it ("should return values from pos up to but not including end", {

				List.make(1, 2, 3, 4).slice(1, 3).equals([2, 3]).should.be(true);

			});

			it("should calculate from the end if pos is negative", {

				List.make(1, 2, 3).slice(-2).equals([2, 3]).should.be(true);

			});

			it("should calculate from the end if end is negative", {

				List.make(1, 2, 3).slice(-2, -1).equals([2]).should.be(true);

			});

		});

		describe("splice", {

			it("should return values from pos to end", {

				List.make(1, 2, 3, 4).splice(2).equals([3, 4]).should.be(true);

			});

			it ("should return len values starting from pos", {

				List.make(1, 2, 3, 4).splice(1, 3).equals([2, 3, 4]).should.be(true);

			});

			it("should calculate from the end if pos is negative", {

				List.make(1, 2, 3, 4).splice(-3, 2).equals([2, 3]).should.be(true);

			});

		});
        
		describe("take", {

			it("should take the first num values of the List", {

				List.make(1, 2, 3, 4).take(2).equals([1, 2]).should.be(true);

			});

			it("should take as many values as it can", {

				List.make(1, 2, 3, 4, 5).take(10).equals([1, 2, 3, 4, 5]).should.be(true);

			});

			it("should work normally for an empty List", {

				new List().take(10).equals([]).should.be(true);

			});

		});

		describe("takeLast", {

			it("should take the last num values of the List", {

				List.make(1, 2, 3, 4).takeLast(2).equals([3, 4]).should.be(true);

			});

			it("should take as many values as it can", {

				List.make(1, 2, 3, 4, 5).takeLast(10).equals([1, 2, 3, 4, 5]).should.be(true);

			});

			it("should work normally for an empty List", {

				new List().takeLast(10).equals([]).should.be(true);

			});

		});

		describe("takeWhile", {

			it("should take values until the predicate returns false", {

				List.make(1, 2, 3, 4, 5).takeWhile(i -> i < 3).equals([1, 2]).should.be(true);

			});

			it("should return the whole List if the predicate never returns false", {

				List.make(1, 2, 3, 4, 5).takeWhile(i -> i > 0).equals([1, 2, 3, 4, 5]).should.be(true);

			});

			it("should work normally for an empty List", {

				new List().takeWhile(i -> i > 0).equals([]).should.be(true);

			});

		});

		describe("takeUntil", {
            
			it("should take values until the predicate returns true", {

				List.make(1, 2, 3, 4, 5).takeUntil(i -> i >= 3).equals([1, 2]).should.be(true);

			});

			it("should return the whole List if the predicate never returns true", {

				List.make(1, 2, 3, 4, 5).takeUntil(i -> i < 0).equals([1, 2, 3, 4, 5]).should.be(true);

			});

			it("should work normally for an empty List", {

				new List().takeUntil(i -> i < 0).equals([]).should.be(true);

			});

		});

		describe("drop", {

			it("should remove the first num values of the List", {

				List.make(1, 2, 3, 4).drop(2).equals([3, 4]).should.be(true);

			});

			it("should drop as many values as it can", {

				List.make(1, 2, 3, 4, 5).drop(10).equals([]).should.be(true);

			});

			it("should work normally for an empty List", {

				new List().drop(10).equals([]).should.be(true);

			});

		});

		describe("dropLast", {

			it("should remove the last num values of the List", {

			List.make(1, 2, 3, 4).dropLast(2).equals([1, 2]).should.be(true);

			});

			it("should drop as many values as it can", {

				List.make(1, 2, 3, 4, 5).dropLast(10).equals([]).should.be(true);

			});

			it("should work normally for an empty List", {

				new List().dropLast(10).equals([]).should.be(true);

			});

		});

		describe("dropWhile", {

			it("should drop values until the predicate returns false", {

				List.make(1, 2, 3, 4, 5).dropWhile(i -> i < 3).equals([3, 4, 5]).should.be(true);

			});

			it("should drop the whole List if the predicate never returns false", {

				List.make(1, 2, 3, 4, 5).dropWhile(i -> i > 0).equals([]).should.be(true);

			});

			it("should work normally for an empty List", {

				new List().dropWhile(i -> i > 0).equals([]).should.be(true);

			});


		});

		describe("dropUntil", {
            
			it("should drop values until the predicate returns true", {

				List.make(1, 2, 3, 4, 5).dropUntil(i -> i >= 3).equals([3, 4, 5]).should.be(true);

			});

			it("should drop the whole List if the predicate never returns true", {

				List.make(1, 2, 3, 4, 5).dropUntil(i -> i < 0).equals([]).should.be(true);

			});

			it("should work normally for an empty List", {

				new List().dropUntil(i -> i < 0).equals([]).should.be(true);

			});

		});

		describe("map", {

			it("should pass each value through the mapper function", {

				List.make(1, 2, 3, 4).map(x -> x * 2).equals([2, 4, 6, 8]).should.be(true);

			});

			it("should work normally for an empty List", {

				new List().map(x -> x * 2).equals([]).should.be(true);

			});

		});

		describe("mapIndex", {

			it("should pass each index and value through the mapper function", {

				List.make(1, 2, 3, 4).mapIndex((k, v) -> k * 2).equals([0, 2, 4, 6]).should.be(true);

			});

			it("should work normally for an empty List", {

				new List().mapIndex((k, v) -> k * 2).equals([]).should.be(true);

			});


		});

		describe("flatMap", {

			it("should properly flatten its results", {

				List.make(1, 2, 3, 4).flatMap(x -> [x, x*2]).equals([1, 2, 2, 4, 3, 6, 4, 8]).should.be(true);

			});

		});

		describe("group", {

			it("should categorize each value", {

				var list = List.make(1, 2, 3, 4, 5, 6, 7).group(x -> x % 2);
				list[0].equals([1, 3, 5, 7]).should.be(true);
				list[1].equals([2, 4, 6]).should.be(true);

			});

		});

		describe("zip", {

			it("should zip the other sequence into this list", {

				var list = List.make(1, 1, 1, 1).zip([9, 9, 9, 9]);
				for (v in list)
					v.equals([1, 9]).should.be(true);

			});

			it("should handle mismatched lengths", {

				var list = List.make(1, 1).zip([9, 9, 9, 9]);
				list.length.should.be(2);
				for (v in list)
					v.equals([1, 9]).should.be(true);

			});

			it("should work normally for an empty list", {

				var list = List.make(1, 1, 1, 1).zip([]);
				list.equals([]).should.be(true);

			});

		});

		describe("zipEach", {

			it("should zip each of the other sequences into this list", {

				var list = List.make(1, 1, 1, 1).zipEach([[9, 9, 9, 9], [10, 10, 10, 10]]);
				// for (v in list)
				// 	v.equals([1, 9, 10]).should.be(true);

			});

			it("should handle mismatched lengths", {

				var list = List.make(1, 1).zipEach([[9, 9], [10, 10, 10]]);
				// list.length.should.be(2);
				// for (v in list)
				// 	v.equals([1, 9, 10]).should.be(true);

			});

			it("should work normally for an empty list", {

				var list = List.make(1, 1, 1, 1).zipEach([[9, 9], []]);
				// list.equals([]).should.be(true);

			});

		});

		describe("fold", {

			it("should accumulate values according to the foldFn function", {

				List.make(1, 2, 3, 4).fold((a, b) -> a - b, 0).should.be(-10);

			});

			it("should return initialValue if the list is empty, without executing foldFn", {

				new List().fold((_, _) -> throw "never", 10).should.be(10);

			});

		});

		describe("foldRight", {

			it("should accumulate values according to the foldFn function, in reverse order", {

				List.make(1, 2, 3, 4).foldRight((a:List<Int>, b) -> a.push(b), new List()).equals([4, 3, 2, 1]).should.be(true);

			});

			it("should return initialValue if the list is empty, without executing foldFn", {

				new List().foldRight((_, _) -> throw "never", 10).should.be(10);

			});

		});

		describe("reduce", {

			it("should accumulate values according to the reducer function", {

				List.make(1, 2, 3, 4).reduce((a, b) -> a - b).should.be(-8);

			});

			it("should return the sole value if the List has only one, without executing reducer", {

				List.make(10).reduce((_, _) -> throw "never").should.be(10);

			});

			it("should throw an exception if used on an empty List", {

				(() -> new List().reduce((a, b) -> a - b)).should.throwAnything();

			});


		});

		describe("reduceRight", {

			it("should accumulate values according to the reducer function, in reverse order", {

				List.make(1, 2, 3, 4).reduceRight((a, b) -> a - b).should.be(-2);

			});

			it("should return the sole value if the List has only one, without executing reducer", {

				List.make(10).reduceRight((_, _) -> throw "never").should.be(10);

			});

			it("should throw an exception if used on an empty List", {

				(() -> new List().reduceRight((a, b) -> a - b)).should.throwAnything();

			});

		});

		describe("length", {

			it("should return the number of elements in the List", {

				List.make(1, 2, 3, 4).length.should.be(4);

			});

			it("should work normally for an empty List", {

				new List().length.should.be(0);

			});

		});

		describe("every", {

			it("should return true if every value satisfies the predicate", {

				List.make(1, 2, 3, 4).every(x -> x < 5).should.be(true);

			});

			it("should return false if any value does not satisfy the predicate, and stop execution early", {

				// (null < 5) should never be executed, so our program should not crash
				List.fromArray(([1, 2, 6, 4, null] : Array<Null<Int>>)).every(x -> x < 5).should.be(false);

			});

			it("should return true for the empty List without executing the predicate", {

				new List().every(_ -> throw "never").should.be(true);

			});

		});

		describe("some", {

			it("should return true if any value satisfies the predicate, and stop execution early", {

				// (null < 5) should never be executed, so our program should not crash
				List.fromArray(([1, null, null, null] : Array<Null<Int>>)).some(x -> x < 5).should.be(true);

			});

			it("should return false if every value fails to satisfy the predicate", {

				List.make(7, 8, 9, 10).some(x -> x < 5).should.be(false);

			});

			it("should return false for the empty List without executing the predicate", {

				new List().some(_ -> throw "never").should.be(false);

			});


		});

		describe("equals", {

			it("should return true if the other List is identical", {

				List.make(1, 2, 3).equals(List.make(1, 2, 3)).should.be(true);

			});

			it("should return false if there is any difference", {

				List.make(1, 2, 3).equals(List.make(1, 2, 3, 4)).should.be(false);
				List.make(1, 2, 3).equals(List.make(1, 2)).should.be(false);
				List.fromArray(([1, 2, 3] : Array<Null<Int>>)).equals(List.make(null)).should.be(false);

			});

			it("should behave normally for the empty List", {

				new List().equals(new List()).should.be(true);
				new List().equals(List.make(1)).should.be(false);
				List.make(1).equals(new List()).should.be(false);

			});

		});

		describe("max", {

			it("should return the numerical maximum of the List", {

				List.make(1, 2, 3, 4).max().should.be(4);

			});

			it("should work normally for floats", {

				List.make(1.0, 2.0, 3.0, 4.0).max().should.be(4.0);

			});

			it("should throw an exception if the List is empty", {

				(() -> new List().max()).should.throwAnything();

			});

		});

		describe("min", {

			it("should return the numerical minimum of the List", {

				List.make(1, 2, 3, 4).min().should.be(1);

			});

			it("should work normally for floats", {

				List.make(1.0, 2.0, 3.0, 4.0).min().should.be(1.0);

			});

			it("should throw an exception if the List is empty", {

				(() -> new List().min()).should.throwAnything();

			});

		});

		describe("sum", {

			it("should return the sum of each value in the List", {

				List.make(1, 2, 3, 4).sum().should.be(10);

			});


			it("should work normally for floats", {

				List.make(1.0, 2.0, 3.0, 4.0).sum().should.be(10.0);

			});

			it("should work normally for strings", {

				List.make("1", "2", "3", "4").sum().should.be("1234");

			});

		});

		describe("product", {

			it("should return the product of each value in the List", {

				List.make(1, 2, 3, 4).product().should.be(24);

			});

			it("should work normally for floats", {

				List.make(1.0, 2.0, 3.0, 4.0).product().should.be(24.0);

			});

		});

		describe("forEach", {

			it("should execute the side effect for every value in the List", {

				var i = 0;
				List.make(1, 2, 3, 4).forEach(x -> i += x);
				i.should.be(10);

			});

			it("should work normally for an empty List", {

				var i = 0;
				List.make().forEach(x -> i += x);
				i.should.be(0);

			});

		});

		describe("forWhile", {

			it("should execute the side effect for every value in the List", {

				var i = 0;
				var c = List.make(1, 2, 3, 4).forWhile(x -> { i += x; true; });
				i.should.be(10);
				c.should.be(4);

			});

			it("should stop execution after the side effect returns false", {

				var i = 0;
				var c = List.make(1, 2, 3, 4).forWhile(x -> { i += x; i < 3; });
				i.should.be(3);
				c.should.be(2);

			});

			it("should work normally for an empty List", {

				var i = 0;
				var c = List.make().forWhile(x -> { i += x; i < 3; });
				i.should.be(0);
				c.should.be(0);

			});

		});


		describe("iterator", {

			it("should iterate over each value in the List", {

				var i = 0;
				for (v in List.make(1, 2, 3, 4))
					i += v;
				i.should.be(10);

			});


			it("should work normally for an empty List", {

				var i = 0;
				for (v in new List())
					i += v;
				i.should.be(0);

			});

		});

		describe("keyValueIterator", {

			it("should iterate over each index and value in the List", {

				var i = 0;
				for (k => v in List.make(1, 2, 3, 4))
					i += k + v;
				i.should.be(16);

			});

			it("should work normally for an empty List", {

				var i = 0;
				for (k => v in new List())
					i += k + v;
				i.should.be(0);

			});

		});

		describe("indices", {

			it("should iterate over each index in the List", {

				var i = 0;
				for (k in List.make(1, 2, 3, 4).indices())
					i += k;
				i.should.be(6);

			});

			it("should work normally for an empty List", {

				var i = 0;
				for (k in new List().indices())
					i += k;
				i.should.be(0);

			});

		});

		describe("values", {

			it("should iterate over each value in the List", {

				var i = 0;
				for (v in List.make(1, 2, 3, 4).values())
					i += v;
				i.should.be(10);

			});


			it("should work normally for an empty List", {

				var i = 0;
				for (v in new List().values())
					i += v;
				i.should.be(0);

			});

		});

		describe("entries", {

			it("should iterate over each index-value pair in the List", {

				var i = 0;
				for (pair in List.make(1, 2, 3, 4).entries())
					i += pair.key + pair.value;
				i.should.be(16);

			});

			it("should work normally for an empty List", {


				var i = 0;
				for (pair in new List().entries())
					i += pair.key + pair.value;
				i.should.be(0);

			}); 

		});

		describe("toArray", {

			it("should convert a List to an equivalent array", {

				var arr = List.make(1, 2, 3, 4).toArray();
				arr.length.should.be(4);
				for (i in 0...arr.length)
					arr[i].should.be(List.make(1, 2, 3, 4)[i]);

			});

		});

		describe("toMap", {

			it("should convert a List to an equivalent Map", {

				var map = List.make(1, 2, 3, 4).toMap();
				map.length.should.be(4);
				for (k in map.keys())
					map.get(k).should.be(List.make(1, 2, 3, 4)[k]);

			});

		});

		describe("toOrderedMap", {

			it("should convert a List to an equivalent OrderedMap", {

				var map = List.make(1, 2, 3, 4).toOrderedMap();
				map.length.should.be(4);
				var i = 0;
				for (k => v in map)
					List.make(1, 2, 3, 4)[i++].should.be(v);

			});

		});

		describe("toSet", {

			it("should convert a List to an equivalent Set", {

				var set = List.make(1, 2, 3, 3, 4).toSet();
				set.length.should.be(4);
				for (v in List.make(1, 2, 3, 3, 4))
					set.has(v).should.be(true);

			});

		});

		describe("toOrderedSet", {

			it("should convert a List to an equivalent OrderedSet", {

				var set = List.make(1, 2, 3, 3, 4).toOrderedSet();
				set.length.should.be(4);
				var i = 0;
				for (v in set)
					List.make(1, 2, 3, 4)[i++].should.be(v);

			});

		});

		describe("toString", {

			it("should convert a List to its string representation", {

				List.make(1, 2, 3, 4).toString().should.be("List [ 1, 2, 3, 4 ]");

			});

			it("should handle the empty List", {

				new List().toString().should.be("List [ ]");

			});

			it("should handle nested List", {

				List.make(List.make(1, 2), List.make(3, 4))
					.toString().should.be("List [ List [ 1, 2 ], List [ 3, 4 ] ]");

			});

		});


		describe("toSequence", {

			it("should convert a List to an equivalent Sequence", {

				var list = List.make(1, 2, 3, 4);
				list.length.should.be(4);
				var i = 0;
				for (v in list)
					Sequence.make(1, 2, 3, 4)[i++].should.be(v);

			});

		});

		describe("toStack", {

			it("should convert a list to an equivalent reversed Stack", {

				var stack = List.make(1, 2, 3, 4).toStack();
				var i = 0;
				for (v in stack)
					List.make(1, 2, 3, 4).reverse()[i++].should.be(v);

			});

		});

	}
}
