package peote.layout;

typedef LayoutOptions =
{
	#if peotelayout_debug
	?name:String,
	#end
	
	// inner size
	?width :Size,
	?height:Size,
	
	// outer margins
	?left:Size,
	?right:Size,
	?top:Size,
	?bottom:Size,
	
	// container options
	?scrollX:Bool, // false by default
	?scrollY:Bool, // false by default
	
	?hAlignOnOversize:HAlign, // force the aligning for all childs on horizontal oversizing
	?vAlignOnOversize:VAlign, // force the aligning for all childs on vertical oversizing
	
	?limitMinWidthToChilds:Bool, // true by default
	?limitMaxWidthToChilds:Bool, // false by default
	?limitMinHeightToChilds:Bool, // true by default
	?limitMaxHeightToChilds:Bool, // false by default
	
	?relativeChildPositions:Bool // false by default	
}
