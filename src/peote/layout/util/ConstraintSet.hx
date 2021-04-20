package peote.layout.util;
import jasper.Constraint;
import jasper.Expression;
import jasper.Solver;
import jasper.Variable;
import jasper.Strength;
import peote.layout.LayoutContainer;

class ConstraintSet 
{
	static inline var strengthHigh = Strength.REQUIRED;	// STRONG TODO: check speed on oversize .. see below
	static inline var strengthNeighbor = Strength.REQUIRED;	// STRONG -> needs double time to init
	static inline var strengthSpan = Strength.WEAK;


	public static var solver:Solver; // TODO

	
	public function new()
	{
	}
	
	public static function toOuterLeftRight(
			leftChild:LayoutContainer, rightChild:LayoutContainer, parentPos:Variable, parentSize:Expression,
			isOversize = true, isScroll = false,
			spanVar:Variable, oversizeVar:Variable, scrollVar:Variable,
			align:Int, autospace:Int
			) {
		toOuter(
			leftChild.constraintSet.left, rightChild.constraintSet.right, 
			leftChild._left, rightChild._right, parentPos, parentSize,
			isOversize, isScroll,
			spanVar, oversizeVar, scrollVar,
			align, autospace);		
	}
	
	public static function toOuterLeft(
			child:LayoutContainer, parentPos:Variable,
			isOversize = true, isScroll = false,
			spanVar:Variable, oversizeVar:Variable, scrollVar:Variable,
			align:Int, autospace:Int
			) {
		toOuterFirst(
			child.constraintSet.left,
			child._left, parentPos,
			isOversize, isScroll,
			spanVar, oversizeVar, scrollVar,
			align, autospace);		
	}
	
	public static function toOuterRight(
			child:LayoutContainer, parentPos:Variable, parentSize:Expression,
			isOversize = true, isScroll = false,
			spanVar:Variable, oversizeVar:Variable, scrollVar:Variable,
			align:Int, autospace:Int
			) {
		toOuterLast(
			child.constraintSet.right, 
			child._right, parentPos, parentSize,
			isOversize, isScroll,
			spanVar, oversizeVar, scrollVar,
			align, autospace);		
	}
	
	public static function toOuterTopBottom(
			topChild:LayoutContainer, bottomChild:LayoutContainer, parentPos:Variable, parentSize:Expression,
			isOversize = true, isScroll = false,
			spanVar:Variable, oversizeVar:Variable, scrollVar:Variable,
			align:Int, autospace:Int
			) {
		toOuter(
			topChild.constraintSet.top, bottomChild.constraintSet.bottom, 
			topChild._top, bottomChild._bottom, parentPos, parentSize,
			isOversize, isScroll,
			spanVar, oversizeVar, scrollVar,
			align, autospace);		
	}	
	
	public static function toOuterTop(
			child:LayoutContainer, parentPos:Variable,
			isOversize = true, isScroll = false,
			spanVar:Variable, oversizeVar:Variable, scrollVar:Variable,
			align:Int, autospace:Int
			) {
		toOuterFirst(
			child.constraintSet.top,
			child._top, parentPos,
			isOversize, isScroll,
			spanVar, oversizeVar, scrollVar,
			align, autospace);		
	}	
	
	public static function toOuterBottom(
			child:LayoutContainer, parentPos:Variable, parentSize:Expression,
			isOversize = true, isScroll = false,
			spanVar:Variable, oversizeVar:Variable, scrollVar:Variable,
			align:Int, autospace:Int
			) {
		toOuterLast(
			child.constraintSet.bottom, 
			child._bottom, parentPos, parentSize,
			isOversize, isScroll,
			spanVar, oversizeVar, scrollVar,
			align, autospace);		
	}	
	
