package com.swfdiy.data.ABC
{
	import com.swfdiy.data.ABC.Global;
	import com.swfdiy.data.helper.IndexMap;

	public class MMultiname
	{
		public var name:int;
		public var ns_set:int;
		

		public function MMultiname( _ns_set:int, _name:int) {
			ns_set = _ns_set;
			name = _name;
		}
		
		
		public function nameStr() :String {
			return Global.STRING(name);
		}
		
		public function nsStr() :String {
			//ns set cannot be zero

			
			return (ns_set  &&  Global.abc.constant_pool.ns_sets[ns_set])?  Global.abc.constant_pool.ns_sets[ns_set].nameStrList().join("|") :"*";
		}
		
		public function fullNameStr():String {
			return  nsStr() + "::" + nameStr();
		}
		

		
		public function dump(pre:String = "", indent:String="    ") :String {	
			var str:String = "";
			str += pre + "ns=" + ns_set + "," + nsStr() + ","; 
				
			str += "name=" +name + ","+ nameStr(); 
			return str;
		}
		
		public function updateIndex(map:IndexMap):void {
			name = map.stringsMap[name];
			ns_set = map.ns_setsMap[ns_set];
			
		}
	}
}