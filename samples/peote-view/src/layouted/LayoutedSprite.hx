package layouted;

import peote.layout.LayoutContainer;
import peote.view.Buffer;
import peote.view.Element;
import peote.view.Program;
import peote.view.Color;

import peote.layout.LayoutElement;


class LayoutedSprite implements LayoutElement implements Element
{
	@color public var borderColor:Color = 0x550000ff; // using propertyname "borderColor" as identifier for setColorFormula()
	@color("bgcolor") public var color:Color = 0xffff00ff; // using different identifier "bgcolor" for setColorFormula()
	
	@custom @varying public var borderRadius:Float = 25.0; // using propertyname as identifier for setColorFormula()
	@custom("borderSize") @varying public var bSize:Float = 5.0; // using different identifier "borderSize" for setColorFormula()
	
	@posX public var x:Int=0;
	@posY public var y:Int=0;	
	@sizeX @varying public var w:Int=800;
	@sizeY @varying public var h:Int=100;
	
	@zIndex public var z:Int = 0;
	
	@custom("maskX") @varying public var maskX:Int = 0;
	@custom("maskY") @varying public var maskY:Int = 0;
	@custom("maskWidth") @varying public var maskWidth:Int = 0;
	@custom("maskHeight") @varying public var maskHeight:Int = 0;
	
	
	static public function initProgram(program:Program) 
	{
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
		program.discardAtAlpha(0.7); // z-ordering and alpha needs to tweak here !  (needs auto-sorting via peote-view or new feature there)
	}
	
	
	var display:LayoutedDisplay;
	
	var isVisible:Bool = false;
		
	public function new(display:LayoutedDisplay, color:Color) {
		this.color = color;
		this.display = display;
	}
	
	public inline function update(layoutContainer:LayoutContainer) {
			x = Math.round(layoutContainer.x);
			y = Math.round(layoutContainer.y);
			z = Math.round(layoutContainer.depth);
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
	}
	
	public inline function show() {
		isVisible = true;
		(display.buffer:Buffer<LayoutedSprite>).addElement(this);
	}
	
	public inline function hide() {
		isVisible = false;
		(display.buffer:Buffer<LayoutedSprite>).removeElement(this);
	}

	
	/* INTERFACE peote.layout.LayoutElement */	

	public inline function showByLayout() {
		if (!isVisible) show();
	}
	
	public inline function hideByLayout() {
		if (isVisible) hide();
	}
	
	public inline function updateByLayout(layoutContainer:LayoutContainer) {
		
		// TODO: layoutContainer.updateMask() from here to make it only on-need
		
		if (isVisible)
		{ 
			if (layoutContainer.isHidden) // if it is full outside of the Mask (so invisible)
			{
				#if peotelayout_debug
				trace("removed", layoutContainer.layout.name);
				#end
				hide();
			}
			else {
				update(layoutContainer);
				(display.buffer:Buffer<LayoutedSprite>).updateElement(this);
			}
		}
		else if (!layoutContainer.isHidden) // not full outside of the Mask anymore
		{
			#if peotelayout_debug
			trace("showed", layoutContainer.layout.name);
			#end
			update(layoutContainer);
			show();
		}
		
	}
	
	
}
