package;

import lime.ui.MouseButton;
import lime.app.Application;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Color;

import peote.layout.LayoutContainer;
import peote.layout.ContainerType;
import peote.layout.Size;

import layoutable.LayoutableSprite;
import layoutable.LayoutableDisplay;

class ManualConstraints extends lime.app.Application
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
	var rootLayoutContainer:LayoutContainer;
	
	public function initPeoteView(window:lime.ui.Window)
	{
		peoteView = new PeoteView(window.context, window.width, window.height);

		display = new LayoutableDisplay(peoteView, Color.GREY1);	

		// add some graphic elements
		var green = new LayoutableSprite(display, Color.GREEN);
		var red = new LayoutableSprite(display, Color.RED);
		var blue = new LayoutableSprite(display, Color.BLUE);
		var yellow = new LayoutableSprite(display, Color.YELLOW);
				
		
		// init a layout
		var redBox = new Box(red);
		var blueBox = new Box(blue);
		var yellowBox = new Box(yellow);
		redBox.layout = {left:100};
		
		var greenBox = new HBox(green,
			[	redBox,
				blueBox,
				yellowBox
			]
		);
				
		var displayLC = new Box(display,
			[ 
				greenBox
			]
		);
		
		displayLC.init();
		
		displayLC.update(peoteView.width, peoteView.height);
		
		rootLayoutContainer = displayLC;
		
		// custom constraints: siehe Kommentare in LayoutContainer -> addConstraintsHBOX 
		//displayLC.addConstraints([
			//(redBox._width == blueBox._width-50) | Strength.create(0, 900, 0),
			//(yellowBox._width == greenBox._width / 2) | Strength.create(0, 900, 0),
		//]);		
		//greenBox.removeConstraints(); // no param -> remove all
		
		//var redConstraint:Constraint = (redBox._width == redBox._height) | Strength.create(0, 0, 900);
		//redBox.addConstraint(redConstraint);
		//redBox.removeConstraint(redConstraint);
		
	

	}
	
/*	public function testConstraints()
	{
		ui.layout.reset();
		grey.layout.reset();

		layout = new Layout ([
			// constraints
			(peoteView.layout.x == 0) | Strength.REQUIRED,
			(peoteView.layout.y == 0) | Strength.REQUIRED,

			ui.layout.centerX == peoteView.layout.centerX,
			ui.layout.top == 10,
			(ui.layout.width == peoteView.layout.width - 20) | Strength.WEAK,
			(ui.layout.bottom == peoteView.layout.bottom - 10) | Strength.WEAK,
			(ui.layout.width <= 1000) | Strength.WEAK,

			(grey.layout.centerX == ui.layout.centerX) | Strength.WEAK,
			(grey.layout.y == ui.layout.y + 0.1*ui.layout.height) | Strength.WEAK,
			//(grey.layout.centerY == ui.layout.centerY) | Strength.MEDIUM,
			
			(grey.layout.width  == ui.layout.width  / 1.1) | Strength.WEAK,
			(grey.layout.height == ui.layout.height / 2.0  - 20) | Strength.WEAK,
			
			(grey.layout.width <= 600) | Strength.MEDIUM,
			(grey.layout.width >= 200) | Strength.MEDIUM,
			(grey.layout.height <= 400) | Strength.MEDIUM,
			(grey.layout.height >= 200) | Strength.MEDIUM
		]);
		
		// adding constraints afterwards:
		var limitHeight:Constraint = (ui.layout.height <= 800) | Strength.WEAK;
		layout.addConstraint(limitHeight);
		
		// that constraints can also be removed again:
		// layout.removeConstraint(limitHeight);
		
		// UI-Displays and UI-Elements to update
		layout.toUpdate([ui, grey]);
		
		// editable Vars
		layout.addVariable(peoteView.layout.width);
		layout.addVariable(peoteView.layout.height);
		
		resizeLayout(peoteView.width, peoteView.height);
	}

	// ----------------------------------------------------------------
		
	public function testRowConstraints()
	{
		ui.layout.reset();
		red.layout.reset();
		green.layout.reset();
		blue.layout.reset();
		
		layout = new Layout ([
			// constraints for the Displays
			(peoteView.layout.x == 0) | Strength.REQUIRED,
			(peoteView.layout.y == 0) | Strength.REQUIRED,

			(ui.layout.centerX == peoteView.layout.centerX) | new Strength(200),
			//(ui.layout.left == peoteView.layout.left) | new Strength(300),
			//(ui.layout.right == peoteView.layout.right) | new Strength(200),
			(ui.layout.width == peoteView.layout.width) | new Strength(100),
			
			(ui.layout.top == 0) | Strength.MEDIUM,
			(ui.layout.bottom == peoteView.layout.bottom) | Strength.MEDIUM,
			(ui.layout.width <= 1000) | Strength.MEDIUM,
		
			// constraints for ui-elements
			
			// size restriction
			(red.layout.width <= 100) | new Strength(500),
			(red.layout.width >= 50) | new Strength(500),
			//(red.layout.width == 100) | new Strength(500),
			
			(green.layout.width <= 200) | new Strength(500),
			(green.layout.width >= 100) | new Strength(500),
			//(green.layout.width == 200) | new Strength(500),
			
			(blue.layout.width <= 300) | new Strength(500),
			(blue.layout.width >= 150) | new Strength(500),
			//(blue.layout.width == 300) | new Strength(500),
			
			// manual hbox constraints
			
			//(red.layout.width   == (ui.layout.width) * ((100+ 50)/2) / ((100+50)/2 + (200+100)/2 + (300+150)/2)) | Strength.WEAK,
			//(green.layout.width == (ui.layout.width) * ((200+100)/2) / ((100+50)/2 + (200+100)/2 + (300+150)/2)) | Strength.WEAK,
			//(blue.layout.width  == (ui.layout.width) * ((300+150)/2) / ((100+50)/2 + (200+100)/2 + (300+150)/2)) | Strength.WEAK,
			
			(red.layout.width == green.layout.width) | Strength.WEAK,
			//(red.layout.width == blue.layout.width) | Strength.WEAK,
			(green.layout.width == blue.layout.width) | Strength.WEAK,
			
			(red.layout.left == ui.layout.left) | new Strength(400),
			(green.layout.left == red.layout.right ) | new Strength(400),
			(blue.layout.left == green.layout.right ) | new Strength(400),
			(blue.layout.right == ui.layout.right) | new Strength(300),
			//(blue.layout.right == ui.layout.right) | Strength.WEAK,
			
			(red.layout.top == ui.layout.top) | Strength.MEDIUM,
			(red.layout.bottom == ui.layout.bottom) | Strength.MEDIUM,
			(green.layout.top == ui.layout.top) | Strength.MEDIUM,
			(green.layout.bottom == ui.layout.bottom) | Strength.MEDIUM,
			(blue.layout.top == ui.layout.top) | Strength.MEDIUM,
			(blue.layout.bottom == ui.layout.bottom) | Strength.MEDIUM,			
		]);
			
		// UI-Displays and UI-Elements to update
		layout.toUpdate([ui, red, green, blue]);
		
		// editable Vars (used in suggest() and suggestValues())
		layout.addVariable(peoteView.layout.width);
		layout.addVariable(peoteView.layout.height);

		resizeLayout(peoteView.width, peoteView.height);
	}
*/
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
