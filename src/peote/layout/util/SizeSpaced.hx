package peote.layout.util;

import jasper.Expression;
import jasper.Solver;
import jasper.Strength;

class SizeSpaced 
{
	public var middle:Size;
	public var first:Size = null;
	public var last:Size  = null;
	
	public var size(get, never):Expression;
	inline function get_size():Expression {
		if (first==null && last==null) return middle.size;
		else if (first== null) return middle.size + last.size;
		else if (last == null) return first.size + middle.size;
		else return first.size + middle.size + last.size;
	}
	
	public function new(sizeMiddle:Size, sizeFirst:Size = null, sizeLast:Size = null) {
		middle = (sizeMiddle != null) ? sizeMiddle : Size.min();
		first = sizeFirst;
		last  = sizeLast;
	}
	
	public function addConstraints(solver:Solver, sizeVars:SizeVars, strength:Strength):SizeVars {
		sizeVars = middle.addConstraints(solver, sizeVars, strength);
		if (first != null) sizeVars = first.addConstraints(solver, sizeVars, strength);
		if (last != null) sizeVars = last.addConstraints(solver, sizeVars, strength);
		return sizeVars;
	}
	
	public function getMin():Int {
		var min:Int = middle._min;
		if (first != null) min += first._min;
		if (last  != null) min += last._min;
		return min;
	}
	
	public function hasSpan():Bool {
		if (middle.span) return true;
		if (first != null) if (first.span) return true;
		if (last  != null) if (last.span) return true;
		return false;
	}
	
	public function getLimitMax():Int {
		var limitMax:Int = (middle._max != null) ? middle._max : middle._min;
		if (first != null) limitMax += (first._max != null) ? first._max : first._min;
		if (last  != null) limitMax += (last._max  != null) ? last._max : last._min;
		return limitMax;
	}
	
	public function getSumWeight():Float {
		var sumWeight:Float = (middle.sizeSpan != null) ? middle._weight : 0.0;
		if (first != null) if (first.sizeSpan != null) sumWeight += first._weight;
		if (last  != null) if (last.sizeSpan  != null) sumWeight += last._weight;
		return sumWeight;
	}
}
