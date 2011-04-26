package com.swfdiy.data
{
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	

	public class SWFTag
	{
		protected var _stream:SWFStream;
		protected var _id:int;
		protected var _unknownType:Boolean = true;
		
		public function get length():int {
			return _stream.length;
		}
		
		public function get id():int
		{
			return _id;
		}
		
		public function get rawdata():ByteArray
		{
			return _stream.rawdata;
		}
		
		public function set data(byteStream:SWFStream):void {
			_stream = byteStream;
			_stream.pos = 0;
			
		}
		
		public function set id(ID:int) :void {
			_id = ID;
		}
		
		public function dump(pre:String = "", indent:String="    ") :String {
			//var file:FileReference = new FileReference();
			
			//file.save(_stream.rawdata, "some.tag");
			
			var str:String = pre + "Tag id=" + id +",len=" + length;
			
			return str;
		}
		
	}
}