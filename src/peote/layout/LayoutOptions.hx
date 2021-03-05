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
	?scrollX:Bool,
	?scrollY:Bool,
	
	?hAlignOnOversize:HAlign, // force the aligning for all childs on horizontal oversizing
	?vAlignOnOversize:VAlign, // force the aligning for all childs on vertical oversizing
	
	?limitMinWidthToChilds:Bool,
	?limitMaxWidthToChilds:Bool,
	?limitMinHeightToChilds:Bool,
	?limitMaxHeightToChilds:Bool,
	
	?relativeChildPositions:Bool	
}