	// TODO: refactor -> separate out the inners into 8 inline functions!
	static function toOuter(
			setConstraintFirstFunction:Constraint->Void, setConstraintLastFunction:Constraint->Void, 
			firstExpr:Expression, lastExpr:Expression, parentPos:Variable, parentSize:Expression,
			isOversize = true, isScroll = false,
			spanVar:Variable, oversizeVar:Variable, scrollVar:Variable,
			align:Int, autospace:Int
			) {
				
		if (!isOversize) {
			// firstExpr
			if (autospace & LayoutContainer.AUTOSPACE_FIRST == 0) {
				if (isScroll) setConstraintFirstFunction( (firstExpr + scrollVar == parentPos) | strengthNeighbor );
				else setConstraintFirstFunction( (firstExpr == parentPos) | strengthNeighbor );
			}
			else {
				if (isScroll) setConstraintFirstFunction( (firstExpr + scrollVar == parentPos + spanVar) | strengthNeighbor );
				else setConstraintFirstFunction( (firstExpr == parentPos + spanVar) | strengthNeighbor );
			}
			// lastExpr
			if (autospace & LayoutContainer.AUTOSPACE_LAST == 0) {
				if (isScroll) setConstraintLastFunction( (lastExpr + scrollVar == parentPos + parentSize) | strengthNeighbor );
				else setConstraintLastFunction( (lastExpr == parentPos + parentSize) | strengthNeighbor );
			}
			else {
				if (isScroll) setConstraintLastFunction( (lastExpr + scrollVar == parentPos + parentSize - spanVar) | strengthNeighbor );
				else setConstraintLastFunction( (lastExpr == parentPos + parentSize - spanVar) | strengthNeighbor );
			}
		}
		else // ---------------- oversize ---------------------
		{
			if (align == Align.AUTO) {
				// do same as for auto spacing
				if (autospace == LayoutContainer.AUTOSPACE_FIRST) align = Align.LAST;
				else if (autospace == LayoutContainer.AUTOSPACE_LAST) align = Align.FIRST;
				else align = Align.CENTER;
			}
			
			if (align == Align.FIRST)        //  ----- oversize align left ----
			{	// firstExpr
				if (autospace & LayoutContainer.AUTOSPACE_FIRST == 0) {
					if (isScroll) setConstraintFirstFunction( (firstExpr + scrollVar == parentPos) | strengthNeighbor );
					else setConstraintFirstFunction( (firstExpr == parentPos) | strengthNeighbor );
				}
				else {
					if (isScroll) setConstraintFirstFunction( (firstExpr + scrollVar == parentPos + spanVar) | strengthNeighbor );
					else setConstraintFirstFunction( (firstExpr == parentPos + spanVar) | strengthNeighbor );
				}
				// lastExpr
				if (autospace & LayoutContainer.AUTOSPACE_LAST == 0) {
					if (isScroll) setConstraintLastFunction( (lastExpr - oversizeVar + scrollVar == parentPos + parentSize) | strengthNeighbor );
					else setConstraintLastFunction( (lastExpr - oversizeVar == parentPos + parentSize) | strengthNeighbor );
				}
				else {
					if (isScroll) setConstraintLastFunction( (lastExpr - oversizeVar + scrollVar == parentPos + parentSize - spanVar) | strengthNeighbor );
					else setConstraintLastFunction( (lastExpr - oversizeVar == parentPos + parentSize - spanVar) | strengthNeighbor );
				}
			}
			else if (align == Align.LAST)   //  ----- oversize align right ----
			{	// firstExpr
				if (autospace & LayoutContainer.AUTOSPACE_FIRST == 0) {
					if (isScroll) setConstraintFirstFunction( (firstExpr + oversizeVar + scrollVar == parentPos) | strengthNeighbor );
					else setConstraintFirstFunction( (firstExpr + oversizeVar == parentPos) | strengthNeighbor );
				}
				else {
					if (isScroll) setConstraintFirstFunction( (firstExpr + oversizeVar + scrollVar == parentPos + spanVar) | strengthNeighbor );
					else setConstraintFirstFunction( (firstExpr + oversizeVar == parentPos + spanVar) | strengthNeighbor );
				}
				// lastExpr
				if (autospace & LayoutContainer.AUTOSPACE_LAST == 0) {
					if (isScroll) setConstraintLastFunction( (lastExpr + scrollVar == parentPos + parentSize) | strengthNeighbor );
					else setConstraintLastFunction( (lastExpr == parentPos + parentSize) | strengthNeighbor );
				}
				else {
					if (isScroll) setConstraintLastFunction( (lastExpr + scrollVar == parentPos + parentSize - spanVar) | strengthNeighbor );
					else setConstraintLastFunction( (lastExpr == parentPos + parentSize - spanVar) | strengthNeighbor );
				}
			}
			else                             //  ---- oversize align centered ---
			{	// firstExpr
				if (autospace & LayoutContainer.AUTOSPACE_FIRST == 0) {
					if (isScroll) setConstraintFirstFunction( (firstExpr + oversizeVar/2 + scrollVar == parentPos) | strengthNeighbor );
					else setConstraintFirstFunction( (firstExpr + oversizeVar/2 == parentPos) | strengthNeighbor );
				}
				else {
					if (isScroll) setConstraintFirstFunction( (firstExpr + oversizeVar/2 + scrollVar == parentPos + spanVar) | strengthNeighbor );
					else setConstraintFirstFunction( (firstExpr + oversizeVar/2 == parentPos + spanVar) | strengthNeighbor );
				}
				// lastExpr
				if (autospace & LayoutContainer.AUTOSPACE_LAST == 0) {
					if (isScroll) setConstraintLastFunction( (lastExpr - oversizeVar/2 + scrollVar == parentPos + parentSize) | strengthNeighbor );
					else setConstraintLastFunction( (lastExpr - oversizeVar/2 == parentPos + parentSize) | strengthNeighbor );
				}
				else {
					if (isScroll) setConstraintLastFunction( (lastExpr - oversizeVar/2 + scrollVar == parentPos + parentSize - spanVar) | strengthNeighbor );
					else setConstraintLastFunction( (lastExpr - oversizeVar/2 == parentPos + parentSize - spanVar) | strengthNeighbor );
				}
			}
		}
		
	}
	
