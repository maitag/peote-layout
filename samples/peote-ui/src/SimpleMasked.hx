package;

import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;
import lime.ui.MouseButton;
import lime.ui.MouseWheelMode;

import peote.view.PeoteView;
import peote.view.Color;

import peote.layout.LayoutContainer;
import peote.layout.Size;
import peote.layout.Align;

import peote.text.Font;

import peote.ui.event.PointerEvent;
import peote.ui.event.WheelEvent;

import peote.ui.style.FontStyleTiled;
import peote.ui.style.FontStylePacked;

import peote.ui.UIDisplay;
import peote.ui.interactive.InteractiveElement;
import peote.ui.interactive.InteractiveTextLine;
import peote.ui.interactive.interfaces.TextLine;
import peote.ui.style.TextLineStyle;
import peote.ui.util.HAlign;
import peote.ui.util.VAlign;

import peote.ui.style.SimpleStyle;
import peote.ui.style.RoundBorderStyle;


class SimpleMasked extends Application
{
	var peoteView:PeoteView;
	var uiDisplay:UIDisplay;
	
	var tiledFont:Font<FontStyleTiled>;
	var packedFont:Font<FontStylePacked>;
	
	var fontStyleTiled:FontStyleTiled;
	var fontStylePacked:FontStylePacked;
	
	var textStyle:TextLineStyle;
		
	var uiLayoutContainer:LayoutContainer;
	
