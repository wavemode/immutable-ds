package wavemode.immutable;

#if macro
import haxe.macro.Expr;
#end

class SequenceMacros {

    /**
        Returns the numerical maximum of the Sequence.
    **/
    public static macro function max<T>(ethis:ExprOf<Sequence<T>>):ExprOf<T>
        return macro $e{ethis}.reduce((a, b) -> if (a > b) a else b);

    /**
        Returns the numerical minimum of the Sequence.
    **/
    public static macro function min<T>(ethis:ExprOf<Sequence<T>>):ExprOf<T>
        return macro $e{ethis}.reduce((a, b) -> if (a < b) a else b);

    /**
        Returns the sum of the elements in the Sequence.
    **/
    public static macro function sum<T>(ethis:ExprOf<Sequence<T>>):ExprOf<T>
        return macro $e{ethis}.reduce((a, b) -> a + b);

    /**
        Returns the product of the elements in the Sequence.
    **/
    public static macro function product<T>(ethis:ExprOf<Sequence<T>>):ExprOf<T>
        return macro $e{ethis}.reduce((a, b) -> a * b);
    
    /**
        Returns a Sequence sorted ascending numerically.
    **/
    public static macro function sortAsc<T>(ethis:ExprOf<Sequence<T>>):ExprOf<Sequence<T>>
        return macro $e{ethis}.sort((a, b) -> if (a > b) 1 else if (a < b) -1 else 0);

    /**
        Returns a Sequence sorted descending numerically.
    **/
    public static macro function sortDesc<T>(ethis:ExprOf<Sequence<T>>):ExprOf<Sequence<T>>
        return macro $e{ethis}.sort((a, b) -> if (a > b) -1 else if (a < b) 1 else 0);
    
}