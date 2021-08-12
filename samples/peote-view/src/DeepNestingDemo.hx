package;

import haxe.Timer;
import lime.ui.MouseButton;
import lime.app.Application;

import peote.view.PeoteView;
import peote.view.Color;

import peote.layout.LayoutContainer;
import peote.layout.ContainerType;
import peote.layout.Size;
import peote.layout.Align;
import peote.layout.Layout;

import layoutable.LayoutableSprite;
import layoutable.LayoutableDisplay;

class DeepNestingDemo extends Application
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
	
	public function initPeoteView(window:lime.ui.Window)
	{
		peoteView = new PeoteView(window);

		display = new LayoutableDisplay(peoteView, Color.BLACK);	

		// init layout
		root = new Box(display,
		[ 	// at a depth greater 8 the cassowary-constraining can be need long to init!
			getRandomLayoutcontainer(8, 1300, 768),
		]);
		
		
		trace('start INIT constraints of $numLayoutContainer LayoutContainer');
		var time = Timer.stamp();
		root.init();
		trace("INIT ready after " + (Timer.stamp() - time)*1000 + "ms");
		
		root.update(peoteView.width, peoteView.height);
	}
	
	var numLayoutContainer:Int = 0;
	
	function getRandomLayoutcontainer(maxDepth:Int, width:Int, height:Int, type = ContainerType.HBOX, depth:Int = 0):LayoutContainer
	{
		numLayoutContainer++;
		
		var numChilds = 2;
		var subType:ContainerType;
		var subWidth = width;
		var subHeight = height;
		
		if (type == ContainerType.HBOX) {
			subType = ContainerType.VBOX;
			subWidth = Std.int(width / numChilds) - 15;
			subHeight = height - 20;
		}
		else {
			subType = ContainerType.HBOX;
			subHeight = Std.int(height/numChilds) - 15;
			subWidth = subWidth - 20;
		}
		return new LayoutContainer( type, new LayoutableSprite(display, Color.random() | 0x000000ff),
		{	
			left: Size.max(5),
			right:Size.max(5),
			top:Size.max(5),
			bottom:Size.max(5),
			width:Size.limit(Std.int( width / 4), width),
			height:Size.limit(Std.int( height / 4), height),
			//width: Size.min(Std.int(width/4)),
			//height:Size.min(Std.int(height/4)),
			//width: Size.max(width),
			//height:Size.max(height),
			//width: width,
			//height:height,
		},
		// childs
		(++depth >= maxDepth) ? null : [
			for (i in 0...numChilds) 
				getRandomLayoutcontainer(maxDepth, subWidth, subHeight, subType, depth)
			]
		);
		
	}
	
	function random(from:Int, to:Int):Int {
		return from + Std.int(Math.random() * (to - from + 1));
	}
	
	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	

	public override function onWindowResize (width:Int, height:Int):Void
	{
		if (root != null) root.update(width, height);
	}

	// public override function onPreloadComplete():Void {}
	// public override function update(deltaTime:Int):Void {}

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
