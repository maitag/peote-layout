package;

import peote.view.Element;
import peote.view.Display;
import peote.view.Program;
import peote.view.Buffer;
import peote.view.Color;

import peote.layout.Border;
import peote.layout.LayoutElement;


class Sprite implements LayoutElement implements Element
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
	
	@custom("maskLeft") @varying public var maskLeft:Int = 0;
	@custom("maskRight") @varying public var maskRight:Int = 0;
	@custom("maskTop") @varying public var maskTop:Int = 0;
	@custom("maskBottom") @varying public var maskBottom:Int = 0;
	
	static public var buffer:Buffer<Sprite>;
	static public var program:Program;
	
	static public function init(display:Display) {
		buffer = new Buffer<Sprite>(100);
		program = new Program(Sprite.buffer);
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
				if (pos.x <= mask.x || pos.x >= mask.y || pos.y <= mask.z || pos.y >= mask.w) return 0.0;
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
		
		program.setColorFormula('compose(bgcolor, borderColor, borderSize, borderRadius, vec4(maskLeft, maskRight, maskTop, maskBottom))');// parsed by color and custom identifiers
		
		program.alphaEnabled = true;
		display.addProgram(program);
	}
	
		
	public function new(color:Color) {
		this.color = color;
		//update({top:5,left:0,right:800,bottom:100}, {top:5,left:10,right:500,bottom:90}, 0);
		update({top:5,left:0,right:800,bottom:100}, {top:0,left:0,right:800,bottom:100}, 0);
	}
	
	
	
	
	
	var insideMask:Bool = false;
	public var isAdded:Bool = false;

	public function show() {
		if (!isAdded) {
			isAdded = true;
			buffer.addElement(this);
		}
	}
	
	public function hide() {
		if (isAdded) {
			isAdded = false;
			buffer.removeElement(this);
		}			
	}
	
	public function update(posSize:Border, mask:Border, z:Int) {
		if (mask != null) {
			
			if (insideMask && isOutsideMask(posSize, mask)) {
				buffer.removeElement(this);
				insideMask = false;
			}
			else {
				x = posSize.left;
				y = posSize.top;
				w = posSize.right - x;
				h = posSize.bottom - y;
				maskLeft = (x > mask.left) ? 0 : mask.left - x;
				maskTop = (y > mask.top) ? 0 : mask.top - y;
				maskRight = (posSize.right < mask.right) ? w : w - (posSize.right - mask.right);
				maskBottom = (posSize.bottom < mask.bottom) ? h : h - (posSize.bottom - mask.bottom);
				
				if (!insideMask) {
					buffer.addElement(this);
					insideMask = true;
				} 
				else buffer.updateElement(this);
			}
			
		} 
		else {
			x = posSize.left;
			y = posSize.top;
			w = posSize.right - x;
			h = posSize.bottom - y;
			maskLeft = 0;
			maskTop = 0;
			maskRight = w;
			maskBottom = h;
			
			if (!insideMask) {
				buffer.addElement(this);
				insideMask = true;
			} 
			else buffer.updateElement(this);
		}
		
	}
	
	public inline function isOutsideMask(posSize:Border, mask:Border) {
		if (posSize.bottom < mask.top) return true;
		if (posSize.top > mask.bottom) return true;
		if (posSize.right < mask.left) return true;
		if (posSize.left > mask.right) return true;
		
		return false;
	}
	
	
	
}
