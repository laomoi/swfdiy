package com.swfdiy.data.ABC
{
	import com.swfdiy.data.ABC.Global;
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
	}
}