package wavemode.immutable;

import haxe.ds.Option;

class Functional {

    /**
        Unwrap an Option<T>. Throws an Exception if the object is null or None.
    **/
    public static function unwrap<T>(opt: Option<T>) : T {
        if (opt == null) throw "attempted to unwrap null";
        switch opt {
            case Some(v): return v;
            case None: throw "attempted to unwrap None";
        }
    }

    /**
        Returns true if the Option<T> object is null or None.
    **/
    public static function isEmpty<T>(opt: Option<T>) : Bool {
        if (opt == null) return true;
        switch opt {
            case Some(v): return false;
            case None: return true;
        }
    }

    /**
        Returns true if two Option<T> objects are equivalent (both empty, or values equal)
    **/
    public static function equals<T>(opt1 : Option<T>, opt2 : Option<T>) {
        if (opt1 == null) return isEmpty(opt2);
        if (opt2 == null) return isEmpty(opt1);
        switch opt1 {
            case Some(v1): {
                switch opt2 {
                    case Some(v2): return v1 == v2;
                    case None: return false; 
                }
            }
            case None: {
                switch opt2 {
                    case Some(v2): return false;
                    case None: return true;
                }
            }
        }
    }

    /**
        Returns true if the Option<T> object contains the given value.
    **/
    public static function is<T>(opt : Option<T>, value : T) : Bool {
        if (opt == null) return false;
        switch opt {
            case Some(v): return value == v;
            case None: return false;
        }
    }

    /**
        Returns the inverse of a predicate (i.e. x -> !pred(x))
    **/
    public static function inverse<T>(pred : T -> Bool) {
        return x -> !pred(x);
    }

    /**
        Returns the conjunction of the predicates (i.e. x -> pred1(x) && pred2(x))
    **/
    public static function conj<T>(pred1 : T -> Bool, pred2 : T -> Bool) {
        return x -> pred1(x) && pred2(x);
    }

}