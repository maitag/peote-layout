package peote.layout;

@:enum abstract Align(Int) from Int to Int 
{
	public static inline var TOP_LEFT    :Int = 0;
	public static inline var TOP         :Int = 1;
	public static inline var TOP_RIGHT   :Int = 2;
	public static inline var LEFT        :Int = 3;
	public static inline var RIGHT       :Int = 4;
	public static inline var BOTTOM_LEFT :Int = 5;
	public static inline var BOTTOM      :Int = 6;
	public static inline var BOTTOM_RIGHT:Int = 7;
	public static inline var CENTER      :Int = 8;
	
	public static inline function hasLeft(align:Align):Bool
		return (align == LEFT || align == TOP_LEFT || align == BOTTOM_LEFT);
		
	public static inline function hasRight(align:Align):Bool
		return (align == RIGHT || align == TOP_RIGHT || align == BOTTOM_RIGHT);
		
	public static inline function hasTop(align:Align):Bool
		return (align == TOP || align == TOP_LEFT || align == TOP_RIGHT);
		
	public static inline function hasBottom(align:Align):Bool
		return (align == BOTTOM || align == BOTTOM_LEFT || align == BOTTOM_RIGHT);

}