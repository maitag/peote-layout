package;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Color;

import peote.layout.LayoutContainer;
import peote.layout.ContainerType;
import peote.layout.Size;


class Main extends lime.app.Application
{
	var peoteView:PeoteView;
	
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
	
	public function initPeoteView(window:lime.ui.Window)
	{
		peoteView = new PeoteView(window.context, window.width, window.height);

		var display = new Display(0, 0, window.width, window.height, Color.GREY1);	
		peoteView.addDisplay(display);

		Sprite.init(display);
		
		// add element to Buffer
		var green = new Sprite(Color.GREEN);
		var red = new Sprite(Color.RED);
		var blue = new Sprite(Color.BLUE);
		var yellow = new Sprite(Color.YELLOW);
		
		var testsize = Size.is(20, 10);
		var testsize1 = new Size(29);
		var testsize2 = Size.min(3, 5, 0.9);
		
		var greenHBox = new LayoutContainer(ContainerType.BOX, green, {left: Size.is(10,20), width:300, height:testsize2} );
		//var greenHBox = HBox(green, {width:300, height:200} );
		greenHBox.layout.height = Size.min(10,30);
		greenHBox.layout.bottom = Size.is(30);
		
/*		greenHBox.init(10, 20 , 400, 300); // at 10, 20
		greenHBox.width = 200;
		greenHBox.height = 300;
		greenHBox.update();
		greenHBox.hide();
		greenHBox.show();
*/		
		
/*		var greenHBox = new HBox(green,  Width.var(200),  LSpace.is(10,20), RSpace.is(10,20), TSpace.is(50) );
		var redScroll = new Scroll(red, ..., xScroll, yScroll);
		
		greenHBox.addChild(redScroll);
		
		
		var blueBox    = new Box(blue, ...);
		var yellowBox  = new Box(yellow, ...);
		
		redScroll.addChild(blueBox);
		redScroll.addChild(yellowBox);

		
		
		greenHBox.initLayout();
				
		greenHBox.width  = peoteView.width
		greenHBox.height = peoteView.height;
		
		redScroll.hScroll = 10;
		redScroll.vScroll = 20;
		
		greenHBox.update();
		
		// greenHBox.hide()
		// greenHBox.show()
*/	

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
	}

	// ----------------- MOUSE EVENTS ------------------------------
	// public override function onMouseMove (x:Float, y:Float):Void {}	
	// public override function onMouseDown (x:Float, y:Float, button:lime.ui.MouseButton):Void {}	
	// public override function onMouseUp (x:Float, y:Float, button:lime.ui.MouseButton):Void {}	
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
