package peote.layout;

interface LayoutElement 
{
	public function updateByLayout(posSize:Bounds, mask:Bounds, z:Int):Void;
}