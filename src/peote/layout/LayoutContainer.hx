package peote.layout;

import jasper.Variable;
import jasper.Expression;
import jasper.Term;
import jasper.Strength;
import jasper.Constraint;
import jasper.Solver;
import peote.layout.Align;
import peote.layout.ContainerOptions;
import peote.layout.Scroll;

import peote.layout.util.SizeSpaced;

typedef InnerLimit = { width:Int, height:Int }


class LayoutContainer
{
	// masked by parent layoutcontainer
	public var isHidden:Bool = false;
	public var isMasked:Bool = false;
	public var maskX(default,null):Float;
	public var maskY(default,null):Float;
	public var maskWidth(default,null):Float;
	public var maskHeight(default,null):Float;
		
	
	// Position and Size (suggesting/accessing jasper-vars)
	var xParentOffset:Float = 0;
	public var x(get,set):Null<Float>;
	inline function get_x():Null<Float> return _x.m_value - xParentOffset;
	inline function set_x(value:Null<Float>):Null<Float> return suggestValue(_x, value - xParentOffset);
	
	var yParentOffset:Float = 0;
	public var y(get,set):Null<Float>;
	inline function get_y():Null<Float> return _y.m_value - yParentOffset;
	inline function set_y(value:Null<Float>):Null<Float> return suggestValue(_y, value - yParentOffset);
	
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

	// scrolling
	public var xScroll(get,set):Null<Float>;
	inline function get_xScroll() {
		//if (Align.hasLeft(align)) 
			return _xScroll.m_value;
		//else if (Align.hasRight(align)) 
			//return 200-_xScroll.m_value;
		//else 
			//return 100-_xScroll.m_value;
	}
	inline function set_xScroll(value:Null<Float>):Null<Float> {
		if (solver == null) throw('Error: can\'t set ${_xScroll.m_name} value of LayoutContainer if its not initialized.');
		
		//if (value == null && xScrollIsEditable) {
		if (value == null && solver.hasEditVariable(_xScroll)) {
			//xScrollIsEditable = false;
			solver.removeEditVariable(_xScroll);
			return null;
		}
		
		//if (!xScrollIsEditable) {
		if (!solver.hasEditVariable(_xScroll)) {
			//xScrollIsEditable = true;
			solver.addEditVariable(_xScroll, strength);
			//solver.addEditVariable(_xScroll, strength); // TODO: needs low strenght to automatically reset on resize
		}
		
		// TODO: precalculate greatest child
		//var greatestChildMinSize = 0;
		//for (child in childs) if (child.hSize.getMin() > greatestChildMinSize) greatestChildMinSize = child.hSize.getMin(); 
		//var greatestXscroll = greatestChildMinSize - hSize.middle._min;
		
		//if (Align.hasLeft(align))
			solver.suggestValue(_xScroll, value);
		//else if (Align.hasRight(align))
			//solver.suggestValue(_xScroll, greatestXscroll-value);     // TODO
		//else solver.suggestValue(_xScroll, greatestXscroll/2-value); // TODO
			
		return value;
	}
	
	public var xScrollMax(get,never):Float;
	inline function get_xScrollMax():Float {
		// TODO: precalculate greatest child
		var greatestChildMinSize = 0;
		for (child in childs) if (child.hSize.getMin() > greatestChildMinSize) greatestChildMinSize = child.hSize.getMin(); 
		if (_width.m_value >= greatestChildMinSize) return 0;
		return greatestChildMinSize - _width.m_value;
	}
	
	// ---------- Variables for Jasper Constraints ------
	public var _xScroll(default,null):Variable = null;
	public var _yScroll(default,null):Variable = null;

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
			
	static var strengthHigh = Strength.create(900, 0, 0);
	static var strengthHigh1 = Strength.create(600, 0, 0);
	static var strengthHigh2 = Strength.create(300, 0, 0);
	static var strength = Strength.create(0, 900, 0);
	static var strength1 = Strength.create(0, 600, 0);
	static var strength2 = Strength.create(0, 300, 0);
	static var strengthLow = Strength.create(0, 0, 900);
	static var strengthLow1 = Strength.create(0, 0, 700);
	static var strengthLow2 = Strength.create(0, 0, 500);
	static var strengthLow3 = Strength.create(0, 0, 300);
	static var strengthLow4 = Strength.create(0, 0, 100);
	
