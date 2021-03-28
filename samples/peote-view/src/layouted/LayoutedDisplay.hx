package layouted;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Program;
import peote.view.Buffer;
import peote.view.Color;

import peote.layout.LayoutElement;

class LayoutedDisplay extends Display implements LayoutElement
{

	public var buffer:Buffer<LayoutedSprite>;
	public var program:Program;

	public function new(color:Color=0x00000000) 
	{
		super(0, 0, 0, 0, color);		
		buffer = new Buffer<LayoutedSprite>(16,8);
		program = new Program(buffer);
		LayoutedSprite.initProgram(program);
		addProgram(program);
	}
	
	// ---------------------------------------- show, hide and interface to peote-layout
	var lastPeoteView:PeoteView = null;
	
	public function show():Void {
		if (peoteView == null && lastPeoteView != null) {
			lastPeoteView.addDisplay(this);
		} 
	}
	
	public function hide():Void{
		if (peoteView != null) {
			lastPeoteView = peoteView;
			peoteView.removeDisplay(this);
		}		
	}
	
	// ------------------------------------------------------------------------------------
	
	// bindings to peote-layout
	
	public function showByLayout():Void show();
	public function hideByLayout():Void hide();
	
	var layoutWasHidden = false;
	public function updateByLayout(layoutContainer:peote.layout.LayoutContainer) 
	{
		
		if (!layoutWasHidden && layoutContainer.isHidden) { // if it is full outside of the Mask (so invisible)
			hideByLayout();
			layoutWasHidden = true;
		}
		else {
			x = Math.round(layoutContainer.x);
			y = Math.round(layoutContainer.y);
			width = Math.round(layoutContainer.width);
			height = Math.round(layoutContainer.height);
			
			if (layoutContainer.isMasked) { // if some of the edges is cut by mask for scroll-area
				x += Math.round(layoutContainer.maskX);
				y += Math.round(layoutContainer.maskY);
				width = Math.round(layoutContainer.maskWidth);
				height = Math.round(layoutContainer.maskHeight);
			}
			
			if (layoutWasHidden) {
				showByLayout();
				layoutWasHidden = false;
			}

		}
	}	
	
}