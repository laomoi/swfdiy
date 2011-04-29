package com.swfdiy.data.ABC
{
	public class RTQName
	{
		public var name:int;
		public function RTQName(_name:int) {
			
			name = _name;
		}
		
		
		public function nameStr() :String {
			return Global.STRING(name);
		}
		
		public function fullNameStr():String {
			return nameStr();
		}
		

		
		public function dump(pre:String = "", indent:String="    ") :String {	
			var str:String = "";
			str += "name=" + nameStr(); 
			return str;
		}
	}
}