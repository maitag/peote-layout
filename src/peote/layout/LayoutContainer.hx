package peote.layout;

import jasper.Variable;
import jasper.Expression;
import jasper.Term;
import jasper.Strength;
import jasper.Constraint;
import jasper.Solver;

import peote.layout.util.SizeSpaced;

typedef InnerLimit = { width:Int, height:Int }


class LayoutContainer
{
	public var containerType:ContainerType;
	public var layoutElement:LayoutElement;
	public var layout:Layout;
	
	public var solver:Null<Solver>;
	
	public var parent:LayoutContainer = null;
	var childs:Array<LayoutContainer> = null;
		
	public var isRoot(get, never):Bool;
	inline function get_isRoot():Bool return (parent == null);
	
	// masked by parent layoutcontainer
	public var isHidden:Bool = false;
	public var isMasked:Bool = false;
	public var maskX(default,null):Float;
	public var maskY(default,null):Float;
	public var maskWidth(default,null):Float;
	public var maskHeight(default,null):Float;
		
	
	// Position and Size (suggesting/accessing jasper-vars)
	public var x(get,set):Null<Float>;
	inline function get_x():Null<Float> return _x.m_value;
	inline function set_x(value:Null<Float>):Null<Float> return suggestValue(_x, value);
	
	public var y(get,set):Null<Float>;
	inline function get_y():Null<Float> return _y.m_value;
	inline function set_y(value:Null<Float>):Null<Float> return suggestValue(_y, value);
	
	public var width(get,set):Null<Float>;
	inline function get_width():Null<Float> return _width.m_value;
	inline function set_width(value:Null<Float>):Null<Float> return suggestValue(_width, value);
	
	public var height(get,set):Null<Float>;
	inline function get_height() return _height.m_value;
	inline function set_height(value:Null<Float>):Null<Float> return suggestValue(_height, value);

	inline function suggestValue(variable:Variable, value:Null<Float>):Null<Float> {
		if (solver == null) throw('Error: can\'t set ${variable.m_name} value of LayoutContainer if its not initialized.');
		
		//if (value == null && heightIsEditable) {
		if (value == null && solver.hasEditVariable(variable)) {
			//heightIsEditable = false;
			solver.removeEditVariable(variable);
			return null;
		}
		
		//if (!heightIsEditable) {
		if (!solver.hasEditVariable(variable)) {
			//heightIsEditable = true;
			solver.addEditVariable(variable, strength);
		}
		solver.suggestValue(variable, value);
		return value;
	}

	// TODO: for inner size:
	// scrollWidth, scrollHeight
	
	// ---------- Variables for Jasper Constraints ------
	public var xScroll(default,null):Variable;

	public var _x(default,null):Variable;
	public var _y(default,null):Variable;	

	public var _width(default,null):Variable;
	public var _height(default,null):Variable;	
	
	public var _centerX:Expression; // TODO: check public/rw-access
	public var _centerY:Expression;

	public var _left(get,never):Expression;
	function get__left():Expression {
		if (hSize.first != null) return new Term(_x) - hSize.first.size;
		else return new Expression([new Term(_x)]);
	}
	public var _right(get,never):Expression;
	function get__right():Expression {
		if (hSize.last != null) return new Term(_x) + _width + hSize.last.size;
		else return new Term(_x) + _width;
	}
	public var _top(get, never):Expression;
	function get__top():Expression {
		if (vSize.first != null) return new Term(_y) - vSize.first.size;
		else return new Expression([new Term(_y)]);
	}
	public var _bottom(get,never):Expression;
	function get__bottom():Expression {
		if (vSize.last != null) return new Term(_y) + _height + vSize.last.size;
		else return new Term(_y) + _height;
	}
	
	public var hSize:SizeSpaced;
	public var vSize:SizeSpaced;
			
	static var strength = Strength.create(0, 900, 0);
	static var strengthLow = Strength.create(0, 0, 900);
	
