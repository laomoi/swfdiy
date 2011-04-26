package com.swfdiy
{
	import com.swfdiy.io.AMFDeserializer;
	import com.swfdiy.io.AMFSerializer;
	
	import flash.utils.ByteArray;
	public class AMFObject
	{
		private var _raw:ByteArray;
		private var _version:uint;
		private var _bodyList:Array ;
		private var _headerList:Array ;
		
		public function AMFObject()
		{
			_version = 3;//default
			_bodyList = [];
			_headerList = [];
		}
		
		public function get version():uint {
			return _version;
		}
		
		public function set raw(data:ByteArray):void {
			_raw = data;
			var deserializer:AMFDeserializer = new AMFDeserializer(_raw);
			_version = deserializer.version;
			_bodyList = deserializer.bodyList;
			_headerList = deserializer.headerList;
		}
		
		public function get bodyList():Array {
			return _bodyList;
		}
		
		public function get headerList():Array {
			return _headerList;
		}
		
		public function addBody(body:*):void {
			
			_bodyList.push(body);
		}
	}
}