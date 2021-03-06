package peote.layout;
import peote.layout.LayoutContainer;

interface ILayoutElement 
{
	public function updateByLayout(layoutContainer:LayoutContainer):Void;
	public function showByLayout():Void;
	public function hideByLayout():Void;
}