	// TODO: refactor
	static function toOuterFirst(
			setConstraintFirstFunction:Constraint->Void, 
			firstExpr:Expression, parentPos:Variable,
			isOversize = true, isScroll = false,
			spanVar:Variable, oversizeVar:Variable, scrollVar:Variable,
			align:Int, autospace:Int
			) {
				
		if (!isOversize) {
			// firstExpr
			if (autospace & LayoutContainer.AUTOSPACE_FIRST == 0) {
				if (isScroll) setConstraintFirstFunction( (firstExpr + scrollVar == parentPos) | strengthNeighbor );
				else setConstraintFirstFunction( (firstExpr == parentPos) | strengthNeighbor );
			}
			else {
				if (isScroll) setConstraintFirstFunction( (firstExpr + scrollVar == parentPos + spanVar) | strengthNeighbor );
				else setConstraintFirstFunction( (firstExpr == parentPos + spanVar) | strengthNeighbor );
			}
		}
		else // ---------------- oversize ---------------------
		{
			if (align == Align.AUTO) {
				// do same as for auto spacing
				if (autospace == LayoutContainer.AUTOSPACE_FIRST) align = Align.LAST;
				else if (autospace == LayoutContainer.AUTOSPACE_LAST) align = Align.FIRST;
				else align = Align.CENTER;
			}
			
			if (align == Align.FIRST)        //  ----- oversize align left ----
			{	// firstExpr
				if (autospace & LayoutContainer.AUTOSPACE_FIRST == 0) {
					if (isScroll) setConstraintFirstFunction( (firstExpr + scrollVar == parentPos) | strengthNeighbor );
					else setConstraintFirstFunction( (firstExpr == parentPos) | strengthNeighbor );
				}
				else {
					if (isScroll) setConstraintFirstFunction( (firstExpr + scrollVar == parentPos + spanVar) | strengthNeighbor );
					else setConstraintFirstFunction( (firstExpr == parentPos + spanVar) | strengthNeighbor );
				}
			}
			else if (align == Align.LAST)   //  ----- oversize align right ----
			{	// firstExpr
				if (autospace & LayoutContainer.AUTOSPACE_FIRST == 0) {
					if (isScroll) setConstraintFirstFunction( (firstExpr + oversizeVar + scrollVar == parentPos) | strengthNeighbor );
					else setConstraintFirstFunction( (firstExpr + oversizeVar == parentPos) | strengthNeighbor );
				}
				else {
					if (isScroll) setConstraintFirstFunction( (firstExpr + oversizeVar + scrollVar == parentPos + spanVar) | strengthNeighbor );
					else setConstraintFirstFunction( (firstExpr + oversizeVar == parentPos + spanVar) | strengthNeighbor );
				}
			}
			else                             //  ---- oversize align centered ---
			{	// firstExpr
				if (autospace & LayoutContainer.AUTOSPACE_FIRST == 0) {
					if (isScroll) setConstraintFirstFunction( (firstExpr + oversizeVar/2 + scrollVar == parentPos) | strengthNeighbor );
					else setConstraintFirstFunction( (firstExpr + oversizeVar/2 == parentPos) | strengthNeighbor );
				}
				else {
					if (isScroll) setConstraintFirstFunction( (firstExpr + oversizeVar/2 + scrollVar == parentPos + spanVar) | strengthNeighbor );
					else setConstraintFirstFunction( (firstExpr + oversizeVar/2 == parentPos + spanVar) | strengthNeighbor );
				}
			}
		}
		
	}
	
