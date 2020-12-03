package peote.layout;

import jasper.Expression;
import jasper.Solver;
import jasper.Term;
import jasper.Variable;
import jasper.Strength;
import peote.layout.util.SizeVars;

@:allow(peote.layout)
class Limit
{
	var _const = true;
	var _span  = true;
	
	var _min:Int = 0;
	var _max:Null<Int>;
	var _weight:Float = 1.0;
	
	var size(get, never):Expression;
	function get_size():Expression {
		if (sizeLimit == null && sizeSpan == null) return new Expression([], _min); // CHECK!
		else if (sizeLimit== null) return _min + (new Term(sizeSpan) * _weight);
		else if (sizeSpan == null) return _min + (new Term(sizeLimit) * (_max - _min));
		else return _min + (new Term(sizeLimit) * (_max - _min)) + (new Term(sizeSpan) * _weight);
	}
	
	var sizeLimit:Null<Variable> = null;
	var sizeSpan:Null<Variable> = null;
	
	public function new(min:Null<Int> = null, max:Null<Int> = null, weight:Null<Float> = null, span = true) {
		if (min != null && max != null) {
			if (min > max) {
				_min = max;
				_max = min;
			} else {
				_min = min;
				_max = max;
				_const = false;
			}
		}
		else if (min != null) _min = min;
		else _max = max;
		if (weight != null) _weight = weight;
		this._span = span;
	}
	
	function addConstraints(solver:Solver, sizeVars:SizeVars, strength:Strength):SizeVars
	{
		if (!_const) {
			if (sizeVars.sLimit == null) {
				sizeVars.sLimit = new Variable();
				solver.addConstraint( (sizeVars.sLimit >= 0) | strength );
			}
			sizeLimit = sizeVars.sLimit;
		}
		
		if (_span) {
			if (sizeVars.sSpan == null) {
				sizeVars.sSpan = new Variable();
				solver.addConstraint( (sizeVars.sSpan >= 0) | strength );
			}
			sizeSpan = sizeVars.sSpan;
		}
		return sizeVars;
	}	
}

@:allow(peote.layout)
@:forward
abstract Size(Limit) from Limit to Limit {
	public inline function new(width:Int) this = new Limit(width, null, false);
	@:from static inline function fromInt(i:Int):Size return new Limit(i, null, false);

	public static inline function const(size:Int):Size return new Limit(size, size, null, false);
	public static inline function max(maxSize:Int):Size return new Limit(0, maxSize, null, false);
	public static inline function limit(minSize:Int, maxSize:Int):Size return new Limit(minSize, maxSize, null, false);
	
	// span is true, so they can be scale higher (reaching its min and relative max-value at the same time in a row)
	public static inline function min(minSize:Int = 0):Size return new Limit(minSize, null, null, true);
	public static inline function span(minSize:Null<Int> = null, relativeMaxSize:Null<Int> = null, relativeWeight:Null<Float> = null):Size
		return new Limit(minSize, relativeMaxSize, relativeWeight, true);

	
	// TODO: ratio to Height?
}
