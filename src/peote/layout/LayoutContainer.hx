package peote.layout;

import jasper.Variable;
import jasper.Expression;
import jasper.Term;
import jasper.Strength;
import jasper.Solver;

import peote.layout.util.SizeVars;
import peote.layout.util.SizeSpaced;

typedef InnerLimit = { width:Int, height:Int }

class LayoutContainer
{
	public var containerType:ContainerType;
	public var layout:Layout;
	public var displayElement:LayoutElement;
	
	var solver:Solver;
	
	public var parent:LayoutContainer;
	var childs:Array<LayoutContainer>;
	
	// ----------
	public var xScroll(default,null):Variable;

	public var x(default,null):Variable;
	public var y(default,null):Variable;	

	public var width(default,null):Variable;
	public var height(default,null):Variable;	
	
	public var centerX:Expression; // TODO: check public/rw-access
	public var centerY:Expression;

	public var left(get,never):Expression;
	function get_left():Expression {
		if (hSize.first != null) return new Term(x) - hSize.first.size;
		else return new Expression([new Term(x)]);
	}
	public var right(get,never):Expression;
	function get_right():Expression {
		if (hSize.last != null) return new Term(x) + width + hSize.last.size;
		else return new Term(x) + width;
	}
	public var top(get, never):Expression;
	function get_top():Expression {
		if (vSize.first != null) return new Term(y) - vSize.first.size;
		else return new Expression([new Term(y)]);
	}
	public var bottom(get,never):Expression;
	function get_bottom():Expression {
		if (vSize.last != null) return new Term(y) + height + vSize.last.size;
		else return new Term(y) + height;
	}
	
	public var hSize:SizeSpaced;
	public var vSize:SizeSpaced;
			
	public function new(containerType:ContainerType = ContainerType.BOX, displayElement:LayoutElement = null, layout:Layout = null, innerLayoutContainer:Array<LayoutContainer> = null) 
	{
		this.containerType = containerType;
		this.layout = layout;
		hSize = new SizeSpaced(layout.width, layout.left, layout.right);
		vSize = new SizeSpaced(layout.height, layout.top, layout.bottom);
		
		childs = innerLayoutContainer;
		

		xScroll = new Variable();// TODO !
		
		x = new Variable();
		y = new Variable();
		width = new Variable();
		height = new Variable();
		
		centerX = new Term(x) + (width / 2.0);
		centerY = new Term(y) + (height / 2.0);
	}
	

	
	function init() // TODO !
	{
		solver = new Solver();
		// recursive Container
		var innerLimit = addConstraints(solver);
		//trace(innerLimit.width);
		solver.addConstraint( (width >= innerLimit.width) | Strength.create(0,900,0) );
		solver.addConstraint( (height >= innerLimit.height) | Strength.create(0,900,0) );
	}
	
	
	
	
	inline function addHConstraints(solver:Solver, sizeVars:SizeVars, strength:Strength):SizeVars {
		sizeVars = hSize.addConstraints(solver, sizeVars, strength);
		solver.addConstraint( (width == hSize.middle.size) | strength );
		return sizeVars;
	}
	
	inline function addVConstraints(solver:Solver, sizeVars:SizeVars, strength:Strength):SizeVars {
		sizeVars = vSize.addConstraints(solver, sizeVars, strength);
		solver.addConstraint( (height == vSize.middle.size) | strength );
		return sizeVars;
	}
	
	static inline function fixLimit(childSize:SizeSpaced, limit:Int) 
	{
		if (childSize.middle._min < limit) {
			childSize.middle._min = limit;
			if (childSize.middle._max != null) childSize.middle._max = Std.int(Math.max(childSize.middle._max, childSize.middle._min));
		}		
	}
	
	static inline function fixSpacer(size:SizeSpaced, childSize:SizeSpaced) 
	{
		if (!childSize.hasSpan()) {
			if ( size.middle.span || childSize.getLimitMax() < ( (size.middle._max != null) ? size.middle._max : size.middle._min) )
			{
				if (childSize.first != null && childSize.last != null) {
					childSize.first.span = true;
					childSize.last.span = true;
				}
				else {
					if (childSize.first == null) childSize.first = Size.min();
					if (childSize.last  == null) childSize.last = Size.min();
				}
			}					
		}		
	}

	inline function fixVSpan():Int {
		var vLimitMax:Int = 0;
		var noChildHasSpan = true;
		for (child in childs) {
			if (noChildHasSpan && child.vSize.hasSpan()) noChildHasSpan = false;
			vLimitMax += child.vSize.getLimitMax();
		}		
		if (noChildHasSpan && childs.length>0) {
			if ( vSize.middle.span || vLimitMax < ( (vSize.middle._max != null) ? vSize.middle._max : vSize.middle._min) )
			{
				if (childs[0].vSize.first != null && childs[childs.length-1].vSize.last != null) {
					childs[0].vSize.first.span = true;
					childs[childs.length-1].vSize.last.span = true;
				}
				else {
					if (childs[0].vSize.first == null) childs[0].vSize.first = Size.min();
					if (childs[childs.length-1].vSize.last  == null) childs[childs.length-1].vSize.last = Size.min();
				}
			}
		}
		return vLimitMax;
	}
	