	override function onWindowCreate():Void
	{
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES:
				try startSample(window)
				catch (_) trace(CallStack.toString(CallStack.exceptionStack()), _);
			default: throw("Sorry, only works with OpenGL.");
		}
	}

	public function startSample(window:Window)
	{
		fontStyleTiled = new FontStyleTiled();
		fontStyleTiled.height = 16.0;
		fontStyleTiled.width = 16.0;
		fontStyleTiled.color = Color.BLACK;
		
		fontStylePacked = new FontStylePacked();
		fontStylePacked.height = 30.0;
		fontStylePacked.width = 30.0;
		fontStylePacked.color = Color.BLACK;
		
		var backgroundStyle = new SimpleStyle(Color.GREEN);
		textStyle = {
			backgroundStyle:backgroundStyle
			,selectionStyle:RoundBorderStyle.createById(0, Color.GREY5)
			//,selectionStyle:SimpleStyle.createById(1, Color.GREY5)
		}
		
		peoteView = new PeoteView(window);
		//uiDisplay = new UIDisplay(0, 0, window.width, window.height, Color.GREY3);
		uiDisplay = new UIDisplay(0, 0, window.width, window.height, Color.GREY3, [backgroundStyle], true);
		peoteView.addDisplay(uiDisplay);
				
		// load the FONTs:
		new Font<FontStyleTiled>("assets/fonts/tiled/hack_ascii.json").load( function(_tiledFont:Font<FontStyleTiled>) {
			tiledFont = _tiledFont;
			new Font<FontStylePacked>("assets/fonts/packed/hack/config.json").load( function(_packedFont:Font<FontStylePacked>) {
				packedFont = _packedFont;
				onAllFontLoaded();
			});				
		});
	}
	
	public function onAllFontLoaded() 
	{		
		var red   = new InteractiveElement(new RoundBorderStyle(Color.RED, Color.BLACK, 0, 10));
		uiDisplay.add(red);

				
		var redBoxes = new Array<Box>();
		for (i in 0...10) {
			var button = new InteractiveElement(new RoundBorderStyle(Color.YELLOW));
			button.onPointerOver = function(elem:InteractiveElement, e:PointerEvent) {
				elem.style.color = Color.YELLOW - 0x00550000;
				elem.updateStyle();
			}
			button.onPointerOut = function(elem:InteractiveElement, e:PointerEvent) {
				elem.style.color = Color.YELLOW;
				elem.updateStyle();
			}
			uiDisplay.add(button);
			
			button.wheelEventsBubbleTo = red;
			
			var textLineTiled = new InteractiveTextLine<FontStyleTiled>(0, 0, {hAlign:HAlign.CENTER, vAlign:VAlign.CENTER}, 'button${i+1}', tiledFont, fontStyleTiled, textStyle);
			textLineTiled.autoWidth = false;
			textLineTiled.autoHeight = false;
			//var textLinePacked = new LayoutedTextLine<FontStylePacked>(0, 0, 130, 25, 0, true, "packed font", packedFont, fontStylePacked);	// masked -> true		
			//trace("KK", textLineTiled.line.textSize); // TODO: line is null
			
			textLineTiled.select(1, 4);
			
			uiDisplay.add(textLineTiled);
			
			redBoxes.push(
				new Box( button,  { left:10, right:10, height:Size.limit(50, 80) }, [
					//new Box( textLineTiled, {  left:Size.min(10), width:Size.limit(95, 125), right:Size.min(10), height:18 })
					//new Box( textLineTiled, { left:Size.min(10), width:Size.limit(textLineTiled.width, 125), right:Size.min(10), height:18 })
					new Box( textLineTiled, { left:Size.min(10), width:Size.limit(50, 130), right:Size.min(10), height:40 })
				])
			);
		}

		
		
		var green = new InteractiveElement(new SimpleStyle(Color.GREEN));
		var blue  = new InteractiveElement(new RoundBorderStyle(Color.BLUE, Color.BLACK, 0, 10));
		
		uiDisplay.add(green);
		uiDisplay.add(blue);
		
		var inputLine = packedFont.createInteractiveTextLine(0, 0, {hAlign:HAlign.CENTER, vAlign:VAlign.CENTER}, 'input line', fontStylePacked);
		inputLine.onPointerOver = function(t:TextLine, e:PointerEvent) {
			trace("onPointerOver");
			t.setInputFocus(e); // alternatively: uiDisplay.setInputFocus(t);
			t.cursor = 2;
			t.cursorShow();
		}
		inputLine.autoWidth = false;
		inputLine.autoHeight = false;

		inputLine.onPointerOut = function(t:TextLine, e:PointerEvent) {
			trace("onPointerOut");
			t.cursorHide();
		}
		uiDisplay.add(inputLine);
		
		// ----------- LAYOUT ---------------
		
		uiLayoutContainer = new HBox( uiDisplay , { width:Size.max(650), relativeChildPositions:true },
		[                                                          
			new VBox( red ,  { top:40, bottom:20, width:Size.limit(100, 250),
				scrollY:true, // TODO: better error-handling if this is forgotten here!
				limitMinHeightToChilds:false, alignChildsOnOversizeY:Align.FIRST }, redBoxes ),
			new VBox( green, { top:40, bottom:20, width:Size.limit(100, 250) }, 
			[
				new Box( inputLine, { left:Size.min(10), width:Size.limit(50, 130), right:Size.min(10), top:10, height:Size.max(40), scrollY:true, limitMinHeightToChilds:false })
			]),							
			new VBox( blue,  { top:40, bottom:20, width:Size.limit(100, 250) }, [] ),						
		]);
		
		uiLayoutContainer.init();
		uiLayoutContainer.update(peoteView.width, peoteView.height);
		
		
		// scrolling		
		red.onMouseWheel = function(b:InteractiveElement, e:WheelEvent) {
			if (e.deltaY != 0) {
				var yScroll = uiLayoutContainer.getChild(0).yScroll - e.deltaY*10;
				//if (xScroll >= 0 && xScroll <= uiLayoutContainer.getChild(0).xScrollMax) {
					uiLayoutContainer.getChild(0).yScroll = yScroll;
					uiLayoutContainer.update();
				//}
			}
		}
		
		
		// delegating lime events to all added UIDisplays and LayoutedUIDisplay
		UIDisplay.registerEvents(window);		
	}

	
	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	
		
	// ----------------- MOUSE EVENTS ------------------------------
	var sizeEmulation = false;
	
	override function onMouseMove (x:Float, y:Float) {
		if (sizeEmulation) uiLayoutContainer.update(Std.int(x),Std.int(y));
	}
	
	override  function onMouseUp (x:Float, y:Float, button:MouseButton) {
		sizeEmulation = !sizeEmulation; 
		if (sizeEmulation) uiLayoutContainer.update(x,y);
		else uiLayoutContainer.update(peoteView.width, peoteView.height);
	}

	override function onMouseWheel (dx:Float, dy:Float, mode:MouseWheelMode) uiDisplay.mouseWheel(dx, dy, mode);
		
	// ----------------- WINDOWS EVENTS ----------------------------
	override function onWindowResize (width:Int, height:Int) {
		// calculates new Layout and updates all Elements 
		if (uiLayoutContainer != null) uiLayoutContainer.update(width, height);
	}
	
}
