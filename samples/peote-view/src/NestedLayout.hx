package;

import lime.ui.MouseButton;
import lime.app.Application;
import peote.layout.Align;

import peote.view.PeoteView;
import peote.view.Color;

import peote.layout.LayoutContainer;
import peote.layout.Size;

import layouted.LayoutedSprite;
import layouted.LayoutedDisplay;

class NestedLayout extends lime.app.Application
{
	var peoteView:PeoteView;
	
	public function new() super();
	
	public override function onWindowCreate():Void
	{
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES: initPeoteView(window); // start sample
			default: throw("Sorry, only works with OpenGL.");
		}
	}
		
	// ------------------------------------------------------------
	// --------------- SAMPLE STARTS HERE -------------------------
	// ------------------------------------------------------------	
	var layoutContainer:LayoutContainer;
	
	public function initPeoteView(window:lime.ui.Window)
	{
		peoteView = new PeoteView(window.context, window.width, window.height);

		var display:LayoutedDisplay = new LayoutedDisplay(Color.GREY4);	
		var yellowDisplay:LayoutedDisplay = new LayoutedDisplay(Color.YELLOW);	
		peoteView.addDisplay(display);
		peoteView.addDisplay(yellowDisplay);

		var sameLimit = Size.limit(80, 150);
		
		// init a complex layout
		
		layoutContainer = new Box( display,
		{
			left:  Size.span(0.05),
			right: Size.span(0.05),
			top:  	20,
			bottom:	20,
			relativeChildPositions:true // the childs (LayoutedSprite) need to positionize relative to the display
		},
		[	// childs -----------------------------------------
			new HBox( new LayoutedSprite(display, Color.GREEN),
			{
				left:  	Size.min(10),
				width: 	Size.limit(100, 1900),
				right: 	Size.max(50),
				top:   	10,
				bottom:	10,
				limitMinWidthToChilds: false, // let is oversize horizontally
				alignChildsOnOversizeX:Align.FIRST,
			},
			[	// childs -----------------------------------------
				new VBox( new LayoutedSprite(display, Color.BLUE),
				{					
					left:  Size.span(0, 0.1),
					width: Size.span(10),
					right: Size.span(10, 0.1),
					limitMinHeightToChilds: false, // let is oversize vertically
				},
				[	// childs -----------------------------------------
					new Box( new LayoutedSprite(display, Color.RED), 
					{	left:   Size.span(10),
						width:  Size.limit(100, 200),
						height: Size.limit(120, 200),
						bottom: 10,
					}),
					new Box( new LayoutedSprite(display, Color.RED), 
					{	left:   Size.span(10),
						width:  Size.span(100, 200),
						height: Size.limit(150, 200),
						bottom: 10,
					}),
					new Box( new LayoutedSprite(display, Color.RED), 
					{	left:   Size.span(10),
						width:  Size.span(100, 200),
						height: Size.limit(180, 200),
					}),
				]),
				
				new VBox( new LayoutedSprite(display, Color.BLUE),
				{
					left:  Size.span(0, 0.2),
					width: Size.span(100),
					right: Size.span(10, 0.3),
				},
				[	// childs -----------------------------------------
				
					// another display inside
					new Box( yellowDisplay, 
					{	left:   Size.span(10, 0.5 ),
						width:  Size.span(180),
						height: Size.span(200,  1.9),
						top:    Size.span(10,  0.1),
						absolutePosition:true, // displays allways using absolute positioning
						relativeChildPositions:true // ... but not its child-elements
					}
					,
					[	// childs -----------------------------------------
						new VBox( new LayoutedSprite(yellowDisplay, Color.MAGENTA),
						{	width:  Size.limit(100, 250),
							height: Size.max(400),
						},
						[	// childs -----------------------------------------
							new Box( new LayoutedSprite(yellowDisplay, Color.GREY6),
							{	width:sameLimit,
								height:sameLimit,
								top:20,
							}),
							new Box( new LayoutedSprite(yellowDisplay, Color.GREY4),
							{	width:  sameLimit,
								height: Size.span(80, 100),
								top:    10,
								bottom: 20,
							}),
						]),
					]),
					// ---------------
					
					new Box( new LayoutedSprite(display, Color.CYAN),
					{
						left:   Size.span(10, 1.5 ),
						width:  Size.span(100),
						height: Size.span(50,  0.5),
						top:    Size.span(10,  0.1),
					}),					
				]),				
			])
		]);		
				
		layoutContainer.init();
		
		layoutContainer.update(peoteView.width, peoteView.height);
		
	}
	
	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	

	public override function onPreloadComplete():Void {
		// access embeded assets here
	}

	public override function update(deltaTime:Int):Void {
		// for game-logic update
	}

	public override function render(context:lime.graphics.RenderContext):Void
	{
		peoteView.render(); // rendering all Displays -> Programs - Buffer
	}
	
	public override function onWindowResize (width:Int, height:Int):Void
	{
		peoteView.resize(width, height);
		if (layoutContainer != null) layoutContainer.update(width, height);
	}

	// ----------------- MOUSE EVENTS ------------------------------
	var sizeEmulation = false;
	
	public override function onMouseMove (x:Float, y:Float) {
		if (sizeEmulation && layoutContainer != null) {
			layoutContainer.update(x, y);
		}
	}
	//public override function onMouseDown (x:Float, y:Float, button:MouseButton) {};
	public override function onMouseUp (x:Float, y:Float, button:MouseButton) {
		sizeEmulation = !sizeEmulation; 
		if (sizeEmulation) onMouseMove(x, y);
		else {
			layoutContainer.update(peoteView.width, peoteView.height);
		}
	}
	public override function onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:lime.ui.MouseWheelMode):Void {
		if (deltaY != 0) {
			//layoutContainer.getChild[0].yScroll += 10 * deltaY;
			//trace(layoutContainer.getChild[0].yScrollMax); // only get: same as innerHeight - height
			//trace(layoutContainer.getChild[0].innerHeight);
		}
	}
	// public override function onMouseMoveRelative (x:Float, y:Float):Void {}

	// ----------------- TOUCH EVENTS ------------------------------
	// public override function onTouchStart (touch:lime.ui.Touch):Void {}
	// public override function onTouchMove (touch:lime.ui.Touch):Void	{}
	// public override function onTouchEnd (touch:lime.ui.Touch):Void {}
	
	// ----------------- KEYBOARD EVENTS ---------------------------
	// public override function onKeyDown (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {}	
	// public override function onKeyUp (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {}

	// -------------- other WINDOWS EVENTS ----------------------------
	// public override function onWindowLeave():Void { trace("onWindowLeave"); }
	// public override function onWindowActivate():Void { trace("onWindowActivate"); }
	// public override function onWindowClose():Void { trace("onWindowClose"); }
	// public override function onWindowDeactivate():Void { trace("onWindowDeactivate"); }
	// public override function onWindowDropFile(file:String):Void { trace("onWindowDropFile"); }
	// public override function onWindowEnter():Void { trace("onWindowEnter"); }
	// public override function onWindowExpose():Void { trace("onWindowExpose"); }
	// public override function onWindowFocusIn():Void { trace("onWindowFocusIn"); }
	// public override function onWindowFocusOut():Void { trace("onWindowFocusOut"); }
	// public override function onWindowFullscreen():Void { trace("onWindowFullscreen"); }
	// public override function onWindowMove(x:Float, y:Float):Void { trace("onWindowMove"); }
	// public override function onWindowMinimize():Void { trace("onWindowMinimize"); }
	// public override function onWindowRestore():Void { trace("onWindowRestore"); }
	
	// public override function onRenderContextLost ():Void trace(" --- WARNING: LOST RENDERCONTEXT --- ");		
	// public override function onRenderContextRestored (context:lime.graphics.RenderContext):Void trace(" --- onRenderContextRestored --- ");		

}
