package peote.layout;

import jasper.Variable;
import jasper.Expression;
import jasper.Term;
import jasper.Strength;
import jasper.Constraint;
import jasper.Solver;
import peote.layout.Align;
import peote.layout.util.ConstraintSet;

import peote.layout.util.SizeSpaced;

typedef InnerLimit = { width:Int, height:Int }

@:allow(peote.layout.util.ConstraintSet)
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
	public var _xScroll(default,null):Null<Variable> = null;
	public var _yScroll(default,null):Null<Variable> = null;

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
	var constraintSet:ConstraintSet;
	
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
		
		constraintSet = new ConstraintSet();
				
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
		if (layout.name != "") trace("----- " + layout.name + "-----");
		#end
		
		if (childs != null && childs.length > 0) {
			for (child in childs) {
				#if peotelayout_debug
				if (child.layout.name != "") trace("  child:" + child.layout.name);
				#end
				child.parent = this;
				calculateChildLimits(child);
				calculateChildOversize(child);
			}
			
			// oversizing or fixing limits  ------ horizontal -----------
			if (containerType == ContainerType.HBOX) {
				fixLimitMin(hSize, childsSumHMin, layout.limitMinWidthToChilds);
				if ( isInnerOversize(hSize, childsSumHMin, layout.limitMinWidthToChilds) ) {
					innerHOversizeVar = new Variable();
					innerHOversizeWeight++; 
				}
				fixLimitMax(hSize, childsSumHMax, layout.limitMaxWidthToChilds);
			} else {                     // BOX
				fixLimitMin(hSize, childsHighestHMin, layout.limitMinWidthToChilds);
				if ( isInnerOversize(hSize, childsHighestHMin, layout.limitMinWidthToChilds && layout.alignChildsOnOversizeX != Align.AUTO) ) {
					innerHOversizeVar = new Variable();
					innerHOversizeWeight++; 
				}
				fixLimitMax(hSize, childsHighestHMax, layout.limitMaxWidthToChilds);
			}
			
			// oversizing or fixing limits  ------ vertical -----------
			if (containerType == ContainerType.VBOX) {
				fixLimitMin(vSize, childsSumVMin, layout.limitMinHeightToChilds);
				if ( isInnerOversize(vSize, childsSumVMin, layout.limitMinHeightToChilds) ) {
					innerVOversizeVar = new Variable();
					innerVOversizeWeight++; 
				}
				fixLimitMax(vSize, childsSumVMax, layout.limitMaxHeightToChilds);
			}
			else {                     // BOX
				fixLimitMin(vSize, childsHighestVMin, layout.limitMinHeightToChilds);
				if ( isInnerOversize(vSize, childsHighestVMin, layout.limitMinHeightToChilds && layout.alignChildsOnOversizeY != Align.AUTO) ) {
					innerVOversizeVar = new Variable();
					innerVOversizeWeight++; 
				}
				fixLimitMax(vSize, childsHighestHMax, layout.limitMaxHeightToChilds);
			}
			
			for (child in childs) {
				#if peotelayout_debug
				if (child.layout.name != "") trace("  child:" + child.layout.name);
				#end
				child.parent = this;
				calculateChildVars(child);
			}
			
		}		
		
		#if peotelayout_debug
		debug();
		#end
		
		this.childs = childs;
		// TODO: update
	}
	
	public function debug() {
		if (layout.name != "") 
		trace(""
			+"\nisInnerHOversize:"+(innerHOversizeVar!=null)
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
			+"\nchildsHighestVMax:"+childsHighestVMax
		);
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
	}
			
	inline function calculateChildOversize(child:LayoutContainer)
	{
		if (containerType != ContainerType.HBOX && !layout.limitMinWidthToChilds 
			&& layout.alignChildsOnOversizeX == Align.AUTO && child.hSize.getLimitMin() > hSize.middle._min) {
			child.outerHOversizeVar = new Variable();
			child.outerHOversizeWeight = child.innerHOversizeWeight + 1;
			innerHOversizeWeight += child.outerHOversizeWeight;
		}
		else innerHOversizeWeight += child.innerHOversizeWeight;
		
		if (containerType != ContainerType.VBOX && !layout.limitMinHeightToChilds
			&& layout.alignChildsOnOversizeY == Align.AUTO && child.vSize.getLimitMin() > vSize.middle._min) {
			child.outerVOversizeVar = new Variable();
			child.outerVOversizeWeight = child.innerVOversizeWeight + 1;
			innerVOversizeWeight += child.outerVOversizeWeight;
		}
		else innerVOversizeWeight += child.innerVOversizeWeight;	
	}
	
	inline function fixLimitMin(size:SizeSpaced, childsMin:Int, limitMinToChilds:Bool):Bool {
		if (limitMinToChilds && size.middle._min < childsMin) {
			size.middle._min = childsMin;
			if (size.middle._max != null && size.middle._max < childsMin) size.middle._max = childsMin;
			return true;
		} else return false;
	}
	
	inline function isInnerOversize(size:SizeSpaced, childsMin:Int, limitMinToChilds:Bool):Bool
		return (!limitMinToChilds && size.middle._min < childsMin);
	
	inline function fixLimitMax(size:SizeSpaced, childsMax:Int, limitMaxToChilds):Bool {
		if ( limitMaxToChilds && childsMax != 0 && (size.middle._max == null || size.middle._max > childsMax) ) {
			size.middle._max = childsMax;
			return true;
		} else return false;
	}
	
	inline function calculateChildVars(child:LayoutContainer)
	{		
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
		
	}
			
	public function getChild(childNumber:Int):LayoutContainer {
		return childs[childNumber];
	}
	
	public function addChild(child:LayoutContainer, atIndex:Null<Int> = null) {
		
		trace("-------- ADD CHILD --------");
		
		if (childs == null) childs = new Array<LayoutContainer>();
		
		var isFirst = false;
		var isLast = false;
		
		if (atIndex == null || atIndex >= childs.length) {
			atIndex = childs.length;
			isLast = true; // add to end
		}
		if (atIndex <= 0) {
			atIndex = 0;
			isFirst = true; // add to start
		}
		
		childs.insert(atIndex, child);
		
		// ------------
		child.parent = this;
		calculateChildLimits(child);
		calculateChildOversize(child);
		
		// TODO: update min/max from this container
			// oversizing or fixing limits  ------ horizontal -----------
			if (containerType == ContainerType.HBOX) {
				fixLimitMin(hSize, childsSumHMin, layout.limitMinWidthToChilds);
				if ( isInnerOversize(hSize, childsSumHMin, layout.limitMinWidthToChilds) ) {
					innerHOversizeVar = new Variable();
					innerHOversizeWeight++; 
				}
				fixLimitMax(hSize, childsSumHMax, layout.limitMaxWidthToChilds);
			} else {                     // BOX
				fixLimitMin(hSize, childsHighestHMin, layout.limitMinWidthToChilds);
				if ( isInnerOversize(hSize, childsHighestHMin, layout.limitMinWidthToChilds && layout.alignChildsOnOversizeX != Align.AUTO) ) {
					innerHOversizeVar = new Variable();
					innerHOversizeWeight++; 
				}
				fixLimitMax(hSize, childsHighestHMax, layout.limitMaxWidthToChilds);
			}
		#if peotelayout_debug
		debug();
		#end
		
		trace("innerHLimitVar before:",(innerHLimitVar != null));
		trace("innerHSpanVar before:",(innerHSpanVar != null));
		trace("innerHOversizeVar before:",(innerHOversizeVar != null));

		calculateChildVars(child);
		
		trace("innerHLimitVar after:",(innerHLimitVar != null));
		trace("innerHSpanVar after:",(innerHSpanVar != null));
		trace("innerHOversizeVar after:",(innerHOversizeVar != null));

		// TODO: recursive upwards if min/max was changed
		
		// -------------------------------------------------
		
		// Only if there is a Solver !
		if (solver == null) return;
		
		// recursive childs
		// TODO: use already initialized constraints
		child.addTreeConstraints(solver, depth);

		// ------------------------- addChild horizontal ---------------------------
		
		if (containerType == ContainerType.HBOX) {
			
			if (innerHLimitVar != null) constraintSet.innerLimit(solver, innerHLimitVar);
			
			// TODO: update: childsNumHSpan, childsSumHMax
			var autospace = getAutospaceRowCol(childsNumHSpan, hSize, childsSumHMax, childs[0].hSize, childs[childs.length - 1].hSize);
			var autospaceSumWeight = 0;
			// TODO: check if autospace was changing to enable or changing side
			if (autospace != AUTOSPACE_NONE) {
				// TODO
				autospaceSumWeight = (autospace == AUTOSPACE_BOTH) ? 2 : 1;
				if (innerHSpanVar == null) innerHSpanVar = new Variable();
			}
			
			// TODO: remove before!
			
			if (innerHSpanVar != null) { trace("KK", childsSumHMax, childsSumHWeight + autospaceSumWeight);
				constraintSet.innerSpan(solver, innerHSpanVar, _width, childsSumHMax, childsSumHWeight + autospaceSumWeight);
			}
			
			// TODO
			var alignOnOversize = layout.alignChildsOnOversizeX;
			if (innerHOversizeVar != null && alignOnOversize == Align.AUTO) {
				alignOnOversize = (autospace != AUTOSPACE_NONE) ? autospace : getAutospaceAlign(childs[0].hSize, childs[childs.length - 1].hSize);
			}
				
			if (isFirst && isLast) {
				ConstraintSet.toOuterLeftRight( solver,
					child, child, _x, _width,
					innerHSpanVar, innerHOversizeVar, _xScroll,
					alignOnOversize, autospace
				);
				
			}
			else if (isFirst) {
				childs[atIndex + 1].constraintSet.removeToLeft(solver);
				childs[atIndex + 1].constraintSet.toLeft(solver, childs[atIndex + 1]._left, child._right );
				
				ConstraintSet.toOuterLeft( solver,
					child, _x,
					innerHSpanVar, innerHOversizeVar, _xScroll,
					alignOnOversize, autospace
				);
				
			} 
			else if (isLast) {
				childs[atIndex - 1].constraintSet.removeToRight(solver);
				child.constraintSet.toLeft(solver, child._left, childs[atIndex - 1]._right );
				
				ConstraintSet.toOuterRight( solver,
					child, _x, _width,
					innerHSpanVar, innerHOversizeVar, _xScroll,
					alignOnOversize, autospace
				);
			
			} 
			else {
				childs[atIndex + 1].constraintSet.removeToLeft(solver);
				childs[atIndex + 1].constraintSet.toLeft(solver, childs[atIndex + 1]._left, child._right );
				child.constraintSet.toLeft(solver, child._left, childs[atIndex - 1]._right );
			}
			
		}
		else { // BOX
			
			// LATER
			
		}
		
		// ------------------------- addChild vertical -----------------------------
		
		if (containerType == ContainerType.VBOX) {
			
			// LATER

		}
		else {
			
			// TODO
			
			if (child.outerVLimitVar != null) child.constraintSet.outerVLimit(solver, child.outerVLimitVar);
			
			var autospace = getAutospaceBox(vSize, child.vSize);
			var alignOnOversize = layout.alignChildsOnOversizeY;
			
			if (child.outerVOversizeVar != null) {
				child.constraintSet.outerVOversize(solver, child.outerVOversizeVar, child.outerVOversizeWeight);
				alignOnOversize = (autospace != AUTOSPACE_NONE) ? autospace : getAutospaceAlign(child.vSize, child.vSize);
			}
			
			if (child.outerVSpanVar != null) {
				child.constraintSet.outerVSpan(solver, child.outerVSpanVar, _height, child.vSize.getLimitMax(), (autospace == AUTOSPACE_NONE) ? child.vSize.getSpanSumWeight() : ((autospace == AUTOSPACE_BOTH) ? 2 : 1));
			}
			
			ConstraintSet.toOuterTopBottom( solver,
				child, child, _y, _height,
				child.outerVSpanVar, (innerVOversizeVar != null) ? innerVOversizeVar : child.outerVOversizeVar, _yScroll,
				alignOnOversize, autospace
			);
			
			
		}
		
		
		
	}
	
	public function removeChild(child:LayoutContainer) {
		
	}
	
	
	// ---------------------------------------------------------------
	// --------------- init Solver -----------------------------------
	// ---------------------------------------------------------------
	var root_width:Variable;
	var root_height:Variable;
	
	static var strengthEditVar = Strength.STRONG;
		
	// TODO: init automatically if not already
	public function init()
	{
		solver = new Solver();
		
		root_width = new Variable();
		root_height = new Variable();
				
		solver.addEditVariable(root_width, strengthEditVar);
		solver.addEditVariable(root_height, strengthEditVar);
		
		solver.addConstraint( (root_width >= hSize.getLimitMin()) | Strength.REQUIRED );
		solver.addConstraint( (root_height >= vSize.getLimitMin()) | Strength.REQUIRED );
					
		//addTreeConstraints(solver, 0); // <- recursive Container
		
		// --------------------------- root-container horizontal -----------------------------		
		var rootWidthExpr = new Expression([new Term(root_width)]);
		var rootHeightExpr = new Expression([new Term(root_height)]);
		var zeroExpr = new Expression([], 0);
		
		outerHLimitVar = hSize.setSizeLimit(null);
		if (outerHLimitVar != null) constraintSet.outerHLimit(solver, outerHLimitVar);
		
		var autospace = (hSize.hasSpan()) ? AUTOSPACE_NONE : getAutospaceAlign(hSize, hSize);
		
		outerHSpanVar = (autospace == AUTOSPACE_NONE) ? hSize.setSizeSpan(null) : new Variable();
		if (outerHSpanVar != null) {
			constraintSet.outerHSpan(solver, outerHSpanVar, rootWidthExpr, hSize.getLimitMax(), (autospace == AUTOSPACE_NONE) ? hSize.getSpanSumWeight() : ((autospace == AUTOSPACE_BOTH) ? 2 : 1) );			
		}
		// left
		if (autospace & AUTOSPACE_FIRST == 0) constraintSet.toLeft(solver, _left, zeroExpr);
		else constraintSet.toLeft(solver, _left, new Expression([new Term(outerHSpanVar)]) );
		// right
		if (autospace & AUTOSPACE_LAST == 0) constraintSet.toRight(solver, _right, rootWidthExpr);
		else constraintSet.toRight(solver, _right, rootWidthExpr - outerHSpanVar );

		// ---------------------------- root-container vertical ------------------------------
		
		outerVLimitVar = vSize.setSizeLimit(null);
		if (outerVLimitVar != null) constraintSet.outerVLimit(solver, outerVLimitVar);
		
		autospace = (vSize.hasSpan()) ? AUTOSPACE_NONE : getAutospaceAlign(vSize, vSize);

		outerVSpanVar = (autospace == AUTOSPACE_NONE) ? vSize.setSizeSpan(null) : new Variable();
		if (outerVSpanVar != null) {
			constraintSet.outerVSpan(solver, outerVSpanVar, rootHeightExpr, vSize.getLimitMax(), (autospace == AUTOSPACE_NONE) ? vSize.getSpanSumWeight() : ((autospace == AUTOSPACE_BOTH) ? 2 : 1));
		}
		// top
		if (autospace & AUTOSPACE_FIRST == 0) constraintSet.toTop(solver, _top, zeroExpr);
		else constraintSet.toTop(solver, _top, new Expression([new Term(outerHSpanVar)]) );
		// bottom
		if (autospace & AUTOSPACE_LAST == 0) constraintSet.toBottom(solver, _bottom, rootHeightExpr );
		else constraintSet.toBottom(solver, _bottom, rootHeightExpr - outerVSpanVar );
		
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
			if (innerHOversizeVar != null) {
				constraintSet.innerHOversize(solver, innerHOversizeVar, innerHOversizeWeight);
			}			
			
			// vertical oversize-align for BOX (if not autoalign) or VBOX
			if (innerVOversizeVar != null) {
				constraintSet.innerVOversize(solver, innerVOversizeVar, innerVOversizeWeight);
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
					if (i>0) child.constraintSet.toLeft(solver, child._left, childs[i-1]._right );
				}
				else                                     // -------- BOX ---------
				{
					if (child.outerHLimitVar != null) child.constraintSet.outerHLimit(solver, child.outerHLimitVar);
					
					autospace = getAutospaceBox(hSize, child.hSize);					
					alignOnOversize = layout.alignChildsOnOversizeX;
					
					if (child.outerHOversizeVar != null) {
						child.constraintSet.outerHOversize(solver, child.outerHOversizeVar, child.outerHOversizeWeight);
						alignOnOversize = (autospace != AUTOSPACE_NONE) ? autospace : getAutospaceAlign(child.hSize, child.hSize);
					}
					
					if (child.outerHSpanVar != null) {
						child.constraintSet.outerHSpan(solver, child.outerHSpanVar, _width, child.hSize.getLimitMax(), (autospace == AUTOSPACE_NONE) ? child.hSize.getSpanSumWeight() : ((autospace == AUTOSPACE_BOTH) ? 2 : 1));
					}
					
					ConstraintSet.toOuterLeftRight( solver,
						child, child, _x, _width,
						child.outerHSpanVar, (innerHOversizeVar != null) ? innerHOversizeVar : child.outerHOversizeVar, _xScroll,
						alignOnOversize, autospace
					);
				}
						
				// ----------------------------------------------------------------
				// ------------------------- vertical -----------------------------
				// ----------------------------------------------------------------
				
				if (containerType == ContainerType.VBOX) // -------- VBOX --------
				{
					if (i > 0) child.constraintSet.toTop(solver, child._top, childs[i-1]._bottom );
				}
				else                                     // -------- BOX ---------
				{
					if (child.outerVLimitVar != null) child.constraintSet.outerVLimit(solver, child.outerVLimitVar);
					
					autospace = getAutospaceBox(vSize, child.vSize);
					alignOnOversize = layout.alignChildsOnOversizeY;
					
					if (child.outerVOversizeVar != null) {
						child.constraintSet.outerVOversize(solver, child.outerVOversizeVar, child.outerVOversizeWeight);
						alignOnOversize = (autospace != AUTOSPACE_NONE) ? autospace : getAutospaceAlign(child.vSize, child.vSize);
					}
					
					if (child.outerVSpanVar != null) {
						child.constraintSet.outerVSpan(solver, child.outerVSpanVar, _height, child.vSize.getLimitMax(), (autospace == AUTOSPACE_NONE) ? child.vSize.getSpanSumWeight() : ((autospace == AUTOSPACE_BOTH) ? 2 : 1));
					}
					
					ConstraintSet.toOuterTopBottom( solver,
						child, child, _y, _height,
						child.outerVSpanVar, (innerVOversizeVar != null) ? innerVOversizeVar : child.outerVOversizeVar, _yScroll,
						alignOnOversize, autospace
					);
				}
				
			}			
			
			// ----------------------------------------------------------------
			// ------- limitVar and sumWeight of childs for ROW or COL --------
			// ----------------------------------------------------------------
			if (containerType != ContainerType.BOX && childs.length > 0)
			{
				var autospaceSumWeight:Int = 0;
				
				if (containerType == ContainerType.HBOX)
				{
					if (innerHLimitVar != null) constraintSet.innerLimit(solver, innerHLimitVar);
				
					autospace = getAutospaceRowCol(childsNumHSpan, hSize, childsSumHMax, childs[0].hSize, childs[childs.length - 1].hSize);
					if (autospace != AUTOSPACE_NONE) {
						autospaceSumWeight = (autospace == AUTOSPACE_BOTH) ? 2 : 1;
						if (innerHSpanVar == null) innerHSpanVar = new Variable();
					}
					
					alignOnOversize = layout.alignChildsOnOversizeX;
					if (innerHOversizeVar != null && alignOnOversize == Align.AUTO) {
						alignOnOversize = (autospace != AUTOSPACE_NONE) ? autospace : getAutospaceAlign(childs[0].hSize, childs[childs.length - 1].hSize);
					}
					
					if (innerHSpanVar != null) {
						constraintSet.innerSpan(solver, innerHSpanVar, _width, childsSumHMax, childsSumHWeight + autospaceSumWeight);
					}
					
					ConstraintSet.toOuterLeftRight( solver,
						childs[0], childs[childs.length-1], _x, _width,
						innerHSpanVar, innerHOversizeVar, _xScroll,
						alignOnOversize, autospace
					);
				}
				else // --------- Container.VBOX --------
				{					
					if (innerVLimitVar != null)	constraintSet.innerLimit(solver, innerVLimitVar );
				
					autospace = getAutospaceRowCol(childsNumVSpan, vSize, childsSumVMax, childs[0].vSize, childs[childs.length - 1].vSize);
					if (autospace != AUTOSPACE_NONE) {
						autospaceSumWeight = (autospace == AUTOSPACE_BOTH) ? 2 : 1;
						if (innerVSpanVar == null) innerVSpanVar = new Variable();
					}
					
					alignOnOversize = layout.alignChildsOnOversizeY;
					if (innerVOversizeVar!= null && alignOnOversize == Align.AUTO) {
						alignOnOversize = (autospace != AUTOSPACE_NONE) ? autospace : getAutospaceAlign(childs[0].vSize, childs[childs.length - 1].vSize);
					}
					
					if (innerVSpanVar != null) {
						constraintSet.innerSpan(solver, innerVSpanVar, _height, childsSumVMax, childsSumVWeight + autospaceSumWeight);
					}
			
					ConstraintSet.toOuterTopBottom( solver,
						childs[0], childs[childs.length-1], _y, _height,
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

