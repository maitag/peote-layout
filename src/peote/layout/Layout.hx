package peote.layout;

typedef Layout =
{
	> ContainerOptions,
	
	// Size
	?width :Size,
	?height:Size,
	
	// Margins
	?left:Size,
	?right:Size,
	?top:Size,
	?bottom:Size,	
	
}