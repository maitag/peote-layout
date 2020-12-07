package peote.layout.util;

import jasper.Expression;
import jasper.Variable;

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
	
	public function setSizeLimit(sizeLimitVar:Null<Variable>):Null<Variable> {
		sizeLimitVar = middle.setSizeLimit(sizeLimitVar);
		if (first != null) sizeLimitVar = first.setSizeLimit(sizeLimitVar);
		if (last != null) sizeLimitVar = last.setSizeLimit(sizeLimitVar);
		return sizeLimitVar;
	}
	
	public function setSizeSpan(sizeSpanVar:Null<Variable>):Null<Variable> {
		sizeSpanVar = middle.setSizeSpan(sizeSpanVar);
		if (first != null) sizeSpanVar = first.setSizeSpan(sizeSpanVar);
		if (last != null) sizeSpanVar = last.setSizeSpan(sizeSpanVar);
		return sizeSpanVar;
	}
	
	public function getMin():Int {
		var min:Int = middle._min;
		if (first != null) min += first._min;
		if (last  != null) min += last._min;
		return min;
	}
	
	public function hasSpan():Bool {
		if (middle._span) return true;
		if (first != null) if (first._span) return true;
		if (last  != null) if (last._span) return true;
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
