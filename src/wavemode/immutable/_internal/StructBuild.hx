/**
 *  Copyright (c) 2020-present, Chukwudi Okechukwu
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the root directory of this source tree.
 *
 */

package wavemode.immutable._internal;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
using haxe.macro.TypeTools;

typedef FieldInfo = {name:String,type:Type};

// get underlying type
// check if anonymous type or class and gather public fields from appropriate method
// define abstract over given type with:
    // from - implicit conversion from given type
    // clone method that creates new object and sets all these fields to be the same
    // read-only parameters for each field
    // set_NAME for each field which returns a copy of the underlying

/**
{
    name: A,
    params: [],
    pos: #pos(src/wavemode/immutable/util/StructUtils.hx:25: lines 25-38),
    fields: [
        {
            name: a,
            pos: #pos(src/wavemode/immutable/util/StructUtils.hx:26: characters 13-42),
            access: [APublic],
            kind: FProp(get,never,TPath({name: <...>, params: <...>, pack: <...>}),null)
        },
        {
            name: get_a,
            pos: #pos(src/wavemode/immutable/util/StructUtils.hx:27: characters 13-50),
            access: [APublic],
            kind: FFun({ret: null, params: [], expr: {pos: <...>, expr: <...>}, args: []})
        },
        {
            name: set_a,
            pos: #pos(src/wavemode/immutable/util/StructUtils.hx:28: lines 28-32), 
            access: [APublic],
            kind: FFun({ret: null, params: [], expr: {pos: <...>, expr: <...>},args: [<...>]})
        },
        {
            name: clone,
            pos: #pos(src/wavemode/immutable/util/StructUtils.hx:33: lines 33-37),
            access: [APublic],
            kind: FFun({ret: null, params: [], expr: {pos: <...>, expr: <...>}, args: []})
        }],
    pack: [],
    kind: TDClass(null,[],false,false),
    meta: [],
    isExtern: false}
**/

class StructBuild {
    static function build() {
        var typeParam:Type = getTypeParam();
        var followedType:Type = TypeTools.follow(typeParam);
        var complexParam:ComplexType = typeParam.toComplexType();

        for (name => type in definedTypes)
            if (equalTypes(type, followedType))
                return Context.getType(name);

        className = getClassName(followedType);
        selfName = abstractName(followedType);

        var fields = abstractFields(followedType);
        var pos = Context.currentPos();
        var localModule = Context.getLocalModule();
        var pack = [];
        var kind = TDAbstract(complexParam, [complexParam], [complexParam]);
        var meta = [];
        var isExtern = false;

        Context.defineType({
            name: selfName,
            fields: fields,
            pos: pos,
            pack: pack,
            kind: kind,
            meta: meta,
            isExtern: isExtern
        });

        definedTypes.set(selfName, followedType);
        return Context.getType(selfName);
    }
    static function getTypeParam():Type {
        var type = Context.getLocalType();
        switch type {
            case TInst(t, params):
                return params[0];
            default:
        }
        throw "build macro only valid on a class";
    }
    static function abstractName(t:Type):String {
        switch t {
            case TInst(t, params):
                return "Struct_" + t.get().name;
            case TType(t, params):
                return "Struct_" + t.get().name;
            case TAnonymous(a):
                return "AnonStruct_" + anonCounter++;
            default:
                return "";
        };
    }
    static function abstractFields(t:Type):Array<Field> {
        var result = [];
        var publicFieldInfo = getPublicFieldInfo(t);

        result.push(makeNew(publicFieldInfo));
        result.push(makeClone(publicFieldInfo));
        
        for (field in publicFieldInfo) {
            result.push(makeProp(field, publicFieldInfo));
            result.push(makeGet(field, publicFieldInfo));
            result.push(makeSet(field, publicFieldInfo));
        }
        return result;
    }
    static function getClassName(t:Type):Null<String> {
        switch t {
            case TInst(t, _):
                return t.get().module + "." + t.get().name;
            default:
        }
        return null;
    }
    static function getPublicFieldInfo(t:Type):Array<FieldInfo> {
        var result = [];
        switch t {
            case TInst(t, _):
                for (field in t.get().fields.get())
                    if (field.isPublic && isFieldVariable(field))
                        result.push({name:field.name,type:field.type});
            case TAnonymous(a):
                for (field in a.get().fields)
                    if (field.isPublic && isFieldVariable(field))
                        result.push({name:field.name,type:field.type});
            default:
                Context.error("type parameter must be a class or anonymous struct", Context.currentPos());
        }
        return result;
    }

