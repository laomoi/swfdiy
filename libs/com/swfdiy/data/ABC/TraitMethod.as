package com.swfdiy.data.ABC
{
	import com.swfdiy.data.ABC.Global;

	public class TraitMethod
	{
		public var disp_id:int;
		public var method:int;
		
		
		public function TraitMethod(_disp_id:int, _method:int)
		{
			
			disp_id = _disp_id;
			method = _method;
		}
		
		public function toString():String {
			return "disp_id=" + disp_id + ",method="  + Global.METHOD(method).nameStr();
		}
		
	}
}