	// ----------------------------------------------------------------------------------------
	// storing constraints
	public var customConstraints:Array<Constraint>;
	
	
	// ----------------------------------------------------------------------------------------
	// --------------------------------- NEW --------------------------------------------------
	// ----------------------------------------------------------------------------------------
	public function new(containerType:ContainerType = ContainerType.BOX, layoutElement:LayoutElement = null, layout:Layout = null, childs:Array<LayoutContainer> = null) 
	{
		set_containerType(containerType);
		set_layoutElement(layoutElement);
		set_layout(layout);
		set_childs(childs);
				
		xScroll = new Variable();// TODO !
		
		_x = new Variable();
		_y = new Variable();
		_width = new Variable();
		_height = new Variable();
		
		_centerX = new Term(_x) + (_width / 2.0);
		_centerY = new Term(_y) + (_height / 2.0);
	}
	
	function set_containerType(containerType:ContainerType) {
		this.containerType = containerType;
		// TODO: update
	}
	
	function set_layoutElement(layoutElement:LayoutElement) {
		this.layoutElement = layoutElement;
		// TODO: update
	}
	
	function set_layout(layout:Layout) {
		this.layout = (layout != null) ? layout : {};
		hSize = new SizeSpaced(this.layout.width, this.layout.left, this.layout.right);
		vSize = new SizeSpaced(this.layout.height, this.layout.top, this.layout.bottom);		
		// TODO: update
	}
	
	function set_childs(childs:Array<LayoutContainer>) {
		if (childs != null) {
			for (child in childs) child.parent = this;
		}
		this.childs = childs;
		// TODO: update
	}
	
	var root_width:Variable;
	var root_height:Variable;
	
	// TODO: init automatically if not already
	public function init() // TODO !
	{
		solver = new Solver();
		
		root_width = new Variable();
		root_height = new Variable();
		solver.addEditVariable(root_width, strength);
		solver.addEditVariable(root_height, strength);
		
		
		var innerLimit = addTreeConstraints(solver); // recursive Container
		//trace(innerLimit._width);
		
		// --------------------------------- horizontal ---------------------------------------				
		fixLimit(hSize, innerLimit.width);
		fixSpacer(null, hSize);
		
		var hSizeLimitVar = hSize.setSizeLimit(null);
		if (hSizeLimitVar != null) {
			solver.addConstraint( (hSizeLimitVar >= 0) | strength );
		}
		var hSizeSpanVar = hSize.setSizeSpan(null);
		if (hSizeSpanVar != null) {
			solver.addConstraint( (hSizeSpanVar >= 0) | strength );
			solver.addConstraint( (hSizeSpanVar == (root_width - hSize.getLimitMax()) / hSize.getSumWeight() ) | strengthLow );
		}
		solver.addConstraint( (_width == hSize.middle.size) | strength );
		
		solver.addConstraint( (_left == 0) | strength );
		solver.addConstraint( (_right == root_width) | strengthLow );
				
		// --------------------------------- vertical ---------------------------------------
		fixLimit(vSize, innerLimit.height);
		fixSpacer(null, vSize);
				
		var vSizeLimitVar = vSize.setSizeLimit(null);
		if (vSizeLimitVar != null) {
			solver.addConstraint( (vSizeLimitVar >= 0) | strength );
		}
		var vSizeSpanVar = vSize.setSizeSpan(null);
		if (vSizeSpanVar != null) {
			solver.addConstraint( (vSizeSpanVar >= 0) | strength );
			solver.addConstraint( (vSizeSpanVar == (root_height - vSize.getLimitMax()) / vSize.getSumWeight() ) | strengthLow );
		}
		solver.addConstraint( (_height == vSize.middle.size) | strength );
		
		solver.addConstraint( (_top == 0) | strength );
		solver.addConstraint( (_bottom == root_height) | strengthLow );				
	}
	
	public function update(width:Float, height:Float)
	{
		if (solver != null) {
			solver.suggestValue(root_width, width);
			solver.suggestValue(root_height, height);
			solver.updateVariables();
			
			updateLayoutElement();
		}
	}
	
	function updateLayoutElement()
	{
		updateMask();
		
		layoutElement.updateByLayout(this);
		if (childs != null) for (child in childs) child.updateLayoutElement();
	}
	
