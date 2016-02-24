package ludamix.computedstack;
import ludamix.GrowVector4;
import haxe.ds.Vector;

class ComputedStackAddInt4 {
	
	// with "add" we emit the sum of the stack and push a default
	
	public var d = new GrowVector4<Int>(4);
	
	public var dirty : Bool = true;
	public var computed = new Vector<Int>(4);
	public var default_data = new Vector<Int>(4);
	
	public var i : Int = 0;
	
	public function new() {
	}
	
	public inline function push() {
		d.push(default_data[0], default_data[1], default_data[2], default_data[3]);
		i += 1;
	}
	
	public inline function pop() {
		if (i < 1) throw "ComputedStackAdd: stack underflow";
		d.l -= 1;
		i -= 1;
	}
	
	public inline function set(v0, v1, v2, v3) {
		d.set(i, v0, v1, v2, v3); dirty = true;
	}
	public inline function setidx(idx, v) {
		d.setidx(i, idx, v); dirty = true;
	}
	public inline function recompute() {
		computed[0] = default_data[0];
		computed[1] = default_data[1];
		computed[2] = default_data[2];
		computed[3] = default_data[3];
		for (n in 0...i) {
			computed[0] += d.get(n, 0);
			computed[1] += d.get(n, 1);
			computed[2] += d.get(n, 2);
			computed[3] += d.get(n, 3);
		}
		dirty = false;
	}
	public inline function emit(buf : GrowVector4<Int>) {
		if (dirty) recompute();
		buf.push(computed[0], computed[1], computed[2], computed[3]);		
	}
	
}
