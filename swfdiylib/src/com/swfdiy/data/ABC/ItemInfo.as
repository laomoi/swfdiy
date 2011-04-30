package com.swfdiy.data.ABC
{
	import com.swfdiy.data.ABC.Global;
	import com.swfdiy.data.helper.IndexMap;

	public class ItemInfo
	{
		public var key:int;
		public var value:int;
		
		public function ItemInfo(_key:int, _value:int)
		{
			key = _key;
			value = _value;
		}
		
		public function toString():String {
			return (key ? Global.STRING(key):"") + Global.STRING(value);
		}
		
		public function updateIndex(map:IndexMap):void {
			key =map.stringsMap[key];
			value =map.stringsMap[value];
		}
	}
}