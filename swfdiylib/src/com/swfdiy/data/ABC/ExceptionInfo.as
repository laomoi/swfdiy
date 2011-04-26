package com.swfdiy.data.ABC
{
	public class ExceptionInfo
	{
		public var from:int;
		public var to:int;
		public var target:int;
		public var exc_type:int;
		public var var_name:int;
		public function ExceptionInfo(_from:int, _to:int, _target:int, _exc_type:int, _var_name:int)
		{
			from = _from;
			to = _to;
			target = _target;
			exc_type = _exc_type;
			var_name = _var_name;
		}
		
		
		public function toString():String {
			return "from:" + from + ",to=" + to  + ",target=" + target  + ",exc_type=" + exc_type + ",var_name=" + var_name;
		}
	}
}