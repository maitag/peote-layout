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
		
		solver.addConstraint( (root_width >= innerLimit.width) | strengthHigh );
		solver.addConstraint( (root_height >= innerLimit.height) | strengthHigh );
		
		// --------------------------------- horizontal ---------------------------------------				
		fixLimit(hSize, innerLimit.width);
		fixSpacer(null, hSize);
		
		var hSizeLimitVar = hSize.setSizeLimit(null);
		if (hSizeLimitVar != null) {
			solver.addConstraint( (hSizeLimitVar >= 0) | strength );
		}
		var hSizeSpanVar = hSize.setSizeSpan(null);
		if (hSizeSpanVar != null) {
			solver.addConstraint( (hSizeSpanVar >= 0) | strengthHigh );
			solver.addConstraint( (hSizeSpanVar == (root_width - hSize.getLimitMax()) / hSize.getSumWeight() ) | strengthLow );
		}
		solver.addConstraint( (_width == hSize.middle.size) | strength );
		
		solver.addConstraint( (_left == 0) | strength );
		solver.addConstraint( (_right == root_width) | strength );
				
		// --------------------------------- vertical ---------------------------------------
		fixLimit(vSize, innerLimit.height);
		fixSpacer(null, vSize);
				
		var vSizeLimitVar = vSize.setSizeLimit(null);
		if (vSizeLimitVar != null) {
			solver.addConstraint( (vSizeLimitVar >= 0) | strength );
		}
		var vSizeSpanVar = vSize.setSizeSpan(null);
		if (vSizeSpanVar != null) {
			solver.addConstraint( (vSizeSpanVar >= 0) | strengthHigh );
			solver.addConstraint( (vSizeSpanVar == (root_height - vSize.getLimitMax()) / vSize.getSumWeight() ) | strengthLow );
		}
		solver.addConstraint( (_height == vSize.middle.size) | strength );
		
		solver.addConstraint( (_top == 0) | strength );
		solver.addConstraint( (_bottom == root_height) | strength );				
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

	// ---------------------------------------------------	
	inline function fixHMaxSpan():Int {
		var hLimitMax:Int = 0;
		var noChildHasSpan = true; // TODO: better storing the number of childs that have a span!
		for (child in childs) {
			if (noChildHasSpan && child.hSize.hasSpan()) noChildHasSpan = false;
			hLimitMax += child.hSize.getLimitMax();
		}
		if (noChildHasSpan && childs.length > 0) {
			if ( hSize.middle._span || hLimitMax < ( (hSize.middle._max != null) ? hSize.middle._max : hSize.middle._min) )
			{
				// TODO: store into a flag to reset later if childs was changed here 
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
	
	inline function fixVMaxSpan():Int {
		var vLimitMax:Int = 0;
		var noChildHasSpan = true;
		for (child in childs) {
			if (noChildHasSpan && child.vSize.hasSpan()) noChildHasSpan = false;
			vLimitMax += child.vSize.getLimitMax();
		}		
		if (noChildHasSpan && childs.length > 0) {
			if ( vSize.middle._span || vLimitMax < ( (vSize.middle._max != null) ? vSize.middle._max : vSize.middle._min) )
			{
				if (childs[0].vSize.first != null && childs[childs.length-1].vSize.last != null) {
					childs[0].vSize.first._span = true;
					childs[childs.length-1].vSize.last._span = true;
				}
				else {
					if (childs[0].vSize.first == null) childs[0].vSize.first = Size.min();
					if (childs[childs.length-1].vSize.last == null) childs[childs.length-1].vSize.last = Size.min();
				}
			}
		}
		return vLimitMax;
	}
	// -----------------------------------------------------------------------------------------------------
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
		
	function addTreeConstraints(solver:Solver):InnerLimit
	{
		this.solver = solver;
		
		var childsLimit = {width:0, height:0};
		if (childs != null)
		{
			var sizeLimitVar:Null<Variable> = null;
			var sizeSpanVar:Null<Variable> = null;			
			var sumWeight:Float = 0.0;			
			var limitMax:Int = 0;
			
			if (containerType == ContainerType.HBOX) limitMax = fixHMaxSpan();
			else if (containerType  == ContainerType.VBOX) limitMax = fixVMaxSpan();
			
			
			for (i in 0...childs.length)
			{	
				var child = childs[i];
				
				var innerLimit = child.addTreeConstraints(solver); // recursive childs
				
				// ------------------------------------------------------
				// ------------------- horizontal -----------------------
				// ------------------------------------------------------
				fixLimit(child.hSize, innerLimit.width);

				if (containerType  == ContainerType.HBOX) // -------- HBOX --------
				{
					childsLimit.width += child.hSize.getMin();
					
					sizeLimitVar = child.hSize.setSizeLimit(sizeLimitVar);
					sizeSpanVar = child.hSize.setSizeSpan(sizeSpanVar);
					sumWeight += child.hSize.getSumWeight();
										
					if (i == 0) child.setConstraintLeft( (child._left == _x) | strength );
					else child.setConstraintLeft( (child._left == childs[i-1]._right) | strength );
					if (i == childs.length - 1) child.setConstraintRight( (child._right == _x + _width) | strength );
				}
				else                                     // -------- BOX ---------
				{
					fixSpacer(hSize, child.hSize);
					
					if (child.hSize.getMin() > childsLimit.width) childsLimit.width = child.hSize.getMin();
					
					var hSizeLimitVar = child.hSize.setSizeLimit(null);
					var hSizeSpanVar = child.hSize.setSizeSpan(null);
					
					if (hSizeLimitVar != null) child.setConstraintHLimit( (hSizeLimitVar >= 0) | strength );
					if (hSizeSpanVar != null) child.setConstraintHSpan( (hSizeSpanVar >= 0) | strengthHigh , (hSizeSpanVar == (_width - child.hSize.getLimitMax()) / child.hSize.getSumWeight() ) | strengthLow );
								
					child.setConstraintLeft( (child._left == _x) | strength );
					child.setConstraintRight( (child._right == _x + _width) | strength );
				}
				
				child.setConstraintWidth( (child._width == child.hSize.middle.size) | strength );
					
								
				// ------------------------------------------------------
				// ------------------- vertical -------------------------
				// ------------------------------------------------------
				fixLimit(child.vSize, innerLimit.height);
					
				if (containerType == ContainerType.VBOX) // -------- VBOX --------
				{
					childsLimit.height += child.vSize.getMin();
					
					sizeLimitVar = child.vSize.setSizeLimit(sizeLimitVar);
					sizeSpanVar = child.vSize.setSizeSpan(sizeSpanVar);
					sumWeight += child.vSize.getSumWeight();
					
					if (i == 0) child.setConstraintTop( (child._top == _y) | strength );
					else child.setConstraintTop( (child._top == childs[i-1]._bottom) | strength );
					if (i == childs.length - 1) child.setConstraintBottom( (child._bottom == _y + _height) | strength );
				}
				else                                    // -------- BOX ---------
				{
					fixSpacer(vSize, child.vSize);
					
					if (child.vSize.getMin() > childsLimit.height) childsLimit.height = child.vSize.getMin();
					
					var vSizeLimitVar = child.vSize.setSizeLimit(null);
					if (vSizeLimitVar != null) child.setConstraintVLimit( (vSizeLimitVar >= 0) | strength );
					
					var vSizeSpanVar = child.vSize.setSizeSpan(null);trace("B",child.vSize.getLimitMax(), child.vSize.getSumWeight());
					if (vSizeSpanVar != null) child.setConstraintVSpan( (vSizeSpanVar >= 0) | strengthHigh, (vSizeSpanVar == (_height - child.vSize.getLimitMax()) / child.vSize.getSumWeight() ) | strengthLow );
					
					child.setConstraintTop( (child._top == _y) | strength );
					child.setConstraintBottom( (child._bottom == _y + _height) | strength );
				}
				
				child.setConstraintHeight( (child._height == child.vSize.middle.size) | strength );

			}			
			
			
			// ----------------------------------------------------------------
			// ------- limitVar and sumWeight of childs for ROW or COL --------
			// ----------------------------------------------------------------
			if (containerType != ContainerType.BOX)
			{
				if (sizeLimitVar != null) {
					setConstraintRowColLimit( (sizeLimitVar >= 0) | strength );
				}
				
				if (sizeSpanVar != null) 
				{
					if (containerType  == ContainerType.HBOX) {
						setConstraintRowColSpan( (sizeSpanVar >= 0) | strength, (sizeSpanVar == (_width - limitMax) / sumWeight ) | strengthLow );
					}
					else { trace("V",limitMax, sumWeight);
						setConstraintRowColSpan( (sizeSpanVar >= 0) | strength, (sizeSpanVar == (_height - limitMax) / sumWeight ) | strengthLow );
					}
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

