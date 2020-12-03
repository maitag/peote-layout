package ;

import openfl.Lib;
import openfl.display.Sprite;
import openfl.geom.Rectangle;

import peote.layout.Bounds;
import peote.layout.LayoutElement;


class LayoutedSprite extends Sprite implements LayoutElement 
{
	var color:Int;
	
	public function new(color:Int) 
	{
		super();
		
		this.color = color;
				
		// self adding to stage
		Lib.current.stage.addChild(this);
	}
	
	public function drawRoundRect (x:Float, y:Float, w:Float, h:Float)
	{
		var radius:Float = 20;
		var lineColor:UInt = 0x550000;
		var lineThickness:Float = 5;
		
		graphics.clear();
		
		graphics.lineStyle(0,0,0);
		graphics.beginFill(lineColor, 1);
		graphics.drawRoundRect(x, y, w, h, 2*radius, 2*radius);
		graphics.drawRoundRect(x+lineThickness, y+lineThickness, w-2*lineThickness, h-2*lineThickness, 2*radius-2*lineThickness, 2*radius-2*lineThickness);
		graphics.endFill();

		graphics.beginFill(color, 1);
		graphics.drawRoundRect(x+lineThickness, y+lineThickness, w-2*lineThickness, h-2*lineThickness, 2*radius-2*lineThickness, 2*radius-2*lineThickness);
		graphics.endFill();
	}	
	
	
	var insideMask = false;
	
	/* INTERFACE peote.layout.LayoutElement */
	public function updateByLayout(posSize:Bounds, mask:Bounds, z:Int) {
		if (mask != null) {
			
			if (insideMask && isOutsideMask(posSize, mask)) {
				Lib.current.stage.removeChild(this);
				insideMask = false;
			}
			else {
				x = posSize.left;
				y = posSize.top;
				
				var w = posSize.right - x;
				var h = posSize.bottom - y;
				
				var maskLeft = (x > mask.left) ? 0 : mask.left - x;
				var maskTop = (y > mask.top) ? 0 : mask.top - y;
				var maskRight = (posSize.right < mask.right) ? w : w - (posSize.right - mask.right);
				var maskBottom = (posSize.bottom < mask.bottom) ? h : h - (posSize.bottom - mask.bottom);
				
				scrollRect = new Rectangle(maskLeft, maskTop, maskRight, maskBottom);
				drawRoundRect(0, 0, w, h);
				
				if (!insideMask) {
					Lib.current.stage.addChild(this);
					insideMask = true;
				} 
			}
			
		} 
		else {
			x = posSize.left;
			y = posSize.top;
			var w = posSize.right - x;
			var h = posSize.bottom - y;
			
			scrollRect = null;
			drawRoundRect(0,0,w,h);
			
			if (!insideMask) {
				Lib.current.stage.addChild(this);
				insideMask = true;
			} 
		}
		
	}
	
	public inline function isOutsideMask(posSize:Bounds, mask:Bounds) {
		if (posSize.bottom < mask.top) return true;
		if (posSize.top > mask.bottom) return true;
		if (posSize.right < mask.left) return true;
		if (posSize.left > mask.right) return true;
		
		return false;
	}	
}