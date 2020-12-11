package;

import peote.layout.LayoutContainer;
import peote.view.Element;
import peote.view.Display;
import peote.view.Program;
import peote.view.Buffer;
import peote.view.Color;

import peote.layout.LayoutElement;


class LayoutedSprite implements LayoutElement implements Element
{
	@color public var borderColor:Color = 0x550000ff; // using propertyname "borderColor" as identifier for setColorFormula()
	@color("bgcolor") public var color:Color = 0xffff00ff; // using different identifier "bgcolor" for setColorFormula()
	
	@custom @varying public var borderRadius:Float = 25.0; // using propertyname as identifier for setColorFormula()
	@custom("borderSize") @varying public var bSize:Float = 10.0;// using different identifier "borderSize" for setColorFormula()
	
	@posX public var x:Int=0;
	@posY public var y:Int=0;	
	@sizeX @varying public var w:Int=800;
	@sizeY @varying public var h:Int=100;
	
	@zIndex public var z:Int = 0;
	
	@custom("maskX") @varying public var maskX:Int = 0;
	@custom("maskY") @varying public var maskY:Int = 0;
	@custom("maskWidth") @varying public var maskWidth:Int = 0;
	@custom("maskHeight") @varying public var maskHeight:Int = 0;
	
	static public var buffer:Buffer<LayoutedSprite>;
	static public var program:Program;
	
	static public function init(display:Display) {
		buffer = new Buffer<LayoutedSprite>(100);
		program = new Program(LayoutedSprite.buffer);
		program.injectIntoFragmentShader(
		"
			float roundedBox (vec2 pos, vec2 size, float padding, float radius)
			{
				radius -= padding;
				pos = (pos - 0.5) * size;
				size = 0.5 * size - vec2(radius, radius) - vec2(padding, padding);
				float d = length(max(abs(pos), size) - size) - radius;
				return smoothstep( 0.0, 1.0,  d );
			}
			
			float roundedBorder (vec2 pos, vec2 size, float thickness, float radius)
			{
				radius -= thickness / 2.0;
				pos = (pos - 0.5) * size;
				size = 0.5 * (size - vec2(thickness, thickness)) - vec2(radius, radius);
				float s = 0.5 / thickness * 2.0;
				float d = length(max(abs(pos), size) - size) - radius;				
				return smoothstep( 0.5+s, 0.5-s, abs(d / thickness)  );
			}
			
			float rectMask (vec2 pos, vec2 size, vec4 mask)
			{
				pos = pos * size;
				if (pos.x < mask.x || pos.x > mask.z || pos.y < mask.y || pos.y > mask.w) return 0.0;
				else return 1.0;
			}

			vec4 compose (vec4 c, vec4 borderColor, float borderSize, float borderRadius, vec4 mask)
			{
				float radius =  max(borderSize+1.0, min(borderRadius, min(vSize.x, vSize.y) / 2.0));
				c = mix(c, vec4(0.0, 0.0, 0.0, 0.0), roundedBox(vTexCoord, vSize, borderSize, radius));				
				c = mix(c, borderColor, roundedBorder(vTexCoord, vSize, borderSize, radius)); // TODO: vSize Varyings also via setColorFormula()
				c = c * rectMask(vTexCoord, vSize, mask);
				return c;
			}
		");
		
		program.setColorFormula('compose(bgcolor, borderColor, borderSize, borderRadius, vec4(maskX, maskY, maskWidth, maskHeight))');// parsed by color and custom identifiers
		
		program.alphaEnabled = true;
		display.addProgram(program);
	}
	
	
	var isVisible:Bool = false;
		
	public function new(color:Color) {
		this.color = color;
		showByLayout();
	}
	
	
	
	/* INTERFACE peote.layout.LayoutElement */	

	public function showByLayout() {
		if (!isVisible) {
			isVisible = true;
			buffer.addElement(this);
		}
	}
	
	public function hideByLayout() {
		if (isVisible) {
			isVisible = false;
			buffer.removeElement(this);
		}			
	}
	
	public function updateByLayout(layoutContainer:LayoutContainer) 
	{
		if (isVisible && layoutContainer.isHidden) { // if it is full outside of the Mask (so invisible)
			hideByLayout();
		}
		else {
			x = Math.round(layoutContainer.x);
			y = Math.round(layoutContainer.y);
			w = Math.round(layoutContainer.width);
			h = Math.round(layoutContainer.height);
			
			if (layoutContainer.isMasked) { // if some of the edges is cut by mask for scroll-area
				maskX = Math.round(layoutContainer.maskX);
				maskY = Math.round(layoutContainer.maskY);
				maskWidth = maskX + Math.round(layoutContainer.maskWidth);
				maskHeight = maskY + Math.round(layoutContainer.maskHeight);
			}
			else { // if its fully displayed
				maskX = 0;
				maskY = 0;
				maskWidth = w;
				maskHeight = h;
			}
			
			if (!isVisible) showByLayout()
			else buffer.updateElement(this);

		}
	}
	
	
	
}
