package;


import openfl.Lib;
import openfl.display.Sprite;
/*
import openfl.text.Font;
import openfl.text.TextField;
import openfl.text.TextFormat;
*/

import peote.layout.LayoutContainer;
import peote.layout.ContainerType;
import peote.layout.Size;

class Main extends Sprite {
	
	
	public function new () {
		
		super ();
		
		//SelfSprite.init(Lib.current.stage);
		
		// add some graphic elements
		var green = new SelfSprite(0x00ff00);
		//var red = new SelfSprite(0xff0000);
				
		
		// init a layout
		var greenLC = new LayoutContainer(ContainerType.BOX, green,
			{
				left: Size.min(100), // can be scale high but not lower as min-value
				width:Size.limit(300, 400), // can be scale from min to max-value
				right:Size.max(200), // can be scale from 0 to max-value
				// right:10 // or can be a fixed value.. same as .limit(10,10)
				
				// for "span" they are reaching its min and max at the same time while scaling
				// in a row, but can be scaled higher as max
				top:Size.span(50, 100),
				height:Size.span(200, 400),
				bottom:Size.span(50, 100),
			},
			// childs
			[
				// Box is shortcut for LayoutContainer(ContainerType.BOX, ...)
				//new Box(red, {left:0, width:300, height:100, bottom:Size.min(100)} ),
				//new Box(blue, {right:0, width:300, height:100, bottom:0} )
			]
		);
		
		greenLC.init();
		greenLC.update(800, 500);
		
		//rootLayoutContainer = greenLC;
		
		
		
/*		var format = new TextFormat ("Katamotz Ikasi", 30, 0x7A0026);
		var textField = new TextField ();
		
		textField.defaultTextFormat = format;
		textField.embedFonts = true;
		textField.selectable = false;
		
		textField.x = 50;
		textField.y = 50;
		textField.width = 200;
		
		textField.text = "Hello World";
		
		addChild (textField);
*/		
	}
	
	
}