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

class Test extends lime.app.Application
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
		display.width = 2000;
		display.height = 2000;
		peoteView.addDisplay(display);

		// add some graphic elements
		var green = new LayoutedSprite(display, Color.GREEN);
		var red = new LayoutedSprite(display, Color.RED);
		var blue = new LayoutedSprite(display, Color.BLUE);
		var yellow = new LayoutedSprite(display, Color.YELLOW);
		var cyan = new LayoutedSprite(display, Color.CYAN);
				
		var green1 = new LayoutedSprite(display, Color.GREEN);
		var red1 = new LayoutedSprite(display, Color.RED);
		var blue1 = new LayoutedSprite(display, Color.BLUE);
				
		var green2 = new LayoutedSprite(display, Color.GREEN);
		var red2 = new LayoutedSprite(display, Color.RED);
		var blue2 = new LayoutedSprite(display, Color.BLUE);
				
		// init a layout
		layoutContainer = new LayoutContainer(ContainerType.BOX, blue2,
		{
			#if peotelayout_debug
			name:"root",
			#end
			//left: Size.max(100),
			//left: 100,
			//right: 10,
			//right: Size.max(100),
			//width:Size.min(50), // TODO: Order of oversizing ! (-> test 50)
			width:Size.limit(50, 800),
			//width:200,
			//alignChildsOnOversizeX:Align.CENTER,
			limitMinWidthToChilds: false,
		},
		[ 
			
			new Box( green,
			{	
				#if peotelayout_debug
				name:"green",
				#end
				// ----- container options:
				scrollX:true, // allow horizontal scrolling of the inner childs
				scrollY:true, // allow vertical scrolling of the inner childs
	
				// limit minimum/maximum to be not smaller than min/max childs size (false per default)
				limitMinWidthToChilds: false, // minimum width >= childs minimum
				//limitMaxWidthToChilds: false, // maximum width >= childs maximum
				//limitMinHeightToChilds: true, // minimum height >= childs minimum
				//limitMaxHeightToChilds: false, // maximum height >= childs maximum
				
				//alignChildsOnOversizeX:Align.FIRST, // force the aligning for all childs on oversizing
				//alignChildsOnOversizeX:Align.AUTO, // auto is default
				
				// ----- inner size (width, height) and outer spacer (left, right, top, bottom):
				top:0,
				height:200,
				//left: 30,
				//left: Size.limit(0, 30),
				width:Size.limit(100, 700),
				//width:Size.min(200),
				//right:30,
			},
			// childs
			[	
				new Box( red, {
					#if peotelayout_debug
					name:"red",
					#end
					top:0,
					height:100,
					left:10,
					//left:Size.limit(50, 100),
					//left:Size.max(100),
					//left:Size.min(50),
					width:Size.limit(200, 300),
					//width:Size.min(200),
					//width:Size.max(200),
					//width:Size.limit(200, 300),
					//width:200,
					//right:0,
					//right:Size.limit(50, 100),
					//right:Size.min(100),
					//right:Size.max(100),
				}),
				new Box( blue, {
					#if peotelayout_debug
					name:"blue",
					#end
					top:110,
					height:90,
					//left:100,
					left:Size.limit(0, 50),
					//left:Size.max(100),
					//left:Size.min(50),
					width:Size.limit(150, 400),
					//width:Size.min(100),
					//width:300,
					right:10,
					//right:Size.limit(10, 100),
					//right:Size.min(50),
					//right:Size.max(50),
					alignChildsOnOversizeX:Align.FIRST, // force the aligning for all childs on oversizing
					limitMinWidthToChilds: false, // minimum width >= childs minimum
				},
				[
					new Box( yellow, {
						#if peotelayout_debug
						name:"yellow",
						#end
						left:Size.limit(0,100),
						width:Size.limit(250, 300),
						//right:Size.max(10),
						height:50,
						limitMinWidthToChilds: false, // minimum width >= childs minimum
						alignChildsOnOversizeX:Align.LAST,
					},
					[
						new Box( cyan, {
							#if peotelayout_debug
							name:"cyan",
							#end
							width:280,
							//right:0,
							height:30,
						})
					]),
				]),
			]),
			
			// ----------------------------------------------
			
			new Box( green1, 
			{
				top:200,
				height:200,
				left: 30,
				width:Size.limit(100, 500),
				//width:Size.min(100),
				right:30,
				
				//alignChildsOnOversizeX:Align.FIRST, // force the aligning for all childs on oversizing
				limitMinWidthToChilds: false, // minimum width >= childs minimum
			},
			// childs
			[
				new Box( red1, {
					top:0,
					height:100,
					width:100,
				}),
				new Box( blue1, {
					top:100,
					height:100,
					width:Size.limit(200, 300),
				}),
			]),
			
			// ----------------------------------------------
			
			new HBox( green2, 
			{
				top:400,
				height:200,
				left: 30,
				//width:Size.limit(100, 500),
				width:Size.min(100),
				//width:Size.max(500),
				right:30,
				//alignChildsOnOversizeX:Align.FIRST, // force the aligning for all childs on oversizing
				limitMinWidthToChilds: false, // minimum width >= childs minimum
			},
			// childs
			[
				new Box( red2, {
					height:100,
					//left:0,
					//left:Size.min(10),
					//left:Size.max(50),
					width:Size.limit(200,300),
					//width:200,
				}),
				new Box( blue2, {
					height:100,
					//left:Size.limit(10,50),
					width:Size.limit(100, 200),
					//right:Size.min(100),
					right:0
				}),
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
	
	var lastScrollValue:Float = 0;
	public override function onMouseMove (x:Float, y:Float) {
		if (sizeEmulation && layoutContainer != null) {
			layoutContainer.update(x, y);
			//trace(layoutContainer.getChild(0).width, layoutContainer.getChild(0).getChild(0).width, layoutContainer.getChild(0).xScrollMax);
			var scrollValue = layoutContainer.getChild(0).xScroll;
			if (lastScrollValue != scrollValue) {
				trace(scrollValue);
				lastScrollValue = scrollValue;
			}
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
			var xScroll = layoutContainer.getChild(0).xScroll + deltaY*5;
			//if (xScroll >= 0 && xScroll <= layoutContainer.getChild(0).xScrollMax) {
				layoutContainer.getChild(0).xScroll = xScroll;
				layoutContainer.update();
			//}
			trace(layoutContainer.getChild(0).xScroll, layoutContainer.getChild(0).xScrollMax);
			
/*			xScroll = layoutContainer.getChild(1).xScroll + deltaY*5;
			//if (xScroll >= 0 && xScroll <= layoutContainer.getChild(0).xScrollMax) {
				layoutContainer.getChild(1).xScroll = xScroll;
				layoutContainer.update();
			//}
			
			xScroll = layoutContainer.getChild(2).xScroll + deltaY*5;
			//if (xScroll >= 0 && xScroll <= layoutContainer.getChild(0).xScrollMax) {
				layoutContainer.getChild(2).xScroll = xScroll;
				layoutContainer.update();
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
