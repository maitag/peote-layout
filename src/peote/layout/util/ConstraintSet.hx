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
		
	public static inline function toOuterLeftRight( solver:Solver,
			leftChild:LayoutContainer, rightChild:LayoutContainer, parentPos:Variable, parentSize:Expression,
			spanVar:Variable, oversizeVar:Null<Variable>, scrollVar:Null<Variable>,
			align:Int, autospace:Int
			) {
		toOuter( solver,
			leftChild._left, rightChild._right, parentPos, parentSize,
			spanVar, oversizeVar, scrollVar,
			align, autospace);		
	}
	
	public static inline function toOuterLeft( solver:Solver,
			child:LayoutContainer, parentPos:Variable,
			spanVar:Variable, oversizeVar:Null<Variable>, scrollVar:Null<Variable>,
			align:Int, autospace:Int
			) {
		toOuterStart( solver,
			child._left, parentPos,
			spanVar, oversizeVar, scrollVar,
			align, autospace);		
	}
	
	public static inline function toOuterRight( solver:Solver,
			child:LayoutContainer, parentPos:Variable, parentSize:Expression,
			spanVar:Variable, oversizeVar:Null<Variable>, scrollVar:Null<Variable>,
			align:Int, autospace:Int
			) {
		toOuterEnd( solver,
			child._right, parentPos, parentSize,
			spanVar, oversizeVar, scrollVar,
			align, autospace);		
	}
	
	public static inline function toOuterTopBottom( solver:Solver,
			topChild:LayoutContainer, bottomChild:LayoutContainer, parentPos:Variable, parentSize:Expression,
			spanVar:Variable, oversizeVar:Null<Variable>, scrollVar:Null<Variable>,
			align:Int, autospace:Int
			) {
		toOuter( solver,
			topChild._top, bottomChild._bottom, parentPos, parentSize,
			spanVar, oversizeVar, scrollVar,
			align, autospace);		
	}	
	
	public static inline function toOuterTop( solver:Solver,
			child:LayoutContainer, parentPos:Variable,
			spanVar:Variable, oversizeVar:Null<Variable>, scrollVar:Null<Variable>,
			align:Int, autospace:Int
			) {
		toOuterStart( solver,
			child._top, parentPos,
			spanVar, oversizeVar, scrollVar,
			align, autospace);		
	}	
	
	public static inline function toOuterBottom( solver:Solver,
			child:LayoutContainer, parentPos:Variable, parentSize:Expression,
			spanVar:Variable, oversizeVar:Null<Variable>, scrollVar:Null<Variable>,
			align:Int, autospace:Int
			) {
		toOuterEnd( solver,
			child._bottom, parentPos, parentSize,
			spanVar, oversizeVar, scrollVar,
			align, autospace);		
	}	
	
	// ---------------------------------------------------------------------
	
	static inline function toOuter( solver:Solver,
			firstExpr:Expression, lastExpr:Expression, parentPos:Variable, parentSize:Expression,
			spanVar:Variable, oversizeVar:Null<Variable>, scrollVar:Null<Variable>,
			align:Int, autospace:Int
			) 
	{
		if (oversizeVar == null) {
			noOversizeStart(solver, firstExpr, parentPos, spanVar, scrollVar, autospace);
			noOversizeEnd(solver, lastExpr, parentPos, parentSize, spanVar, scrollVar, autospace);
		}
		else // ---------------- oversize ---------------------
		{
			if (align == Align.AUTO) { // do same as for auto spacing
				if (autospace == LayoutContainer.AUTOSPACE_FIRST) align = Align.LAST;
				else if (autospace == LayoutContainer.AUTOSPACE_LAST) align = Align.FIRST;
				else align = Align.CENTER;
			}
			if (align == Align.FIRST) {     // oversize align top or left
				oversizeAlignFirstStart(solver, firstExpr, parentPos, spanVar, scrollVar, autospace);
				oversizeAlignFirstEnd(solver, lastExpr, parentPos, parentSize, spanVar, oversizeVar, scrollVar, autospace);
			}
			else if (align == Align.LAST) { // oversize align bottom or right
				oversizeAlignLastStart(solver, firstExpr, parentPos, spanVar, oversizeVar, scrollVar, autospace);
				oversizeAlignLastEnd(solver, lastExpr, parentPos, parentSize, spanVar, scrollVar, autospace);
			}
			else {                          // oversize align centered
				oversizeAlignCenterStart(solver, firstExpr, parentPos, spanVar, oversizeVar, scrollVar, autospace);
				oversizeAlignCenterEnd(solver, lastExpr, parentPos, parentSize, spanVar, oversizeVar, scrollVar, autospace);
			}
		}
	}
	
	// ---------------------------------------------------------------------
	
	static inline function toOuterStart( solver:Solver,
			firstExpr:Expression, parentPos:Variable,
			spanVar:Variable, oversizeVar:Null<Variable>, scrollVar:Null<Variable>,
			align:Int, autospace:Int
			) 
	{
		if (oversizeVar == null) noOversizeStart(solver, firstExpr, parentPos, spanVar, scrollVar, autospace);
		else
		{	// ---------------- oversize ---------------------
			if (align == Align.AUTO) { // do same as for auto spacing
				if (autospace == LayoutContainer.AUTOSPACE_FIRST) align = Align.LAST;
				else if (autospace == LayoutContainer.AUTOSPACE_LAST) align = Align.FIRST;
				else align = Align.CENTER;
			}			
			if (align == Align.FIRST)     // oversize align top or left
				oversizeAlignFirstStart(solver, firstExpr, parentPos, spanVar, scrollVar, autospace);
			else if (align == Align.LAST) // oversize align bottom or right
				oversizeAlignLastStart(solver, firstExpr, parentPos, spanVar, oversizeVar, scrollVar, autospace);
			else                          // oversize align centered
				oversizeAlignCenterStart(solver, firstExpr, parentPos, spanVar, oversizeVar, scrollVar, autospace);
		}		
	}
	
	static inline function noOversizeStart(solver:Solver, firstExpr:Expression, parentPos:Variable, spanVar:Variable, scrollVar:Null<Variable>, autospace:Int) {
		if (autospace & LayoutContainer.AUTOSPACE_FIRST == 0) {
			if (scrollVar != null) solver.addConstraint( (firstExpr + scrollVar == parentPos) | strengthNeighbor );
			else solver.addConstraint( (firstExpr == parentPos) | strengthNeighbor );
		}
		else {
			if (scrollVar != null) solver.addConstraint( (firstExpr + scrollVar == parentPos + spanVar) | strengthNeighbor );
			else solver.addConstraint( (firstExpr == parentPos + spanVar) | strengthNeighbor );
		}
	}
	
	static inline function oversizeAlignFirstStart(solver:Solver, firstExpr:Expression, parentPos:Variable, spanVar:Variable, scrollVar:Null<Variable>, autospace:Int) {
		if (autospace & LayoutContainer.AUTOSPACE_FIRST == 0) {
			if (scrollVar != null) solver.addConstraint( (firstExpr + scrollVar == parentPos) | strengthNeighbor );
			else solver.addConstraint( (firstExpr == parentPos) | strengthNeighbor );
		}
		else {
			if (scrollVar != null) solver.addConstraint( (firstExpr + scrollVar == parentPos + spanVar) | strengthNeighbor );
			else solver.addConstraint( (firstExpr == parentPos + spanVar) | strengthNeighbor );
		}
	}
	
	static inline function oversizeAlignLastStart(solver:Solver, firstExpr:Expression, parentPos:Variable, spanVar:Variable, oversizeVar:Null<Variable>, scrollVar:Null<Variable>, autospace:Int) {
		if (autospace & LayoutContainer.AUTOSPACE_FIRST == 0) {
			if (scrollVar != null) solver.addConstraint( (firstExpr + oversizeVar + scrollVar == parentPos) | strengthNeighbor );
			else solver.addConstraint( (firstExpr + oversizeVar == parentPos) | strengthNeighbor );
		}
		else {
			if (scrollVar != null) solver.addConstraint( (firstExpr + oversizeVar + scrollVar == parentPos + spanVar) | strengthNeighbor );
			else solver.addConstraint( (firstExpr + oversizeVar == parentPos + spanVar) | strengthNeighbor );
		}
	}
	
	static inline function oversizeAlignCenterStart(solver:Solver, firstExpr:Expression, parentPos:Variable, spanVar:Variable, oversizeVar:Null<Variable>, scrollVar:Null<Variable>, autospace:Int) {
		if (autospace & LayoutContainer.AUTOSPACE_FIRST == 0) {
			if (scrollVar != null) solver.addConstraint( (firstExpr + oversizeVar/2 + scrollVar == parentPos) | strengthNeighbor );
			else solver.addConstraint( (firstExpr + oversizeVar/2 == parentPos) | strengthNeighbor );
		}
		else {
			if (scrollVar != null) solver.addConstraint( (firstExpr + oversizeVar/2 + scrollVar == parentPos + spanVar) | strengthNeighbor );
			else solver.addConstraint( (firstExpr + oversizeVar/2 == parentPos + spanVar) | strengthNeighbor );
		}
	}

	// ---------------------------------------------------------------------
	
	static inline function toOuterEnd( solver:Solver,
			lastExpr:Expression, parentPos:Variable, parentSize:Expression,
			spanVar:Variable, oversizeVar:Null<Variable>, scrollVar:Null<Variable>,
			align:Int, autospace:Int
			)
	{				
		if (oversizeVar == null) noOversizeEnd(solver, lastExpr, parentPos, parentSize, spanVar, scrollVar, autospace);
		else 
		{	// ---------------- oversize ---------------------
			if (align == Align.AUTO) { // do same as for auto spacing
				if (autospace == LayoutContainer.AUTOSPACE_FIRST) align = Align.LAST;
				else if (autospace == LayoutContainer.AUTOSPACE_LAST) align = Align.FIRST;
				else align = Align.CENTER;
			}			
			if (align == Align.FIRST)     // oversize align top or left
				oversizeAlignFirstEnd(solver, lastExpr, parentPos, parentSize, spanVar, oversizeVar, scrollVar, autospace);
			else if (align == Align.LAST) // oversize align bottom or right
				oversizeAlignLastEnd(solver, lastExpr, parentPos, parentSize, spanVar, scrollVar, autospace);
			else                          // oversize align centered
				oversizeAlignCenterEnd(solver, lastExpr, parentPos, parentSize, spanVar, oversizeVar, scrollVar, autospace);
		}		
	}
	
	static inline function noOversizeEnd(solver:Solver, lastExpr:Expression, parentPos:Variable, parentSize:Expression, spanVar:Variable, scrollVar:Null<Variable>, autospace:Int) {
		if (autospace & LayoutContainer.AUTOSPACE_LAST == 0) {
			if (scrollVar != null) solver.addConstraint( (lastExpr + scrollVar == parentPos + parentSize) | strengthNeighbor );
			else solver.addConstraint( (lastExpr == parentPos + parentSize) | strengthNeighbor );
		}
		else {
			if (scrollVar != null) solver.addConstraint( (lastExpr + scrollVar == parentPos + parentSize - spanVar) | strengthNeighbor );
			else solver.addConstraint( (lastExpr == parentPos + parentSize - spanVar) | strengthNeighbor );
		}
	}
	
	static inline function oversizeAlignFirstEnd(solver:Solver, lastExpr:Expression, parentPos:Variable, parentSize:Expression, spanVar:Variable, oversizeVar:Null<Variable>, scrollVar:Null<Variable>, autospace:Int) {
		if (autospace & LayoutContainer.AUTOSPACE_LAST == 0) {
			if (scrollVar != null) solver.addConstraint( (lastExpr - oversizeVar + scrollVar == parentPos + parentSize) | strengthNeighbor );
			else solver.addConstraint( (lastExpr - oversizeVar == parentPos + parentSize) | strengthNeighbor );
		}
		else {
			if (scrollVar != null) solver.addConstraint( (lastExpr - oversizeVar + scrollVar == parentPos + parentSize - spanVar) | strengthNeighbor );
			else solver.addConstraint( (lastExpr - oversizeVar == parentPos + parentSize - spanVar) | strengthNeighbor );
		}
	}
	
	static inline function oversizeAlignLastEnd(solver:Solver, lastExpr:Expression, parentPos:Variable, parentSize:Expression, spanVar:Variable, scrollVar:Null<Variable>, autospace:Int) {
		if (autospace & LayoutContainer.AUTOSPACE_LAST == 0) {
			if (scrollVar != null) solver.addConstraint( (lastExpr + scrollVar == parentPos + parentSize) | strengthNeighbor );
			else solver.addConstraint( (lastExpr == parentPos + parentSize) | strengthNeighbor );
		}
		else {
			if (scrollVar != null) solver.addConstraint( (lastExpr + scrollVar == parentPos + parentSize - spanVar) | strengthNeighbor );
			else solver.addConstraint( (lastExpr == parentPos + parentSize - spanVar) | strengthNeighbor );
		}
	}
	
	static inline function oversizeAlignCenterEnd(solver:Solver, lastExpr:Expression, parentPos:Variable, parentSize:Expression, spanVar:Variable, oversizeVar:Null<Variable>, scrollVar:Null<Variable>, autospace:Int) {
		if (autospace & LayoutContainer.AUTOSPACE_LAST == 0) {
			if (scrollVar != null) solver.addConstraint( (lastExpr - oversizeVar/2 + scrollVar == parentPos + parentSize) | strengthNeighbor );
			else solver.addConstraint( (lastExpr - oversizeVar/2 == parentPos + parentSize) | strengthNeighbor );
		}
		else {
			if (scrollVar != null) solver.addConstraint( (lastExpr - oversizeVar/2 + scrollVar == parentPos + parentSize - spanVar) | strengthNeighbor );
			else solver.addConstraint( (lastExpr - oversizeVar/2 == parentPos + parentSize - spanVar) | strengthNeighbor );
		}
	}
	
	
	// ----------------------------------------------------------------------------------------------------
	// ----------------------------------------------------------------------------------------------------
	// ----------------------------------------------------------------------------------------------------
	
	// TODO: optimization with static ?
	public static inline function toLeft(solver:Solver, a:Expression, b:Expression) {
		solver.addConstraint( (a == b) | strengthNeighbor );
	}

	public static inline function toRight(solver:Solver, a:Expression, b:Expression) {
		solver.addConstraint( (a == b) | strengthNeighbor );
	}

	public static inline function toTop(solver:Solver, a:Expression, b:Expression) {
		solver.addConstraint( (a == b) | strengthNeighbor );
	}

	public static inline function toBottom(solver:Solver, a:Expression, b:Expression) {
		solver.addConstraint( (a == b) | strengthNeighbor );
	}


	//TODO:  hasConstraintVar.left
		
	
	// -------------------------------------------------------------------------	
	
	// TODO: optimize c1, c2 and so out if all runs stable!
	
	public static inline function innerLimit(solver:Solver, innerLimitVar:Variable) {
		//var c1:Constraint = (innerLimitVar >= 0) | strengthHigh;
		var c1:Constraint = (innerLimitVar >= 0) | Strength.STRONG;
		//var c2:Constraint = (innerLimitVar <= 1) | strengthHigh; // need because of rounding error if multiple childs!
		solver.addConstraint(c1);
		//solver.addConstraint(c2);
	}
	
	public static inline function innerSpan(solver:Solver, innerSpanVar:Variable, parent_size:Expression, sumMax:Int, sumWeight:Float) {
		//var c1:Constraint = (innerSpanVar >= 0) | strengthHigh;
		var c1:Constraint = (innerSpanVar >= 0) | Strength.STRONG;
		var c2:Constraint = (innerSpanVar == (parent_size - sumMax) / sumWeight) | strengthSpan;
		solver.addConstraint(c1);
		solver.addConstraint(c2);
	}
	
	public static inline function outerHLimit(solver:Solver, outerHLimitVar:Variable) {
		//var c1:Constraint = (outerHLimitVar >= 0) | strengthHigh;
		var c1:Constraint = (outerHLimitVar >= 0) | Strength.STRONG;
		//var c2:Constraint = (outerHLimitVar <= 1) | strengthHigh; // need because of rounding error if multiple childs!
		solver.addConstraint(c1);
		//solver.addConstraint(c2);
	}
	public static inline function outerVLimit(solver:Solver, outerVLimitVar:Variable) {
		//var c1:Constraint = (outerVLimitVar >= 0) | strengthHigh;
		var c1:Constraint = (outerVLimitVar >= 0) | Strength.STRONG;
		//var c2:Constraint = (outerVLimitVar <= 1) | strengthHigh; // need because of rounding error if multiple childs!
		solver.addConstraint(c1);
		//solver.addConstraint(c2);
	}
	
	public static inline function outerHSpan(solver:Solver, outerHSpanVar:Variable, parent_width:Expression, limitMax:Int, sumWeight:Float) {
		//var c1:Constraint = (outerHSpanVar >= 0) | strengthHigh; // <-
		var c1:Constraint = (outerHSpanVar >= 0) | Strength.STRONG; // <-
		// TODO: maybe optimizing later here (if parent_width is _const or sumWeight is 1)
		var c2:Constraint = (outerHSpanVar == (parent_width - limitMax) / sumWeight) | strengthSpan;
		solver.addConstraint(c1);
		solver.addConstraint(c2);
	}
	
	public static inline function outerVSpan(solver:Solver, outerVSpanVar:Variable, parent_height:Expression, limitMax:Int, sumWeight:Float) {
		//var c1:Constraint = (outerVSpanVar >= 0) | strengthHigh;
		var c1:Constraint = (outerVSpanVar >= 0) | Strength.STRONG;
		var c2:Constraint = (outerVSpanVar == (parent_height - limitMax) / sumWeight) | strengthSpan;
		solver.addConstraint(c1);
		solver.addConstraint(c2);
	}
		
	// -------------------------------------------------------------------------	
	
	public static inline function innerHOversize(solver:Solver, innerHOversizeVar:Variable, innerHOversizeWeight:Float) {
		var c1:Constraint = (innerHOversizeVar >= 0 ) | strengthHigh;	
		//var c2:Constraint = (innerHOversizeVar <= childsHMin - hSize.middle._min) | strengthHigh;				
		var c3:Constraint = (innerHOversizeVar == 0) | Strength.create(0, innerHOversizeWeight, 0);
		solver.addConstraint(c1);
		//solver.addConstraint(c2);
		solver.addConstraint(c3);
	}
	
	public static inline function innerVOversize(solver:Solver, innerVOversizeVar:Variable, innerVOversizeWeight:Float) {
		var c1:Constraint = (innerVOversizeVar >= 0 ) | strengthHigh;	
		//var c2:Constraint = (innerVOversizeVar <= childsVMin - vSize.middle._min) | strengthHigh;				
		var c3:Constraint = (innerVOversizeVar == 0) | Strength.create(0, innerVOversizeWeight, 0);
		solver.addConstraint(c1);
		//solver.addConstraint(c2);
		solver.addConstraint(c3);
	}
		
	public static inline function outerHOversize(solver:Solver, outerHOversizeVar:Variable, outerHOversizeWeight:Float) {
		var c1:Constraint = (outerHOversizeVar >= 0 ) | strengthHigh;	
		//var c2:Constraint = (outerHOversizeVar <= hSize.getLimitMin() - parent.hSize.middle._min) | strengthHigh;				
		var c3:Constraint = (outerHOversizeVar == 0) | Strength.create(0, outerHOversizeWeight, 0);
		solver.addConstraint(c1);
		//solver.addConstraint(c2);
		solver.addConstraint(c3);
	}
	
	public static inline function outerVOversize(solver:Solver, outerVOversizeVar:Variable, outerVOversizeWeight:Float) {
		var c1:Constraint = (outerVOversizeVar >= 0 ) | strengthHigh;	
		//var c2:Constraint = (outerVOversizeVar <= vSize.getLimitMin() - parent.vSize.middle._min) | strengthHigh;				
		var c3:Constraint = (outerVOversizeVar == 0) | Strength.create(0, outerVOversizeWeight, 0);
		solver.addConstraint(c1);
		//solver.addConstraint(c2);
		solver.addConstraint(c3);
	}
	
}