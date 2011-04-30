package com.swfdiy.data.ABC
{
	import com.swfdiy.data.helper.IndexMap;

	public class MTypeName
	{
		public var name:int;
		public var types:Array;
		public function MTypeName(_name:int, _types:Array)
		{
			name = _name;
			types = _types;
		}
		
		public function fullNameStr():String {
			return  nameStr();
		}
		
		public function nameStr() :String {
			return Global.STRING(name);
		}
		
		public function dump(pre:String = "", indent:String="    ") :String {	
			var str:String = "";
			str += pre + ",name=" + nameStr(); 
			return str;
		}
		
		public function updateIndex(map:IndexMap):void {
			name = map.stringsMap[name];
			//I am not sure about the types, I didn't get any docs about it. 
			//TBD..
			
			
		}
		
	}
}