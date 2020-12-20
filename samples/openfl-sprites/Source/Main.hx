package;

import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;

import peote.layout.LayoutContainer;
import peote.layout.Size;

import layouted.LayoutedSprite;

class Main extends Sprite {
	
	var layoutContainer:LayoutContainer;
	
	public function new () {
		
		super();
		
		// add some graphic elements
		var gray   = new LayoutedSprite(0x555555);
		var green  = new LayoutedSprite(0x00ff00);
		var yellow = new LayoutedSprite(0xffff00);
		var red    = new LayoutedSprite(0xff0000); red.alpha  = 0.7;
		var blue   = new LayoutedSprite(0x0000ff); blue.alpha = 0.7;
		
		
		// init layout and bind to graphic elements
		layoutContainer = new Box( gray, // without layout param it fully scales
		[	
			// only one child container inside grey box
			new Box( green,
			{
				// layout for size (width/height) and spacing (left, right, top, bottom) to outer container
				left: Size.max(100),        // "max"   scales from 0 to max-value
				width:Size.limit(300, 800), // "limit" scales from min to max-value
				right:Size.min(50),         // "min"   scales high but not lower as min-value
				// right:10                 // or can be a fixed value.. same as .limit(10,10)
				
				// for "span" they are reaching its min and max at the same time
				// while scaling in a row, but can be scaled higher as max
				top:   Size.span(50 , 100),
				height:Size.span(200, 600),
				bottom:Size.span(50 , 100),
			},
			[	
				// three child containers inside green box
				new Box( yellow,
				{	left:Size.max(10), width:Size.limit(100, 500), right:Size.max(10),
					height:Size.limit(100, 300)
				}),
				new Box( red,
				{ 	left:0, width:300,
					height:100, bottom:Size.min(100)
				}),
				new Box( blue,
				{	width:300, right:0,
					height:100, bottom:0
				}),
				
			]),	
		]);
		
		layoutContainer.init();
		layoutContainer.update(stage.stageWidth, stage.stageHeight);
		
		
		// window resize is updating outer Box of rootLayoutContainer  
		stage.addEventListener( Event.RESIZE, function(e) onWindowResize( stage.stageWidth, stage.stageHeight ) );
		
		// to simmulate resizing via moving mouse after pressing left mousebutton
		stage.addEventListener( MouseEvent.MOUSE_UP,   onMouseUp );
		stage.addEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
	}
	
	
	
	// ----------------- RESIZE EVENT ------------------------------
	
	function onWindowResize (width:Float, height:Float):Void {
		if (layoutContainer != null) layoutContainer.update(width, height);
	}
		
	// ----------------- MOUSE EVENTS ------------------------------
	
	var sizeEmulation = false;
	
	function onMouseMove (e:MouseEvent) {
		if (sizeEmulation && layoutContainer != null)
			layoutContainer.update(e.stageX, e.stageY);
	}
	
	function onMouseUp (e:MouseEvent) {
		sizeEmulation = !sizeEmulation; 
		if (sizeEmulation) onMouseMove(e);
		else if (layoutContainer != null)
			layoutContainer.update(stage.stageWidth, stage.stageHeight);
	}
	
}