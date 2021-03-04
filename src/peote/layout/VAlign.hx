package peote.layout;

@:enum abstract VAlign(Int) from Int to Int 
{
	public static inline var TOP   :Int = 0;
	public static inline var BOTTOM:Int = 1;
	public static inline var CENTER:Int = 2;
	public static inline var AUTO  :Int = 3;
}