	// TODO: refactor
	static function toOuterLast(
			setConstraintLastFunction:Constraint->Void, 
			lastExpr:Expression, parentPos:Variable, parentSize:Expression,
			isOversize = true, isScroll = false,
			spanVar:Variable, oversizeVar:Variable, scrollVar:Variable,
			align:Int, autospace:Int
			) {
				
		if (!isOversize) {
			// lastExpr
			if (autospace & LayoutContainer.AUTOSPACE_LAST == 0) {
				if (isScroll) setConstraintLastFunction( (lastExpr + scrollVar == parentPos + parentSize) | strengthNeighbor );
				else setConstraintLastFunction( (lastExpr == parentPos + parentSize) | strengthNeighbor );
			}
			else {
				if (isScroll) setConstraintLastFunction( (lastExpr + scrollVar == parentPos + parentSize - spanVar) | strengthNeighbor );
				else setConstraintLastFunction( (lastExpr == parentPos + parentSize - spanVar) | strengthNeighbor );
			}
		}
		else // ---------------- oversize ---------------------
		{
			if (align == Align.AUTO) {
				// do same as for auto spacing
				if (autospace == LayoutContainer.AUTOSPACE_FIRST) align = Align.LAST;
				else if (autospace == LayoutContainer.AUTOSPACE_LAST) align = Align.FIRST;
				else align = Align.CENTER;
			}
			
			if (align == Align.FIRST)        //  ----- oversize align left ----
			{	// lastExpr
				if (autospace & LayoutContainer.AUTOSPACE_LAST == 0) {
					if (isScroll) setConstraintLastFunction( (lastExpr - oversizeVar + scrollVar == parentPos + parentSize) | strengthNeighbor );
					else setConstraintLastFunction( (lastExpr - oversizeVar == parentPos + parentSize) | strengthNeighbor );
				}
				else {
					if (isScroll) setConstraintLastFunction( (lastExpr - oversizeVar + scrollVar == parentPos + parentSize - spanVar) | strengthNeighbor );
					else setConstraintLastFunction( (lastExpr - oversizeVar == parentPos + parentSize - spanVar) | strengthNeighbor );
				}
			}
			else if (align == Align.LAST)   //  ----- oversize align right ----
			{	// lastExpr
				if (autospace & LayoutContainer.AUTOSPACE_LAST == 0) {
					if (isScroll) setConstraintLastFunction( (lastExpr + scrollVar == parentPos + parentSize) | strengthNeighbor );
					else setConstraintLastFunction( (lastExpr == parentPos + parentSize) | strengthNeighbor );
				}
				else {
					if (isScroll) setConstraintLastFunction( (lastExpr + scrollVar == parentPos + parentSize - spanVar) | strengthNeighbor );
					else setConstraintLastFunction( (lastExpr == parentPos + parentSize - spanVar) | strengthNeighbor );
				}
			}
			else                             //  ---- oversize align centered ---
			{	// lastExpr
				if (autospace & LayoutContainer.AUTOSPACE_LAST == 0) {
					if (isScroll) setConstraintLastFunction( (lastExpr - oversizeVar/2 + scrollVar == parentPos + parentSize) | strengthNeighbor );
					else setConstraintLastFunction( (lastExpr - oversizeVar/2 == parentPos + parentSize) | strengthNeighbor );
				}
				else {
					if (isScroll) setConstraintLastFunction( (lastExpr - oversizeVar/2 + scrollVar == parentPos + parentSize - spanVar) | strengthNeighbor );
					else setConstraintLastFunction( (lastExpr - oversizeVar/2 == parentPos + parentSize - spanVar) | strengthNeighbor );
				}
			}
		}
		
	}
	
