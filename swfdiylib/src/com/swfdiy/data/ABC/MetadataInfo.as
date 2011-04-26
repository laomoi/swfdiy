package com.swfdiy.data.ABC
{
	import com.swfdiy.data.ABCStream;
	import com.swfdiy.data.ABC.Global;
	public class MetadataInfo
	{
		public var name:int;
		public var item_count:int;
		public var items:Array;
		public function MetadataInfo(stream:ABCStream)
		{
			name = stream.read_u32();
			item_count = stream.read_u32();
			items = [];
			for (var i:int=0;i<item_count;i++) {
				items[i] = new ItemInfo( stream.read_u32(), stream.read_u32() );
			}
		}
		
		public function dump(pre:String = "", indent:String="    ") :String {	
			//set current abc to be the global abc so that the constant pool can be referered
			
			var str:String = "";
			
			str += pre + "name:" + Global.STRING(name) + "\n";
			str += pre + "item_count:" + item_count + "\n";
			
			
			var i :int;
			for (i=0;i<item_count;i++) {
				
				str += pre + indent + items[i].toString() + "\n";
			}
			
			
			
			return str;
		}
	}
}