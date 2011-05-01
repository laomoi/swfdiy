package com.swfdiy.data.ABC
{
	import com.swfdiy.data.ABC.Constant;
	import com.swfdiy.data.ABC.Global;
	import com.swfdiy.data.helper.IndexMap;

	public class MQName
	{
		public var ns:int;
		public var name:int;
		
			
		public function MQName(_ns:int, _name:int) {
			ns = _ns;
			name = _name;
		}
		
		public function nameStr() :String {
			return Global.STRING(name);
		}
		
		public function nsStr() :String {
			return ns ?  Global.NAMESPACE(ns).nameStr() :"*";
		}
		
		public function fullNameStr():String {
			return  nsStr() + "::" + nameStr();
		}
		
		
	
		public function dump(pre:String = "", indent:String="    ") :String {	
			var str:String = "";
			str += pre + "ns=" + nsStr()+ ",name=" + nameStr(); 
			return str;
		}
		
		public function updateIndex(map:IndexMap):void {
			name = map.stringsMap[name];
			ns = map.namespaceMap[ns];
		}
	}
}