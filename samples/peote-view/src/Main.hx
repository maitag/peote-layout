package;

import lime.app.Application;
import lime.ui.Window;
import lime.ui.MouseButton;

import peote.view.PeoteView;
import peote.view.Color;

import peote.layout.LayoutContainer;
import peote.layout.ContainerType;
import peote.layout.Size;

import layoutable.LayoutableSprite;
import layoutable.LayoutableDisplay;

import peote.layout.Align;

class Main extends Application
{
	
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
		var peoteView = new PeoteView(window);

		var display = new LayoutableDisplay(peoteView, Color.GREY1);

		// add some graphic elements
		var green = new LayoutableSprite(display, Color.GREEN);
		var red = new LayoutableSprite(display, Color.RED);
		var blue = new LayoutableSprite(display, Color.BLUE);
		var yellow = new LayoutableSprite(display, Color.YELLOW);
				
		
		// init a layout
		layoutContainer = new LayoutContainer(ContainerType.BOX, display,
		{
			#if peotelayout_debug
			name:"root",
			#end
			// relativeChildPositions:true, // need sometimes for peoteView Display (because all sprites are into and relative to)
			//width:Size.limit(100,200),
			//limitMinWidthToChilds: false, // allow oversizing of the inner containers
			//alignChildsOnOversizeX:Align.LAST, // for all childs to align at right if the inner containers not fit into
		},
		[	// green child
			new Box( green, // same as new LayoutContainer(ContainerType.BOX, green, ...)
			{
				#if peotelayout_debug
				name:"green",
				#end
				left: Size.min(100), // can be scale high but not lower as min-value
				width:Size.limit(100, 400), // can be scale from min to max-value
				right:Size.max(200), // can be scale from 0 to max-value
				//right:10, // or can be a fixed value.. same as .limit(10,10)
				
				// for "span" they are reaching its min and max at the same time while scaling
				// in a row, but can be scaled higher as max
				top:   Size.span(50, 100),
				height:Size.span(200, 400),
				bottom:Size.span(50, 100),
			},
			[	// red, blue and yellow childs
				new Box( red, {
					#if peotelayout_debug
					name:"red",
					#end
					left:0,
					width:300,
					height:100,
					bottom:Size.min(100),
				}),
				new Box( blue, {
					#if peotelayout_debug
					name:"blue",
					#end
					right:0,
					width:300,
					height:100,
					bottom:0,
				}),
				new Box( yellow, {
					#if peotelayout_debug
					name:"yellow",
					#end
					width:100,
					height:Size.limit(100, 300),
				}),
			]),
		]);
		
		layoutContainer.init();
		
		layoutContainer.update(peoteView.width, peoteView.height);
		
	}
	
	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	

	public override function onWindowResize (width:Int, height:Int):Void
	{
		if (layoutContainer != null) layoutContainer.update(width, height);
	}

	// public override function onPreloadComplete():Void {}
	// public override function update(deltaTime:Int):Void {}

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
			layoutContainer.update(window.width, window.height);
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
