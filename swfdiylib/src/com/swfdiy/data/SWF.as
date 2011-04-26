package com.swfdiy.data
{

	import com.swfdiy.data.SWFStream;
	import com.swfdiy.data.SWFTag.*;
	
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	public class SWF
	{
		private var _stream:SWFStream;
		
		private var _version:int;
		private var _swf_length:int;
		private var _frame_rate:int;
		private var _frames_count:int;
		
		private var _width:int;
		
		private var _height:int; 
		private var _tag_start_pos:int;
		
	
		public function SWF(data:ByteArray) : void
		{
			_stream = new SWFStream(data);
			
			_init();
			
		}
		
		private function _init():void {
			var b1:int = _stream.read_UI8();
			var b2:int = _stream.read_UI8();
			var b3:int = _stream.read_UI8();			
			
			_version = _stream.read_UI8();
			_swf_length = _stream.read_UI32();		
			
			if (b1 == 67) {
				//compressed
				this.uncompress();
			}
			
			
			_stream.pos = 8;
			
			//RECT
			var nbits:int = _stream.read_bits(5);
			//Debug.log("nbits=" + nbits);
			var xmin:int = _stream.read_bits(nbits);
			var xmax:int = _stream.read_bits(nbits);
			var ymin:int = _stream.read_bits(nbits);
			var ymax:int = _stream.read_bits(nbits);
			
			_width = (xmax - xmin) / 20;
			_height = (ymax - ymin) / 20;
			
			_frame_rate = _stream.read_UI16() / 256;
			_frames_count = _stream.read_UI16();
			
			_tag_start_pos = _stream.pos;
		}
		
		public function read_UI8() : int {
			return _stream.read_UI8();
		}
		
		public function read_UI16() : int {
			return _stream.read_UI16();
		}
		
		public function get_bytes(start_pos:int, end_pos:int):ByteArray {
			return _stream.get_bytes(start_pos, end_pos);
		}
		
		public function read_UI32() : int {
			return _stream.read_UI32();
		}
		
		public function uncompress() :Boolean {
			_stream.uncompress();
			
			return true;
		}
		
		public function startReadTags():void {
			_stream.pos = _tag_start_pos;
		}
		
		
		public function set pos(p:int): void {
			_stream.pos = p;
		}
		
		public function get pos(): int {
			return _stream.pos;
		}
		public function get length(): int {
			return _stream.length;
		}
		
		public function read_bits(nbits:int) :int {
			return _stream.read_bits(nbits);
		}
		
		public function read_tag( ): SWFTag {
			
			if (_stream.pos >= _stream.length) {
				return null;
			}			
			
			//Debug.log("pos:" + _stream.pos);		
			var tag_header:int = _stream.read_UI16();
			var type : int = tag_header >> 6;
			
			var tag_len :int = tag_header & 0x003f;
			if (tag_len  == 0x3f) {
				tag_len = _stream.read_UI32();
			}
			
			var destStream:SWFStream = _stream.read_bytes(tag_len); 
			if (destStream == null) {
				return null;
			}		
			
			var tag:SWFTag;
			if (type == TagSymbolClass.ID) {
				tag = new TagSymbolClass();
				tag.data = destStream;
			} 
			/* haven't finish function */
			else if (type == TagDoABC.ID) {
				tag = new TagDoABC();
				tag.data = destStream;
			}
			else {
				tag = new TagUnknown();
				tag.id = type;
				tag.data = destStream;
			}
			
			return tag;
		}
		
		public function make_swf_bytes_from_tags(tags:Array):ByteArray{
			var swf_bytes:ByteArray = new ByteArray;
			
			var header_bytes :ByteArray = this.get_bytes(0, _tag_start_pos);
			var tag_bytes:ByteArray = new ByteArray;
			
			for (var i:int=0;i<tags.length;i++) {
				tag_bytes.writeBytes(tags[i],0);
			}
			
			//update header length
			header_bytes[0] = 70;
			header_bytes.position = 4;
			header_bytes.endian  = Endian.LITTLE_ENDIAN;
			header_bytes.writeUnsignedInt(header_bytes.length + tag_bytes.length);
			swf_bytes.writeBytes(header_bytes,0);
			swf_bytes.writeBytes(tag_bytes,0);
			return swf_bytes;
		}
		
		public function get_uncompress_bytes():ByteArray {
			var swf_bytes:ByteArray = new ByteArray;
			
		
			//update header length
			_stream.rawdata[0] = 70;
			swf_bytes.writeBytes(_stream.rawdata,0);
			return swf_bytes;
		}
		
		public function save():void {
			var file:FileReference = new FileReference();
			//file.save(_stream., "b.txt");
		}
		
	}
}