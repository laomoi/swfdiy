package com.swfdiy.data.ABC
{
	import com.swfdiy.data.ABCStream;
	public class ScriptInfo
	{
		public var init:int;
		public var trait_count:int;
		public var traits:Array;
		public function ScriptInfo(stream:ABCStream)
		{
			var i:int;
			init = stream.read_u32();
			
			trait_count = stream.read_u32();
			traits = [];
			for (i=0;i<trait_count;i++) {
				traits[i] = new Trait(stream);
			}
		}
		
		public function dump(pre:String = "", indent:String="    ") :String {
			var str:String = "";
			
			str += pre + "init:"  + init  + "\n";
			
			
			str += pre + "trait_count:"  + trait_count  + "\n";
			var i:int;
			for (i=0;i<trait_count;i++) {				
				str += traits[i].dump(pre +indent, indent) + "\n";
			}
			
			return str;
		}
	}
}