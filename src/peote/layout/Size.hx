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
	var const = true;
	var span  = true;
	
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
	
	inline function new(min:Null<Int> = null, max:Null<Int> = null, weight:Null<Float> = null, span = true) {
		if (min != null && max != null) {
			if (min > max) {
				_min = max;
				_max = min;
			} else {
				_min = min;
				_max = max;
				const = false;
			}
		}
		else if (min != null) _min = min;
		else _max = max;
		if (weight != null) _weight = weight;
		this.span = span;
	}
	
	function addConstraints(solver:Solver, sizeVars:SizeVars, strength:Strength):SizeVars
	{
		if (!const) {
			if (sizeVars.sLimit == null) {
				sizeVars.sLimit = new Variable();
				solver.addConstraint( (sizeVars.sLimit >= 0) | strength );
			}
			sizeLimit = sizeVars.sLimit;
		}
		
		if (span) {
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
	public static inline function is (min:Null<Int> = null, max:Null<Int> = null):Size return new Limit(min, max, false);
	public static inline function min(min:Null<Int> = null, max:Null<Int> = null, weight:Null<Float> = null):Size return new Limit(min, max, weight);
	// TODO: ratio to Height?
}
