package;

import openfl.Lib;
import openfl.display.Sprite;
import openfl.geom.Rectangle;

import peote.layout.LayoutElement;
import peote.layout.LayoutContainer;


class LayoutedSprite extends Sprite implements LayoutElement 
{
	var color:Int;
	
	public function new(color:Int) 
	{
		super();
		
		this.color = color;
		Lib.current.stage.addChild(this); // self adding to stage
	}
	
	public function drawNewRoundRect (x:Float, y:Float, w:Float, h:Float)
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
	
	
	/* INTERFACE peote.layout.LayoutElement */
	
	var isHidden = false;	
	
	public function updateByLayout(layoutContainer:LayoutContainer) 
	{
		if (layoutContainer.isHidden) // if it is fully outside of the scroll-area mask
		{
			if (!isHidden) {
				Lib.current.stage.removeChild(this);
				isHidden = true;
			}
		}
		else 
		{
			if (layoutContainer.isMasked) // if its partly inside of mask for scroll-area
			{
				//scrollRect = new Rectangle(
				//	layoutContainer.maskX,
				//	layoutContainer.maskY,
				//	layoutContainer.maskWidth,
				//	layoutContainer.maskHeight
				//);
			}
			else scrollRect = null;
			
			x = layoutContainer.x;
			y = layoutContainer.y;
			
			drawNewRoundRect(0, 0, layoutContainer.width, layoutContainer.height);
			
			if (isHidden) {
				Lib.current.stage.addChild(this);
				isHidden = false;
			} 
		}
		
	}
	
}