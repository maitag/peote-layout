package peote.layout;

@:enum abstract Align(Int) from Int to Int 
{
	public static inline var AUTO  :Int = 0; // do not change numbers here because of autospace
	public static inline var FIRST :Int = 1;
	public static inline var LAST  :Int = 2;
	public static inline var CENTER:Int = 3;
}