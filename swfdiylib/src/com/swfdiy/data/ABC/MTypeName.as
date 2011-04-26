package com.swfdiy.data.ABC
{
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
		
	}
}