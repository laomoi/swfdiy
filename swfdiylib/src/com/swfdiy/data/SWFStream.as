package com.swfdiy.data
{
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	public class SWFStream 
	{
		private var _data:ByteArray;
		private var _cacheByte:int;
		private var _cacheByteUsedBits:int;
		
		public function SWFStream(data:ByteArray) : void
		{
			_data = data;	
			_data.endian  = Endian.LITTLE_ENDIAN;
			_cacheByteUsedBits = 8;
			_cacheByte = 0;
		}
		
		public function get_bytes(start_pos:int, end_pos:int):ByteArray {
			var bytes:ByteArray = new ByteArray;
			bytes.writeBytes(_data, start_pos, end_pos - start_pos);
			return bytes;
		}
		
		
		
		public function read_bytes(len:int=0):SWFStream {
			
			var dest:ByteArray = new ByteArray();
			dest.endian = Endian.LITTLE_ENDIAN;
			if (len ==0) {
				return new SWFStream(dest);
			}
			try {
				_data.readBytes(dest,0, len); 
			} catch (e:*) {
				
				return null;
			}
			var destStream:SWFStream = new SWFStream(dest);
			return destStream;
		}
		
		public function read_UI8() : int {
			return _data.readUnsignedByte();
		}
		
		public function read_UI16() : int {
			return _data.readUnsignedShort();
		}
		
		public function read_UI32() : int {
			return _data.readUnsignedInt();
		}
		
		public function read_SI8() : int {
			return _data.readByte();
		}
		
		public function read_SI16() : int {
			return _data.readShort();
		}
		
		public function read_SI32() : int {
			return _data.readInt();
		}
		
		public function uncompress() :Boolean {
			var unData:ByteArray = new ByteArray();
			unData.endian = Endian.LITTLE_ENDIAN;
			_data.position = 8;		
			_data.readBytes(unData);
			
			unData.uncompress();
			_data.position = 8;	
			_data.writeBytes(unData);
			
			return true;
		}
		
		public function set pos(p:int): void {
			_data.position = p;
		}
		
		public function get pos(): int {
			return _data.position;
		}
		public function get length(): int {
			return _data.length;
		}
		
		public function get bytesAvailable() :int {
			return _data.bytesAvailable;
		}
		
		public function get rawdata():ByteArray {
			return _data;
		}
		
		private function _get_mask(bit_start:int):int {
			var mask:int = 0;
			if (bit_start == 0) {
				mask = 0x80;
			} else if (bit_start == 1) {
				mask = 0x40;
			}else if (bit_start == 2) {
				mask = 0x20;
			}else if (bit_start == 3) {
				mask = 0x10;
			}else if (bit_start == 4) {
				mask = 0x08;
			}else if (bit_start == 5) {
				mask = 0x04;
			}else if (bit_start == 6) {
				mask = 0x02;
			}else if (bit_start == 7) {
				mask = 0x01;
			}
			return mask;
		} 
		
		private function _get_short_mask(bit_start:int):int {
			var mask:int = 0;	
			if (bit_start == 0) {
				mask = 0x8000;
			} else if (bit_start == 1) {
				mask = 0x4000;
			}else if (bit_start == 2) {
				mask = 0x2000;
			}else if (bit_start == 3) {
				mask = 0x1000;
			}else if (bit_start == 4) {
				mask = 0x0800;
			}else if (bit_start == 5) {
				mask = 0x0400;
			}else if (bit_start == 6) {
				mask = 0x0200;
			}else if (bit_start == 7) {
				mask = 0x0100;
			} else if (bit_start == 8) {
				mask = 0x0080;
			} else if (bit_start == 9) {
				mask = 0x0040;
			}else if (bit_start == 10) {
				mask = 0x0020;
			}else if (bit_start == 11) {
				mask = 0x0010;
			}else if (bit_start == 12) {
				mask = 0x0008;
			}else if (bit_start == 13) {
				mask = 0x0004;
			}else if (bit_start == 14) {
				mask = 0x0002;
			}else if (bit_start == 15) {
				mask = 0x0001;
			}
			return mask;
		} 
		
		
		public function read_bits(  nbits:int):int {
			//private var _cacheByte:int;
			//private var _cacheByteUsedBits:int;
			
			//read from pre bits
			var readingBits:Array = new Array();
			//int real_use = 0;
			var nbits_left:int = nbits;
			
			var i:int;
			var j:int;
			var k:int;
			var mask:int;
			var bytes_tmp:Array ;
			
			if (_cacheByteUsedBits < 8) {
				var nbits_cache_left :int  = 8 - _cacheByteUsedBits;
				var should_read:int = nbits_left;
				if (should_read > nbits_cache_left) {
					should_read = nbits_cache_left;
				}
				var bit_start :int = _cacheByteUsedBits;
				for (i=0;i<should_read;i++){
					mask = _get_mask(bit_start+i);
					
					readingBits.push( _cacheByte & mask ? 1: 0);
				}
				_cacheByteUsedBits += should_read;
				nbits_left -= should_read;
			}
			
			//read from bytes
			var bytes:int = int(nbits_left / 8);
			if (bytes) {
				bytes_tmp = new Array();
				for ( j=0;j<bytes;j++) {
					var b:int = _data.readByte();
					bytes_tmp.push(b);
				}
				
				for ( i=0;i<bytes;i++){
					for ( j=0;j<8;j++) {
						mask = _get_mask(j);
						readingBits.push( bytes_tmp[i] & mask ? 1: 0);
					}
				}
				nbits_left -= bytes*8;
			}
			
			if (nbits_left) {
				bytes_tmp = new Array();			
				bytes_tmp.push(_data.readByte());
				
				_cacheByteUsedBits= 0;
				_cacheByte = bytes_tmp[0];
				
				for ( j=0;j<nbits_left;j++) {
					mask = _get_mask(j);
					readingBits.push( _cacheByte & mask ? 1: 0);
					_cacheByteUsedBits++;
				}
				
				nbits_left = 0;
			}
			//finish
			var result:int = 0;
			for ( i=nbits-1;i>=0;i--) {
				if (readingBits[i]) {
					//1
					result |= _get_short_mask(15 - (nbits -1 -i));
				} else {
					//0
					
				}
			}
			
			return result;	
		}
		
		
		public function read_string():String {
			//find the string len at first
			var oldPos:int = _data.position;
			var len:int = 0;
			var finded:Boolean = false;
			while (_data.position < _data.length) {
				
				var val:int = _data.readByte();
				len++;
				if (val == 0) {
					finded = true;
					break;
				}
			}
			
			if (!finded) {
				//error....
				
				return "";
			} else {
				_data.position = oldPos;
				var str:String = _data.readUTFBytes(len-1);
				_data.readByte();
				return str;
			}
			
		}
		
	}
}