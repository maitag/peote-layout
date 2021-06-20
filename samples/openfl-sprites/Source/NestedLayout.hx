package;

import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;

import peote.layout.LayoutContainer;
import peote.layout.Size;

import LayoutableSprite;

class NestedLayout extends Sprite {
	
	var layoutContainer:LayoutContainer;
	
	public function new () {
		
		super();
		
		
		var sameLimit = Size.limit(80, 150);
		
		// init a complex layout
		layoutContainer = new Box( // no binding here !
		[	// childs -----------------------------------------
			new HBox( new LayoutableSprite(0x00ff00), // green
			{	left:  	Size.min(10),
				width: 	Size.limit(100, 1900),
				right: 	Size.max(50),
				top:   	10,
				bottom:	10,
			},
			[	// childs -----------------------------------------
				new VBox( // no binding here !
				{	left:  Size.span(0, 0.1),
					width: Size.span(10),
					right: Size.span(10, 0.1),
				},
				[	// childs -----------------------------------------
					new Box( new LayoutableSprite(0xff0000), // red
					{	left:   Size.span(10),
						width:  Size.limit(100, 200),
						height: sameLimit,
						bottom: 10,
					}),
					new Box( new LayoutableSprite(0xff0000), // red
					{	left:   Size.span(10),
						width:  Size.span(100, 200),
						height: Size.limit(160, 300),
					}),
				]),
				new VBox( new LayoutableSprite(0x0000ff), // blue
				{	left:  Size.span(0, 0.2),
					width: Size.span(100),
					right: Size.span(10, 0.3),
				},
				[	// childs -----------------------------------------
					new Box( new LayoutableSprite(0xffff00), // yellow
					{	left:   Size.span(10, 0.5 ),
						width:  Size.span(180),
						height: Size.span(200,  1.9),
						top:    Size.span(10,  0.1),
					},
					[	// childs -----------------------------------------
						new VBox( new LayoutableSprite(0xff00ff), // magenta
						{	width:  Size.limit(100, 250),
							height: Size.max(400),
						},
						[	// childs -----------------------------------------
							new Box( new LayoutableSprite(0x777777), // grey light
							{	width:sameLimit,
								height:sameLimit,
								top:20,
							}),
							new Box( new LayoutableSprite(0x444444), // grey dark
							{	width:  sameLimit,
								height: Size.span(80, 100),
								top:    10,
								bottom: 20,
							}),
						]),
					]),
					new Box( new LayoutableSprite(0x00ffff), // cyan
					{	left:   Size.span(10, 1.5 ),
						width:  Size.span(100),
						height: Size.span(50,  0.5),
						top:    Size.span(10,  0.1),
					}),					
				]),
			])
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