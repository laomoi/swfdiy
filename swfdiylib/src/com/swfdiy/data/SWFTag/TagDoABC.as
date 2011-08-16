package com.swfdiy.data.SWFTag
{
	import com.swfdiy.data.ABC;
	import com.swfdiy.data.ABCStream;
	import com.swfdiy.data.SWFStream;
	import com.swfdiy.data.SWFTag;
	
	import flash.utils.ByteArray;

	public class TagDoABC extends SWFTag
	{
		static public var ID:int = 82;
		
		
		private var _Flags:int;
		private var _Name :String;
		private var _abc:ABC;
		
		private var _data_start_pos:int;
		override public function set data(byteStream:SWFStream):void {
			_stream = byteStream;
			_stream.pos = 0;
			
			_Flags = _stream.read_UI32();
			_Name = _stream.read_string();
			
			_data_start_pos = _stream.pos;
			
			_abc = new ABC();
			var _abcStream:SWFStream = _stream.read_bytes(_stream.bytesAvailable);
			 _abc.data = new ABCStream(_abcStream.rawdata);
		}
		
		public function get Flags() :int {
			return _Flags;
		}
		
		
		public function get Name():String {
			return _Name;
		}
		
		public function abc() :ABC {
			return _abc;
		}
		
		/*public function updateAbc(abc:ABC):void {
			_abc = abc;
			_stream.pos = _data_start_pos;
			_stream.rawdata.writeBytes(abc.data.rawdata);
			
		}*/
		
		public  function refreshRawData():void
		{
			_stream.pos = _data_start_pos;
			_stream.rawdata.writeBytes(_abc.data.rawdata);
		}
		
		public function get_abc_bytes():ByteArray {
			return ABC(_abc).data.rawdata;//   _abc.data.rawdata;
		}
		
		override public function dump(pre:String = "", indent:String="    ") :String {	
			var str:String = pre + "Tag id=" + id +",len=" + length + ",DoABC" + "\n";
			str += pre + indent + "Flags=" + _Flags + "\n";
			
			str += _abc.dump(pre + indent, indent);
			
			
			return str;
		}
		
		public function TagDoABC() {
			_unknownType = false;
			_id = ID;
		}
		
		
	}
}