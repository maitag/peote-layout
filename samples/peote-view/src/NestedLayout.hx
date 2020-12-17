package;

import lime.ui.MouseButton;
import lime.app.Application;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Color;

import peote.layout.LayoutContainer;
import peote.layout.ContainerType;
import peote.layout.Size;

import layouted.LayoutedSprite;
import layouted.LayoutedDisplay;

class NestedLayout extends lime.app.Application
{
	var peoteView:PeoteView;
	var display:LayoutedDisplay;
	
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
	var rootLayoutContainer:LayoutContainer;
	
	public function initPeoteView(window:lime.ui.Window)
	{
		peoteView = new PeoteView(window.context, window.width, window.height);

		display = new LayoutedDisplay(Color.GREY1);	
		peoteView.addDisplay(display);

				
		var sameLimit = Size.limit(80, 150);
		
		// init a complex layout
		var displayLC = new Box( display,
		[	// childs -----------------------------------------
			new HBox( new LayoutedSprite(display, Color.GREEN),
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
					new Box( new LayoutedSprite(display, Color.RED), 
					{	left:   Size.span(10),
						width:  Size.limit(100, 200),
						height: sameLimit,
						bottom: 10,
					}),
					new Box( new LayoutedSprite(display, Color.RED), 
					{	left:   Size.span(10),
						width:  Size.span(100, 200),
						height: Size.limit(160, 300),
					}),
				]),
				new VBox( new LayoutedSprite(display, Color.BLUE),
				{	left:  Size.span(0, 0.2),
					width: Size.span(100),
					right: Size.span(10, 0.3),
				},
				[	// childs -----------------------------------------
					new Box( new LayoutedSprite(display, Color.YELLOW), 
					{	left:   Size.span(10, 0.5 ),
						width:  Size.span(180),
						height: Size.span(200,  1.9),
						top:    Size.span(10,  0.1),
					},
					[	// childs -----------------------------------------
						new VBox( new LayoutedSprite(display, Color.MAGENTA),
						{	width:  Size.limit(100, 250),
							height: Size.max(400),
						},
						[	// childs -----------------------------------------
							new Box( new LayoutedSprite(display, Color.GREY6),
							{	width:sameLimit,
								height:sameLimit,
								top:20,
							}),
							new Box( new LayoutedSprite(display, Color.GREY4),
							{	width:  sameLimit,
								height: Size.span(80, 100),
								top:    10,
								bottom: 20,
							}),
						]),
					]),
					new Box( new LayoutedSprite(display, Color.CYAN), 
					{	left:   Size.span(10, 1.5 ),
						width:  Size.span(100),
						height: Size.span(50,  0.5),
						top:    Size.span(10,  0.1),
					}),					
				]),
			])
		]);
		
		displayLC.init();
		
		displayLC.update(peoteView.width, peoteView.height);
		
		rootLayoutContainer = displayLC;
		
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
		if (rootLayoutContainer != null) rootLayoutContainer.update(width, height);
	}

	// ----------------- MOUSE EVENTS ------------------------------
	var sizeEmulation = false;
	
	public override function onMouseMove (x:Float, y:Float) {
		if (sizeEmulation && rootLayoutContainer != null) {
			rootLayoutContainer.update(x, y);
		}
	}
	//public override function onMouseDown (x:Float, y:Float, button:MouseButton) {};
	public override function onMouseUp (x:Float, y:Float, button:MouseButton) {
		sizeEmulation = !sizeEmulation; 
		if (sizeEmulation) onMouseMove(x, y);
		else {
			rootLayoutContainer.update(peoteView.width, peoteView.height);
		}
	}
	// public override function onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:lime.ui.MouseWheelMode):Void {}
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
