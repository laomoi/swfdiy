package com.swfdiy.data.ABC
{
	import com.swfdiy.data.ABC.ConstantPool;
	import com.swfdiy.data.ABC.Global;
	import com.swfdiy.data.ABCStream;
	public class Multiname
	{
		public var kind:int;
		public var data:*;
		
		
	
	
		
		public function Multiname(_kind:int, _data:*) :void
		{
			kind = _kind;
			data = _data;
			
		}
		
		public function fullNameStr():String {
			if (data) {
				return data.fullNameStr();
			}
			return "";
		}
		
		
		public function dump(pre:String = "", indent:String="    ") :String {	
			var str:String = "";
			str += pre + "kind=" + kind + "," + Constant.toStr(kind) + "\n";
			if (data) {
				str += data.dump(pre, indent) + "\n";
			}
			
			return str;
		}
	}
	

	
}

