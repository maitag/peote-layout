package peote.layout;

import jasper.Variable;
import jasper.Expression;
import jasper.Term;
import jasper.Strength;
import jasper.Constraint;
import jasper.Solver;
import peote.layout.Align;
import peote.layout.Scroll;

import peote.layout.util.SizeSpaced;

typedef InnerLimit = { width:Int, height:Int }


class LayoutContainer
{
	public var container:Container;
	public var scroll:Scroll;
	public var align:Align;
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

	// TODO: for inner size:
	// scrollWidth, scrollHeight
	
	// ---------- Variables for Jasper Constraints ------
	public var xScroll(default,null):Variable;
	public var yScroll(default,null):Variable;

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
	static var strength = Strength.create(0, 900, 0);
	static var strengthLow = Strength.create(0, 0, 900);
	
	// ----------------------------------------------------------------------------------------
	// storing constraints
	public var customConstraints:Array<Constraint>;
	
	
	// ----------------------------------------------------------------------------------------
	// --------------------------------- NEW --------------------------------------------------
	// ----------------------------------------------------------------------------------------
	public function new(container:Container = Container.BOX, layoutElement:LayoutElement = null,
		innerScroll:Scroll = Scroll.NONE, innerAlign:Align = Align.TOP_LEFT,
		layout:Layout = null, childs:Array<LayoutContainer> = null) 
	{
		set_containerType(container);
		set_scroll(innerScroll);
		set_align(innerAlign);
		set_layoutElement(layoutElement);
		set_layout(layout);
		set_childs(childs);
		
		if (scroll == Scroll.HORIZONTAL) xScroll = new Variable();
		if (scroll == Scroll.VERTICAL) yScroll = new Variable();
		
		_x = new Variable();
		_y = new Variable();
		_width = new Variable();
		_height = new Variable();
		
		_centerX = new Term(_x) + (_width / 2.0);
		_centerY = new Term(_y) + (_height / 2.0);
	}
	
	function set_containerType(container:Container) {
		this.container = container;
		// TODO: update
	}
	
	function set_scroll(scroll:Scroll) {
		this.scroll = scroll;
		// TODO: update
	}
	
