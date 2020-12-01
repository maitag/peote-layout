package peote.layout;

interface LayoutElement 
{
	public function update(posSize:Bounds, mask:Bounds, z:Int):Void;
}