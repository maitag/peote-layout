package peote.layout;

import jasper.Variable;
import jasper.Expression;
import jasper.Term;
import jasper.Strength;
import jasper.Constraint;
import jasper.Solver;
import peote.layout.Align;

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
			solver.addEditVariable(variable, strengthEditVar);
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
			solver.addEditVariable(_xScroll, strengthEditVar);
			//solver.addEditVariable(_xScroll, strengthEditVar); // TODO: needs low strenght to automatically reset on resize
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
	
	public var depth(default, null):Int = 0;
		
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
	
	
	var innerHOversizeWeight:Int = 0;
	var outerHOversizeWeight:Int = 0;	
	var innerVOversizeWeight:Int = 0;
	var outerVOversizeWeight:Int = 0;	
	var isInnerHOversize:Bool = false;
	var isInnerVOversize:Bool = false;
	var isOuterHOversize:Bool = false;
	var isOuterVOversize:Bool = false;
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
		
	inline function set_childs(childs:Array<LayoutContainer>) {
		#if peotelayout_debug
		trace("----- " + this.layout.name + "-----");
		#end
		
		if (childs != null && childs.length > 0) {
			for (child in childs) {
				#if peotelayout_debug
				trace("  child:" + child.layout.name);
				#end
				child.parent = this;
				calculateChildLimits(child);
			}
			
			// Fixing limits  ------ horizontal -----------
			if (containerType == ContainerType.HBOX) {
				// FIX MIN
				if (hSize.middle._min < childsSumHMin) {
					if (layout.limitMinWidthToChilds) {
						hSize.middle._min = childsSumHMin;
						if (hSize.middle._max != null && hSize.middle._max < childsSumHMin)
							hSize.middle._max = childsSumHMin;
					}
					else {
						isInnerHOversize = true;//TODO
						innerHOversizeWeight++; 
					}
				}
				// FIX MAX
				if (layout.limitMaxWidthToChilds && childsSumHMax != 0) {
					if (hSize.middle._max == null || hSize.middle._max > childsSumHMax)
						hSize.middle._max = childsSumHMax;
				}
			}
			else {                     // BOX
				// FIX MIN
				if (hSize.middle._min < childsHighestHMin) {
					if (layout.limitMinWidthToChilds) {
						hSize.middle._min = childsHighestHMin;
						if (hSize.middle._max != null && hSize.middle._max < childsHighestHMin)
							hSize.middle._max = childsHighestHMin;
					}
					else if (layout.alignChildsOnOversizeX != Align.AUTO) {
						isInnerHOversize = true;
						innerHOversizeWeight++; //TODO
					}						
				}
				// FIX MAX
				if (layout.limitMaxWidthToChilds && childsHighestHMax != 0) {
					if (hSize.middle._max == null || hSize.middle._max > childsHighestHMax)
						hSize.middle._max = childsHighestHMax;
				}
				
			}
			
			// Fixing limits  ------ vertical -----------
			if (containerType == ContainerType.VBOX) {
				// FIX MIN
				if (vSize.middle._min < childsSumVMin) {
					if (layout.limitMinHeightToChilds) {
						vSize.middle._min = childsSumVMin;
						if (vSize.middle._max != null && vSize.middle._max < childsSumVMin)
							vSize.middle._max = childsSumVMin;
					}
					else {
						isInnerVOversize = true;
						innerVOversizeWeight++; 
					}
				}
				// FIX MAX
				if (layout.limitMaxHeightToChilds && childsSumVMax != 0) {
					if (vSize.middle._max == null || vSize.middle._max > childsSumVMax)
						vSize.middle._max = childsSumVMax;
				}
			}
			else {                     // BOX
				// FIX MIN
				if (vSize.middle._min < childsHighestVMin) {
					if (layout.limitMinHeightToChilds) {
						vSize.middle._min = childsHighestVMin;
						if (vSize.middle._max != null && vSize.middle._max < childsHighestVMin)
							vSize.middle._max = childsHighestVMin;
					}
					else if (layout.alignChildsOnOversizeY != Align.AUTO) {
						isInnerVOversize = true;
						innerVOversizeWeight++;
					}
				}
				// FIX MAX
				if (layout.limitMaxHeightToChilds && childsHighestVMax != 0) {
					if (vSize.middle._max == null || vSize.middle._max > childsHighestVMax)
						vSize.middle._max = childsHighestVMax;
				}
				
			}
		}		
		
		#if peotelayout_debug
		trace(""
			+"\nisInnerHOversize:"+isInnerHOversize
			+"\ninnerHOversizeWeight:"+innerHOversizeWeight
			+"\nhSize.middle._min:"+hSize.middle._min
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
	
	inline function calculateChildLimits(child:LayoutContainer)
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
		
		// TODO
		if (!layout.limitMinWidthToChilds && containerType == ContainerType.BOX 
			&& layout.alignChildsOnOversizeX == Align.AUTO && child.hSize.getLimitMin() > hSize.middle._min) {
			child.isOuterHOversize = true;
			child.outerHOversizeWeight = child.innerHOversizeWeight + 1;
			innerHOversizeWeight += child.outerHOversizeWeight;
		}
		else innerHOversizeWeight += child.innerHOversizeWeight;
		
		if (!layout.limitMinHeightToChilds && containerType == ContainerType.BOX 
			&& layout.alignChildsOnOversizeY == Align.AUTO && child.vSize.getLimitMin() > vSize.middle._min) {
			child.isOuterVOversize = true;
			child.outerVOversizeWeight = child.innerVOversizeWeight + 1;
			innerVOversizeWeight += child.outerVOversizeWeight;
		}
		else innerVOversizeWeight += child.innerVOversizeWeight;
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
	public function init()
	{
		solver = new Solver();
		
		root_width = new Variable();
		root_height = new Variable();
		
		solver.addEditVariable(root_width, strengthEditVar);
		solver.addEditVariable(root_height, strengthEditVar);
		
		solver.addConstraint( (root_width >= hSize.getLimitMin()) | strengthHigh );
		//solver.addConstraint( (root_width >= hSize.middle._min) | strengthHigh );
		solver.addConstraint( (root_height >= vSize.middle._min) | strengthHigh );
		
		addTreeConstraints(solver, 0); // <- recursive Container
			
		// --------------------------- root-container horizontal -----------------------------
		
		outerHLimitVar = hSize.setSizeLimit(null);
		if (outerHLimitVar != null) {
			setConstraintHLimit( (outerHLimitVar >= 0) | strengthHigh );
			// next is need because of rounding error if multiple childs! (or see width-constraints below!)
			setConstraintHLimit( (outerHLimitVar <= 1) | strengthHigh );
		}
		
		var autospace = AUTOSPACE_BOTH;
		if (hSize.hasSpan()) autospace = AUTOSPACE_NONE;
		else if (hSize.first == null && hSize.last != null) autospace = AUTOSPACE_FIRST;
		else if (hSize.last == null && hSize.first != null) autospace = AUTOSPACE_LAST;		
		
		outerHSpanVar = (autospace == AUTOSPACE_NONE) ? hSize.setSizeSpan(null) : new Variable();
		if (outerHSpanVar != null) {
			var _sumWeight = (autospace == AUTOSPACE_NONE) ? hSize.getSpanSumWeight() : ((autospace == AUTOSPACE_BOTH) ? 2 : 1);
			//trace(layout.name + ":span",hSize.middle._min / _sumWeight, hSize.getLimitMax() /  _sumWeight);
			setConstraintHSpan(	(outerHSpanVar >= 0) | strengthHigh,
				(outerHSpanVar == (root_width - hSize.getLimitMax()) / _sumWeight) | strengthSpan
			);			
		}
		// left
		if (autospace & AUTOSPACE_FIRST == 0)
			setConstraintLeft( (_left == 0) | strengthNeighbor );
		else setConstraintLeft( (_left == outerHSpanVar) | strengthNeighbor );
		// right
		if (autospace & AUTOSPACE_LAST == 0)
			setConstraintRight( (_right == root_width) | strengthNeighbor );
		else setConstraintRight( (_right == root_width - outerHSpanVar) | strengthNeighbor );

		// check out if it is faster to use lower strength here because of LIMITs-rounding error if multiple childs!
		setConstraintWidth( (_width == hSize.middle.size) | strengthWidthHeight );
				
		// ---------------------------- root-container vertical ------------------------------
		
		outerVLimitVar = vSize.setSizeLimit(null);
		if (outerVLimitVar != null) {
			solver.addConstraint( (outerVLimitVar >= 0) | strengthHigh );
			// next is need because of rounding error if multiple childs! (or see height-constraints below!)
			solver.addConstraint( (outerVLimitVar <= 1) | strengthHigh );
		}
		
		autospace = AUTOSPACE_BOTH;
		if (vSize.hasSpan()) autospace = AUTOSPACE_NONE;
		else if (vSize.first == null && vSize.last != null) autospace = AUTOSPACE_FIRST;
		else if (vSize.last == null && vSize.first != null) autospace = AUTOSPACE_LAST;		

		outerVSpanVar = (autospace == AUTOSPACE_NONE) ? vSize.setSizeSpan(null) : new Variable();
		if (outerVSpanVar != null) {
			var _sumWeight = (autospace == AUTOSPACE_NONE) ? vSize.getSpanSumWeight() : ((autospace == AUTOSPACE_BOTH) ? 2 : 1);
			setConstraintVSpan(	(outerVSpanVar >= 0) | strengthHigh,
				(outerVSpanVar == (root_height - vSize.getLimitMax()) / _sumWeight) | strengthSpan
			);
		}
		// top
		if (autospace & AUTOSPACE_FIRST == 0)
			setConstraintTop( (_top == 0) | strengthNeighbor );
		else setConstraintTop( (_top == outerVSpanVar) | strengthNeighbor );
		// bottom
		if (autospace & AUTOSPACE_LAST == 0)
			setConstraintBottom( (_bottom == root_height) | strengthNeighbor );
		else setConstraintBottom( (_bottom == root_height - outerVSpanVar) | strengthNeighbor );
		
		// check out if it is faster to use lower strength here because of LIMITs-rounding error if multiple childs!
		setConstraintHeight( (_height == vSize.middle.size) | strengthWidthHeight );
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
	static var strengthEditVar = Strength.STRONG; //Strength.create(900, 0, 0);
	
	static var strengthHigh = Strength.REQUIRED; // Strength.create(900, 0, 0);
	static var strengthNeighbor = Strength.REQUIRED; //Strength.create(500, 0, 0);
	
	//static var strengthWidthHeight = Strength.create(2, 1, 0);
	static var strengthWidthHeight = Strength.STRONG; //Strength.create(0, 500, 0);
	
	//static var strengthOversize = Strength.create(0, 100, 100);
	//static var strengthOversize = Strength.MEDIUM; //Strength.create(0, 100, 0);
	
	static var strengthSpan = Strength.WEAK; //Strength.create(0, 0, 10);
	
	static inline var AUTOSPACE_NONE:Int = 0;
	static inline var AUTOSPACE_FIRST:Int= Align.LAST;
	static inline var AUTOSPACE_LAST:Int = Align.FIRST;
	static inline var AUTOSPACE_BOTH:Int = Align.CENTER;

	static inline function getAutospaceBox(size:SizeSpaced, childSize:SizeSpaced):Int
	{
		if (childSize.hasSpan()) return AUTOSPACE_NONE;
		if (size.middle._span || childSize.getLimitMax() < ( (size.middle._max != null) ? size.middle._max : size.middle._min))
			return getAutospaceAlign(childSize, childSize);
		else return AUTOSPACE_NONE;
	}
	
	static inline function getAutospaceRowCol(numHasSpan:Int, size:SizeSpaced, limitMax:Int, firstSize:SizeSpaced, lastSize:SizeSpaced):Int
	{
		if (numHasSpan > 0) return AUTOSPACE_NONE;
		if (size.middle._span || limitMax < ( (size.middle._max != null) ? size.middle._max : size.middle._min))
			return getAutospaceAlign(firstSize, lastSize);
		else return AUTOSPACE_NONE;
	}
		
	static inline function getAutospaceAlign(firstSize:SizeSpaced, lastSize:SizeSpaced):Int
	{
		if (firstSize.first == null && lastSize.last != null) return AUTOSPACE_FIRST;
		else if (lastSize.last == null && firstSize.first != null) return AUTOSPACE_LAST;
		else return AUTOSPACE_BOTH;
	}
		
	// -----------------------------------------------------------------------------------------------------

	static inline function setConstraintsNeighbors(
			setConstraintFirst:Constraint->Void, setConstraintLast:Constraint->Void, 
			first:Expression, last:Expression, parentPos:Variable, parentSize:Variable,
			isOversize = true, isScroll = false,
			spanVar:Variable, oversizeVar:Variable, scrollVar:Variable,
			align:Int, autospace:Int
			)
	{
		if (!isOversize) {
			// first
			if (autospace & AUTOSPACE_FIRST == 0) {
				if (isScroll) setConstraintFirst( (first + scrollVar == parentPos) | strengthNeighbor );
				else setConstraintFirst( (first == parentPos) | strengthNeighbor );
			}
			else {
				if (isScroll) setConstraintFirst( (first + scrollVar == parentPos + spanVar) | strengthNeighbor );
				else setConstraintFirst( (first == parentPos + spanVar) | strengthNeighbor );
			}
			// last
			if (autospace & AUTOSPACE_LAST == 0) {
				if (isScroll) setConstraintLast( (last + scrollVar == parentPos + parentSize) | strengthNeighbor );
				else setConstraintLast( (last == parentPos + parentSize) | strengthNeighbor );
			}
			else {
				if (isScroll) setConstraintLast( (last + scrollVar == parentPos + parentSize - spanVar) | strengthNeighbor );
				else setConstraintLast( (last == parentPos + parentSize - spanVar) | strengthNeighbor );
			}
		}
		else // ---------------- oversize ---------------------
		{
			if (align == Align.AUTO) {
				// do same as for auto spacing
				if (autospace == AUTOSPACE_FIRST) align = Align.LAST;
				else if (autospace == AUTOSPACE_LAST) align = Align.FIRST;
				else align = Align.CENTER;
			}
			
			if (align == Align.FIRST)        //  ----- oversize align left ----
			{	// first
				if (autospace & AUTOSPACE_FIRST == 0) {
					if (isScroll) setConstraintFirst( (first + scrollVar == parentPos) | strengthNeighbor );
					else setConstraintFirst( (first == parentPos) | strengthNeighbor );
				}
				else {
					if (isScroll) setConstraintFirst( (first + scrollVar == parentPos + spanVar) | strengthNeighbor );
					else setConstraintFirst( (first == parentPos + spanVar) | strengthNeighbor );
				}
				// last
				if (autospace & AUTOSPACE_LAST == 0) {
					if (isScroll) setConstraintLast( (last - oversizeVar + scrollVar == parentPos + parentSize) | strengthNeighbor );
					else setConstraintLast( (last - oversizeVar == parentPos + parentSize) | strengthNeighbor );
				}
				else {
					if (isScroll) setConstraintLast( (last - oversizeVar + scrollVar == parentPos + parentSize - spanVar) | strengthNeighbor );
					else setConstraintLast( (last - oversizeVar == parentPos + parentSize - spanVar) | strengthNeighbor );
				}
			}
			else if (align == Align.LAST)   //  ----- oversize align right ----
			{	// first
				if (autospace & AUTOSPACE_FIRST == 0) {
					if (isScroll) setConstraintFirst( (first + oversizeVar + scrollVar == parentPos) | strengthNeighbor );
					else setConstraintFirst( (first + oversizeVar == parentPos) | strengthNeighbor );
				}
				else {
					if (isScroll) setConstraintFirst( (first + oversizeVar + scrollVar == parentPos + spanVar) | strengthNeighbor );
					else setConstraintFirst( (first + oversizeVar == parentPos + spanVar) | strengthNeighbor );
				}
				// last
				if (autospace & AUTOSPACE_LAST == 0) {
					if (isScroll) setConstraintLast( (last + scrollVar == parentPos + parentSize) | strengthNeighbor );
					else setConstraintLast( (last == parentPos + parentSize) | strengthNeighbor );
				}
				else {
					if (isScroll) setConstraintLast( (last + scrollVar == parentPos + parentSize - spanVar) | strengthNeighbor );
					else setConstraintLast( (last == parentPos + parentSize - spanVar) | strengthNeighbor );
				}
			}
			else                             //  ---- oversize align centered ---
			{	// first
				if (autospace & AUTOSPACE_FIRST == 0) {
					if (isScroll) setConstraintFirst( (first + oversizeVar/2 + scrollVar == parentPos) | strengthNeighbor );
					else setConstraintFirst( (first + oversizeVar/2 == parentPos) | strengthNeighbor );
				}
				else {
					if (isScroll) setConstraintFirst( (first + oversizeVar/2 + scrollVar == parentPos + spanVar) | strengthNeighbor );
					else setConstraintFirst( (first + oversizeVar/2 == parentPos + spanVar) | strengthNeighbor );
				}
				// last
				if (autospace & AUTOSPACE_LAST == 0) {
					if (isScroll) setConstraintLast( (last - oversizeVar/2 + scrollVar == parentPos + parentSize) | strengthNeighbor );
					else setConstraintLast( (last - oversizeVar/2 == parentPos + parentSize) | strengthNeighbor );
				}
				else {
					if (isScroll) setConstraintLast( (last - oversizeVar/2 + scrollVar == parentPos + parentSize - spanVar) | strengthNeighbor );
					else setConstraintLast( (last - oversizeVar/2 == parentPos + parentSize - spanVar) | strengthNeighbor );
				}
			}
		}
		
	}
	
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
	
	var innerHLimitVar:Null<Variable> = null;
	var innerVLimitVar:Null<Variable> = null;	
	var innerHSpanVar:Null<Variable> = null;
	var innerVSpanVar:Null<Variable> = null;	
	
	var outerHLimitVar:Null<Variable> = null;
	var outerVLimitVar:Null<Variable> = null;	
	var outerHSpanVar:Null<Variable> = null;
	var outerVSpanVar:Null<Variable> = null;	
	
	var innerHOversizeVar:Null<Variable> = null;
	var innerVOversizeVar:Null<Variable> = null;
	var outerHOversizeVar:Null<Variable> = null;
	var outerVOversizeVar:Null<Variable> = null;

	function addTreeConstraints(solver:Solver, depth:Int)
	{
		this.solver = solver;
		this.depth = depth++;
		
		if (childs != null)
		{
			var autospace:Int;
			var alignOnOversize:Align;
			
			var hOversizeWeightSubtractor = 0;
			var vOversizeWeightSubtractor = 0;
			
			// horizontal oversize-align for box (if not autoalign) or hbox
			if (isInnerHOversize) {
				innerHOversizeVar = new Variable();
				solver.addConstraint( (innerHOversizeVar >= 0 ) | strengthHigh);				
				//trace(depth,layout.name + ":innerOversize", childsHighestHMin-hSize.middle._min, hOversizeWeight);
				if (containerType == ContainerType.BOX)
					solver.addConstraint( (innerHOversizeVar <= childsHighestHMin - hSize.middle._min) | strengthHigh);				
				else solver.addConstraint( (innerHOversizeVar <= childsSumHMin - hSize.middle._min) | strengthHigh);					
				solver.addConstraint( (innerHOversizeVar == 0) | Strength.create(0, innerHOversizeWeight, 0));
			}			
			
			// vertical oversize-align for box (if not autoalign) or hbox
			if (isInnerVOversize) {
				innerVOversizeVar = new Variable();
				solver.addConstraint( (innerVOversizeVar >= 0 ) | strengthHigh);
				if (containerType == ContainerType.BOX)
					solver.addConstraint( (innerVOversizeVar <= childsHighestVMin - vSize.middle._min) | strengthHigh);		
				else solver.addConstraint( (innerVOversizeVar <= childsSumVMin - vSize.middle._min) | strengthHigh);					
				solver.addConstraint( (innerVOversizeVar == 0) | Strength.create(0, innerVOversizeWeight, 0));
			}
						
			for (i in 0...childs.length)
			{	
				var child = childs[i];
				
				child.addTreeConstraints(solver, depth); // <- recursive childs
				
				// ----------------------------------------------------------------
				// ------------------------- horizontal ---------------------------
				// ----------------------------------------------------------------
				
				if (containerType == ContainerType.HBOX) // -------- HBOX --------
				{
					innerHLimitVar = child.hSize.setSizeLimit(innerHLimitVar);
					innerHSpanVar = child.hSize.setSizeSpan(innerHSpanVar);								
					if (i>0) child.setConstraintLeft( (child._left == childs[i-1]._right) | strengthNeighbor );
				}
				else                                     // -------- BOX ---------
				{
					child.outerHLimitVar = child.hSize.setSizeLimit(null);
					if (child.outerHLimitVar != null) {
						child.setConstraintHLimit( (child.outerHLimitVar >= 0) | strengthHigh );
						// next is need because of rounding error if multiple childs! (or see with-constraints below!)
						solver.addConstraint((child.outerHLimitVar <= 1) | strengthHigh);
					}
					
					autospace = getAutospaceBox(hSize, child.hSize);					
					alignOnOversize = layout.alignChildsOnOversizeX;
					
					if (child.isOuterHOversize) {
						child.outerHOversizeVar = new Variable();
						//trace(depth, child.layout.name + ":outerOversize", child.hSize.getLimitMin()-hSize.middle._min, hOversizeWeight);
						solver.addConstraint( (child.outerHOversizeVar >= 0 ) | strengthHigh);	
						solver.addConstraint( (child.outerHOversizeVar <= child.hSize.getLimitMin() - hSize.middle._min) | strengthHigh);				
						solver.addConstraint( (child.outerHOversizeVar == 0) | Strength.create(0, child.outerHOversizeWeight, 0));
						alignOnOversize = (autospace != AUTOSPACE_NONE) ? autospace : getAutospaceAlign(child.hSize, child.hSize);
					}
					
					child.outerHSpanVar = (autospace == AUTOSPACE_NONE) ? child.hSize.setSizeSpan(null) : new Variable();
					if (child.outerHSpanVar != null) {
						var _sumWeight = (autospace == AUTOSPACE_NONE) ? child.hSize.getSpanSumWeight() : ((autospace == AUTOSPACE_BOTH) ? 2 : 1);
						//trace(child.layout.name + ":span",hSize.middle._min / _sumWeight, child.hSize.getLimitMax() /  _sumWeight);
						child.setConstraintHSpan(
							(child.outerHSpanVar >= 0) | strengthHigh,
							(child.outerHSpanVar == (_width - child.hSize.getLimitMax()) / _sumWeight) | strengthSpan
						);
					}
					
					setConstraintsNeighbors(
						child.setConstraintLeft, child.setConstraintRight,
						child._left, child._right, _x, _width,
						(isInnerHOversize || child.isOuterHOversize), layout.scrollX,
						child.outerHSpanVar, 
						(isInnerHOversize) ? innerHOversizeVar : child.outerHOversizeVar,
						_xScroll, alignOnOversize, autospace
					);
				}
						
				// check out if it is faster to use lower strength here because of LIMITs-rounding error if multiple childs!
				child.setConstraintWidth( (child._width == child.hSize.middle.size) | strengthWidthHeight );
												
				// ----------------------------------------------------------------
				// ------------------------- vertical -----------------------------
				// ----------------------------------------------------------------
				
				if (containerType == ContainerType.VBOX) // -------- VBOX --------
				{
					innerVLimitVar = child.vSize.setSizeLimit(innerVLimitVar);
					innerVSpanVar = child.vSize.setSizeSpan(innerVSpanVar);					
					if (i > 0) child.setConstraintTop( (child._top == childs[i-1]._bottom) | strengthNeighbor );
				}
				else                                     // -------- BOX ---------
				{
					child.outerVLimitVar = child.vSize.setSizeLimit(null);
					if (child.outerVLimitVar != null) {
						child.setConstraintVLimit( (child.outerVLimitVar >= 0) | strengthHigh );
						// next is need because of rounding error if multiple childs! (or see height-constraints below!)
						solver.addConstraint((child.outerVLimitVar <= 1) | strengthHigh);
					}
					
					autospace = getAutospaceBox(vSize, child.vSize);
					alignOnOversize = layout.alignChildsOnOversizeY;
					
					if (child.isOuterVOversize) {
						child.outerVOversizeVar = new Variable();
						solver.addConstraint( (child.outerVOversizeVar >= 0 ) | strengthHigh);						
						solver.addConstraint( (child.outerVOversizeVar <= child.vSize.getLimitMin() - vSize.middle._min) | strengthHigh);				
						solver.addConstraint( (child.outerVOversizeVar == 0) | Strength.create(0, child.outerVOversizeWeight, 0));
						alignOnOversize = (autospace != AUTOSPACE_NONE) ? autospace : getAutospaceAlign(child.vSize, child.vSize);
					}
					
					child.outerVSpanVar = (autospace == AUTOSPACE_NONE) ? child.vSize.setSizeSpan(null) : new Variable();
					if (child.outerVSpanVar != null) {
						var _sumWeight = (autospace == AUTOSPACE_NONE) ? child.vSize.getSpanSumWeight() : ((autospace == AUTOSPACE_BOTH) ? 2 : 1);
						child.setConstraintVSpan(
							(child.outerVSpanVar >= 0) | strengthHigh,
							(child.outerVSpanVar == (_height - child.vSize.getLimitMax()) / _sumWeight) | strengthSpan
						);
					}
					
					setConstraintsNeighbors(
						child.setConstraintTop, child.setConstraintBottom, 
						child._top, child._bottom, _y, _height,
						(isInnerVOversize || child.isOuterVOversize), layout.scrollY,
						child.outerVSpanVar, 
						(isInnerVOversize) ? innerVOversizeVar : child.outerVOversizeVar,
						_yScroll, alignOnOversize, autospace
					);
				}
				
				// check out if it is faster to use lower strength here because of LIMITs-rounding error if multiple childs!
				child.setConstraintHeight( (child._height == child.vSize.middle.size) | strengthWidthHeight );
			}			
			
			// ----------------------------------------------------------------
			// ------- limitVar and sumWeight of childs for ROW or COL --------
			// ----------------------------------------------------------------
			if (containerType != ContainerType.BOX && childs.length > 0)
			{
				var autospaceSumWeight:Int = 0;
				
				if (containerType == ContainerType.HBOX)
				{
					if (innerHLimitVar != null) {
						setConstraintRowColLimit( (innerHLimitVar >= 0) | strengthHigh );
						setConstraintRowColLimit( (innerHLimitVar <= 1) | strengthHigh ); // CHECK: here also <= 1 ?
					}
				
					autospace = getAutospaceRowCol(childsNumHSpan, hSize, childsSumHMax, childs[0].hSize, childs[childs.length - 1].hSize);
					if (autospace != AUTOSPACE_NONE) {
						autospaceSumWeight = (autospace == AUTOSPACE_BOTH) ? 2 : 1;
						if (innerHSpanVar == null) innerHSpanVar = new Variable();
					}
					
					alignOnOversize = layout.alignChildsOnOversizeX;
					
					if (isInnerHOversize && alignOnOversize == Align.AUTO) {
						alignOnOversize = (autospace != AUTOSPACE_NONE) ? autospace : getAutospaceAlign(childs[0].hSize, childs[childs.length - 1].hSize);
					}
					
					if (innerHSpanVar != null) {
						setConstraintRowColSpan(
							(innerHSpanVar >= 0) | strengthHigh,
							(innerHSpanVar == (_width - childsSumHMax) / (childsSumHWeight + autospaceSumWeight) ) | strengthSpan
						);
					}
			
					setConstraintsNeighbors(
						setConstraintLeft, setConstraintRight, 
						childs[0]._left, childs[childs.length-1]._right, _x, _width,
						isInnerHOversize, layout.scrollX,
						innerHSpanVar, innerHOversizeVar, _xScroll,
						alignOnOversize, autospace
					);
				}
				else // --------- Container.VBOX --------
				{					
					if (innerVLimitVar != null) {
						setConstraintRowColLimit( (innerVLimitVar >= 0) | strengthHigh );
						setConstraintRowColLimit( (innerVLimitVar <= 1) | strengthHigh ); // CHECK: here also <= 1 ?
					}
				
					autospace = getAutospaceRowCol(childsNumVSpan, vSize, childsSumVMax, childs[0].vSize, childs[childs.length - 1].vSize);
					if (autospace != AUTOSPACE_NONE) {
						autospaceSumWeight = (autospace == AUTOSPACE_BOTH) ? 2 : 1;
						if (innerVSpanVar == null) innerVSpanVar = new Variable();
					}
					
					alignOnOversize = layout.alignChildsOnOversizeY;
					
					if (isInnerVOversize && alignOnOversize == Align.AUTO) {
						alignOnOversize = (autospace != AUTOSPACE_NONE) ? autospace : getAutospaceAlign(childs[0].vSize, childs[childs.length - 1].vSize);
					}
					
					if (innerVSpanVar != null) {
						setConstraintRowColSpan(
							(innerVSpanVar >= 0) | strengthHigh,
							(innerVSpanVar == (_height - childsSumVMax) / (childsSumVWeight + autospaceSumWeight) ) | strengthSpan
						);
					}
			
					setConstraintsNeighbors(
						setConstraintTop, setConstraintBottom, 
						childs[0]._top, childs[childs.length-1]._bottom, _y, _height,
						isInnerVOversize, layout.scrollY,
						innerVSpanVar, innerVOversizeVar, _yScroll,
						alignOnOversize, autospace
					);
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
			
			//trace(Std.int(childs[0].width) + "-" + childs[0].layout.name + Std.int(childs[0].outerHOversizeVar.m_value),
			//	childs[0].childs[0].layout.name + Std.int(childs[0].childs[0].outerHOversizeVar.m_value));
			//trace(childs[0].childs[1].childs[1]._x.m_value);
			
			// TODO: fire all onOversize Events
			
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

