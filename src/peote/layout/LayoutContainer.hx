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
		for (child in childs) if (child.hSize.getLimitMin() > greatestChildMinSize) greatestChildMinSize = child.hSize.getLimitMin(); 
		if (_width.m_value >= greatestChildMinSize) return 0;
		return greatestChildMinSize - _width.m_value;
	}
	
	// ---------- Variables for Jasper Constraints ------
	public var _xScroll(default,null):Variable;
	public var _yScroll(default,null):Variable;

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
			
	// ----------------------------------------------------------------------------------------
	
	public var containerType:ContainerType;
	public var layoutElement:LayoutElement;	
	public var layout:Layout;
	
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
		layout:Layout = null,
		childs:Array<LayoutContainer> = null) 
	{
		this.containerType = containerType;
		this.layoutElement = layoutElement;
		set_layout(layout);
		set_childs(childs);
				
		_x = new Variable();
		_y = new Variable();
		_width = new Variable();
		_height = new Variable();
		
		_centerX = new Term(_x) + (_width / 2.0);
		_centerY = new Term(_y) + (_height / 2.0);
	}
		
	inline function set_layout(_layout:Layout)
	{
		layout = (_layout != null) ? _layout : {};
		
		hSize = new SizeSpaced(layout.width, layout.left, layout.right);
		vSize = new SizeSpaced(layout.height, layout.top, layout.bottom);
		
		if (layout.scrollX) _xScroll = new Variable();
		if (layout.scrollY) _yScroll = new Variable();

		// TODO: update
	}
	
	inline function set_childs(childs:Array<LayoutContainer>) {
		#if peotelayout_debug
		trace("new:"+this.layout.name);
		#end
		if (childs != null && childs.length > 0) {
			for (child in childs) {
				#if peotelayout_debug
				trace("  child:" + child.layout.name);
				#end
				child.parent = this;
				calculateChildLimits(child);
			}
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
			
			// Fixing limits
			if (containerType == ContainerType.HBOX) {
				if (hSize.middle._min < childsSumHMin) {
					if (layout.limitMinWidthToChilds) {
						hSize.middle._min = childsSumHMin;
						if (hSize.middle._max != null && hSize.middle._max < childsSumHMin)
							hSize.middle._max = childsSumHMin;
					}
					else { // OVERSIZE
						//childsSumHMin = hSize.middle._min;
					}
				}
			} else { // BOX
				// FIX MIN
				if (hSize.middle._min < childsHighestHMin) {
					if (layout.limitMinWidthToChilds) {
						hSize.middle._min = childsHighestHMin;
						if (hSize.middle._max != null && hSize.middle._max < childsHighestHMin)
							hSize.middle._max = childsHighestHMin;
					}
					else { // OVERSIZE 
					}
				}
				// FIX MAX
				if (hSize.middle._max > childsHighestHMax) {
					if (layout.limitMaxWidthToChilds) {
						hSize.middle._max = childsHighestHMax;
					}
				}
				
			}
		}		
		else {
			childsSumHMin = hSize.getLimitMin();
			childsSumHMax = hSize.getLimitMax();
			childsSumVMin = vSize.getLimitMin();		
			childsSumVMax = vSize.getLimitMax();			
		}
		
		#if peotelayout_debug
		trace(""
			//+"\nchildsNumHSpan:"+childsNumHSpan
			//+"\nchildsNumVSpan:"+childsNumVSpan
			+"\nchildsSumHMin:"+childsSumHMin
			//+"\nchildsSumHMax:"+childsSumHMax
			//+"\nchildsSumVMin:"+childsSumVMin
			//+"\nchildsSumVMax:"+childsSumVMax
			+"\nchildsHighestHMin:"+childsHighestHMin
			//+"\nchildsHighestVMin:"+childsHighestVMin
			//+"\nchildsSumHWeight:"+childsSumHWeight
			//+"\nchildsSumVWeight:"+childsSumVWeight
		);
		#end
		
		this.childs = childs;
		// TODO: update
	}
	// TODO:
	
	var childsNumHSpan:Int = 0;
	var childsNumVSpan:Int = 0;
	
	var childsSumHMin:Int = 0;
	var childsSumVMin:Int = 0;
	
	var childsSumHMax:Int = 0;
	var childsSumVMax:Int = 0;
	
	var childsHighestHMin:Int = 0;
	var childsHighestVMin:Int = 0;
	
	var childsHighestHMax:Int = 0;
	var childsHighestVMax:Int = 0;
	
	var childsSumHWeight:Float = 0.0;
	var childsSumVWeight:Float = 0.0;
	
	//var sizeLimitVar:Null<Variable> = null;
	//var sizeSpanVar:Null<Variable> = null;
	
	function calculateChildLimits(child:LayoutContainer)
	{
		if (child.hSize.hasSpan()) childsNumHSpan++;
		if (child.vSize.hasSpan()) childsNumVSpan++;
		
		childsSumHMin += child.hSize.getLimitMin();
		childsSumHMax += child.hSize.getLimitMax();
		childsSumVMin += child.vSize.getLimitMin();		
		childsSumVMax += child.vSize.getLimitMax();
		
		if (child.hSize.getLimitMin() > childsHighestHMin) childsHighestHMin = child.hSize.getLimitMin();
		if (child.hSize.getLimitMax() > childsHighestHMax) childsHighestHMax = child.hSize.getLimitMax();
		if (child.vSize.getLimitMin() > childsHighestVMin) childsHighestVMin = child.vSize.getLimitMin();
		if (child.vSize.getLimitMax() > childsHighestVMax) childsHighestVMax = child.vSize.getLimitMax();
		
		childsSumHWeight += child.hSize.getSpanSumWeight();
		childsSumVWeight += child.vSize.getSpanSumWeight();		
	}
			
	public function getChild(childNumber:Int):LayoutContainer {
		return childs[childNumber];
	}
	
	public function addChild(child:LayoutContainer) {
		
	}
	
	public function removeChild(child:LayoutContainer) {
		
	}
	
	
	// ---------------------------------------------------------------
	// --------------- init Solver -----------------------------------
	// ---------------------------------------------------------------
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
		
		addTreeConstraints(solver); // recursive Container
		
		solver.addConstraint( (root_width >= childsHighestHMin) | strengthHigh );
		//solver.addConstraint( (root_height >= childsSumVMin) | strengthHigh );
		
		// --------------------------- root-container horizontal -----------------------------			
		//fixLimit(hSize, innerLimit.width);
		//fixSpacer(null, hSize);
		
		var hSizeLimitVar = hSize.setSizeLimit(null);
		if (hSizeLimitVar != null) solver.addConstraint( (hSizeLimitVar >= 0) | strength );
		
		var autospace = AUTOSPACE_BOTH;
		if (hSize.hasSpan()) autospace = AUTOSPACE_NONE;
		else if (hSize.first == null && hSize.last != null) autospace = AUTOSPACE_FIRST;
		else if (hSize.last == null && hSize.first != null) autospace = AUTOSPACE_LAST;		
		
		var hSizeSpanVar = (autospace == AUTOSPACE_NONE) ? hSize.setSizeSpan(null) : new Variable();
		if (hSizeSpanVar != null) {
			var _sumWeight = (autospace == AUTOSPACE_NONE) ? hSize.getSpanSumWeight() : ((autospace == AUTOSPACE_BOTH) ? 2 : 1);
			solver.addConstraint( (hSizeSpanVar >= 0) | strengthHigh );
			solver.addConstraint( (hSizeSpanVar == (root_width - hSize.getLimitMax()) / _sumWeight ) | strengthLow );
		}
		solver.addConstraint( (_left == 0) | strength );
		solver.addConstraint( (_right == root_width) | strength );
		
		solver.addConstraint( (_width == hSize.middle.size) | strength );
				
		// ---------------------------- root-container vertical ------------------------------			
		//fixLimit(vSize, innerLimit.height);
		//fixSpacer(null, vSize);
				
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
	
	// TODO:
	public function show() {
		
	}
	
	public function hide() {
		
	}
	
	// -----------------------------------------------------------------------
	// --------------- custom Constraints ------------------------------------
	// -----------------------------------------------------------------------
	
	public var customConstraints:Array<Constraint>; // storing constraints

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
	
	// --------------------------------------------------------------------------
	// --------------------- CONSTRAINTS ----------------------------------------
	// --------------------------------------------------------------------------
	static var strengthHigh = Strength.create(900, 0, 0);
	//static var strengthHigh1 = Strength.create(600, 0, 0);
	//static var strengthHigh2 = Strength.create(300, 0, 0);
	static var strength = Strength.create(0, 900, 0);
	//static var strength1 = Strength.create(0, 600, 0);
	//static var strength2 = Strength.create(0, 300, 0);
	static var strengthLow = Strength.create(0, 0, 900);
	static var strengthLow1 = Strength.create(0, 0, 700);
	//static var strengthLow2 = Strength.create(0, 0, 500);
	//static var strengthLow3 = Strength.create(0, 0, 300);
	//static var strengthLow4 = Strength.create(0, 0, 100);
	
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
	

	function addTreeConstraints(solver:Solver)
	{
		this.solver = solver;
		
		if (childs != null)
		{
			var sizeLimitVar:Null<Variable> = null;
			var sizeSpanVar:Null<Variable> = null;			
			
			var autospace:Int = 0;
						
			var oversize = new Variable();
			if (layout.scrollX) {
				//solver.addConstraint( (oversize == 0 ) | strengthHigh);
				solver.addConstraint( (oversize == 0 ) | strengthLow1);
				solver.addConstraint( (oversize >= 0 ) | strengthHigh);				
				// TODO: scroll-mode only if child.hSize.getMin() - hSize.getMin() > 0
				//solver.addConstraint( (oversize <= child.hSize.getMin() - hSize.getMin()  ) | strengthHigh);
				
			}
			
			for (i in 0...childs.length)
			{	
				var child = childs[i];
				
				child.addTreeConstraints(solver); // recursive childs
				
				// ------------------------------------------------------
				// ------------------- horizontal -----------------------
				// ------------------------------------------------------
				
				if (containerType == ContainerType.HBOX) // -------- HBOX --------
				{
					sizeLimitVar = child.hSize.setSizeLimit(sizeLimitVar);
					sizeSpanVar = child.hSize.setSizeSpan(sizeSpanVar);										
					if (i>0) child.setConstraintLeft( (child._left == childs[i-1]._right) | strength );
				}
				else                             // -------- BOX ---------
				{
					var hSizeLimitVar = child.hSize.setSizeLimit(null);
					if (hSizeLimitVar != null) {
						child.setConstraintHLimit( (hSizeLimitVar >= 0) | strength ); // TODO: also strengtHigh here?
						// TODO: OVERSIZE
						if (layout.scrollX) child.setConstraintHLimit( (hSizeLimitVar >= oversize) | strengthLow ); 
					}
					
					autospace = getAutospaceBox(hSize, child.hSize);
					var hSizeSpanVar = (autospace == AUTOSPACE_NONE) ? child.hSize.setSizeSpan(null) : new Variable();
					if (hSizeSpanVar != null) {
						var _sumWeight = (autospace == AUTOSPACE_NONE) ? child.hSize.getSpanSumWeight() : ((autospace == AUTOSPACE_BOTH) ? 2 : 1);
						if (! layout.scrollX) {
							child.setConstraintHSpan( (hSizeSpanVar >= 0) | strengthHigh, // origin strengthLow ... check strengthHigh (nested boxes+rows)
								(hSizeSpanVar == (_width - child.hSize.getLimitMax()) / _sumWeight) | strengthLow ); // origin strengthLow
						}
						else { // CHECK:+oversize
							child.setConstraintHSpan( (hSizeSpanVar >= 0) | strengthHigh,
								(hSizeSpanVar == (_width +oversize - child.hSize.getLimitMax()) / _sumWeight) | strengthLow );
						}
					}
								
					// TODO: no OVERSIZE?
					if (! layout.scrollX) {
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
						if (layout.hAlignOnOversize == HAlign.LEFT)        //  ----- scroll align left ----
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
						else if (layout.hAlignOnOversize  == HAlign.RIGHT)   //  ----- scroll align right ----
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
				// TODO: ==??==
				child.setConstraintWidth( (child._width == child.hSize.middle.size) | strength );
												
				// ------------------------------------------------------
				// ------------------- vertical -------------------------
				// ------------------------------------------------------
				if (containerType == ContainerType.VBOX) // -------- VBOX --------
				{
					sizeLimitVar = child.vSize.setSizeLimit(sizeLimitVar);
					sizeSpanVar = child.vSize.setSizeSpan(sizeSpanVar);					
					if (i > 0) child.setConstraintTop( (child._top == childs[i-1]._bottom) | strength );
				}
				else                             // -------- BOX ---------
				{
					var vSizeLimitVar = child.vSize.setSizeLimit(null);
					if (vSizeLimitVar != null) child.setConstraintVLimit( (vSizeLimitVar >= 0) | strength );
					
					autospace = getAutospaceBox(vSize, child.vSize);
					var vSizeSpanVar = (autospace == AUTOSPACE_NONE) ? child.vSize.setSizeSpan(null) : new Variable();
					if (vSizeSpanVar != null) {
						var _sumWeight = (autospace == AUTOSPACE_NONE) ? child.vSize.getSpanSumWeight() : ((autospace == AUTOSPACE_BOTH) ? 2 : 1);
						child.setConstraintVSpan( (vSizeSpanVar >= 0) | strengthHigh, // check nested boxes+rows here
							(vSizeSpanVar == (_height - child.vSize.getLimitMax()) / _sumWeight) | strengthLow );
					}
					
					// TODO: same a horizontal
					if (autospace & AUTOSPACE_FIRST == 0) child.setConstraintTop( (child._top == _y) | strength );
					else child.setConstraintTop( (child._top - vSizeSpanVar == _y) | strength );
					if (autospace & AUTOSPACE_LAST == 0) child.setConstraintBottom( (child._bottom == _y + _height) | strength );
					else child.setConstraintBottom( (child._bottom + vSizeSpanVar == _y + _height) | strength );
				}
				// TODO: ==??==
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
				
				var autospaceSumWeight:Int = 0;
				
				if (containerType == ContainerType.HBOX)
				{
					if (childsNumHSpan == 0) {
						autospace = getAutospace(hSize, childsSumHMax, childs[0].hSize, childs[childs.length - 1].hSize);
						if (autospace != AUTOSPACE_NONE) {
							autospaceSumWeight = (autospace == AUTOSPACE_BOTH) ? 2 : 1;
							if (sizeSpanVar == null) sizeSpanVar = new Variable();
						}
					}
					else autospace = AUTOSPACE_NONE;
					
					if (sizeSpanVar != null) {
						setConstraintRowColSpan( (sizeSpanVar >= 0) | strength, (sizeSpanVar == (_width - childsSumHMax) / (childsSumHWeight + autospaceSumWeight) ) | strengthLow );
					}
			
					// TODO: change connections here in depend of yscroll, innerAlign and innerScroll
					if (autospace & AUTOSPACE_FIRST == 0) childs[0].setConstraintLeft( (childs[0]._left == _x) | strength );
					else childs[0].setConstraintLeft( (childs[0]._left - sizeSpanVar == _x) | strength );
					if (autospace & AUTOSPACE_LAST == 0) childs[childs.length-1].setConstraintRight( (childs[childs.length-1]._right == _x + _width) | strength );
					else childs[childs.length-1].setConstraintRight( (childs[childs.length-1]._right + sizeSpanVar == _x + _width) | strength );
				
				}
				else // --------- Container.VBOX --------
				{					
					if (childsNumVSpan == 0) {
						autospace = getAutospace(vSize, childsSumVMax, childs[0].vSize, childs[childs.length - 1].vSize);
						if (autospace != AUTOSPACE_NONE) {
							autospaceSumWeight = (autospace == AUTOSPACE_BOTH) ? 2 : 1;
							if (sizeSpanVar == null) sizeSpanVar = new Variable();
						}
					}
					else autospace = AUTOSPACE_NONE;
					
					if (sizeSpanVar != null) {
						setConstraintRowColSpan( (sizeSpanVar >= 0) | strength, (sizeSpanVar == (_height - childsSumVMax) / (childsSumVWeight + autospaceSumWeight) ) | strengthLow );
					}
			
					// TODO: change connections here in depend of yscroll, innerAlign and innerScroll
					if (autospace & AUTOSPACE_FIRST == 0) childs[0].setConstraintTop( (childs[0]._top == _y) | strength );
					else childs[0].setConstraintTop( (childs[0]._top - sizeSpanVar == _y) | strength );
					if (autospace & AUTOSPACE_LAST == 0) childs[childs.length-1].setConstraintBottom( (childs[childs.length-1]._bottom == _y + _height) | strength );
					else childs[childs.length-1].setConstraintBottom( (childs[childs.length-1]._bottom + sizeSpanVar == _y + _height) | strength );
				}
			}
			
			
		}
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
	
	// ---------------------------------------------------------
	// ---------- Update LayoutElement and Mask ----------------
	// ---------------------------------------------------------
	
	// masked by parent layoutcontainer
	public var isHidden:Bool = false;
	public var isMasked:Bool = false;
	public var maskX(default,null):Float;
	public var maskY(default,null):Float;
	public var maskWidth(default,null):Float;
	public var maskHeight(default,null):Float;
	
	function updateLayoutElement(xOffset:Float, yOffset:Float)
	{
		xParentOffset = xOffset;
		yParentOffset = yOffset;
		if (layout.relativeChildPositions) {
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

