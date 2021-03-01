package peote.layout;

typedef ContainerOptions =
{
	?scrollX:Bool,
	?scrollY:Bool,
	
	?alignOnOversize:Align, // force the aligning for all childs on oversizing
	
	?limitMinWidthToChilds:Bool,
	?limitMaxWidthToChilds:Bool,
	?limitMinHeightToChilds:Bool,
	?limitMaxHeightToChilds:Bool,
	
	?relativeChildPositions:Bool
}