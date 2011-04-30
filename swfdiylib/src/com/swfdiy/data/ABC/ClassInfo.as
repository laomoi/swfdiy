package com.swfdiy.data.ABC
{
	import com.swfdiy.data.ABC.Constant;
	import com.swfdiy.data.ABC.Trait;
	import com.swfdiy.data.ABCStream;
	import com.swfdiy.data.helper.IndexMap;

	public class ClassInfo
	{
		public var cinit:int;
		public var trait_count:int;
		public var traits:Array;
		
		
		public function ClassInfo(stream:ABCStream)
		{
			var i:int;
			cinit = stream.read_u32();
						
			trait_count = stream.read_u32();
			traits = [];
			for (i=0;i<trait_count;i++) {
				traits[i] = new Trait(stream);
			}
			
		}
		
		public function dumpRawData(_newStream:ABCStream):void {
			var i:int;
			_newStream.write_u32(cinit);
			_newStream.write_u32(trait_count);
		
			for (i=0;i<trait_count;i++) {
				traits[i].dumpRawData(_newStream);
			}
		}
		
		
		public function dump(pre:String = "", indent:String="    ") :String {
			var str:String = "";
			
			str += pre + "cinit:"  + cinit  + "\n";
		
			
			str += pre + "trait_count:"  + trait_count  + "\n";
			var i:int;
			for (i=0;i<trait_count;i++) {				
				str += traits[i].dump(pre +indent, indent) + "\n";
			}
			
			return str;
		}
		
		public function updateIndex(map:IndexMap):void {
			cinit =map.methodsMap[cinit];
			
			var i:int;
			for (i=0;i<trait_count;i++) {				
				traits[i].updateIndex(map);
			}
		}
	}
}