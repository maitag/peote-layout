package ;

import openfl.display.Stage;
import openfl.display.Sprite;

import peote.layout.Bounds;
import peote.layout.LayoutElement;


class SelfSprite extends Sprite implements LayoutElement 
{
	public function new(color:Int) 
	{
		super();
		
		graphics.beginFill(0xff0000);
		graphics.drawRect(0, 0, 100, 100);
		
		// self adding to stage ~(^_^)~ not possible`?
		stage.addChild(this);
	}
	
	
	/* INTERFACE peote.layout.LayoutElement */
	
	public function update(posSize:Bounds, mask:Bounds, z:Int) {
/*		if (mask != null) {
			
			if (insideMask && isOutsideMask(posSize, mask)) {
				buffer.removeElement(this);
				insideMask = false;
			}
			else {
				x = posSize.left;
				y = posSize.top;
				w = posSize.right - x;
				h = posSize.bottom - y;
				maskLeft = (x > mask.left) ? 0 : mask.left - x;
				maskTop = (y > mask.top) ? 0 : mask.top - y;
				maskRight = (posSize.right < mask.right) ? w : w - (posSize.right - mask.right);
				maskBottom = (posSize.bottom < mask.bottom) ? h : h - (posSize.bottom - mask.bottom);
				
				if (!insideMask) {
					buffer.addElement(this);
					insideMask = true;
				} 
				else buffer.updateElement(this);
			}
			
		} 
		else {
			x = posSize.left;
			y = posSize.top;
			w = posSize.right - x;
			h = posSize.bottom - y;
			maskLeft = 0;
			maskTop = 0;
			maskRight = w;
			maskBottom = h;
			
			if (!insideMask) {
				buffer.addElement(this);
				insideMask = true;
			} 
			else buffer.updateElement(this);
		}
*/		
	}
	
	public inline function isOutsideMask(posSize:Bounds, mask:Bounds) {
		if (posSize.bottom < mask.top) return true;
		if (posSize.top > mask.bottom) return true;
		if (posSize.right < mask.left) return true;
		if (posSize.left > mask.right) return true;
		
		return false;
	}	
}