	// ----------------------------------------------------------------------------------------
	// storing constraints
	public var customConstraints:Array<Constraint>;
	
	// ----------------------------------------------------------------------------------------
	public var containerType:ContainerType;
	public var layoutElement:LayoutElement;
	
	public var layout:Layout;
	public var options:ContainerOptions;
	
	public var solver:Null<Solver>;
	
	public var parent:LayoutContainer = null;
	var childs:Array<LayoutContainer> = null;
		
	public var isRoot(get, never):Bool;
	inline function get_isRoot():Bool return (parent == null);	
	
	// ----------------------------------------------------------------------------------------
	// --------------------------------- NEW --------------------------------------------------
	// ----------------------------------------------------------------------------------------
	public function new(
		containerType:ContainerType = ContainerType.BOX,
		layoutElement:LayoutElement = null,
		layoutOptions:Layout = null,
		childs:Array<LayoutContainer> = null) 
	{
		set_containerType(containerType);
		set_layoutElement(layoutElement);
		set_layoutOptions(layoutOptions);
		set_childs(childs);
				
		_x = new Variable();
		_y = new Variable();
		_width = new Variable();
		_height = new Variable();
		
		_centerX = new Term(_x) + (_width / 2.0);
		_centerY = new Term(_y) + (_height / 2.0);
	}
	
	inline function set_containerType(containerType:ContainerType) {
		this.containerType = containerType;
		// TODO: update
	}
	
	inline function set_layoutElement(layoutElement:LayoutElement) {
		this.layoutElement = layoutElement;
		// TODO: update
	}
	
	function set_layoutOptions(layoutOptions:Layout)
	{
		if (layoutOptions == null) layoutOptions = {};
		layout = layoutOptions;
		hSize = new SizeSpaced(layout.width, layout.left, layout.right);
		vSize = new SizeSpaced(layout.height, layout.top, layout.bottom);
		
		options = layoutOptions;
		if (options.scrollX != null && options.scrollX) _xScroll = new Variable();
		if (options.scrollY != null && options.scrollY) _yScroll = new Variable();

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
		trace("root:",innerLimit.width);
		
		solver.addConstraint( (root_width >= innerLimit.width) | strengthHigh );
		solver.addConstraint( (root_height >= innerLimit.height) | strengthHigh );
		
		// --------------------------- root-container horizontal -----------------------------			
		fixLimit(hSize, innerLimit.width);
		fixSpacer(null, hSize);
		
		var hSizeLimitVar = hSize.setSizeLimit(null);
		if (hSizeLimitVar != null) solver.addConstraint( (hSizeLimitVar >= 0) | strength );
		
		var hSizeSpanVar = hSize.setSizeSpan(null);
		if (hSizeSpanVar != null) {
			solver.addConstraint( (hSizeSpanVar >= 0) | strengthHigh );
			solver.addConstraint( (hSizeSpanVar == (root_width - hSize.getLimitMax()) / hSize.getSpanSumWeight() ) | strengthLow );
		}
		solver.addConstraint( (_left == 0) | strength );
		solver.addConstraint( (_right == root_width) | strength );
		
		solver.addConstraint( (_width == hSize.middle.size) | strength );
				
		// ---------------------------- root-container vertical ------------------------------			
		fixLimit(vSize, innerLimit.height);
		fixSpacer(null, vSize);
				
		var vSizeLimitVar = vSize.setSizeLimit(null);
		if (vSizeLimitVar != null) solver.addConstraint( (vSizeLimitVar >= 0) | strength );
		
		var vSizeSpanVar = vSize.setSizeSpan(null);
		if (vSizeSpanVar != null) {
			solver.addConstraint( (vSizeSpanVar >= 0) | strengthHigh );
			solver.addConstraint( (vSizeSpanVar == (root_height - vSize.getLimitMax()) / vSize.getSpanSumWeight() ) | strengthLow );
		}
		solver.addConstraint( (_top == 0) | strength );
		solver.addConstraint( (_bottom == root_height) | strength );				
		
		solver.addConstraint( (_height == vSize.middle.size) | strength );
	}
	
