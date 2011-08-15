package com.swfdiy.data
{
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	

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
		
		public function tagData():ByteArray {
			var len:int = this.length;
			var ba:ByteArray = new ByteArray();
			ba.endian = Endian.LITTLE_ENDIAN;
			var s:int = ( _id <<6 ) & 0xffff;
			if (len < 63) {
				s = s | len;
				ba.writeShort(s);
			} else {
				s = s | 0x3f;
				ba.writeShort(s);
				
				//more SI32 LEN
				ba.writeInt(len);
			}
			ba.writeBytes(_stream.rawdata,0);
			return ba;
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