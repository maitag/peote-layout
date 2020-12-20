package peote.layout;

@:enum abstract Scroll(Int) from Int to Int 
{
	public static inline var NONE      :Int = 0;
	public static inline var HORIZONTAL:Int = 1;
	public static inline var VERTICAL  :Int = 2;
	public static inline var FULL      :Int = 3;
	
	public static inline function hasHorizontal(scroll:Scroll):Bool
		return (scroll == HORIZONTAL || scroll == FULL);
		
	public static inline function hasVertical(scroll:Scroll):Bool
		return (scroll == VERTICAL || scroll == FULL);

}