package peote.layout;

@:allow(peote.layout.Layout)
@:publicFields
private class LayoutImpl
{
	#if peotelayout_debug
	var name(default, null):String = "";
	#end
	
	// inner size
	var width (default, null):Size;
	var height(default, null):Size;
	
	// outer margins
	var left  (default, null):Size;
	var right (default, null):Size;
	var top   (default, null):Size;
	var bottom(default, null):Size;
	
	// container options
	var scrollX(default, null):Bool = false;
	var scrollY(default, null):Bool = false;
	
	var alignChildsOnOversizeX(default, null):Align = Align.AUTO;
	var alignChildsOnOversizeY(default, null):Align = Align.AUTO;
	
	var limitMinWidthToChilds(default, null):Bool = true;
	var limitMaxWidthToChilds(default, null):Bool = false;
	var limitMinHeightToChilds(default, null):Bool = true;
	var limitMaxHeightToChilds(default, null):Bool = false;
	
	var relativeChildPositions(default, null):Bool = false;
	var absolutePosition(default, null):Bool = false;
	
	public inline function new() {}
}

@:forward
abstract Layout(LayoutImpl) from LayoutImpl
{
	public inline function new(
		#if peotelayout_debug
		?name:String = "",
		#end
		?width:Size, ?height:Size, ?left:Size, ?right:Size, ?top:Size, ?bottom:Size,
		scrollX:Bool = false, scrollY:Bool = false,
		alignChildsOnOversizeX:Align = Align.AUTO,
		alignChildsOnOversizeY:Align = Align.AUTO,
		limitMinWidthToChilds:Bool = true,
		limitMaxWidthToChilds:Bool = false,
		limitMinHeightToChilds:Bool = true,
		limitMaxHeightToChilds:Bool = false,
		relativeChildPositions:Bool = false,
		absolutePosition:Bool = false)
	{
		this = new LayoutImpl();
		#if peotelayout_debug
		this.name = name;
		#end
		this.width  = width;
		this.height = height;
		this.left   = left;
		this.right  = right;
		this.top    = top;
		this.bottom = bottom;
		this.scrollX = scrollX;
		this.scrollY = scrollY;
		this.alignChildsOnOversizeX = alignChildsOnOversizeX;
		this.alignChildsOnOversizeY = alignChildsOnOversizeY;
		this.limitMinWidthToChilds = limitMinWidthToChilds;
		this.limitMaxWidthToChilds = limitMaxWidthToChilds;
		this.limitMinHeightToChilds = limitMinHeightToChilds;
		this.limitMaxHeightToChilds = limitMaxHeightToChilds;
		this.relativeChildPositions = relativeChildPositions;
		this.absolutePosition = absolutePosition;
	}
	
	@:from static #if !neko inline #end function fromLayoutOptions(p:LayoutOptions):Layout
	{
		var layout:Layout = new LayoutImpl();
		layout.update(p);
		return layout;
	}
	
	public inline function update(p:LayoutOptions):Void
	{
		if (p == null) return;
		#if peotelayout_debug
		if (p.name  != null) this.name  = p.name;
		#end
		if (p.width  != null) this.width  = p.width;
		if (p.height != null) this.height = p.height;
		if (p.left   != null) this.left   = p.left;
		if (p.right  != null) this.right  = p.right;
		if (p.top    != null) this.top    = p.top;
		if (p.bottom != null) this.bottom = p.bottom;
		if (p.scrollX != null) this.scrollX = p.scrollX;
		if (p.scrollY != null) this.scrollY = p.scrollY;
		if (p.alignChildsOnOversizeX != null) this.alignChildsOnOversizeX = p.alignChildsOnOversizeX;
		if (p.alignChildsOnOversizeY != null) this.alignChildsOnOversizeY = p.alignChildsOnOversizeY;
		if (p.limitMinWidthToChilds  != null) this.limitMinWidthToChilds  = p.limitMinWidthToChilds;
		if (p.limitMaxWidthToChilds  != null) this.limitMaxWidthToChilds  = p.limitMaxWidthToChilds;
		if (p.limitMinHeightToChilds != null) this.limitMinHeightToChilds = p.limitMinHeightToChilds;
		if (p.limitMaxHeightToChilds != null) this.limitMaxHeightToChilds = p.limitMaxHeightToChilds;
		if (p.relativeChildPositions != null) this.relativeChildPositions = p.relativeChildPositions;
		if (p.absolutePosition       != null) this.absolutePosition       = p.absolutePosition;
	}
}
