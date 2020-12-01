package;

import lime.ui.MouseButton;
import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Color;

import peote.layout.LayoutContainer;
import peote.layout.ContainerType;
import peote.layout.Size;


class Main extends lime.app.Application
{
	var peoteView:PeoteView;
	var display:Display;
	
	public function new() super();
	
	public override function onWindowCreate():Void
	{
		// to get sure into rendercontext
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES: 
				initPeoteView(window); // start sample
			default:
				throw("Sorry, only works with OpenGL.");
		}
	}
		
	// ------------------------------------------------------------
	// --------------- SAMPLE STARTS HERE -------------------------
	// ------------------------------------------------------------	
	var rootLayoutContainer:LayoutContainer;
	
	public function initPeoteView(window:lime.ui.Window)
	{
		peoteView = new PeoteView(window.context, window.width, window.height);

		display = new Display(0, 0, window.width, window.height, Color.GREY1);	
		peoteView.addDisplay(display);

		Sprite.init(display);
		
		// add element to Buffer
		var green = new Sprite(Color.GREEN);
		var red = new Sprite(Color.RED);
		var blue = new Sprite(Color.BLUE);
		var yellow = new Sprite(Color.YELLOW);
				
		var greenHBox = new LayoutContainer(ContainerType.BOX, green, {
			left: Size.min(100),
			width:Size.limit(300, 400), // TODO: constraints-strength anpassen
			right:Size.max(200),
			//top:Size.const(100),
			top:Size.limit(100, 200),
			height:Size.span(100,250),
			bottom:Size.limit(100, 300),
			//bottom:100
		});
		// shortcut:
		//var greenHBox = HBox(green, {width:300, height:200} );
		
		greenHBox.init();
		greenHBox.update(peoteView.width, peoteView.height);
		
		rootLayoutContainer = greenHBox;
		
		
		// TODO: show/hide all layoutElements
		// greenHBox.hide();
		// greenHBox.show();
		
		// greenHBox.layout.height = 100;
		// greenHBox.layout.bottom = 200;
		
	

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
		display.width = width;
		display.height = height;
		if (rootLayoutContainer != null) rootLayoutContainer.update(width, height);
	}

	// ----------------- MOUSE EVENTS ------------------------------
	var sizeEmulation = false;
	
	public override function onMouseMove (x:Float, y:Float) {
		if (sizeEmulation && rootLayoutContainer != null) {
			display.width = Std.int(x);
			display.height = Std.int(y);
			rootLayoutContainer.update(Std.int(x),Std.int(y));
		}
	}
	//public override function onMouseDown (x:Float, y:Float, button:MouseButton) {};
	public override function onMouseUp (x:Float, y:Float, button:MouseButton) {
		sizeEmulation = !sizeEmulation; 
		if (sizeEmulation) onMouseMove(x, y);
		else {
			display.width = peoteView.width;
			display.height = peoteView.height;
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
