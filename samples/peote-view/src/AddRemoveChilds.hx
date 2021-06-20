package;

import lime.ui.MouseButton;
import lime.app.Application;
import peote.layout.Align;
import peote.layout.Layout;

import peote.view.PeoteView;
import peote.view.Color;

import peote.layout.LayoutContainer;
import peote.layout.ContainerType;
import peote.layout.Size;

import layoutable.LayoutableSprite;
import layoutable.LayoutableDisplay;

class AddRemoveChilds extends lime.app.Application
{
	var peoteView:PeoteView;
	var display:LayoutableDisplay;
	
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
	var root:LayoutContainer;
	var green:LayoutContainer;
	
	public function initPeoteView(window:lime.ui.Window)
	{
		peoteView = new PeoteView(window.context, window.width, window.height);

		display = new LayoutableDisplay(peoteView, Color.GREY1);	

		// add some graphic elements
		green = new Box( new LayoutableSprite(display, Color.GREEN),
		{	
			#if peotelayout_debug
			name:"green",
			#end
			// ----- container options:
			//scrollX:true, // allow horizontal scrolling of the inner childs
			//scrollY:true, // allow vertical scrolling of the inner childs

			// limit minimum/maximum to be not smaller than min/max childs size (false per default)
			limitMinWidthToChilds: false, // minimum width >= childs minimum
			//limitMaxWidthToChilds: false, // maximum width >= childs maximum
			//limitMinHeightToChilds: false, // minimum height >= childs minimum
			//limitMaxHeightToChilds: true, // maximum height >= childs maximum
			
			//alignChildsOnOversizeY:Align.LAST, // force the aligning for all childs on oversizing
			
			// ----- inner size (width, height) and outer spacer (left, right, top, bottom):
			width:Size.limit(100, 200),
		},
		// childs
		[	
/*			new Box( new LayoutedSprite(display, Color.RED), {
				#if peotelayout_debug
				name:"red",
				#end
				width:Size.limit(50, 100),
			}),
			new Box( new LayoutedSprite(display, Color.BLUE), {
				#if peotelayout_debug
				name:"blue",
				#end
				width:Size.limit(100, 200),
			}),
*/		]);
				
				
		// init a layout
		root = new HBox(display,
		{
			#if peotelayout_debug
			name:"root",
			#end
			relativeChildPositions:true,
			width:Size.limit(300,500),
			//alignChildsOnOversizeX:Align.CENTER,
			//limitMinWidthToChilds: false,
		},
		[ 						
			//green,
		]);
		
		root.init();
		root.addChild(green);
		
		root.update(peoteView.width, peoteView.height);
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
		if (root != null) root.update(width, height);
	}

	// ----------------- MOUSE EVENTS ------------------------------
	var sizeEmulation = false;
	
	var lastScrollValue:Float = 0;
	public override function onMouseMove (x:Float, y:Float) {
		if (sizeEmulation && root != null) {
			root.update(x, y);
/*			var scrollValue = root.getChild(0).xScroll;
			if (lastScrollValue != scrollValue) {
				trace(scrollValue);
				lastScrollValue = scrollValue;
			}
*/		}
	}
	//public override function onMouseDown (x:Float, y:Float, button:MouseButton) {};
	public override function onMouseUp (x:Float, y:Float, button:MouseButton) {
		sizeEmulation = !sizeEmulation; 
		if (sizeEmulation) onMouseMove(x, y);
		else {
			root.update(peoteView.width, peoteView.height);
		}
	}
	public override function onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:lime.ui.MouseWheelMode):Void {
		if (deltaY != 0) {
			//var xScroll = root.getChild(0).xScroll + deltaY*5;
			//if (xScroll >= 0 && xScroll <= root.getChild(0).xScrollMax) {
				//root.getChild(0).xScroll = xScroll;
				//root.update();
			//}
			
			//trace(root.getChild(0).xScroll, root.getChild(0).xScrollMax);
			
/*			xScroll = root.getChild(1).xScroll + deltaY*5;
			//if (xScroll >= 0 && xScroll <= root.getChild(0).xScrollMax) {
				root.getChild(1).xScroll = xScroll;
				root.update();
			//}
			
			xScroll = root.getChild(2).xScroll + deltaY*5;
			//if (xScroll >= 0 && xScroll <= root.getChild(0).xScrollMax) {
				root.getChild(2).xScroll = xScroll;
				root.update();
			//}
*/		}
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
