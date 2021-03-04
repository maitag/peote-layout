package peote.layout;

@:enum abstract HAlign(Int) from Int to Int 
{
	public static inline var LEFT  :Int = 0;
	public static inline var RIGHT :Int = 1;
	public static inline var CENTER:Int = 2;
	public static inline var AUTO  :Int = 3;
}