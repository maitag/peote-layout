package;

import lime.ui.MouseButton;
import lime.app.Application;

import peote.view.PeoteView;
import peote.view.Color;

import peote.layout.LayoutContainer;
import peote.layout.Size;

import layouted.LayoutedSprite;
import layouted.LayoutedDisplay;

class SizingAligning extends lime.app.Application
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
	var layoutContainer:LayoutContainer;
	
	public function initPeoteView(window:lime.ui.Window)
	{
		peoteView = new PeoteView(window.context, window.width, window.height);

		display = new LayoutedDisplay(Color.GREY1);	
		peoteView.addDisplay(display);

		
		// Sizing and Aligning in row-containers
		
		layoutContainer = new VBox( display, {height:Size.min(300)},
		[	
			// ----------- aligning ------------------------------
			
			new HBox( new LayoutedSprite(display, Color.RED), // auto spacing because all Sizes are constant
			[	
				new Box( new LayoutedSprite(display, Color.GREY3), {         width:100} ),					
				new Box( new LayoutedSprite(display, Color.GREY4), {left:10, width:100} ),					
				new Box( new LayoutedSprite(display, Color.GREY5), {left:10, width:100} ),					
			]),
			new HBox( new LayoutedSprite(display, Color.GREEN), // left aligned because there is no last right-spacer
			[	
				new Box( new LayoutedSprite(display, Color.GREY3), {left:0,  width:100} ),					
				new Box( new LayoutedSprite(display, Color.GREY4), {left:10, width:100} ),					
				new Box( new LayoutedSprite(display, Color.GREY5), {left:10, width:100} ),					
			]),
			new HBox( new LayoutedSprite(display, Color.BLUE), // right aligned because the first left spacer have no max size
			[	
				new Box( new LayoutedSprite(display, Color.GREY3), {left:Size.min(), width:100} ),
				new Box( new LayoutedSprite(display, Color.GREY4), {left:10, width:100} ),		
				new Box( new LayoutedSprite(display, Color.GREY5), {left:10, width:100} ),
			]),
			new HBox( new LayoutedSprite(display, Color.YELLOW), // left aligned until the last reaching max value
			[	
				new Box( new LayoutedSprite(display, Color.GREY3), {         width:100} ),
				new Box( new LayoutedSprite(display, Color.GREY4), {left:10, width:100} ),
				new Box( new LayoutedSprite(display, Color.GREY5), {left:10, width:100, right:Size.max(400)} ),
			]),
			
			
			// -------------- limits, min and max Sizes --------------
			
			new HBox( new LayoutedSprite(display, Color.RED), {top:14}, // the first and the last spans because no width-definitions
			[	
				new Box( new LayoutedSprite(display, Color.GREY3) ),
				new Box( new LayoutedSprite(display, Color.GREY4), {left:10, width:200} ),
				new Box( new LayoutedSprite(display, Color.GREY5), {left:10} ),
			]),
			new HBox( new LayoutedSprite(display, Color.GREEN), // auto spacing if reaching max-values
			[	
				new Box( new LayoutedSprite(display, Color.GREY3), {         width:Size.max(200)} ),
				new Box( new LayoutedSprite(display, Color.GREY4), {left:10, width:Size.max(200)} ),
				new Box( new LayoutedSprite(display, Color.GREY5), {left:10, width:Size.max(200)} ),
			]),
			new HBox( new LayoutedSprite(display, Color.BLUE), // the inner spacing is span because the "left" only have a min-size
			[	
				new Box( new LayoutedSprite(display, Color.GREY3), {                   width:Size.max(200)} ),
				new Box( new LayoutedSprite(display, Color.GREY4), {left:Size.min(10), width:Size.limit(100,200)} ),
				new Box( new LayoutedSprite(display, Color.GREY5), {left:Size.min(10), width:Size.max(200)} ),
			]),
			new HBox( new LayoutedSprite(display, Color.YELLOW), // only limited sizes
			[	
				new Box( new LayoutedSprite(display, Color.GREY3), {width:Size.limit(50,  250)} ),
				new Box( new LayoutedSprite(display, Color.GREY4), {width:Size.limit(100, 250)} ),
				new Box( new LayoutedSprite(display, Color.GREY5), {width:Size.limit(200, 250)} ),
			]),
			new HBox( new LayoutedSprite(display, Color.MAGENTA), // mixing min, max and limit
			[	
				new Box( new LayoutedSprite(display, Color.GREY3), {left:Size.max(10),      width:Size.min(100)} ),
				new Box( new LayoutedSprite(display, Color.GREY4), {left:Size.limit(10,40), width:Size.min(100)} ),
				new Box( new LayoutedSprite(display, Color.GREY5), {left:Size.limit(10,40), width:Size.limit(100,200), right:Size.max(10)} ),
			]),
			
			
			// -------------------- span with relative values --------------------
			
			new HBox( new LayoutedSprite(display, Color.RED), {top:14},
			[	
				new Box( new LayoutedSprite(display, Color.GREY3), {width:Size.span(50,  250)} ),
				new Box( new LayoutedSprite(display, Color.GREY4), {width:Size.span(100, 250)} ),
				new Box( new LayoutedSprite(display, Color.GREY5), {width:Size.span(200, 250)} ),
			]),
			new HBox( new LayoutedSprite(display, Color.GREEN),
			[	
				new Box( new LayoutedSprite(display, Color.GREY3), {width:Size.span(50,  100)} ),
				new Box( new LayoutedSprite(display, Color.GREY4), {width:Size.span(100, 200)} ),
				new Box( new LayoutedSprite(display, Color.GREY5), {width:Size.span(200, 400)} ),
			]),
			new HBox( new LayoutedSprite(display, Color.BLUE), // span with weightning
			[	
				new Box( new LayoutedSprite(display, Color.GREY3), {width:Size.span(0.5)} ),
				new Box( new LayoutedSprite(display, Color.GREY4), {width:Size.span(1.0)} ),
				new Box( new LayoutedSprite(display, Color.GREY5), {width:Size.span(2.0)} ),
			]),
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
			//layoutContainer.firstChild.xScroll += 10 * deltaY;
			//trace(layoutContainer.firstChild.xScrollMax); // only get: same as innerHeight - height
			//trace(layoutContainer.firstChild.innerHeight);
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