    static function isFieldVariable(f:ClassField):Bool {
        switch f.kind {
            case FVar(read, write):
                if (!(read.match(AccNormal) || read.match(AccCall)))
                    return false;
                if (!(write.match(AccNormal) || write.match(AccCall)))
                    return false;
                if (f.isExtern || f.isFinal)
                    return false;
                return true;
            default:
        }
        return false;
    }

    static function makeNew(fieldInfo:Array<FieldInfo>):Field {
        var pos = Context.currentPos();
        var access = [APublic, AInline];
        var meta = null;
        var doc = "Create a new default object.";
        var name = "new";

        var newExprs = [];
        if (className != null) {
            newExprs.push(Context.parse('this = new $className()', pos));
            for (field in fieldInfo)
                newExprs.push(Context.parse('this.${field.name} = ${field.name}', pos));
        } else {
            var decl = "this = {";
            for (field in fieldInfo)
                decl += '${field.name}: ${field.name},';
            newExprs.push(Context.parse(decl+"}", pos));
        }

        var kind = FFun({
            ret: null,
            params: null,
            expr: macro { $a{newExprs} },
            args: fieldInfo.map(x -> {name: x.name, type: null, meta: null, value: null, opt: null})
        });

        return {
            pos: pos,
            access: access,
            meta: meta,
            doc: doc,
            name: name,
            kind: kind
        };
    }

    static function makeClone(fieldInfo:Array<FieldInfo>):Field {
        var pos = Context.currentPos();
        var access = [APublic, AInline];
        var meta = null;
        var doc = "Create a clone of this object.";
        var name = "clone";

        var cloneStr = 'return new $selfName(';
        for (field in fieldInfo)
            cloneStr += field.name + ",";
        var cloneExpr = Context.parse(cloneStr.substr(0, cloneStr.length-1)+")", pos);

        var kind = FFun({
            ret: null,
            params: null,
            expr: cloneExpr,
            args: []
        });

        return {
            pos: pos,
            access: access,
            meta: meta,
            doc: doc,
            name: name,
            kind: kind
        };
    }

    static function makeProp(field:FieldInfo, all:Array<FieldInfo>):Field {
        var pos = Context.currentPos();
        var access = [APublic];
        var meta = null;
        var doc = null;
        var name = field.name;

        var kind = FProp("get", "never", field.type.toComplexType());

        return {
            pos: pos,
            access: access,
            meta: meta,
            doc: doc,
            name: name,
            kind: kind
        };
    }
    static function makeGet(field:FieldInfo, all:Array<FieldInfo>):Field {
        var pos = Context.currentPos();
        var access = [APublic];
        var meta = null;
        var doc = null;
        var name = "get_" + field.name;

        var getExpr = Context.parse('return this.${field.name}', pos);

        var kind = FFun({
            ret: null,
            params: null,
            expr: getExpr,
            args: []
        });

        return {
            pos: pos,
            access: access,
            meta: meta,
            doc: doc,
            name: name,
            kind: kind
        };
    }
    static function makeSet(field:FieldInfo, all:Array<FieldInfo>):Field {
        var pos = Context.currentPos();
        var access = [APublic];
        var meta = null;
        var doc = null;
        var name = "set_" + field.name;

        var cloneStr = 'return new $selfName(';
        for (field in all)
            cloneStr += field.name + ",";
        var cloneExpr = Context.parse(cloneStr.substr(0, cloneStr.length-1)+")", pos);

        var kind = FFun({
            ret: null,
            params: null,
            expr: cloneExpr,
            args: [{name: field.name, type: null, meta: null, value: null, opt: null}]
        });

        return {
            pos: pos,
            access: access,
            meta: meta,
            doc: doc,
            name: name,
            kind: kind
        };
    }

    static function equalTypes(t1:Type, t2:Type):Bool
        return TypeTools.unify(t1, t2) && TypeTools.unify(t2, t1);

    static var className:Null<String> = null;
    static var selfName:Null<String> = null;
    @:persistent static var anonCounter = 0;
    @:persistent static var definedTypes = new haxe.ds.Map<String, Type>();
}