	function updateMask()
	{
		isMasked = false;
		isHidden = false;

		if (isRoot) {
			maskX = 0;
			maskY = 0;
			maskWidth = width;
			maskHeight = height;
		}
		else {
			if (parent.isHidden) {
				isMasked = true;
				isHidden = true;
			}
			else
			{				
				maskX = parent.x + parent.maskX - x;
				if (maskX > 0) {
					isMasked = true;
					maskWidth = width - maskX;
					if (maskWidth < 0) isHidden = true;
					else if (maskWidth > parent.maskWidth) maskWidth = parent.maskWidth;
				}
				else {
					maskWidth = parent.maskWidth + maskX;
					if (maskWidth >= width) maskWidth = width;
					else {
						isMasked = true;
						if (maskWidth < 0) isHidden = true;
					}
					maskX = 0;
				}
				
				if (!isHidden) {
					maskY = parent.y + parent.maskY - y;
					if (maskY > 0) {
						isMasked = true;
						maskHeight = height - maskY;
						if (maskHeight < 0) isHidden = true;
						else if (maskHeight > parent.maskHeight) maskHeight = parent.maskHeight;
					}
					else {
						maskHeight = parent.maskHeight + maskY;
						if (maskHeight >= height) maskHeight = height;
						else {
							isMasked = true;
							if (maskHeight < 0) isHidden = true;
						}
						maskY = 0;
					}
				}
			}
		}
	}
	
	
	// TODO:
	public function addChild(child:LayoutContainer) {
		
	}
	
	public function removeChild(child:LayoutContainer) {
		
	}
	
	public function show() {
		
	}
	
	public function hide() {
		
	}
	
	public inline function addConstraint(constraint:Constraint) {
		if (customConstraints == null) customConstraints = new Array<Constraint>();
		customConstraints.push(constraint);
		if (solver != null && !solver.hasConstraint(constraint)) solver.addConstraint(constraint);
	}
	
	public inline function removeConstraint(constraint:Constraint) {
		if (customConstraints != null) customConstraints.remove(constraint);
		if (solver != null && solver.hasConstraint(constraint)) solver.removeConstraint(constraint);
	}
	
	public function addConstraints(constraints:Array<Constraint>) {
		for (constraint in constraints)	addConstraint(constraint);
	}
	
	public function removeConstraints(constraints:Array<Constraint>) {
		for (constraint in constraints)	removeConstraint(constraint);
	}
	