	inline function fixHSpan():Int {
		var hLimitMax:Int = 0;
		var noChildHasSpan = true;
		for (child in childs) {
			if (noChildHasSpan && child.hSize.hasSpan()) noChildHasSpan = false;
			hLimitMax += child.hSize.getLimitMax();
		}
		if (noChildHasSpan && childs.length > 0) {
			if ( hSize.middle.span || hLimitMax < ( (hSize.middle._max != null) ? hSize.middle._max : hSize.middle._min) )
			{
				if (childs[0].hSize.first != null && childs[childs.length-1].hSize.last != null) {
					childs[0].hSize.first.span = true;
					childs[childs.length-1].hSize.last.span = true;
				}
				else {
					if (childs[0].hSize.first == null) childs[0].hSize.first = Size.min();
					if (childs[childs.length-1].hSize.last  == null) childs[childs.length-1].hSize.last = Size.min();
				}					
			}					
		}
		return hLimitMax;
	}
	
	// -----------------------------------------------------------------------------------------------------
	// -----------------------------------------------------------------------------------------------------
	// -----------------------------------------------------------------------------------------------------
		
	function addConstraints(solver:Solver):InnerLimit
	{
		switch (containerType) {
			case BOX    : return addConstraintsBOX(solver);
			case HBOX   : return addConstraintsHBOX(solver);
			case VBOX   : return addConstraintsVBOX(solver);
			case SCROLL : return addConstraintsSCROLL(solver);
			//case HSCROLL: return addConstraintsHSCROLL(solver);		
			//case VSCROLL: return addConstraintsVSCROLL(solver);		
		}
	}
	
	var strength = Strength.create(0, 900, 0); // TODO: gloabalstatic
	var strengthLow = Strength.create(0, 0, 900);		
	
	// ----------------------------------- BOX ------------------------------------------
	
	inline function addConstraintsBOX(solver:Solver):InnerLimit
	{	
		var childsLimit = {width:0, height:0};
		if (childs != null)
		{
			for (child in childs)
			{	
				// ------------------------- recursive childs --------------------------
				var innerLimit = child.addConstraints(solver);				
				
				// --------------------------------- horizontal ---------------------------------------				
				fixLimit(child.hSize, innerLimit.width);
				fixSpacer(hSize, child.hSize);
				
				if (child.hSize.getMin() > childsLimit.width) childsLimit.width = child.hSize.getMin();
				
				var hSizeVars = child.addHConstraints(solver, {sLimit:null, sSpan:null}, strength);				
				if (hSizeVars.sSpan != null) solver.addConstraint( (hSizeVars.sSpan == (width - child.hSize.getLimitMax()) / child.hSize.getSumWeight() ) | strengthLow );
				
				solver.addConstraint( (child.left == x) | strength );
				solver.addConstraint( (child.right == x + width) | strength );
				
				// --------------------------------- vertical ---------------------------------------
				fixLimit(child.vSize, innerLimit.height);
				fixSpacer(vSize, child.vSize);
				
				if (child.vSize.getMin() > childsLimit.height) childsLimit.height = child.vSize.getMin();
				
				var vSizeVars = child.addVConstraints(solver, {sLimit:null, sSpan:null}, strength);				
				if (vSizeVars.sSpan != null) solver.addConstraint( (vSizeVars.sSpan == (height - child.vSize.getLimitMax()) / child.vSize.getSumWeight() ) | strengthLow );
				
				solver.addConstraint( (child.top == y) | strength );
				solver.addConstraint( (child.bottom == y + height) | strength );				
			}
		}
		return childsLimit;
	}
	
	// ----------------------------------- HBOX ------------------------------------------
	
	inline function addConstraintsHBOX(solver:Solver):InnerLimit
	{
		var childsLimit = {width:0, height:0};
		
		if (childs != null)
		{
			var hSizeVars:SizeVars = {sLimit:null, sSpan:null};
			var hSumWeight:Float = 0.0;
			var hLimitMax:Int = fixHSpan();
			
			for (i in 0...childs.length)
			{	
				var child = childs[i];
				// ------------------------- recursive childs --------------------------
				var innerLimit = child.addConstraints(solver);			
				
				// --------------------------------- horizontal ---------------------------------------				
				fixLimit(child.hSize, innerLimit.width);
				
				childsLimit.width += child.hSize.getMin();
				
				hSizeVars = child.addHConstraints(solver, hSizeVars, strength);
				hSumWeight += child.hSize.getSumWeight();
				
				if (i == 0) solver.addConstraint( (child.left == x) | strength ); // first
				else solver.addConstraint( (child.left == childs[i-1].right) | strength ); // not first
				if (i == childs.length - 1) solver.addConstraint( (child.right == x + width) | strength ); // last
				
				// --------------------------------- vertical ---------------------------------------
				fixLimit(child.vSize, innerLimit.height);
				fixSpacer(vSize, child.vSize);
				
				if (child.vSize.getMin() > childsLimit.height) childsLimit.height = child.vSize.getMin();
				
				var vSizeVars = child.addVConstraints(solver, {sLimit:null, sSpan:null}, strength);				
				if (vSizeVars.sSpan != null) solver.addConstraint( (vSizeVars.sSpan == (height - child.vSize.getLimitMax()) / child.vSize.getSumWeight() ) | strengthLow );
				
				solver.addConstraint( (child.top == y) | strength );
				solver.addConstraint( (child.bottom == y + height) | strength );
			}
			
			if (hSizeVars.sSpan != null) solver.addConstraint( (hSizeVars.sSpan == (width - hLimitMax) / hSumWeight ) | strengthLow );			
		}		
		return childsLimit;
	}
	
