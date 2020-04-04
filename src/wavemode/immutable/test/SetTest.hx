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

class SetTest extends BuddySuite {
	public function new() {

        // TODO: failure for unhashable types
        // TODO: success for hashable types
        // TODO: proper conversion testing

        describe("iterator", {});
        describe("fromArray", {});
        describe("length", {});
        describe("add", {});
        describe("addAll", {});
        describe("remove", {});
        describe("removeAll", {});
        describe("clear", {});
        describe("update", {});
        describe("union", {});
        describe("unionAll", {});
        describe("intersect", {});
        describe("intersectAll", {});
        describe("subtract", {});
        describe("subtractAll", {});
        describe("map", {});
        describe("filter", {});
        describe("values", {});
        describe("equals", {});
        describe("has", {});
        describe("forEach", {});
        describe("forWhile", {});
        describe("toArray", {});
        describe("toSequence", {});
        describe("toSet", {});
        describe("toList", {});
        describe("toStack", {});

    }
    
}