	// TODO: optimization with static ?
	public inline function toLeft(a:Expression, b:Expression) {
		left( (a == b) | strengthNeighbor );
	}

	public inline function toRight(a:Expression, b:Expression) {
		right( (a == b) | strengthNeighbor );
	}

	public inline function toTop(a:Expression, b:Expression) {
		top( (a == b) | strengthNeighbor );
	}

	public inline function toBottom(a:Expression, b:Expression) {
		bottom( (a == b) | strengthNeighbor );
	}

	
	//var cLeft:Null<Constraint> = null;
	inline function left(c:Constraint) {
		//cLeft = c;
		solver.addConstraint(c);
	}
	inline function right(c:Constraint) {
		solver.addConstraint(c);
	}
	inline function top(c:Constraint) {
		solver.addConstraint(c);
	}
	inline function bottom(c:Constraint) {
		solver.addConstraint(c);
	}
	
	public inline function innerLimit(innerLimitVar:Variable) {
		//var c1:Constraint = (innerLimitVar >= 0) | strengthHigh;
		var c1:Constraint = (innerLimitVar >= 0) | Strength.STRONG;
		//var c2:Constraint = (innerLimitVar <= 1) | strengthHigh; // need because of rounding error if multiple childs!
		solver.addConstraint(c1);
		//solver.addConstraint(c2);
	}
	
	public inline function innerSpan(innerSpanVar:Variable, parent_size:Expression, sumMax:Int, sumWeight:Float) {
		//var c1:Constraint = (innerSpanVar >= 0) | strengthHigh;
		var c1:Constraint = (innerSpanVar >= 0) | Strength.STRONG;
		var c2:Constraint = (innerSpanVar == (parent_size - sumMax) / sumWeight) | strengthSpan;
		solver.addConstraint(c1);
		solver.addConstraint(c2);
	}
	
