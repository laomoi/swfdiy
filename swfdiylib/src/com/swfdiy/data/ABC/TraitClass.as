package com.swfdiy.data.ABC
{
	import com.swfdiy.data.ABC.Global;

	public class TraitClass
	{
		public var slot_id:int;
		public var classi:int;
		public function TraitClass(_slot_id:int, _classi:int)
		{
			slot_id = _slot_id;
			classi = _classi;
		}
		public function toString():String {
			return "slot_id=" + slot_id + ",class="  + classi;
		}
	}
}