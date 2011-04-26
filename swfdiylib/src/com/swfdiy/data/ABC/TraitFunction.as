package com.swfdiy.data.ABC
{


	import com.swfdiy.data.ABC.Global;
	public class TraitFunction
	{
		public var slot_id:int;
		public var mfunction:int;
		
		public function  TraitFunction(_slot_id:int, _mfunction:int)
		{
			
			slot_id = _slot_id;
			mfunction = _mfunction;
		}
		
		public function toString():String {
			return "slot_id=" + slot_id + ",function="  + Global.METHOD(mfunction).nameStr();
		}
		
	}
}