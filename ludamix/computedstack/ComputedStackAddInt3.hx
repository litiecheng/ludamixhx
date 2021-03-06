package ludamix.computedstack;
import ludamix.GrowVector3;
import haxe.ds.Vector;

class ComputedStackAddInt3 {
	
	// with "add" we emit the sum of the stack and push a default
	
	public var d = new GrowVector3<Int>(3);
	
	public var dirty : Bool = true;
	public var computed = new Vector<Int>(3);
	public var default_data = new Vector<Int>(3);
	
	public var i : Int = -1;
	
	public function new() {
	}
	
	public inline function push() {
		d.push(default_data[0], default_data[1], default_data[2]);
		i += 1;
		dirty = true;
	}
	
	public inline function pop() {
		if (i < 0) throw "ComputedStackAdd: stack underflow";
		d.l -= 1;
		i -= 1;
		dirty = true;
	}
	
	public inline function set(v0, v1, v2) {
		d.set(i, v0, v1, v2); dirty = true;
	}
	public inline function setidx(idx, v) {
		d.setidx(i, idx, v); dirty = true;
	}
	public inline function recompute() {
		computed[0] = d.get(0, 0);
		computed[1] = d.get(0, 1);
		computed[2] = d.get(0, 2);
		for (n in 1...(i+1)) {
			computed[0] += d.get(n, 0);
			computed[1] += d.get(n, 1);
			computed[2] += d.get(n, 2);
		}
		dirty = false;
	}
	public inline function emit(buf : GrowVector3<Int>) {
		if (dirty) recompute();
		buf.push(computed[0], computed[1], computed[2]);		
	}
	
}