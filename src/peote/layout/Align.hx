package peote.layout;

@:enum abstract Align(Int) from Int to Int 
{
	public static inline var FIRST :Int = 0;
	public static inline var LAST  :Int = 1;
	public static inline var CENTER:Int = 2;
	public static inline var AUTO  :Int = 3;
}