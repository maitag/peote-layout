package peote.layout;

@:enum abstract ContainerType(Int) from Int to Int 
{
	public static inline var BOX :Int = 0;
	public static inline var HBOX:Int = 1;
	public static inline var VBOX:Int = 2;
	//public static inline var GRID:Int = 3;
}