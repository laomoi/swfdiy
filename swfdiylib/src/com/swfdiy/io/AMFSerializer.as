/*
*  from www.swfdiy.com
*  the Deserializer and Serializer copy many code snippets from phpAFM.
*  thanks to phpAMF
*  
*/
package com.swfdiy.io
{
	import com.swfdiy.AMFObject;
	
	import flash.net.ObjectEncoding;
	import flash.utils.ByteArray;
	public class AMFSerializer
	{
		private var _buffer:ByteArray;
		private var amf0StoredObjects :Array;
		
		public var amfEncoding:uint = ObjectEncoding.AMF3;
		
		public function AMFSerializer()
		{
		}
		public function serialize(amf:AMFObject):ByteArray {
			_buffer = new ByteArray();
			_buffer.objectEncoding = amfEncoding;
			_buffer.writeShort(amf.version);
			
			var headerCount:int = amf.headerList.length;
			var i:int;
			_buffer.writeShort(headerCount);
			
			for (i=0;i<headerCount;i++) {
				var header:Object = amf.headerList[i];
				_buffer.writeUTF(header.name);
				_buffer.writeByte(header.understand);
				_buffer.writeInt(header.headerLen);
				_writeData(header.value);
				
			}
			
			
			
			var bodyCount:int = amf.bodyList.length;
			
			_buffer.writeShort(bodyCount);
			for (i=0;i<bodyCount;i++) {
				var body:Object = amf.bodyList[i];
				_buffer.writeUTF(body.responseURI); // write the responseURI header
				_buffer.writeUTF(body.responseTarget); //  write null, haven't found another use for this
				var lenPos:int = _buffer.position;
				_buffer.writeInt(0);//this is body len, occupy 4 bytes and reset the value later
				var bodyStart:int =  _buffer.position;
				_writeData(body.value);
				
				//reset body length 
				var bodyEnd:int =  _buffer.position;
				_buffer.position = lenPos;
				_buffer.writeInt(bodyEnd - bodyStart);
				_buffer.position = bodyEnd;
			}
			return _buffer;
		}
		
		private function _writeNULL():void {
			_buffer.writeByte(5);
		}
		
		private function _writeArray(d:Array) :void {
			var count:int = d.length; // get the new count
			_buffer.writeByte(10);
			_buffer.writeInt(count);
			
			
			var i:int;
			for (i=0;i<count;i++) {
				_writeData(d[i]);
			}
			
		}
		
		private function _writeObject(d:Object):void {
			
			//_buffer.writeObject(d);
			
			//actrually we can use amf0.bytearray.writeObject
		
			_buffer.writeByte(3);
			for (var k:String in d) {
				_buffer.writeUTF(k);  // write the name of the object
				_writeData(d[k]); // write the value of the object
			}
			_buffer.writeShort(0); //  write the end object flag 0x00, 0x00, 0x09
			_buffer.writeByte(9);
			
		}
		
		private function _writeData(d:*):void {
			if (d is Number) 
			{ // double
				_buffer.writeByte(0);
				_buffer.writeDouble(d);
				return;
			} 
			else if (d is String) 
			{ // string
				_buffer.writeByte(2);
				_buffer.writeUTF(d);
				return;
			} 
			else if (d is Boolean) 
			{ // boolean
				_buffer.writeByte(1);
				_buffer.writeBoolean(d);
				return;
			} 
			else if (d == null)
			{ // null
				_writeNULL();
				return;
			} else if (amfEncoding == ObjectEncoding.AMF3)
			{
				//ok, we want to use AMF3 to reprent the object/array data
				_buffer.writeByte(0x11);
				var oldEncoding:uint = _buffer.objectEncoding;
				_buffer.objectEncoding = ObjectEncoding.AMF3;
				_buffer.writeObject(d);
				_buffer.objectEncoding = oldEncoding;
				return;
			}
			else if (d is Array) //amf0
			{ // array
				_writeArray(d);
				return;
			} 
			else if (d is Object) //amf0
			{ // array
				_writeObject(d);
				return;
			} 
			
		}
	}
}