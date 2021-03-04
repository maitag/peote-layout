package peote.layout;

@:allow(peote.layout.Layout)
@:publicFields
private class LayoutImpl
{
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
	
	var hAlignOnOversize(default, null):HAlign = HAlign.AUTO;
	var vAlignOnOversize(default, null):VAlign = VAlign.AUTO;
	
	var limitMinWidthToChilds(default, null):Bool = true;
	var limitMaxWidthToChilds(default, null):Bool = false;
	var limitMinHeightToChilds(default, null):Bool = true;
	var limitMaxHeightToChilds(default, null):Bool = false;
	
	var relativeChildPositions(default, null):Bool = false;
	
	public inline function new() {}
}

@:forward
abstract Layout(LayoutImpl) from LayoutImpl
{
	public inline function new(
		width:Size, height:Size, left:Size, right:Size, top:Size, bottom:Size,
		scrollX:Bool,
		scrollY:Bool,
		hAlignOnOversize:HAlign,
		vAlignOnOversize:VAlign,
		limitMinWidthToChilds:Bool,
		limitMaxWidthToChilds:Bool,
		limitMinHeightToChilds:Bool,
		limitMaxHeightToChilds:Bool,
		relativeChildPositions:Bool)
	{
		this = new LayoutImpl();
		this.width  = width;
		this.height = height;
		this.left   = left;
		this.right  = right;
		this.top    = top;
		this.bottom = bottom;
		this.scrollX = scrollX;
		this.scrollY = scrollY;
		this.hAlignOnOversize = hAlignOnOversize;
		this.limitMinWidthToChilds = limitMinWidthToChilds;
		this.limitMaxWidthToChilds = limitMaxWidthToChilds;
		this.limitMinHeightToChilds = limitMinHeightToChilds;
		this.limitMaxHeightToChilds = limitMaxHeightToChilds;
		this.relativeChildPositions = relativeChildPositions;
		this.relativeChildPositions = relativeChildPositions;
	}
	
	@:from static inline function fromLayoutOptions(p:LayoutOptions):Layout
	{
		var layout:Layout = new LayoutImpl();
		layout.update(p);
		return layout;
	}
	
	public inline function update(p:LayoutOptions):Void
	{
		if (p == null) return;
		if (p.width  != null) this.width  = p.width;
		if (p.height != null) this.height = p.height;
		if (p.left   != null) this.left   = p.left;
		if (p.right  != null) this.right  = p.right;
		if (p.top    != null) this.top    = p.top;
		if (p.bottom != null) this.bottom = p.bottom;
		if (p.scrollX != null) this.scrollX = p.scrollX;
		if (p.scrollY != null) this.scrollY = p.scrollY;
		if (p.hAlignOnOversize != null) this.hAlignOnOversize = p.hAlignOnOversize;
		if (p.vAlignOnOversize != null) this.vAlignOnOversize = p.vAlignOnOversize;
		if (p.limitMinWidthToChilds  != null) this.limitMinWidthToChilds  = p.limitMinWidthToChilds;
		if (p.limitMaxWidthToChilds  != null) this.limitMaxWidthToChilds  = p.limitMaxWidthToChilds;
		if (p.limitMinHeightToChilds != null) this.limitMinHeightToChilds = p.limitMinHeightToChilds;
		if (p.limitMaxHeightToChilds != null) this.limitMaxHeightToChilds = p.limitMaxHeightToChilds;
		if (p.relativeChildPositions != null) this.relativeChildPositions = p.relativeChildPositions;
	}
}