	// ----------------------------------- VBOX ------------------------------------------
	
	inline function addConstraintsVBOX(solver:Solver):InnerLimit
	{
		var childsLimit = {width:0, height:0};

		if (childs != null)
		{
			var vSizeVars:SizeVars = {sLimit:null, sSpan:null};
			var vSumWeight:Float = 0.0;			
			var vLimitMax:Int = fixVSpan();
			
			for (i in 0...childs.length)
			{	
				var child = childs[i];
				// ------------------------- recursive childs --------------------------
				var innerLimit = child.addConstraints(solver);			
				
				// --------------------------------- horizontal ---------------------------------------				
				fixLimit(child.hSize, innerLimit.width);
				fixSpacer(hSize, child.hSize);
				
				if (child.hSize.getMin() > childsLimit.width) childsLimit.width = child.hSize.getMin();
				
				var hSizeVars = child.addHConstraints(solver, {sLimit:null, sSpan:null}, strength);				
				if (hSizeVars.sSpan != null) solver.addConstraint( (hSizeVars.sSpan == (width - child.hSize.getLimitMax()) / child.hSize.getSumWeight() ) | strengthLow );
				
				solver.addConstraint( (child.left == x) | strength );
				solver.addConstraint( (child.right == x + width) | strength );
				
				// --------------------------------- vertical ---------------------------------------
				fixLimit(child.vSize, innerLimit.height);
				
				childsLimit.height += child.vSize.getMin();
				
				vSizeVars = child.addVConstraints(solver, vSizeVars, strength);
				vSumWeight += child.vSize.getSumWeight();
				
				if (i == 0) solver.addConstraint( (child.top == y) | strength ); // first
				else solver.addConstraint( (child.top == childs[i-1].bottom) | strength ); // not first
				if (i == childs.length - 1) solver.addConstraint( (child.bottom == y + height) | strength ); // last
			}
			
			if (vSizeVars.sSpan != null) solver.addConstraint( (vSizeVars.sSpan == (height - vLimitMax) / vSumWeight ) | strengthLow );			
		}		
		return childsLimit;
	}


	// TODO:  
	
	// ----------------------------------- SCROLL ------------------------------------------
	
	inline function addConstraintsSCROLL(solver:Solver):InnerLimit
	{
		var childsLimit = {width:0, height:0};
		
		if (childs != null)
		{
			for (child in childs)
			{	
				// ------------------------- recursive childs --------------------------
				var innerLimit = child.addConstraints(solver);				
				
				// --------------------------------- horizontal ---------------------------------------				
				fixLimit(child.hSize, innerLimit.width);
				fixSpacer(hSize, child.hSize);
				
				//if (child.hSize.getMin() > childsLimit.width) childsLimit.width = child.hSize.getMin();
				
				var hSizeVars = child.addHConstraints(solver, {sLimit:null, sSpan:null}, strength);				
				if (hSizeVars.sSpan != null) solver.addConstraint( (hSizeVars.sSpan == (width - child.hSize.getLimitMax()) / child.hSize.getSumWeight() ) | strengthLow );
				
				// TODO: xScroll 
				solver.addConstraint( (child.left == x - xScroll) | strength );
				solver.addConstraint( (child.right == x + width - xScroll) | strengthLow );
				
				// --------------------------------- vertical ---------------------------------------
				fixLimit(child.vSize, innerLimit.height);
				fixSpacer(vSize, child.vSize);
				
				if (child.vSize.getMin() > childsLimit.height) childsLimit.height = child.vSize.getMin();
				
				var vSizeVars = child.addVConstraints(solver, {sLimit:null, sSpan:null}, strength);				
				if (vSizeVars.sSpan != null) solver.addConstraint( (vSizeVars.sSpan == (height - child.vSize.getLimitMax()) / child.vSize.getSumWeight() ) | strengthLow );
				
				solver.addConstraint( (child.top == y) | strength );
				solver.addConstraint( (child.bottom == y + height) | strength );				
			}
		}
		return childsLimit;
	}
	
	
	
	
	
	
}