	function set_align(align:Align) {
		this.align = align;
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
	
	public function update(width:Float, height:Float)
	{
		if (solver != null) {
			solver.suggestValue(root_width, width);
			solver.suggestValue(root_height, height);
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
		//if (childSize.hasSpan()) return AUTOSPACE_NONE; // TODO: numSpan
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
			
			for (i in 0...childs.length)
			{	
				var child = childs[i];
				
				var innerLimit = child.addTreeConstraints(solver); // recursive childs
				
				// ------------------------------------------------------
				// ------------------- horizontal -----------------------
				// ------------------------------------------------------
				if (!Scroll.hasHorizontal(child.scroll)) fixLimit(child.hSize, innerLimit.width);

				if (container == Container.HBOX) // -------- HBOX --------
				{
					childsLimit.width += child.hSize.getMin();
					
					if (child.hSize.hasSpan()) childsNumSpan++;
					limitMax += child.hSize.getLimitMax();
						
					sizeLimitVar = child.hSize.setSizeLimit(sizeLimitVar);
					sizeSpanVar = child.hSize.setSizeSpan(sizeSpanVar);
					sumWeight += child.hSize.getSpanSumWeight();
										
					if (i>0) child.setConstraintLeft( (child._left == childs[i-1]._right) | strength );
				}
				else                             // -------- BOX ---------
				{
					if (child.hSize.getMin() > childsLimit.width) childsLimit.width = child.hSize.getMin();
					
					var hSizeLimitVar = child.hSize.setSizeLimit(null); 
					if (hSizeLimitVar != null) child.setConstraintHLimit( (hSizeLimitVar >= 0) | strength );
					
					autospace = getAutospaceBox(hSize, child.hSize);
					
					var hSizeSpanVar = (autospace == AUTOSPACE_NONE) ? child.hSize.setSizeSpan(null) : new Variable();
					if (hSizeSpanVar != null) {
						var _sumWeight = (autospace == AUTOSPACE_NONE) ? child.hSize.getSpanSumWeight() : ((autospace == AUTOSPACE_BOTH) ? 2 : 1);
						child.setConstraintHSpan( (hSizeSpanVar >= 0) | strengthHigh, // check nested boxes+rows here
							(hSizeSpanVar == (_width - child.hSize.getLimitMax()) / _sumWeight) | strengthLow );
					}
								
					// TODO: change connections here in depend of yscroll, innerAlign and innerScroll					
					if (autospace & AUTOSPACE_FIRST == 0) child.setConstraintLeft( (child._left == _x) | strength );
					else child.setConstraintLeft( (child._left - hSizeSpanVar == _x) | strength );
					if (autospace & AUTOSPACE_LAST == 0) child.setConstraintRight( (child._right == _x + _width) | strength );
					else child.setConstraintRight( (child._right + hSizeSpanVar == _x + _width) | strength );
				}
				
				child.setConstraintWidth( (child._width == child.hSize.middle.size) | strength );
												
				// ------------------------------------------------------
				// ------------------- vertical -------------------------
				// ------------------------------------------------------
				if (!Scroll.hasVertical(child.scroll)) fixLimit(child.vSize, innerLimit.height);
					
				if (container == Container.VBOX) // -------- VBOX --------
				{
					childsLimit.height += child.vSize.getMin();
					
					if (child.vSize.hasSpan()) childsNumSpan++;
					limitMax += child.vSize.getLimitMax();
										
					sizeLimitVar = child.vSize.setSizeLimit(sizeLimitVar);
					sizeSpanVar = child.vSize.setSizeSpan(sizeSpanVar);
					sumWeight += child.vSize.getSpanSumWeight();
					
					if (i > 0) child.setConstraintTop( (child._top == childs[i-1]._bottom) | strength );
				}
				else                             // -------- BOX ---------
				{
					if (child.vSize.getMin() > childsLimit.height) childsLimit.height = child.vSize.getMin();
					
					var vSizeLimitVar = child.vSize.setSizeLimit(null);
					if (vSizeLimitVar != null) child.setConstraintVLimit( (vSizeLimitVar >= 0) | strength );
					
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
			if (container != Container.BOX && childs.length > 0)
			{
				if (sizeLimitVar != null) {
					setConstraintRowColLimit( (sizeLimitVar >= 0) | strength );
				}
				
				if (container == Container.HBOX)
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
	public inline function new(layoutElement:LayoutElement = null, innerScroll:Scroll = Scroll.NONE, innerAlign:Align = Align.TOP_LEFT, layout:Layout = null, innerLayoutContainer:Array<LayoutContainer> = null) 
	{
		this = new LayoutContainer(Container.BOX, layoutElement, innerScroll, innerAlign, layout, innerLayoutContainer);
	}
}

@:forward
abstract HBox(LayoutContainer) from LayoutContainer to LayoutContainer {
	public inline function new(layoutElement:LayoutElement = null, innerScroll:Scroll = Scroll.NONE, innerAlign:Align = Align.TOP_LEFT, layout:Layout = null, innerLayoutContainer:Array<LayoutContainer> = null) 
	{
		this = new LayoutContainer(Container.HBOX, layoutElement, innerScroll, innerAlign, layout, innerLayoutContainer);
	}
}

@:forward
abstract VBox(LayoutContainer) from LayoutContainer to LayoutContainer {
	public inline function new(layoutElement:LayoutElement = null, innerScroll:Scroll = Scroll.NONE, innerAlign:Align = Align.TOP_LEFT, layout:Layout = null, innerLayoutContainer:Array<LayoutContainer> = null) 
	{
		this = new LayoutContainer(Container.VBOX, layoutElement, innerScroll, innerAlign, layout, innerLayoutContainer);
	}
}