	public function update(width:Null<Float> = null, height:Null<Float> = null)
	{
		if (solver != null) {
			if (width != null) solver.suggestValue(root_width, width);
			if (height != null) solver.suggestValue(root_height, height);
			solver.updateVariables();
			
			updateLayoutElement(xParentOffset, yParentOffset);
		}
	}
	
	function updateLayoutElement(xOffset:Float, yOffset:Float)
	{
		xParentOffset = xOffset;
		yParentOffset = yOffset;
		if (layout.relativeChildPositions != null && layout.relativeChildPositions == true) {
			xOffset += x;
			yOffset += y;
		}
		
		updateMask();		
		
		if (layoutElement != null) layoutElement.updateByLayout(this);
		
		if (childs != null) 
			for (child in childs) child.updateLayoutElement(xOffset, yOffset); // recursive
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
				maskX = parent._x.m_value + parent.maskX - _x.m_value;
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
					maskY = parent._y.m_value + parent.maskY - _y.m_value;
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
	public function getChild(childNumber:Int):LayoutContainer {
		return childs[childNumber];
	}
	
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

	static inline var AUTOSPACE_NONE:Int = 0;
	static inline var AUTOSPACE_FIRST:Int = 1;
	static inline var AUTOSPACE_LAST:Int = 2;
	static inline var AUTOSPACE_BOTH:Int = 3;

	static inline function getAutospaceBox(size:SizeSpaced, childSize:SizeSpaced):Int
	{
		if (childSize.hasSpan()) return AUTOSPACE_NONE;
		if (size.middle._span || childSize.getLimitMax() < ( (size.middle._max != null) ? size.middle._max : size.middle._min))
		{
			if (childSize.first == null && childSize.last != null) return AUTOSPACE_FIRST;
			else if (childSize.last == null && childSize.first != null) return AUTOSPACE_LAST;
			else return AUTOSPACE_BOTH;
		}
		else return AUTOSPACE_NONE;
	}
	
	static inline function getAutospace(size:SizeSpaced, limitMax:Int, firstSize:SizeSpaced, lastSize:SizeSpaced):Int
	{
		if (size.middle._span || limitMax < ( (size.middle._max != null) ? size.middle._max : size.middle._min))
		{
			if (firstSize.first == null && lastSize.last != null) return AUTOSPACE_FIRST;
			else if (lastSize.last == null && firstSize.first != null) return AUTOSPACE_LAST;
			else return AUTOSPACE_BOTH;
		}
		else return AUTOSPACE_NONE;
	}
	
	// -----------------------------------------------------------------------------------------------------
	// TODO
	inline function setConstraintLeft(c:Constraint) {
		solver.addConstraint(c);
	}
	inline function setConstraintRight(c:Constraint) {
		solver.addConstraint(c);
	}
	inline function setConstraintTop(c:Constraint) {
		solver.addConstraint(c);
	}
	inline function setConstraintBottom(c:Constraint) {
		solver.addConstraint(c);
	}
	
	inline function setConstraintWidth(c:Constraint) {
		solver.addConstraint(c);
	}
	inline function setConstraintHeight(c:Constraint) {
		solver.addConstraint(c);
	}
		
	inline function setConstraintHLimit(c:Constraint) {
		solver.addConstraint(c);
	}
	inline function setConstraintVLimit(c:Constraint) {
		solver.addConstraint(c);
	}
	
	inline function setConstraintHSpan(c1:Constraint, c2:Constraint) {
		solver.addConstraint(c1);
		solver.addConstraint(c2);
	}
	inline function setConstraintVSpan(c1:Constraint, c2:Constraint) {
		solver.addConstraint(c1);
		solver.addConstraint(c2);
	}
		
	inline function setConstraintRowColLimit(c:Constraint) {
		solver.addConstraint(c);
	}
	
	inline function setConstraintRowColSpan(c1:Constraint, c2:Constraint) {
		solver.addConstraint(c1);
		solver.addConstraint(c2);
	}
	
	// TODO:
/*	
	var childsNumHSpan:Int = 0;
	var childsNumVSpan:Int = 0;
	
	var childsSumHMin:Int = 0;
	var childsSumVMin:Int = 0;
	
	var childsSumHMax:Int = 0;
	var childsSumVMax:Int = 0;
	
	var childsHighestHMin:Int = 0;
	var childsHighestVMin:Int = 0;
	
	var childsSumHWeight:Int = 0;
	var childsSumVWeight:Int = 0;
	
	var sizeLimitVar:Null<Variable> = null;
	var sizeSpanVar:Null<Variable> = null;
	
	function setLimits()
	{
		childsNumHSpan = 0;
		childsNumVSpan = 0;
		if (childs != null)
			for (child in childs)
			{
				child.setLimits() // recursive childs
				
				if (child.hSize.hasSpan()) childsNumHSpan++;
				if (child.vSize.hasSpan()) childsNumVSpan++;
				
				childsSumHMin += child.hSize.getMin();
				childsSumVMin += child.vSize.getMin();
				
				childsSumHMax += child.hSize.getLimitMax();
				childsSumVMax += child.vSize.getLimitMax();
				
				if (child.hSize.getMin() > childsHighestHMin) childsHighestHMin = child.hSize.getMin();
				if (child.vSize.getMin() > childsHighestVMin) childsHighestVMin = child.vSize.getMin();
				
				childsSumHWeight += child.hSize.getSumWeight();
				childsSumVWeight += child.vSize.getSumWeight();
			}
	}
*/		
	function addTreeConstraints(solver:Solver):InnerLimit
	{
		this.solver = solver;
		
		var childsLimit = {width:0, height:0};
		if (childs != null)
		{
			var sizeLimitVar:Null<Variable> = null;
			var sizeSpanVar:Null<Variable> = null;			
			
			var childsNumSpan:Int = 0;
			var limitMax:Int = 0;
			var sumWeight:Float = 0.0;		
			
			var autospace:Int = 0;
						
			var oversize = new Variable();
			if (_xScroll != null) {
				solver.addConstraint( (oversize == 0 ) | strengthLow1);
				solver.addConstraint( (oversize >= 0 ) | strengthHigh);				
				// TODO: scroll-mode only if child.hSize.getMin() - hSize.getMin() > 0
				//solver.addConstraint( (oversize <= child.hSize.getMin() - hSize.getMin()  ) | strengthHigh);
				
			}
			
			for (i in 0...childs.length)
			{	
				var child = childs[i];
				
				var innerLimit = child.addTreeConstraints(solver); // recursive childs
				
				// ------------------------------------------------------
				// ------------------- horizontal -----------------------
				// ------------------------------------------------------
				
/*				
				//var isHOversize = false;
				if (limitMinWidthToChilds) {
					if (child.hSize.middle._min < innerLimit.width) {
						child.hSize.middle._min = innerLimit.width;
						if (child.hSize.middle._max != null && child.hSize.middle._max < child.hSize.middle._min)
							child.hSize.middle._max = child.hSize.middle._min);
					}						
				} 
				else if (child.hSize.middle._min < innerLimit.width) child.isHOversize = true;
				
				
				if (limitMaxWidthToChilds) {
					if (child.hSize.middle._max == null) child.hSize.middle._max = innerLimit.widthMax;
					if (child.hSize.middle._max > innerLimit.widthMax) child.hSize.middle._max = innerLimit.widthMax;
					if (child.hSize.middle._min > child.hSize.middle._max) child.hSize.middle._min = child.hSize.middle._max;
				}
*/				
				if (_xScroll == null) fixLimit(child.hSize, innerLimit.width);
				else {
					childsLimit.width = hSize.middle._min;
					trace(childsLimit.width);// TODO: not do every child here!!! .. put into initialization
				}
				
				if (containerType == ContainerType.HBOX) // -------- HBOX --------
				{
					childsLimit.width += child.hSize.getMin();
					
					if (child.hSize.hasSpan()) childsNumSpan++;
					limitMax += child.hSize.getLimitMax();
					sumWeight += child.hSize.getSpanSumWeight();
						
					sizeLimitVar = child.hSize.setSizeLimit(sizeLimitVar);
					sizeSpanVar = child.hSize.setSizeSpan(sizeSpanVar);
										
					if (i>0) child.setConstraintLeft( (child._left == childs[i-1]._right) | strength );
				}
				else                             // -------- BOX ---------
				{
					if (_xScroll == null)
						if (child.hSize.getMin() > childsLimit.width) childsLimit.width = child.hSize.getMin();
					
					var hSizeLimitVar = child.hSize.setSizeLimit(null);
					if (hSizeLimitVar != null) {
						child.setConstraintHLimit( (hSizeLimitVar >= 0) | strength ); // TODO: also strengtHigh here?
						//if (Scroll.hasHorizontal(scroll)) child.setConstraintHLimit( (hSizeLimitVar == 0) | strengthLow ); 
						if (_xScroll != null) child.setConstraintHLimit( (hSizeLimitVar >= oversize) | strengthLow ); 
					}
					
					autospace = getAutospaceBox(hSize, child.hSize);
					var hSizeSpanVar = (autospace == AUTOSPACE_NONE) ? child.hSize.setSizeSpan(null) : new Variable();
					if (hSizeSpanVar != null) {
						var _sumWeight = (autospace == AUTOSPACE_NONE) ? child.hSize.getSpanSumWeight() : ((autospace == AUTOSPACE_BOTH) ? 2 : 1);
						if (_xScroll == null) {
							child.setConstraintHSpan( (hSizeSpanVar >= 0) | strengthHigh, // origin strengthLow ... check strengthHigh (nested boxes+rows)
								(hSizeSpanVar == (_width - child.hSize.getLimitMax()) / _sumWeight) | strengthLow ); // origin strengthLow
						}
						else { // CHECK:
							child.setConstraintHSpan( (hSizeSpanVar >= 0) | strengthHigh,
								(hSizeSpanVar == (_width +oversize - child.hSize.getLimitMax()) / _sumWeight) | strengthLow );
						}
					}
								
					// no scroll		
					if (_xScroll == null) {
						if (autospace & AUTOSPACE_FIRST == 0) child.setConstraintLeft( (child._left == _x) | strength );
						else child.setConstraintLeft( (child._left - hSizeSpanVar == _x) | strength );
						if (autospace & AUTOSPACE_LAST == 0) child.setConstraintRight( (child._right == _x + _width) | strength );
						else child.setConstraintRight( (child._right + hSizeSpanVar == _x + _width) | strength );
					}
					else { // change connections here in depend of xScroll
												
						//trace("greatestChildMinSize - child.hSize.getMin():"+(greatestChildMinSize - child.hSize.getMin()));
						
						// TODO: calculate Align in depend of first and last OR do an oversize for every child if "scrollAlign" was set
						// var autoalign = getAutoalignBox(hSize, child.hSize);
						
						
						//CHECK: do this only for the greatest child and if not constrain left and right to that one
						if (Align.hasLeft(options.alignOnOversize))        //  ----- scroll align left ----
						{
							// left
							if (autospace & AUTOSPACE_FIRST == 0)
							     child.setConstraintLeft( (child._left + _xScroll == _x               ) | strength );
							else child.setConstraintLeft( (child._left + _xScroll == _x + hSizeSpanVar) | strength );
							// right
							if (autospace & AUTOSPACE_LAST == 0)
								 child.setConstraintRight( (child._right - oversize + _xScroll == _x + _width               ) | strength );
							else child.setConstraintRight( (child._right - oversize + _xScroll == _x + _width - hSizeSpanVar) | strength );
						}
						else if (Align.hasRight(options.alignOnOversize))   //  ----- scroll align right ----
						{
							// left
							if (autospace & AUTOSPACE_FIRST == 0)
							     child.setConstraintLeft( (child._left + oversize - _xScroll == _x               ) | strength );
							else child.setConstraintLeft( (child._left + oversize - _xScroll == _x + hSizeSpanVar) | strength );
							// right
							if (autospace & AUTOSPACE_LAST == 0)
							     child.setConstraintRight( (child._right - _xScroll   == _x + _width               ) | strength );
							else child.setConstraintRight( (child._right - _xScroll   == _x + _width - hSizeSpanVar) | strength );
						}
						else                             //  ---- scroll align centered ---    <--- check how useful is this into practice
						{
							// left
							if (autospace & AUTOSPACE_FIRST == 0) 
							     child.setConstraintLeft( (child._left + oversize/2 + _xScroll == _x               ) | strength );
							else child.setConstraintLeft( (child._left + oversize/2 + _xScroll == _x + hSizeSpanVar) | strength );
							// right
							if (autospace & AUTOSPACE_LAST == 0)
							     child.setConstraintRight( (child._right - oversize/2 + _xScroll == _x + _width               ) | strength );
							else child.setConstraintRight( (child._right - oversize/2 + _xScroll == _x + _width - hSizeSpanVar) | strength );
						}
					}
					
				}
				
				child.setConstraintWidth( (child._width == child.hSize.middle.size) | strength );
												
				// ------------------------------------------------------
				// ------------------- vertical -------------------------
				// ------------------------------------------------------
				if (_yScroll == null) fixLimit(child.vSize, innerLimit.height);
					
				if (containerType == ContainerType.VBOX) // -------- VBOX --------
				{
					childsLimit.height += child.vSize.getMin();
					
					if (child.vSize.hasSpan()) childsNumSpan++;
					limitMax += child.vSize.getLimitMax();
					sumWeight += child.vSize.getSpanSumWeight();
										
					sizeLimitVar = child.vSize.setSizeLimit(sizeLimitVar);
					sizeSpanVar = child.vSize.setSizeSpan(sizeSpanVar);					
					
					if (i > 0) child.setConstraintTop( (child._top == childs[i-1]._bottom) | strength );
				}
				else                             // -------- BOX ---------
				{
					if (child.vSize.getMin() > childsLimit.height) childsLimit.height = child.vSize.getMin();
					
					var vSizeLimitVar = child.vSize.setSizeLimit(null);
					if (vSizeLimitVar != null) child.setConstraintVLimit( (vSizeLimitVar >= 0) | strength );
					
					autospace = getAutospaceBox(vSize, child.vSize);
					var vSizeSpanVar = (autospace == AUTOSPACE_NONE) ? child.vSize.setSizeSpan(null) : new Variable();
					if (vSizeSpanVar != null) {
						var _sumWeight = (autospace == AUTOSPACE_NONE) ? child.vSize.getSpanSumWeight() : ((autospace == AUTOSPACE_BOTH) ? 2 : 1);
						child.setConstraintVSpan( (vSizeSpanVar >= 0) | strengthHigh, // check nested boxes+rows here
							(vSizeSpanVar == (_height - child.vSize.getLimitMax()) / _sumWeight) | strengthLow );
					}
					
					// TODO: change connections here in depend of yscroll, innerAlign and innerScroll
					if (autospace & AUTOSPACE_FIRST == 0) child.setConstraintTop( (child._top == _y) | strength );
					else child.setConstraintTop( (child._top - vSizeSpanVar == _y) | strength );
					if (autospace & AUTOSPACE_LAST == 0) child.setConstraintBottom( (child._bottom == _y + _height) | strength );
					else child.setConstraintBottom( (child._bottom + vSizeSpanVar == _y + _height) | strength );
				}
				
				child.setConstraintHeight( (child._height == child.vSize.middle.size) | strength );
			}			
			
			// ----------------------------------------------------------------
			// ------- limitVar and sumWeight of childs for ROW or COL --------
			// ----------------------------------------------------------------
			if (containerType != ContainerType.BOX && childs.length > 0)
			{
				if (sizeLimitVar != null) {
					setConstraintRowColLimit( (sizeLimitVar >= 0) | strength );
				}
				
				if (containerType == ContainerType.HBOX)
				{
					if (childsNumSpan == 0) {
						autospace = getAutospace(hSize, limitMax, childs[0].hSize, childs[childs.length - 1].hSize);
						if (autospace != AUTOSPACE_NONE) {
							sumWeight += (autospace == AUTOSPACE_BOTH) ? 2 : 1;
							if (sizeSpanVar == null) sizeSpanVar = new Variable();
						}
					}
					else autospace = AUTOSPACE_NONE;
					
					if (sizeSpanVar != null) {
						setConstraintRowColSpan( (sizeSpanVar >= 0) | strength, (sizeSpanVar == (_width - limitMax) / sumWeight ) | strengthLow );
					}
			
					// TODO: change connections here in depend of yscroll, innerAlign and innerScroll
					if (autospace & AUTOSPACE_FIRST == 0) childs[0].setConstraintLeft( (childs[0]._left == _x) | strength );
					else childs[0].setConstraintLeft( (childs[0]._left - sizeSpanVar == _x) | strength );
					if (autospace & AUTOSPACE_LAST == 0) childs[childs.length-1].setConstraintRight( (childs[childs.length-1]._right == _x + _width) | strength );
					else childs[childs.length-1].setConstraintRight( (childs[childs.length-1]._right + sizeSpanVar == _x + _width) | strength );
				
				}
				else // --------- Container.VBOX --------
				{					
					if (childsNumSpan == 0) {
						autospace = getAutospace(vSize, limitMax, childs[0].vSize, childs[childs.length - 1].vSize);
						if (autospace != AUTOSPACE_NONE) {
							sumWeight += (autospace == AUTOSPACE_BOTH) ? 2 : 1;
							if (sizeSpanVar == null) sizeSpanVar = new Variable();
						}
					}
					else autospace = AUTOSPACE_NONE;
					
					if (sizeSpanVar != null) {
						setConstraintRowColSpan( (sizeSpanVar >= 0) | strength, (sizeSpanVar == (_height - limitMax) / sumWeight ) | strengthLow );
					}
			
					// TODO: change connections here in depend of yscroll, innerAlign and innerScroll
					if (autospace & AUTOSPACE_FIRST == 0) childs[0].setConstraintTop( (childs[0]._top == _y) | strength );
					else childs[0].setConstraintTop( (childs[0]._top - sizeSpanVar == _y) | strength );
					if (autospace & AUTOSPACE_LAST == 0) childs[childs.length-1].setConstraintBottom( (childs[childs.length-1]._bottom == _y + _height) | strength );
					else childs[childs.length-1].setConstraintBottom( (childs[childs.length-1]._bottom + sizeSpanVar == _y + _height) | strength );
				}
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
	public inline function new(layoutElement:LayoutElement = null, layoutOptions:Layout = null, innerLayoutContainer:Array<LayoutContainer> = null) 
	{
		this = new LayoutContainer(ContainerType.BOX, layoutElement, layoutOptions, innerLayoutContainer);
	}
}

@:forward
abstract HBox(LayoutContainer) from LayoutContainer to LayoutContainer {
	public inline function new(layoutElement:LayoutElement = null, layoutOptions:Layout = null, innerLayoutContainer:Array<LayoutContainer> = null) 
	{
		this = new LayoutContainer(ContainerType.HBOX, layoutElement, layoutOptions, innerLayoutContainer);
	}
}

@:forward
abstract VBox(LayoutContainer) from LayoutContainer to LayoutContainer {
	public inline function new(layoutElement:LayoutElement = null, layoutOptions:Layout = null, innerLayoutContainer:Array<LayoutContainer> = null) 
	{
		this = new LayoutContainer(ContainerType.VBOX, layoutElement, layoutOptions, innerLayoutContainer);
	}
}

