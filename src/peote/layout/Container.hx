package peote.layout;

@:enum abstract Container(Int) from Int to Int 
{
	public static inline var BOX :Int = 0;
	public static inline var HBOX:Int = 1;
	public static inline var VBOX:Int = 2;
}