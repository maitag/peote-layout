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
	
	public function new()
	{
	}
	
	public static function toOuterLeftRight( solver:Solver,
			leftChild:LayoutContainer, rightChild:LayoutContainer, parentPos:Variable, parentSize:Expression,
			spanVar:Variable, oversizeVar:Null<Variable>, scrollVar:Null<Variable>,
			align:Int, autospace:Int
			) {
		toOuter( solver,
			leftChild.constraintSet.left, rightChild.constraintSet.right, 
			leftChild._left, rightChild._right, parentPos, parentSize,
			spanVar, oversizeVar, scrollVar,
			align, autospace);		
	}
	
	public static function toOuterLeft( solver:Solver,
			child:LayoutContainer, parentPos:Variable,
			spanVar:Variable, oversizeVar:Null<Variable>, scrollVar:Null<Variable>,
			align:Int, autospace:Int
			) {
		toOuterStart( solver,
			child.constraintSet.left,
			child._left, parentPos,
			spanVar, oversizeVar, scrollVar,
			align, autospace);		
	}
	
	public static function toOuterRight( solver:Solver,
			child:LayoutContainer, parentPos:Variable, parentSize:Expression,
			spanVar:Variable, oversizeVar:Null<Variable>, scrollVar:Null<Variable>,
			align:Int, autospace:Int
			) {
		toOuterEnd( solver,
			child.constraintSet.right, 
			child._right, parentPos, parentSize,
			spanVar, oversizeVar, scrollVar,
			align, autospace);		
	}
	
	public static function toOuterTopBottom( solver:Solver,
			topChild:LayoutContainer, bottomChild:LayoutContainer, parentPos:Variable, parentSize:Expression,
			spanVar:Variable, oversizeVar:Null<Variable>, scrollVar:Null<Variable>,
			align:Int, autospace:Int
			) {
		toOuter( solver,
			topChild.constraintSet.top, bottomChild.constraintSet.bottom, 
			topChild._top, bottomChild._bottom, parentPos, parentSize,
			spanVar, oversizeVar, scrollVar,
			align, autospace);		
	}	
	
	public static function toOuterTop( solver:Solver,
			child:LayoutContainer, parentPos:Variable,
			spanVar:Variable, oversizeVar:Null<Variable>, scrollVar:Null<Variable>,
			align:Int, autospace:Int
			) {
		toOuterStart( solver,
			child.constraintSet.top,
			child._top, parentPos,
			spanVar, oversizeVar, scrollVar,
			align, autospace);		
	}	
	
	public static function toOuterBottom( solver:Solver,
			child:LayoutContainer, parentPos:Variable, parentSize:Expression,
			spanVar:Variable, oversizeVar:Null<Variable>, scrollVar:Null<Variable>,
			align:Int, autospace:Int
			) {
		toOuterEnd( solver,
			child.constraintSet.bottom, 
			child._bottom, parentPos, parentSize,
			spanVar, oversizeVar, scrollVar,
			align, autospace);		
	}	
	
	// ---------------------------------------------------------------------
	
	static inline function toOuter( solver:Solver,
			setConstraintFunctionStart:Solver->Constraint->Void, setConstraintFunctionEnd:Solver->Constraint->Void, 
			firstExpr:Expression, lastExpr:Expression, parentPos:Variable, parentSize:Expression,
			spanVar:Variable, oversizeVar:Null<Variable>, scrollVar:Null<Variable>,
			align:Int, autospace:Int
			) 
	{
		if (oversizeVar == null) {
			noOversizeStart(solver, setConstraintFunctionStart, firstExpr, parentPos, spanVar, scrollVar, autospace);
			noOversizeEnd(solver, setConstraintFunctionEnd, lastExpr, parentPos, parentSize, spanVar, scrollVar, autospace);
		}
		else // ---------------- oversize ---------------------
		{
			if (align == Align.AUTO) { // do same as for auto spacing
				if (autospace == LayoutContainer.AUTOSPACE_FIRST) align = Align.LAST;
				else if (autospace == LayoutContainer.AUTOSPACE_LAST) align = Align.FIRST;
				else align = Align.CENTER;
			}
			if (align == Align.FIRST) {     // oversize align top or left
				oversizeAlignFirstStart(solver, setConstraintFunctionStart, firstExpr, parentPos, spanVar, scrollVar, autospace);
				oversizeAlignFirstEnd(solver, setConstraintFunctionEnd, lastExpr, parentPos, parentSize, spanVar, oversizeVar, scrollVar, autospace);
			}
			else if (align == Align.LAST) { // oversize align bottom or right
				oversizeAlignLastStart(solver, setConstraintFunctionStart, firstExpr, parentPos, spanVar, oversizeVar, scrollVar, autospace);
				oversizeAlignLastEnd(solver, setConstraintFunctionEnd, lastExpr, parentPos, parentSize, spanVar, scrollVar, autospace);
			}
			else {                          // oversize align centered
				oversizeAlignCenterStart(solver, setConstraintFunctionStart, firstExpr, parentPos, spanVar, oversizeVar, scrollVar, autospace);
				oversizeAlignCenterEnd(solver, setConstraintFunctionEnd, lastExpr, parentPos, parentSize, spanVar, oversizeVar, scrollVar, autospace);
			}
		}
	}
	
	// ---------------------------------------------------------------------
	
	static inline function toOuterStart( solver:Solver,
			setConstraintFunctionStart:Solver->Constraint->Void, 
			firstExpr:Expression, parentPos:Variable,
			spanVar:Variable, oversizeVar:Null<Variable>, scrollVar:Null<Variable>,
			align:Int, autospace:Int
			) 
	{
		if (oversizeVar == null) noOversizeStart(solver, setConstraintFunctionStart, firstExpr, parentPos, spanVar, scrollVar, autospace);
		else
		{	// ---------------- oversize ---------------------
			if (align == Align.AUTO) { // do same as for auto spacing
				if (autospace == LayoutContainer.AUTOSPACE_FIRST) align = Align.LAST;
				else if (autospace == LayoutContainer.AUTOSPACE_LAST) align = Align.FIRST;
				else align = Align.CENTER;
			}			
			if (align == Align.FIRST)     // oversize align top or left
				oversizeAlignFirstStart(solver, setConstraintFunctionStart, firstExpr, parentPos, spanVar, scrollVar, autospace);
			else if (align == Align.LAST) // oversize align bottom or right
				oversizeAlignLastStart(solver, setConstraintFunctionStart, firstExpr, parentPos, spanVar, oversizeVar, scrollVar, autospace);
			else                          // oversize align centered
				oversizeAlignCenterStart(solver, setConstraintFunctionStart, firstExpr, parentPos, spanVar, oversizeVar, scrollVar, autospace);
		}		
	}
	
	static inline function noOversizeStart(solver:Solver, setConstraintFunctionStart:Solver->Constraint->Void, firstExpr:Expression, parentPos:Variable, spanVar:Variable, scrollVar:Null<Variable>, autospace:Int) {
		if (autospace & LayoutContainer.AUTOSPACE_FIRST == 0) {
			if (scrollVar != null) setConstraintFunctionStart(solver, (firstExpr + scrollVar == parentPos) | strengthNeighbor );
			else setConstraintFunctionStart(solver, (firstExpr == parentPos) | strengthNeighbor );
		}
		else {
			if (scrollVar != null) setConstraintFunctionStart(solver, (firstExpr + scrollVar == parentPos + spanVar) | strengthNeighbor );
			else setConstraintFunctionStart(solver, (firstExpr == parentPos + spanVar) | strengthNeighbor );
		}
	}
	
	static inline function oversizeAlignFirstStart(solver:Solver, setConstraintFunctionStart:Solver->Constraint->Void, firstExpr:Expression, parentPos:Variable, spanVar:Variable, scrollVar:Null<Variable>, autospace:Int) {
		if (autospace & LayoutContainer.AUTOSPACE_FIRST == 0) {
			if (scrollVar != null) setConstraintFunctionStart(solver, (firstExpr + scrollVar == parentPos) | strengthNeighbor );
			else setConstraintFunctionStart(solver, (firstExpr == parentPos) | strengthNeighbor );
		}
		else {
			if (scrollVar != null) setConstraintFunctionStart(solver, (firstExpr + scrollVar == parentPos + spanVar) | strengthNeighbor );
			else setConstraintFunctionStart(solver, (firstExpr == parentPos + spanVar) | strengthNeighbor );
		}
	}
	
	static inline function oversizeAlignLastStart(solver:Solver, setConstraintFunctionStart:Solver->Constraint->Void, firstExpr:Expression, parentPos:Variable, spanVar:Variable, oversizeVar:Null<Variable>, scrollVar:Null<Variable>, autospace:Int) {
		if (autospace & LayoutContainer.AUTOSPACE_FIRST == 0) {
			if (scrollVar != null) setConstraintFunctionStart(solver, (firstExpr + oversizeVar + scrollVar == parentPos) | strengthNeighbor );
			else setConstraintFunctionStart(solver, (firstExpr + oversizeVar == parentPos) | strengthNeighbor );
		}
		else {
			if (scrollVar != null) setConstraintFunctionStart(solver, (firstExpr + oversizeVar + scrollVar == parentPos + spanVar) | strengthNeighbor );
			else setConstraintFunctionStart(solver, (firstExpr + oversizeVar == parentPos + spanVar) | strengthNeighbor );
		}
	}
	
	static inline function oversizeAlignCenterStart(solver:Solver, setConstraintFunctionStart:Solver->Constraint->Void, firstExpr:Expression, parentPos:Variable, spanVar:Variable, oversizeVar:Null<Variable>, scrollVar:Null<Variable>, autospace:Int) {
		if (autospace & LayoutContainer.AUTOSPACE_FIRST == 0) {
			if (scrollVar != null) setConstraintFunctionStart(solver, (firstExpr + oversizeVar/2 + scrollVar == parentPos) | strengthNeighbor );
			else setConstraintFunctionStart(solver, (firstExpr + oversizeVar/2 == parentPos) | strengthNeighbor );
		}
		else {
			if (scrollVar != null) setConstraintFunctionStart(solver, (firstExpr + oversizeVar/2 + scrollVar == parentPos + spanVar) | strengthNeighbor );
			else setConstraintFunctionStart(solver, (firstExpr + oversizeVar/2 == parentPos + spanVar) | strengthNeighbor );
		}
	}

	// ---------------------------------------------------------------------
	
	static inline function toOuterEnd( solver:Solver,
			setConstraintFunctionEnd:Solver->Constraint->Void, 
			lastExpr:Expression, parentPos:Variable, parentSize:Expression,
			spanVar:Variable, oversizeVar:Null<Variable>, scrollVar:Null<Variable>,
			align:Int, autospace:Int
			)
	{				
		if (oversizeVar == null) noOversizeEnd(solver, setConstraintFunctionEnd, lastExpr, parentPos, parentSize, spanVar, scrollVar, autospace);
		else 
		{	// ---------------- oversize ---------------------
			if (align == Align.AUTO) { // do same as for auto spacing
				if (autospace == LayoutContainer.AUTOSPACE_FIRST) align = Align.LAST;
				else if (autospace == LayoutContainer.AUTOSPACE_LAST) align = Align.FIRST;
				else align = Align.CENTER;
			}			
			if (align == Align.FIRST)     // oversize align top or left
				oversizeAlignFirstEnd(solver, setConstraintFunctionEnd, lastExpr, parentPos, parentSize, spanVar, oversizeVar, scrollVar, autospace);
			else if (align == Align.LAST) // oversize align bottom or right
				oversizeAlignLastEnd(solver, setConstraintFunctionEnd, lastExpr, parentPos, parentSize, spanVar, scrollVar, autospace);
			else                          // oversize align centered
				oversizeAlignCenterEnd(solver, setConstraintFunctionEnd, lastExpr, parentPos, parentSize, spanVar, oversizeVar, scrollVar, autospace);
		}		
	}
	
	static inline function noOversizeEnd(solver:Solver, setConstraintFunctionEnd:Solver->Constraint->Void, lastExpr:Expression, parentPos:Variable, parentSize:Expression, spanVar:Variable, scrollVar:Null<Variable>, autospace:Int) {
		if (autospace & LayoutContainer.AUTOSPACE_LAST == 0) {
			if (scrollVar != null) setConstraintFunctionEnd(solver, (lastExpr + scrollVar == parentPos + parentSize) | strengthNeighbor );
			else setConstraintFunctionEnd(solver, (lastExpr == parentPos + parentSize) | strengthNeighbor );
		}
		else {
			if (scrollVar != null) setConstraintFunctionEnd(solver, (lastExpr + scrollVar == parentPos + parentSize - spanVar) | strengthNeighbor );
			else setConstraintFunctionEnd(solver, (lastExpr == parentPos + parentSize - spanVar) | strengthNeighbor );
		}
	}
	
	static inline function oversizeAlignFirstEnd(solver:Solver, setConstraintFunctionEnd:Solver->Constraint->Void, lastExpr:Expression, parentPos:Variable, parentSize:Expression, spanVar:Variable, oversizeVar:Null<Variable>, scrollVar:Null<Variable>, autospace:Int) {
		if (autospace & LayoutContainer.AUTOSPACE_LAST == 0) {
			if (scrollVar != null) setConstraintFunctionEnd(solver, (lastExpr - oversizeVar + scrollVar == parentPos + parentSize) | strengthNeighbor );
			else setConstraintFunctionEnd(solver, (lastExpr - oversizeVar == parentPos + parentSize) | strengthNeighbor );
		}
		else {
			if (scrollVar != null) setConstraintFunctionEnd(solver, (lastExpr - oversizeVar + scrollVar == parentPos + parentSize - spanVar) | strengthNeighbor );
			else setConstraintFunctionEnd(solver, (lastExpr - oversizeVar == parentPos + parentSize - spanVar) | strengthNeighbor );
		}
	}
	
	static inline function oversizeAlignLastEnd(solver:Solver, setConstraintFunctionEnd:Solver->Constraint->Void, lastExpr:Expression, parentPos:Variable, parentSize:Expression, spanVar:Variable, scrollVar:Null<Variable>, autospace:Int) {
		if (autospace & LayoutContainer.AUTOSPACE_LAST == 0) {
			if (scrollVar != null) setConstraintFunctionEnd(solver, (lastExpr + scrollVar == parentPos + parentSize) | strengthNeighbor );
			else setConstraintFunctionEnd(solver, (lastExpr == parentPos + parentSize) | strengthNeighbor );
		}
		else {
			if (scrollVar != null) setConstraintFunctionEnd(solver, (lastExpr + scrollVar == parentPos + parentSize - spanVar) | strengthNeighbor );
			else setConstraintFunctionEnd(solver, (lastExpr == parentPos + parentSize - spanVar) | strengthNeighbor );
		}
	}
	
	static inline function oversizeAlignCenterEnd(solver:Solver, setConstraintFunctionEnd:Solver->Constraint->Void, lastExpr:Expression, parentPos:Variable, parentSize:Expression, spanVar:Variable, oversizeVar:Null<Variable>, scrollVar:Null<Variable>, autospace:Int) {
		if (autospace & LayoutContainer.AUTOSPACE_LAST == 0) {
			if (scrollVar != null) setConstraintFunctionEnd(solver, (lastExpr - oversizeVar/2 + scrollVar == parentPos + parentSize) | strengthNeighbor );
			else setConstraintFunctionEnd(solver, (lastExpr - oversizeVar/2 == parentPos + parentSize) | strengthNeighbor );
		}
		else {
			if (scrollVar != null) setConstraintFunctionEnd(solver, (lastExpr - oversizeVar/2 + scrollVar == parentPos + parentSize - spanVar) | strengthNeighbor );
			else setConstraintFunctionEnd(solver, (lastExpr - oversizeVar/2 == parentPos + parentSize - spanVar) | strengthNeighbor );
		}
	}
	
	
	// ----------------------------------------------------------------------------------------------------
	// ----------------------------------------------------------------------------------------------------
	// ----------------------------------------------------------------------------------------------------
	
	// TODO: optimization with static ?
	public inline function toLeft(solver:Solver, a:Expression, b:Expression) {
		left(solver, (a == b) | strengthNeighbor );
	}

	public inline function removeToLeft(solver:Solver) {
		solver.removeConstraint(cLeft);
	}
	
	public inline function toRight(solver:Solver, a:Expression, b:Expression) {
		right(solver, (a == b) | strengthNeighbor );
	}

	public inline function removeToRight(solver:Solver) {
		solver.removeConstraint(cRight);
	}
	
	public inline function toTop(solver:Solver, a:Expression, b:Expression) {
		top(solver, (a == b) | strengthNeighbor );
	}

	public inline function toBottom(solver:Solver, a:Expression, b:Expression) {
		bottom(solver, (a == b) | strengthNeighbor );
	}


	//TODO:  hasConstraintVar.left
	
	public var cLeft:Constraint;
	public var cRight:Constraint;
	
	inline function left(solver:Solver, c:Constraint) {
		cLeft = c;
		solver.addConstraint(cLeft);
	}
	inline function right(solver:Solver, c:Constraint) {
		cRight = c;
		solver.addConstraint(cRight);
	}
	inline function top(solver:Solver, c:Constraint) {
		solver.addConstraint(c);
	}
	inline function bottom(solver:Solver, c:Constraint) {
		solver.addConstraint(c);
	}
	
	
	// -------------------------------------------------------------------------	
	
	public inline function innerLimit(solver:Solver, innerLimitVar:Variable) {
		//var c1:Constraint = (innerLimitVar >= 0) | strengthHigh;
		var c1:Constraint = (innerLimitVar >= 0) | Strength.STRONG;
		//var c2:Constraint = (innerLimitVar <= 1) | strengthHigh; // need because of rounding error if multiple childs!
		solver.addConstraint(c1);
		//solver.addConstraint(c2);
	}
	
	public inline function innerSpan(solver:Solver, innerSpanVar:Variable, parent_size:Expression, sumMax:Int, sumWeight:Float) {
		//var c1:Constraint = (innerSpanVar >= 0) | strengthHigh;
		var c1:Constraint = (innerSpanVar >= 0) | Strength.STRONG;
		var c2:Constraint = (innerSpanVar == (parent_size - sumMax) / sumWeight) | strengthSpan;
		solver.addConstraint(c1);
		solver.addConstraint(c2);
	}
	
	public inline function outerHLimit(solver:Solver, outerHLimitVar:Variable) {
		//var c1:Constraint = (outerHLimitVar >= 0) | strengthHigh;
		var c1:Constraint = (outerHLimitVar >= 0) | Strength.STRONG;
		//var c2:Constraint = (outerHLimitVar <= 1) | strengthHigh; // need because of rounding error if multiple childs!
		solver.addConstraint(c1);
		//solver.addConstraint(c2);
	}
	public inline function outerVLimit(solver:Solver, outerVLimitVar:Variable) {
		//var c1:Constraint = (outerVLimitVar >= 0) | strengthHigh;
		var c1:Constraint = (outerVLimitVar >= 0) | Strength.STRONG;
		//var c2:Constraint = (outerVLimitVar <= 1) | strengthHigh; // need because of rounding error if multiple childs!
		solver.addConstraint(c1);
		//solver.addConstraint(c2);
	}
	
	public inline function outerHSpan(solver:Solver, outerHSpanVar:Variable, parent_width:Expression, limitMax:Int, sumWeight:Float) {
		//var c1:Constraint = (outerHSpanVar >= 0) | strengthHigh; // <-
		var c1:Constraint = (outerHSpanVar >= 0) | Strength.STRONG; // <-
		// TODO: maybe optimizing later here (if parent_width is _const or sumWeight is 1)
		var c2:Constraint = (outerHSpanVar == (parent_width - limitMax) / sumWeight) | strengthSpan;
		solver.addConstraint(c1);
		solver.addConstraint(c2);
	}
	
	public inline function outerVSpan(solver:Solver, outerVSpanVar:Variable, parent_height:Expression, limitMax:Int, sumWeight:Float) {
		//var c1:Constraint = (outerVSpanVar >= 0) | strengthHigh;
		var c1:Constraint = (outerVSpanVar >= 0) | Strength.STRONG;
		var c2:Constraint = (outerVSpanVar == (parent_height - limitMax) / sumWeight) | strengthSpan;
		solver.addConstraint(c1);
		solver.addConstraint(c2);
	}
		
	// -------------------------------------------------------------------------	
	
	public inline function innerHOversize(solver:Solver, innerHOversizeVar:Variable, innerHOversizeWeight:Float) {
		var c1:Constraint = (innerHOversizeVar >= 0 ) | strengthHigh;	
		//var c2:Constraint = (innerHOversizeVar <= childsHMin - hSize.middle._min) | strengthHigh;				
		var c3:Constraint = (innerHOversizeVar == 0) | Strength.create(0, innerHOversizeWeight, 0);
		solver.addConstraint(c1);
		//solver.addConstraint(c2);
		solver.addConstraint(c3);
	}
	
	public inline function innerVOversize(solver:Solver, innerVOversizeVar:Variable, innerVOversizeWeight:Float) {
		var c1:Constraint = (innerVOversizeVar >= 0 ) | strengthHigh;	
		//var c2:Constraint = (innerVOversizeVar <= childsVMin - vSize.middle._min) | strengthHigh;				
		var c3:Constraint = (innerVOversizeVar == 0) | Strength.create(0, innerVOversizeWeight, 0);
		solver.addConstraint(c1);
		//solver.addConstraint(c2);
		solver.addConstraint(c3);
	}
		
	public inline function outerHOversize(solver:Solver, outerHOversizeVar:Variable, outerHOversizeWeight:Float) {
		var c1:Constraint = (outerHOversizeVar >= 0 ) | strengthHigh;	
		//var c2:Constraint = (outerHOversizeVar <= hSize.getLimitMin() - parent.hSize.middle._min) | strengthHigh;				
		var c3:Constraint = (outerHOversizeVar == 0) | Strength.create(0, outerHOversizeWeight, 0);
		solver.addConstraint(c1);
		//solver.addConstraint(c2);
		solver.addConstraint(c3);
	}
	
	public inline function outerVOversize(solver:Solver, outerVOversizeVar:Variable, outerVOversizeWeight:Float) {
		var c1:Constraint = (outerVOversizeVar >= 0 ) | strengthHigh;	
		//var c2:Constraint = (outerVOversizeVar <= vSize.getLimitMin() - parent.vSize.middle._min) | strengthHigh;				
		var c3:Constraint = (outerVOversizeVar == 0) | Strength.create(0, outerVOversizeWeight, 0);
		solver.addConstraint(c1);
		//solver.addConstraint(c2);
		solver.addConstraint(c3);
	}
	
}