	// -----------------------------------------------------------------------------------------------------
	// -----------------------------------------------------------------------------------------------------
	// -----------------------------------------------------------------------------------------------------

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
			if (size == null || (size.middle._span || childSize.getLimitMax() < ( (size.middle._max != null) ? size.middle._max : size.middle._min) ))
			{
				if (childSize.first != null && childSize.last != null) {
					childSize.first._span = true;
					childSize.last._span = true;
				}
				else {
					if (childSize.first == null) childSize.first = Size.min();
					if (childSize.last  == null) childSize.last = Size.min();
				}
			}					
		}		
	}

	// -----------------------------------------------------------------------------------------------------
		
	function addTreeConstraints(solver:Solver):InnerLimit
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
	
	
	// ----------------------------------- BOX ------------------------------------------
	
	inline function addConstraintsBOX(solver:Solver):InnerLimit
	{	
		var childsLimit = {width:0, height:0};
		if (childs != null)
		{
			for (child in childs)
			{	
				// ------------------------- recursive childs --------------------------
				var innerLimit = child.addTreeConstraints(solver);
				
				// --------------------------------- horizontal ---------------------------------------				
				fixLimit(child.hSize, innerLimit.width);
				fixSpacer(hSize, child.hSize);
				
				if (child.hSize.getMin() > childsLimit.width) childsLimit.width = child.hSize.getMin();
				
				var hSizeLimitVar = child.hSize.setSizeLimit(null);
				if (hSizeLimitVar != null) {
					solver.addConstraint( (hSizeLimitVar >= 0) | strength );
				}
				var hSizeSpanVar = child.hSize.setSizeSpan(null);
				if (hSizeSpanVar != null) {
					solver.addConstraint( (hSizeSpanVar >= 0) | strength );
					solver.addConstraint( (hSizeSpanVar == (_width - child.hSize.getLimitMax()) / child.hSize.getSumWeight() ) | strengthLow );
				}
				solver.addConstraint( (child._width == child.hSize.middle.size) | strength );
		
				solver.addConstraint( (child._left == _x) | strength );
				solver.addConstraint( (child._right == _x + _width) | strength );
				
				// --------------------------------- vertical ---------------------------------------
				fixLimit(child.vSize, innerLimit.height);
				fixSpacer(vSize, child.vSize);
				
				if (child.vSize.getMin() > childsLimit.height) childsLimit.height = child.vSize.getMin();
				
				var vSizeLimitVar = child.vSize.setSizeLimit(null);
				if (vSizeLimitVar != null) {
					solver.addConstraint( (vSizeLimitVar >= 0) | strength );
				}
				var vSizeSpanVar = child.vSize.setSizeSpan(null);
				if (vSizeSpanVar != null) {
					solver.addConstraint( (vSizeSpanVar >= 0) | strength );
					solver.addConstraint( (vSizeSpanVar == (_height - child.vSize.getLimitMax()) / child.vSize.getSumWeight() ) | strengthLow );
				}
				solver.addConstraint( (child._height == child.vSize.middle.size) | strength );				
				
				solver.addConstraint( (child._top == _y) | strength );
				solver.addConstraint( (child._bottom == _y + _height) | strength );				
			}
		}
		return childsLimit;
	}

	
	
	// ----------------------------------- HBOX ------------------------------------------
	inline function fixHMaxSpan():Int {
		var hLimitMax:Int = 0;
		var noChildHasSpan = true;
		for (child in childs) {
			if (noChildHasSpan && child.hSize.hasSpan()) noChildHasSpan = false;
			hLimitMax += child.hSize.getLimitMax();
		}
		if (noChildHasSpan && childs.length > 0) {
			if ( hSize.middle._span || hLimitMax < ( (hSize.middle._max != null) ? hSize.middle._max : hSize.middle._min) )
			{
				if (childs[0].hSize.first != null && childs[childs.length-1].hSize.last != null) {
					childs[0].hSize.first._span = true;
					childs[childs.length-1].hSize.last._span = true;
				}
				else {
					if (childs[0].hSize.first == null) childs[0].hSize.first = Size.min();
					if (childs[childs.length-1].hSize.last  == null) childs[childs.length-1].hSize.last = Size.min();
				}					
			}					
		}
		return hLimitMax;
	}
	
	
	// TODO: set- and removeConstraint... functions

	
		
	inline function addConstraintsHBOX(solver:Solver):InnerLimit
	{
		var childsLimit = {width:0, height:0};
		
		if (childs != null)
		{
			var hSizeLimitVar:Null<Variable> = null;
			var hSizeSpanVar:Null<Variable> = null;
			
			var hSumWeight:Float = 0.0;
			var hLimitMax:Int = fixHMaxSpan();
			
			for (i in 0...childs.length)
			{	
				var child = childs[i];
				// ------------------------- recursive childs --------------------------
				var innerLimit = child.addTreeConstraints(solver);			
				
				// --------------------------------- horizontal ---------------------------------------				
				fixLimit(child.hSize, innerLimit.width);
				
				childsLimit.width += child.hSize.getMin();
				
				hSizeLimitVar = child.hSize.setSizeLimit(hSizeLimitVar);
				hSizeSpanVar = child.hSize.setSizeSpan(hSizeSpanVar);
// setConstraintToMiddleSize
				solver.addConstraint( (child._width == child.hSize.middle.size) | strength );
				//solver.addConstraint( (child._width == child.hSize.middle.size) | strengthLow ); // sonst funzen keine custom constraints !!!
				
				hSumWeight += child.hSize.getSumWeight();
				
// setConstraintConnectToNeighboars
				if (i == 0) solver.addConstraint( (child._left == _x) | strength ); // first
				else solver.addConstraint( (child._left == childs[i-1]._right) | strength ); // not first
				if (i == childs.length - 1) solver.addConstraint( (child._right == _x + _width) | strength ); // last
				
				// --------------------------------- vertical ---------------------------------------
				fixLimit(child.vSize, innerLimit.height);
				fixSpacer(vSize, child.vSize);
				
				if (child.vSize.getMin() > childsLimit.height) childsLimit.height = child.vSize.getMin();
//B Limit				
				var vSizeLimitVar = child.vSize.setSizeLimit(null);
				if (vSizeLimitVar != null) {
					solver.addConstraint( (vSizeLimitVar >= 0) | strength );
				}
				
//B Span				
				var vSizeSpanVar = child.vSize.setSizeSpan(null);
				if (vSizeSpanVar != null) {
					solver.addConstraint( (vSizeSpanVar >= 0) | strength );
					solver.addConstraint( (vSizeSpanVar == (_height - child.vSize.getLimitMax()) / child.vSize.getSumWeight() ) | strengthLow );
				}
				
//B child._height				
				solver.addConstraint( (child._height == child.vSize.middle.size) | strength );				
				//solver.addConstraint( (child._height == child.vSize.middle.size) | strengthLow ); // sonst funzen keine custom constraints !!!			
				
// setConstraintConnectToParent			
				solver.addConstraint( (child._top == _y) | strength );
				solver.addConstraint( (child._bottom == _y + _height) | strength );
			}
			
//A Limit				
			if (hSizeLimitVar != null) {
				solver.addConstraint( (hSizeLimitVar >= 0) | strength );
			}
//A Span				
			if (hSizeSpanVar != null) {//trace(hLimitMax, hSumWeight);
				solver.addConstraint( (hSizeSpanVar >= 0) | strength );
				solver.addConstraint( (hSizeSpanVar == (_width - hLimitMax) / hSumWeight ) | strengthLow );			
			}
		}		
		return childsLimit;
	}
	
	// ----------------------------------- VBOX ------------------------------------------
	inline function fixVMaxSpan():Int {
		var vLimitMax:Int = 0;
		var noChildHasSpan = true;
		for (child in childs) {
			if (noChildHasSpan && child.vSize.hasSpan()) noChildHasSpan = false;
			vLimitMax += child.vSize.getLimitMax();
		}		
		if (noChildHasSpan && childs.length>0) {
			if ( vSize.middle._span || vLimitMax < ( (vSize.middle._max != null) ? vSize.middle._max : vSize.middle._min) )
			{
				if (childs[0].vSize.first != null && childs[childs.length-1].vSize.last != null) {
					childs[0].vSize.first._span = true;
					childs[childs.length-1].vSize.last._span = true;
				}
				else {
					if (childs[0].vSize.first == null) childs[0].vSize.first = Size.min();
					if (childs[childs.length-1].vSize.last  == null) childs[childs.length-1].vSize.last = Size.min();
				}
			}
		}
		return vLimitMax;
	}
		
	inline function addConstraintsVBOX(solver:Solver):InnerLimit
	{
		var childsLimit = {width:0, height:0};

		if (childs != null)
		{
			var vSizeLimitVar:Null<Variable> = null;
			var vSizeSpanVar:Null<Variable> = null;

			var vSumWeight:Float = 0.0;			
			var vLimitMax:Int = fixVMaxSpan();
			
			for (i in 0...childs.length)
			{	
				var child = childs[i];
				// ------------------------- recursive childs --------------------------
				var innerLimit = child.addTreeConstraints(solver);			
				
				// --------------------------------- horizontal ---------------------------------------				
				fixLimit(child.hSize, innerLimit.width);
				fixSpacer(hSize, child.hSize);
				
				if (child.hSize.getMin() > childsLimit.width) childsLimit.width = child.hSize.getMin();
				
				var hSizeLimitVar = child.hSize.setSizeLimit(null);
				if (hSizeLimitVar != null) {
					solver.addConstraint( (hSizeLimitVar >= 0) | strength );
				}
				var hSizeSpanVar = child.hSize.setSizeSpan(null);
				if (hSizeSpanVar != null) {
					solver.addConstraint( (hSizeSpanVar >= 0) | strength );
					solver.addConstraint( (hSizeSpanVar == (_width - child.hSize.getLimitMax()) / child.hSize.getSumWeight() ) | strengthLow );
				}
				solver.addConstraint( (child._width == child.hSize.middle.size) | strength );
				
				solver.addConstraint( (child._left == _x) | strength );
				solver.addConstraint( (child._right == _x + _width) | strength );
				
				// --------------------------------- vertical ---------------------------------------
				fixLimit(child.vSize, innerLimit.height);
				
				childsLimit.height += child.vSize.getMin();
				
				vSizeLimitVar = child.vSize.setSizeLimit(vSizeLimitVar);
				vSizeSpanVar = child.vSize.setSizeSpan(vSizeSpanVar);
				solver.addConstraint( (child._height == child.vSize.middle.size) | strength );
				
				vSumWeight += child.vSize.getSumWeight();
				
				if (i == 0) solver.addConstraint( (child._top == _y) | strength ); // first
				else solver.addConstraint( (child._top == childs[i-1]._bottom) | strength ); // not first
				if (i == childs.length - 1) solver.addConstraint( (child._bottom == _y + _height) | strength ); // last
			}
			
			if (vSizeLimitVar != null) {
				solver.addConstraint( (vSizeLimitVar >= 0) | strength );
			}
			if (vSizeSpanVar != null) {
				solver.addConstraint( (vSizeSpanVar >= 0) | strength );
				solver.addConstraint( (vSizeSpanVar == (_height - vLimitMax) / vSumWeight ) | strengthLow );			
			}
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
				var innerLimit = child.addTreeConstraints(solver);				
				
				// --------------------------------- horizontal ---------------------------------------				
				fixLimit(child.hSize, innerLimit.width);
				fixSpacer(hSize, child.hSize);
				
				//if (child.hSize.getMin() > childsLimit._width) childsLimit._width = child.hSize.getMin();
				
				var hSizeLimitVar = child.hSize.setSizeLimit(null);
				if (hSizeLimitVar != null) {
					solver.addConstraint( (hSizeLimitVar >= 0) | strength );
				}
				var hSizeSpanVar = child.hSize.setSizeSpan(null);
				if (hSizeSpanVar != null) {
					solver.addConstraint( (hSizeSpanVar >= 0) | strength );
					solver.addConstraint( (hSizeSpanVar == (_width - child.hSize.getLimitMax()) / child.hSize.getSumWeight() ) | strengthLow );
				}
				solver.addConstraint( (child._width == child.hSize.middle.size) | strength );
				
				// TODO: xScroll 
				solver.addConstraint( (child._left == _x - xScroll) | strength );
				solver.addConstraint( (child._right == _x + _width - xScroll) | strengthLow );
				
				// --------------------------------- vertical ---------------------------------------
				fixLimit(child.vSize, innerLimit.height);
				fixSpacer(vSize, child.vSize);
				
				if (child.vSize.getMin() > childsLimit.height) childsLimit.height = child.vSize.getMin();
				
				var vSizeLimitVar = child.vSize.setSizeLimit(null);
				if (vSizeLimitVar != null) {
					solver.addConstraint( (vSizeLimitVar >= 0) | strength );
				}
				var vSizeSpanVar = child.vSize.setSizeSpan(null);
				if (vSizeSpanVar != null) {
					solver.addConstraint( (vSizeSpanVar >= 0) | strength );
					solver.addConstraint( (vSizeSpanVar == (_height - child.vSize.getLimitMax()) / child.vSize.getSumWeight() ) | strengthLow );
				}
				solver.addConstraint( (child._height == child.vSize.middle.size) | strength );				
				
				solver.addConstraint( (child._top == _y) | strength );
				solver.addConstraint( (child._bottom == _y + _height) | strength );				
			}
		}
		return childsLimit;
	}
	
	
	
}

// ------------------------------------------------------------------------------------------
// ---------------------- shortener for the different container-types -----------------------
// ------------------------------------------------------------------------------------------
@:forward
abstract Box(LayoutContainer) from LayoutContainer to LayoutContainer {
	public inline function new(layoutElement:LayoutElement = null, layout:Layout = null, innerLayoutContainer:Array<LayoutContainer> = null) 
	{
		this = new LayoutContainer(ContainerType.BOX, layoutElement, layout, innerLayoutContainer);
	}
}

@:forward
abstract HBox(LayoutContainer) from LayoutContainer to LayoutContainer {
	public inline function new(layoutElement:LayoutElement = null, layout:Layout = null, innerLayoutContainer:Array<LayoutContainer> = null) 
	{
		this = new LayoutContainer(ContainerType.HBOX, layoutElement, layout, innerLayoutContainer);
	}
}

@:forward
abstract VBox(LayoutContainer) from LayoutContainer to LayoutContainer {
	public inline function new(layoutElement:LayoutElement = null, layout:Layout = null, innerLayoutContainer:Array<LayoutContainer> = null) 
	{
		this = new LayoutContainer(ContainerType.VBOX, layoutElement, layout, innerLayoutContainer);
	}
}

