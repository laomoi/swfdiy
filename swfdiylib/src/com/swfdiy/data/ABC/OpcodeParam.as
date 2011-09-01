package com.swfdiy.data.ABC
{
	public class OpcodeParam
	{
		public var type:String;
		public var indexType:String;
		public var val:*;
		public var extra:Object;
		public function OpcodeParam(_type:String, _val:*, _indexType:String="", _extra:Object=null) {
			type = _type;
			val = _val;
			indexType = _indexType;
			extra = _extra;
		}
	}
}