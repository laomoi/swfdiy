package com.swfdiy.data.ABC
{
	import com.swfdiy.data.ABC.Global;
	public class MMultiname
	{
		public var name:int;
		public var ns_set:int;
		
		public function MMultiname(_name:int, _ns_set:int) {
			
			name = _name;
			ns_set = _ns_set;
		}
		
		
		public function nameStr() :String {
			return Global.STRING(name);
		}
		
		public function nsStr() :String {
			//ns set cannot be zero

			
			return (ns_set  &&  Global.abc.constant_pool.ns_sets[ns_set])?  Global.abc.constant_pool.ns_sets[ns_set].nameStrList().join("|") :"*";
		}
		
		public function fullNameStr():String {
			return nsStr() + "::" + nameStr();
		}
		
		public function dump(pre:String = "", indent:String="    ") :String {	
			var str:String = "";
			str += pre + "ns=" + nsStr() + ","; 
				
			str += "name=" + nameStr(); 
			return str;
		}
	}
}