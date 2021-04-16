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
	inline function get_width():Null<Float> {
		//return _width.m_value;
		if (hSize.middle.sizeLimit != null && hSize.middle.sizeSpan != null) return hSize.middle._min + hSize.middle.sizeLimit.m_value * (hSize.middle._max - hSize.middle._min) + hSize.middle.sizeSpan.m_value * hSize.middle._weight;
		else if (hSize.middle.sizeLimit != null) return hSize.middle._min + hSize.middle.sizeLimit.m_value * (hSize.middle._max - hSize.middle._min);
		else if (hSize.middle.sizeSpan  != null) return hSize.middle._min + hSize.middle.sizeSpan.m_value * hSize.middle._weight;
		else return hSize.middle._min;
	}
	inline function set_width(value:Null<Float>):Null<Float> {
		// TODO
		return value;
	}
	
	public var height(get,set):Null<Float>;
	inline function get_height() {
		//return _height.m_value;
		if (vSize.middle.sizeLimit != null && vSize.middle.sizeSpan != null) return vSize.middle._min + vSize.middle.sizeLimit.m_value * (vSize.middle._max - vSize.middle._min) + vSize.middle.sizeSpan.m_value * vSize.middle._weight;
		else if (vSize.middle.sizeLimit != null) return vSize.middle._min + vSize.middle.sizeLimit.m_value * (vSize.middle._max - vSize.middle._min);
		else if (vSize.middle.sizeSpan  != null) return vSize.middle._min + vSize.middle.sizeSpan.m_value * vSize.middle._weight;
		else return vSize.middle._min;
	}
	inline function set_height(value:Null<Float>):Null<Float> {
		// TODO
		return value;
	}

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
		if (width >= greatestChildMinSize) return 0;
		return greatestChildMinSize - width;
	}
	
	// ---------- Variables for Jasper Constraints ------
	public var _xScroll(default,null):Variable;
	public var _yScroll(default,null):Variable;

	public var _x(default,null):Variable;
	public var _y(default,null):Variable;	

	public var _centerX:Expression; // TODO: check public/rw-access
	public var _centerY:Expression;

	public var _width(get,never):Expression;
	function get__width():Expression {
		return hSize.middle.size;
	}
	public var _height(get,never):Expression;	
	function get__height():Expression {
		return vSize.middle.size;
	}	
	public var _left(get,never):Expression;
	function get__left():Expression {
		if (hSize.first != null) return new Term(_x) - hSize.first.size;
		else return new Expression([new Term(_x)]);
	}
	public var _right(get,never):Expression;
	function get__right():Expression {
		if (hSize.last != null) return new Term(_x) + hSize.middle.size + hSize.last.size;
		else return new Term(_x) + hSize.middle.size;
	}
	public var _top(get, never):Expression;
	function get__top():Expression {
		if (vSize.first != null) return new Term(_y) - vSize.first.size;
		else return new Expression([new Term(_y)]);
	}
	public var _bottom(get,never):Expression;
	function get__bottom():Expression {
		if (vSize.last != null) return new Term(_y) + vSize.middle.size + vSize.last.size;
		else return new Term(_y) + vSize.middle.size;
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
		
		_centerX = new Term(_x) + (hSize.middle.size / 2.0);
		_centerY = new Term(_y) + (hSize.middle.size / 2.0);
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
		
		if (containerType == ContainerType.HBOX) {
			innerHLimitVar = child.hSize.setSizeLimit(innerHLimitVar);
			innerHSpanVar = child.hSize.setSizeSpan(innerHSpanVar);								
		}
		else {
			child.outerHLimitVar = child.hSize.setSizeLimit(null);
			var autospace = getAutospaceBox(hSize, child.hSize);
			child.outerHSpanVar = (autospace == AUTOSPACE_NONE) ? child.hSize.setSizeSpan(null) : new Variable();			
		}
		
		if (containerType == ContainerType.VBOX) {
			innerVLimitVar = child.vSize.setSizeLimit(innerVLimitVar);
			innerVSpanVar = child.vSize.setSizeSpan(innerVSpanVar);					
		}
		else {
			child.outerVLimitVar = child.vSize.setSizeLimit(null);
			var autospace = getAutospaceBox(vSize, child.vSize);
			child.outerVSpanVar = (autospace == AUTOSPACE_NONE) ? child.vSize.setSizeSpan(null) : new Variable();
		}
		
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
		solver.addConstraint( (root_height >= vSize.getLimitMin()) | strengthHigh );
		
			
		// --------------------------- root-container horizontal -----------------------------		
		outerHLimitVar = hSize.setSizeLimit(null);
		if (outerHLimitVar != null) setConstraintOuterHLimit();
		
		var autospace = (hSize.hasSpan()) ? AUTOSPACE_NONE : getAutospaceAlign(hSize, hSize);
		
		outerHSpanVar = (autospace == AUTOSPACE_NONE) ? hSize.setSizeSpan(null) : new Variable();
		if (outerHSpanVar != null) {
			//setConstraintOuterHSpan( root_width, (autospace == AUTOSPACE_NONE) ? hSize.getSpanSumWeight() : ((autospace == AUTOSPACE_BOTH) ? 2 : 1) );			
			var sumWeight = (autospace == AUTOSPACE_NONE) ? hSize.getSpanSumWeight() : ((autospace == AUTOSPACE_BOTH) ? 2 : 1);
			var c1:Constraint = (outerHSpanVar >= 0) | strengthHigh;
			var c2:Constraint = (outerHSpanVar == (root_width - hSize.getLimitMax()) / sumWeight) | strengthSpan;
			solver.addConstraint(c1);
			solver.addConstraint(c2);
		}
		// left
		if (autospace & AUTOSPACE_FIRST == 0) setConstraintLeft( (_left == 0) | strengthNeighbor );
		else setConstraintLeft( (_left == outerHSpanVar) | strengthNeighbor );
		// right
		if (autospace & AUTOSPACE_LAST == 0) setConstraintRight( (_right == root_width) | strengthNeighbor );
		else setConstraintRight( (_right == root_width - outerHSpanVar) | strengthNeighbor );

		// ---------------------------- root-container vertical ------------------------------		
		outerVLimitVar = vSize.setSizeLimit(null);
		if (outerVLimitVar != null) setConstraintOuterVLimit();
		
		autospace = (vSize.hasSpan()) ? AUTOSPACE_NONE : getAutospaceAlign(vSize, vSize);

		outerVSpanVar = (autospace == AUTOSPACE_NONE) ? vSize.setSizeSpan(null) : new Variable();
		if (outerVSpanVar != null) {
			//setConstraintOuterVSpan(root_height, (autospace == AUTOSPACE_NONE) ? vSize.getSpanSumWeight() : ((autospace == AUTOSPACE_BOTH) ? 2 : 1));
			var sumWeight = (autospace == AUTOSPACE_NONE) ? vSize.getSpanSumWeight() : ((autospace == AUTOSPACE_BOTH) ? 2 : 1);
			var c1:Constraint = (outerVSpanVar >= 0) | strengthHigh;
			var c2:Constraint = (outerVSpanVar == (root_height - vSize.getLimitMax()) / sumWeight) | strengthSpan;
			solver.addConstraint(c1);
			solver.addConstraint(c2);
		}
		// top
		if (autospace & AUTOSPACE_FIRST == 0) setConstraintTop( (_top == 0) | strengthNeighbor );
		else setConstraintTop( (_top == outerVSpanVar) | strengthNeighbor );
		// bottom
		if (autospace & AUTOSPACE_LAST == 0) setConstraintBottom( (_bottom == root_height) | strengthNeighbor );
		else setConstraintBottom( (_bottom == root_height - outerVSpanVar) | strengthNeighbor );
		
		addTreeConstraints(solver, 0); // <- recursive Container
		
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
	static var strengthEditVar = Strength.STRONG;
	//static var strengthEditVar = Strength.MEDIUM;
	
	static var strengthHigh = Strength.REQUIRED;
	//static var strengthHigh = Strength.STRONG;
	
	static var strengthNeighbor = Strength.REQUIRED;
	//static var strengthNeighbor = Strength.STRONG;
	
	static var strengthSpan = Strength.WEAK;
	//static var strengthSpan = Strength.MEDIUM;
	
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
			first:Expression, last:Expression, parentPos:Variable, parentSize:Expression,
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
	
	inline function setConstraintInnerLimit(innerLimitVar:Variable) {
		//var c1:Constraint = (innerLimitVar >= 0) | strengthHigh;
		var c1:Constraint = (innerLimitVar >= 0) | Strength.STRONG;
		//var c2:Constraint = (innerLimitVar <= 1) | strengthHigh; // need because of rounding error if multiple childs!
		solver.addConstraint(c1);
		//solver.addConstraint(c2);
	}
	
	inline function setConstraintOuterHLimit() {
		//var c1:Constraint = (outerHLimitVar >= 0) | strengthHigh;
		var c1:Constraint = (outerHLimitVar >= 0) | Strength.STRONG;
		//var c2:Constraint = (outerHLimitVar <= 1) | strengthHigh; // need because of rounding error if multiple childs!
		solver.addConstraint(c1);
		//solver.addConstraint(c2);
	}
	inline function setConstraintOuterVLimit() {
		//var c1:Constraint = (outerVLimitVar >= 0) | strengthHigh;
		var c1:Constraint = (outerVLimitVar >= 0) | Strength.STRONG;
		//var c2:Constraint = (outerVLimitVar <= 1) | strengthHigh; // need because of rounding error if multiple childs!
		solver.addConstraint(c1);
		//solver.addConstraint(c2);
	}
	
	inline function setConstraintInnerSpan(innerSpanVar:Variable, sizeVar:Expression, sumMax:Int, sumWeight:Float) {
		//var c1:Constraint = (innerSpanVar >= 0) | strengthHigh;
		var c1:Constraint = (innerSpanVar >= 0) | Strength.STRONG;
		var c2:Constraint = (innerSpanVar == (sizeVar - sumMax) / sumWeight) | strengthSpan;
		solver.addConstraint(c1);
		solver.addConstraint(c2);
	}
	
	inline function setConstraintOuterHSpan(parent_width:Expression, sumWeight:Float) {
		//var c1:Constraint = (outerHSpanVar >= 0) | strengthHigh; // <-
		var c1:Constraint = (outerHSpanVar >= 0) | Strength.STRONG; // <-
		var c2:Constraint = (outerHSpanVar == (parent_width - hSize.getLimitMax()) / sumWeight) | strengthSpan;
		solver.addConstraint(c1);
		solver.addConstraint(c2);
	}
	
	inline function setConstraintOuterVSpan(parent_height:Expression, sumWeight:Float) {
		//var c1:Constraint = (outerVSpanVar >= 0) | strengthHigh;
		var c1:Constraint = (outerVSpanVar >= 0) | Strength.STRONG;
		var c2:Constraint = (outerVSpanVar == (parent_height - vSize.getLimitMax()) / sumWeight) | strengthSpan;
		solver.addConstraint(c1);
		solver.addConstraint(c2);
	}
		
	inline function setConstraintInnerHOversize(childsHMin:Int) {
		var c1:Constraint = (innerHOversizeVar >= 0 ) | strengthHigh;	
		var c2:Constraint = (innerHOversizeVar <= childsHMin - hSize.middle._min) | strengthHigh;				
		var c3:Constraint = (innerHOversizeVar == 0) | Strength.create(0, innerHOversizeWeight, 0);
		solver.addConstraint(c1);
		solver.addConstraint(c2);
		solver.addConstraint(c3);
	}
	
	inline function setConstraintOuterHOversize() {
		var c1:Constraint = (outerHOversizeVar >= 0 ) | strengthHigh;	
		var c2:Constraint = (outerHOversizeVar <= hSize.getLimitMin() - parent.hSize.middle._min) | strengthHigh;				
		var c3:Constraint = (outerHOversizeVar == 0) | Strength.create(0, outerHOversizeWeight, 0);
		solver.addConstraint(c1);
		solver.addConstraint(c2);
		solver.addConstraint(c3);
	}
	
	inline function setConstraintInnerVOversize(childsVMin:Int) {
		var c1:Constraint = (innerVOversizeVar >= 0 ) | strengthHigh;	
		var c2:Constraint = (innerVOversizeVar <= childsVMin - vSize.middle._min) | strengthHigh;				
		var c3:Constraint = (innerVOversizeVar == 0) | Strength.create(0, innerVOversizeWeight, 0);
		solver.addConstraint(c1);
		solver.addConstraint(c2);
		solver.addConstraint(c3);
	}
		
	inline function setConstraintOuterVOversize() {
		var c1:Constraint = (outerVOversizeVar >= 0 ) | strengthHigh;	
		var c2:Constraint = (outerVOversizeVar <= vSize.getLimitMin() - parent.vSize.middle._min) | strengthHigh;				
		var c3:Constraint = (outerVOversizeVar == 0) | Strength.create(0, outerVOversizeWeight, 0);
		solver.addConstraint(c1);
		solver.addConstraint(c2);
		solver.addConstraint(c3);
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
			
			// horizontal oversize-align for BOX (if not autoalign) or HBOX
			if (isInnerHOversize) {
				innerHOversizeVar = new Variable();
				if (containerType == ContainerType.BOX) setConstraintInnerHOversize(childsHighestHMin);
				else setConstraintInnerHOversize(childsSumHMin);
			}			
			
			// vertical oversize-align for BOX (if not autoalign) or VBOX
			if (isInnerVOversize) {
				innerVOversizeVar = new Variable();
				if (containerType == ContainerType.BOX) setConstraintInnerVOversize(childsHighestVMin);
				else setConstraintInnerVOversize(childsSumVMin);
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
					if (i>0) child.setConstraintLeft( (child._left == childs[i-1]._right) | strengthNeighbor );
				}
				else                                     // -------- BOX ---------
				{
					if (child.outerHLimitVar != null) child.setConstraintOuterHLimit();
					
					autospace = getAutospaceBox(hSize, child.hSize);					
					alignOnOversize = layout.alignChildsOnOversizeX;
					
					if (child.isOuterHOversize) {
						child.outerHOversizeVar = new Variable();
						child.setConstraintOuterHOversize();
						alignOnOversize = (autospace != AUTOSPACE_NONE) ? autospace : getAutospaceAlign(child.hSize, child.hSize);
					}
					
					if (child.outerHSpanVar != null) {
						child.setConstraintOuterHSpan(_width, (autospace == AUTOSPACE_NONE) ? child.hSize.getSpanSumWeight() : ((autospace == AUTOSPACE_BOTH) ? 2 : 1));
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
						
				//child.setConstraintWidth();
												
				// ----------------------------------------------------------------
				// ------------------------- vertical -----------------------------
				// ----------------------------------------------------------------
				
				if (containerType == ContainerType.VBOX) // -------- VBOX --------
				{
					if (i > 0) child.setConstraintTop( (child._top == childs[i-1]._bottom) | strengthNeighbor );
				}
				else                                     // -------- BOX ---------
				{
					if (child.outerVLimitVar != null) child.setConstraintOuterVLimit();
					
					autospace = getAutospaceBox(vSize, child.vSize);
					alignOnOversize = layout.alignChildsOnOversizeY;
					
					if (child.isOuterVOversize) {
						child.outerVOversizeVar = new Variable();
						setConstraintOuterVOversize();
						alignOnOversize = (autospace != AUTOSPACE_NONE) ? autospace : getAutospaceAlign(child.vSize, child.vSize);
					}
					
					if (child.outerVSpanVar != null) {
						child.setConstraintOuterVSpan(_height, (autospace == AUTOSPACE_NONE) ? child.vSize.getSpanSumWeight() : ((autospace == AUTOSPACE_BOTH) ? 2 : 1));
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
				
				//child.setConstraintHeight();
			}			
			
			// ----------------------------------------------------------------
			// ------- limitVar and sumWeight of childs for ROW or COL --------
			// ----------------------------------------------------------------
			if (containerType != ContainerType.BOX && childs.length > 0)
			{
				var autospaceSumWeight:Int = 0;
				
				if (containerType == ContainerType.HBOX)
				{
					if (innerHLimitVar != null) setConstraintInnerLimit(innerHLimitVar);
				
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
						setConstraintInnerSpan( innerHSpanVar, _width, childsSumHMax, childsSumHWeight + autospaceSumWeight);
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
					if (innerVLimitVar != null)	setConstraintInnerLimit( innerVLimitVar );
				
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
						setConstraintInnerSpan( innerVSpanVar, _height, childsSumVMax, childsSumVWeight + autospaceSumWeight);
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

