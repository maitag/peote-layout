package;

import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;

import peote.layout.LayoutContainer;
import peote.layout.ContainerType;
import peote.layout.Size;

class Main extends Sprite {
	
	var rootLayoutContainer:LayoutContainer;
	var display:Sprite;
	
	public function new () {
		
		super ();

		// background
		display = new Sprite();
		display.graphics.beginFill(0x333333);
		display.graphics.drawRect(0, 0, Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
		display.graphics.endFill();
		Lib.current.stage.addChild(display);

		
		// add some graphic elements
		var green = new LayoutedSprite(0x00ff00);
		var red = new LayoutedSprite(0xff0000);
		var blue = new LayoutedSprite(0x0000ff);
		var yellow = new LayoutedSprite(0xffff00);
				
		
		// init a layout
		var greenLC = new LayoutContainer(ContainerType.BOX, green,
			{
				left: Size.min(100), // can be scale high but not lower as min-value
				width:Size.limit(300, 400), // can be scale from min to max-value
				right:Size.max(200), // can be scale from 0 to max-value
				// right:10 // or can be a fixed value.. same as .limit(10,10)
				
				// for "span" they are reaching its min and max at the same time while scaling
				// in a row, but can be scaled higher as max
				top:   Size.span(50, 100),
				height:Size.span(200, 400),
				bottom:Size.span(50, 100),
			},
			// childs
			[
				// Box is shortcut for LayoutContainer(ContainerType.BOX, ...)
				new Box(red,    {left:0, width:300, height:100, bottom:Size.min(100)} ),
				new Box(blue,   {right:0, width:300, height:100, bottom:0} ),
				new Box(yellow, {width:100, height:Size.limit(100, 300)} )
			]
		);
		
		greenLC.init();
		greenLC.update(Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
		
		//greenLC.hide();
		//greenLC.showt();
		
		rootLayoutContainer = greenLC;
		
		Lib.current.stage.addEventListener( Event.RESIZE, function(e) onWindowResize( Lib.current.stage.stageWidth, Lib.current.stage.stageHeight ) );
		Lib.current.stage.addEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
		Lib.current.stage.addEventListener( MouseEvent.MOUSE_UP,   onMouseUp );
	}
	
	function onWindowResize (width:Float, height:Float):Void
	{
		display.width = width;
		display.height = height;
		if (rootLayoutContainer != null) rootLayoutContainer.update(width, height);
	}
	
	// ----------------- MOUSE EVENTS ------------------------------
	var sizeEmulation = false;
	
	function onMouseMove (e:MouseEvent) {
		if (sizeEmulation && rootLayoutContainer != null) {
			display.width = e.stageX;
			display.height = e.stageY;
			rootLayoutContainer.update(e.stageX, e.stageY);
		}
	}
	
	function onMouseUp (e:MouseEvent) {
		sizeEmulation = !sizeEmulation; 
		if (sizeEmulation) {
			onMouseMove(e);
		}
		else {
			display.width = Lib.current.stage.stageWidth;
			display.height = Lib.current.stage.stageHeight;
			if (rootLayoutContainer != null) rootLayoutContainer.update(Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
		}
	}
	
}