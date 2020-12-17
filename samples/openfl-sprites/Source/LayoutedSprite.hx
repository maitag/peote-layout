package;

import openfl.Lib;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.geom.Rectangle;

import peote.layout.LayoutElement;
import peote.layout.LayoutContainer;


class LayoutedSprite extends Sprite implements LayoutElement 
{
	var color:Int;
	
	public function new(?parent:DisplayObjectContainer, color:Int) 
	{
		super();
		this.color = color;
		if (parent == null) parent = Lib.current.stage;
		parent.addChild(this); // self adding
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
	
	
	// ----------------------------------------------------------------------------
	// ----------- Interface functions for peote.layout.LayoutElement -------------
	// ----------------------------------------------------------------------------
	
	// instead of changing visible it can be also add or remove from parent displayObjectContainer
	// var lastParent:DisplayObjectContainer = null;
	
	public function showByLayout():Void {
		visible = true;
 		// to add at Stage again
		// if (parent == null && lastParent != null) {
			// lastParent.addChild(this);
		//}
	}
	
	public function hideByLayout():Void{
		visible = false;
		// to remove from Stage
		// if (parent != null) {
			// lastParent = parent;
			// parent.removeChild(this);
		//}
	}
	
	var layoutWasHidden = false;
	
	public function updateByLayout(layoutContainer:LayoutContainer) 
	{
		if (!layoutWasHidden && layoutContainer.isHidden) // if it is fully outside of the scroll-area mask
		{
			hideByLayout();
			layoutWasHidden = true;
		}
		else
		{
			x = layoutContainer.x;
			y = layoutContainer.y;
			
			drawNewRoundRect(0, 0, layoutContainer.width, layoutContainer.height); // todo: optimize (draw only again if size is changing!) 
			
			if (layoutContainer.isMasked) // if some of the edges is cut by mask for scroll-area
			{
				x += layoutContainer.maskX;
				y += layoutContainer.maskY;
				
				// todo: optimize (set only changed mask parameters!)
				scrollRect = new Rectangle(
					layoutContainer.maskX,
					layoutContainer.maskY,
					layoutContainer.maskWidth,
					layoutContainer.maskHeight
				);
			}
			else scrollRect = null;
			
			if (layoutWasHidden) {
				showByLayout();
				layoutWasHidden = false;
			} 
		}
		
	}
	
}