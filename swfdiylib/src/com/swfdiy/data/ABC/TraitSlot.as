package com.swfdiy.data.ABC
{
	import com.swfdiy.data.ABC.Global;
	public class TraitSlot
	{
		public var slot_id:int;
		public var type_name:int;
		public var vindex:int;
		public var vkind:int;
		
		
		
		
		public function TraitSlot(_slot_id:int, _type_name:int, _vindex:int, _vkind:int)
		{
			slot_id = _slot_id;
			type_name = _type_name;
			vindex = _vindex;
			vkind = _vkind;
		}
		
		
		public function toString():String {
			return "slot_id=" + slot_id + ",type_name="  + Global.MULTINAME(type_name) + ",vindex=" + vindex + ",vkind=" + vkind;
		}
	}
}