	public inline function outerHLimit(outerHLimitVar:Variable) {
		//var c1:Constraint = (outerHLimitVar >= 0) | strengthHigh;
		var c1:Constraint = (outerHLimitVar >= 0) | Strength.STRONG;
		//var c2:Constraint = (outerHLimitVar <= 1) | strengthHigh; // need because of rounding error if multiple childs!
		solver.addConstraint(c1);
		//solver.addConstraint(c2);
	}
	public inline function outerVLimit(outerVLimitVar:Variable) {
		//var c1:Constraint = (outerVLimitVar >= 0) | strengthHigh;
		var c1:Constraint = (outerVLimitVar >= 0) | Strength.STRONG;
		//var c2:Constraint = (outerVLimitVar <= 1) | strengthHigh; // need because of rounding error if multiple childs!
		solver.addConstraint(c1);
		//solver.addConstraint(c2);
	}
	
	public inline function outerHSpan(outerHSpanVar:Variable, parent_width:Expression, limitMax:Int, sumWeight:Float) {
		//var c1:Constraint = (outerHSpanVar >= 0) | strengthHigh; // <-
		var c1:Constraint = (outerHSpanVar >= 0) | Strength.STRONG; // <-
		var c2:Constraint = (outerHSpanVar == (parent_width - limitMax) / sumWeight) | strengthSpan;
		solver.addConstraint(c1);
		solver.addConstraint(c2);
	}
	
	public inline function outerVSpan(outerVSpanVar:Variable, parent_height:Expression, limitMax:Int, sumWeight:Float) {
		//var c1:Constraint = (outerVSpanVar >= 0) | strengthHigh;
		var c1:Constraint = (outerVSpanVar >= 0) | Strength.STRONG;
		var c2:Constraint = (outerVSpanVar == (parent_height - limitMax) / sumWeight) | strengthSpan;
		solver.addConstraint(c1);
		solver.addConstraint(c2);
	}
		
	public inline function innerHOversize(innerHOversizeVar:Variable, innerHOversizeWeight:Float) {
		var c1:Constraint = (innerHOversizeVar >= 0 ) | strengthHigh;	
		//var c2:Constraint = (innerHOversizeVar <= childsHMin - hSize.middle._min) | strengthHigh;				
		var c3:Constraint = (innerHOversizeVar == 0) | Strength.create(0, innerHOversizeWeight, 0);
		solver.addConstraint(c1);
		//solver.addConstraint(c2);
		solver.addConstraint(c3);
	}
	
	public inline function innerVOversize(innerVOversizeVar:Variable, innerVOversizeWeight:Float) {
		var c1:Constraint = (innerVOversizeVar >= 0 ) | strengthHigh;	
		//var c2:Constraint = (innerVOversizeVar <= childsVMin - vSize.middle._min) | strengthHigh;				
		var c3:Constraint = (innerVOversizeVar == 0) | Strength.create(0, innerVOversizeWeight, 0);
		solver.addConstraint(c1);
		//solver.addConstraint(c2);
		solver.addConstraint(c3);
	}
		
	public inline function outerHOversize(outerHOversizeVar:Variable, outerHOversizeWeight:Float) {
		var c1:Constraint = (outerHOversizeVar >= 0 ) | strengthHigh;	
		//var c2:Constraint = (outerHOversizeVar <= hSize.getLimitMin() - parent.hSize.middle._min) | strengthHigh;				
		var c3:Constraint = (outerHOversizeVar == 0) | Strength.create(0, outerHOversizeWeight, 0);
		solver.addConstraint(c1);
		//solver.addConstraint(c2);
		solver.addConstraint(c3);
	}
	
	public inline function outerVOversize(outerVOversizeVar:Variable, outerVOversizeWeight:Float) {
		var c1:Constraint = (outerVOversizeVar >= 0 ) | strengthHigh;	
		//var c2:Constraint = (outerVOversizeVar <= vSize.getLimitMin() - parent.vSize.middle._min) | strengthHigh;				
		var c3:Constraint = (outerVOversizeVar == 0) | Strength.create(0, outerVOversizeWeight, 0);
		solver.addConstraint(c1);
		//solver.addConstraint(c2);
		solver.addConstraint(c3);
	}
	
}