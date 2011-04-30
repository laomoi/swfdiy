package com.swfdiy.data.ABC
{
	import com.swfdiy.data.ABC.Global;
	import com.swfdiy.data.ABCStream;
	import com.swfdiy.data.helper.IndexMap;

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
		public function dumpRawData(_newStream:ABCStream):void {
			_newStream.write_u32(name);
			_newStream.write_u32(item_count);
			for (var i:int=0;i<item_count;i++) {
				_newStream.write_u32(items[i].key);
				_newStream.write_u32(items[i].value);
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
		
		
		public function updateIndex(map:IndexMap):void {
			name =map.stringsMap[name];
			var i :int;
			for (i=0;i<item_count;i++) {
				items[i].updateIndex(map);
			}
		}
	}
}