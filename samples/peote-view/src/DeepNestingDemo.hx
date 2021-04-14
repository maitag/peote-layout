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

import layouted.LayoutedSprite;
import layouted.LayoutedDisplay;

class DeepNestingDemo extends lime.app.Application
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
	var root:LayoutContainer;
	
	public function initPeoteView(window:lime.ui.Window)
	{
		peoteView = new PeoteView(window.context, window.width, window.height);

		display = new LayoutedDisplay(Color.BLACK);	
		peoteView.addDisplay(display);

		// init layout
		root = new Box(display,
		[ 	// at greater DEPHT -> PROBLEM: cassowary-constraining needs exponential long TIME to INIT and goes crazy later into UPDATE also !
			getRandomLayoutcontainer(5, peoteView.width, peoteView.height),
		]);
		
		
		trace("start INIT constraints");
		root.init();
		trace("INIT ready");
		
		root.update(peoteView.width, peoteView.height);
	}
	
	function getRandomLayoutcontainer(maxDepth:Int, width:Int, height:Int, type = ContainerType.HBOX, depth:Int = 0):LayoutContainer
	{
		var numChilds = 2;
		var subType:ContainerType;
		var subWidth = width;
		var subHeight = height;
		
		if (type == ContainerType.HBOX) {
			subType = ContainerType.VBOX;
			subWidth = Std.int(width/numChilds);
		}
		else {
			subType = ContainerType.HBOX;
			subHeight = Std.int(height/numChilds);
		}
		return new LayoutContainer( type, new LayoutedSprite(display, Color.random() | 0x000000ff),
		{	
			left: 10,
			right:10,
			top:10,
			bottom:10,
			width:Size.limit(Std.int( width / 3), width),
			height:Size.limit(Std.int( height / 3), height),
			//width: Size.min(Std.int(width/5)),
			//height:Size.min(Std.int(height/5)),
			//width: Size.max(width),
			//height:Size.max(height),
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