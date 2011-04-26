/*
 *  from www.swfdiy.com
 *  the Deserializer and Serializer copy many code snippets from phpAFM.
 *  thanks to phpAMF
 *  
*/
package com.swfdiy.io
{
	import flash.utils.ByteArray;
	import flash.net.ObjectEncoding;
	public class AMFDeserializer
	{
		private var _raw:ByteArray;
		private var _version:uint;
		private var _headerCount:uint;
		private var _bodyCount:uint;
		
		private var _bodyList:Array = [];
		private var _headerList:Array = [];
		
		private var storedStrings:Array =[] ;
		private var storedObjects:Array =[] ;
		private var storedDefinitions:Array =[] ;
		private var amf0storedObjects:Array =[];
		
		
		public function AMFDeserializer(raw:ByteArray)
		{
			_raw = raw;
			
			_parse();
		}
		
		public function get version():uint {
			return _version;
		}
		
		private function _parse():void {
			_version = _raw.readShort();
			_headerCount = _raw.readShort();
		
			var i:int;
			
			_headerList =[];
			for (i=0;i<_headerCount;i++) {
				_readHeader();
			}
		
			_bodyList = [];
			storedStrings = [];
			storedDefinitions = [];
			storedObjects = [];
			amf0storedObjects = [];
			
			_bodyCount = _raw.readShort();
			for (i=0;i<_bodyCount;i++) {
				_readBody();
			}
		}
		
		//I am NOT sure the _readHeader is correct or not, no enough AMF data for testing
		private function _readHeader():void {
			var name:String = _raw.readUTF();
			var understand:uint = _raw.readUnsignedByte();
			var headerLen:uint = _raw.readInt();
		
			//var headerData:ByteArray = new ByteArray;
			//_raw.readUnsignedBytes(headerData, 0 , headerLen);
			
			
			var type:uint = _raw.readUnsignedByte();	
			_headerList.push({value:_readData(type), type:type, name:name, understand:understand, headerLen:headerLen});
			
		}
		private function _readData(type:uint):* {
			var i:int;
			var data:*;
			var val:*;
			var key:*;
			var t:uint;
			switch (type) {
				case 0: // number
					data =_raw.readDouble();
					break;
				case 1: // boolean
					data =_raw.readUnsignedByte() == 1;
					break;
				case 2: // string
					data =_raw.readUTF();
					break;
				case 3: // AMF0 object Object
					var oldEncoding:unit = _raw.objectEncoding;
					_raw.position -=1;
					_raw.objectEncoding = ObjectEncoding.AMF0;
					data =_raw.readObject();
					_raw.objectEncoding = oldEncoding;
					amf0storedObjects.push(data);
					break;
				case 5: // null
					data = null;
					break;
				case 6: // undefined
					data = null;
					break;
				case 7: // Circular references are returned here
					var refIndex:uint = _raw.readShort();
					data = amf0storedObjects[refIndex];
					break;
				case 8: // mixed array with numeric and string keys
					key = _raw.readUTF();
					data = new Object();
					for (t = _raw.readUnsignedByte();t!=9;t=_raw.readUnsignedByte()) {
						val = _readData(t);
						if (!isNaN(Number(key)) ) {
							data[Number(key)] = val;
						} else {
							data[key] = val;
						}
						
					}
					
					amf0storedObjects.push(data);
					break;
				case 10: // array
					data = [];
					var arrayCount:uint = _raw.readInt();
					for (i=0;i<arrayCount;i++) {
						var _t:uint = _raw.readUnsignedByte();
						var tmpData:* = _readData(_t);
						data.push(tmpData);
					} 
					amf0storedObjects.push(data);
					break;
				case 11: // date
					var ms:Number = _raw.readDouble();
					var tz:uint = _raw.readShort();
					if (tz > 720) {
						tz = -(65535 - tz)
					}
					tz *= -60;
					//...tz..
					
					data = ms;
					break;
				case 12: // string, strlen(string) > 2^16
					var strLen:uint = _raw.readInt();
					data = _raw.readUTFBytes(strLen);
					break;
				case 13: // mainly internal AS objects
					data = null;
					break;
				case 15: // XML
					//same to read long utf string
					data = _readData(12);
					break;
				case 16: // Custom Class
					var typeIdentifier:String = _raw.readUTF();
					typeIdentifier = typeIdentifier.replace(/\.\./g,'');
					
					var obj:Object = mapClass(typeIdentifier);
					var isObject:Boolean = true;
					if(obj == null)
					{
						obj = {};
						isObject = false;
					}
					amf0storedObjects.push(obj);
					key = _raw.readUTF(); // grab the key
					
					
					for (t = _raw.readUnsignedByte();t!=9;t=_raw.readUnsignedByte()) {
						val = _readData(t); // grab the value
						if(isObject)
						{
							obj.key = val; // save the name alue pair in the array
						}
						else
						{
							obj[key] = val; // save the name alue pair in the array
						}
						key = _raw.readUTF();  // get the next name
					}
					
					if(!isObject)
					{
						obj['_explicitType'] = typeIdentifier;
					}
					data = obj;		
					amf0storedObjects.push(data);
					break;
				case 17: //AMF3-specific
					data = _readAmf3Data();
					break;
				default: // unknown case
					
					break;
			} 
			return data;
		}
		
		private function _readBody():void {
			var target:String = _raw.readUTF();
			var responder:String = _raw.readUTF();
			var bodyLen:uint = _raw.readInt();
			if (bodyLen != -1 && bodyLen > 	_raw.bytesAvailable) {
				//not long enough
				trace("not long enough");
				throw new Error("not long enough");
				return;
			}		
			var type:uint = _raw.readUnsignedByte();	
			var data:* = _readData(type);
			_bodyList.push({ responseURI: target, responseTarget: responder, value:data });
		}
		
		public function get bodyList():Array {
			return _bodyList;
		}
		public function get headerList():Array {
			return _headerList;
		}
		
		/********************************************************************************
		 *                       This is the AMF3 specific stuff
		 ********************************************************************************/
		private function _readAmf3Data():*	{
			var type:uint = _raw.readUnsignedByte();
			switch(type)
			{
				case 0x00 : return null; //undefined
				case 0x01 : return null; //null
				case 0x02 : return false; //boolean false
				case 0x03 : return true;  //boolean true
				case 0x04 : return _readAmf3Int();
				case 0x05 : return _raw.readDouble();
				case 0x06 : return _readAmf3String();
				case 0x07 : return _readAmf3XmlString();
				case 0x08 : return _readAmf3Date();
				case 0x09 : return _readAmf3Array();
				case 0x0A : return _readAmf3Object();
				case 0x0B : return _readAmf3XmlString();
				case 0x0C : return _readAmf3ByteArray();
				default: 
					//error
					
			}
			return null;
		}
		
		/// <summary>
		/// Handle decoding of the variable-length representation
		/// which gives seven bits of value per serialized byte by using the high-order bit 
		/// of each byte as a continuation flag.
		/// </summary>
		/// <returns></returns>
		private function _readAmf3Int():uint
		{
			var interger:uint = _raw.readUnsignedByte();
			if(interger < 128)
				return interger;
			else
			{
				interger = (interger & 0x7f) << 7;
				var tmp:uint = _raw.readUnsignedByte();
				if(tmp < 128)
				{
					return interger | tmp;
				}
				else
				{
					interger = (interger | (tmp & 0x7f)) << 7;
					tmp = _raw.readUnsignedByte();
					if(tmp < 128)
					{
						return interger | tmp;
					}
					else
					{
						interger = (interger | (tmp & 0x7f)) << 8;
						tmp = _raw.readUnsignedByte();
						interger |= tmp;
						
						// Check if the integer should be negative
						if ((interger & 0x10000000) != 0) {
							// and extend the sign bit
							interger |= 0xe0000000;
						}
						return interger;
					}
				}
			}
		}
		
		private function _readAmf3Date():* 
		{
			var dateref:uint = _readAmf3Int();
			if ((dateref & 0x01) == 0) {
				dateref = dateref >> 1;
				if (dateref>= storedObjects.length) {
					//Undefined date reference
					return false;
				}
				return storedObjects[dateref];
			}
			//timeOffset = (dateref >> 1) * 6000 * -1;
			var ms:Number = _raw.readDouble();
			storedObjects.push(ms);
			return ms;
		}
		
		/**
		 * readString 
		 * 
		 * @return string 
		 */
		private function _readAmf3String():String {
			
			var strref:uint = _readAmf3Int();
			
			if ((strref & 0x01) == 0) {
				strref = strref >> 1;
				if (strref >= storedStrings.length) {
					//Undefined string reference
					return "";
				}
				return storedStrings[strref];
			} else {
				var strlen:uint = strref >> 1; 
				var str:String = "";
				if (strlen > 0) 
				{
					str = _raw.readUTFBytes(strlen);
					storedStrings.push(str);
				}
				return str;
			}
			
		}
		
		private function _readAmf3XmlString():String
		{
			var handle:uint = _readAmf3Int();
			var inline:Boolean = ((handle & 1) != 0 ); 
			handle = handle >> 1;
			var xml:String;
			if( inline )
			{
				xml = _raw.readUTFBytes(handle);
				storedStrings.push(xml);
			}
			else
			{
				xml = storedObjects[handle];
			}
			return xml;
		}
		
		private function _readAmf3ByteArray():ByteArray
		{
			var handle:uint = _readAmf3Int();
			var inline:Boolean = ((handle & 1) != 0 ); 
			handle = handle >> 1;
			var ba :ByteArray;
			if( inline )
			{
				ba = new ByteArray();
				_raw.readBytes(ba,0,handle);			
				storedObjects.push(ba);
			}
			else
			{
				ba = storedObjects[handle];
			}
			return ba;
		}
		
		private function _readAmf3Array():Object
		{
			var handle:uint = _readAmf3Int();
			var inline:Boolean = ((handle & 1) != 0 ); 
			handle = handle >> 1;
			if( inline )
			{
				var hashtable: Object = {};
				storedObjects.push(hashtable);
				var key:String = _readAmf3String();
				while( key != "" )
				{
					var value:* = _readAmf3Data();
					hashtable[key] = value;
					key = _readAmf3String();
				}
				var i:int;
				for(i = 0; i < handle; i++)
				{
					//Grab the type for each element.
					value = _readAmf3Data();
					hashtable[i] = value;
				}
				return hashtable;
			}
			else
			{
				return storedObjects[handle];
			}
		}
		
		private function _readAmf3Object():Object
		{
			var handle:uint = _readAmf3Int();
			//trace("handle=" + handle);
			var inline:Boolean = ((handle & 1) != 0 ); 
			handle = handle >> 1;
			var classDefinition:Object;
			if( inline )
			{	
				//an inline object
				var inlineClassDef:Boolean = ((handle & 1) != 0 );handle = handle >> 1;
				if( inlineClassDef )
				{
					//inline class-def
					var typeIdentifier:String  = _readAmf3String();
					//trace("typeIdentifier=" + typeIdentifier);
					var typedObject:Boolean = !(typeIdentifier == null) && typeIdentifier != "";
					//trace("typedObject=" + typedObject);
					//flags that identify the way the object is serialized/deserialized
					//trace("now handle=" + handle);
					var externalizable:Boolean = ((handle & 1) != 0 );
					
					handle = handle >> 1;
					//trace("externalizable=" + externalizable);
					var dynamic :Boolean= ((handle & 1) != 0 );handle = handle >> 1;
					var classMemberCount:int = handle;
					
					var classMemberDefinitions:Array = [];
					var i:int;
					for(i = 0; i < classMemberCount; i++)
					{
						classMemberDefinitions.push(_readAmf3String());
					}
					//string mappedTypeName = typeIdentifier;
					//if( applicationContext != null )
					//	mappedTypeName = applicationContext.GetMappedTypeName(typeIdentifier);
					
					classDefinition = {
							"type" : typeIdentifier, 
							"members" : classMemberDefinitions,
							"externalizable" : externalizable, 
							"dynamic" : dynamic
					}; 
					storedDefinitions.push(classDefinition);
				}
				else
				{
					//a reference to a previously passed class-def
					classDefinition = storedDefinitions[handle];
				}
			}
			else
			{
				//an object reference
				return storedObjects[handle];
			}		
			
			var type:* = classDefinition['type'];
			var obj:Object = mapClass(type);
			
			var isObject:Boolean = true;
			if(obj == null)
			{
				obj = {};
				isObject = false;
			}
			
			//Add to references as circular references may search for this object
			storedObjects.push(obj);
			
			if( classDefinition['externalizable'] )
			{
				if(type == 'flex.messaging.io.ArrayCollection')
				{
					obj = _readAmf3Data();
				}
				else if(type == 'flex.messaging.io.ObjectProxy')
				{
					obj = _readAmf3Data();
				}
				else
				{
					//"Unable to read externalizable data type "
					trace("extend error");
					//return null;
				}
			}
			else
			{
				var members:Array = classDefinition['members'];
				var memberCount:int = members.length;
				var key:*;
				var val:* ;
				for(i = 0; i < memberCount; i++)
				{
					val = _readAmf3Data();
					key = members[i];
					if(isObject)
					{
						obj.key = val;
					}
					else
					{
						obj[key] = val;
					}
				}
				
				if(classDefinition['dynamic'])
				{
					key = _readAmf3String();
					while( key != "" )
					{
						val = _readAmf3Data();
						if(isObject)
						{
							obj.key = val;
						}
						else
						{
							obj[key] = val;
						}
						key = _readAmf3String();
					}
				}
				
				if(type != '' && !isObject)
				{
					obj['_explicitType'] = type;
				}
			}
			
			if(isObject && obj["init"])
			{
				obj["init"].call();
			}
			
			return obj;
			
		}
		
		private function mapClass(typeIdentifier:String):* {
		
			//Check out if class exists
			if(typeIdentifier == "")
			{
				return null;
			}
			/*
			$clazz = NULL;
			$mappedClass = str_replace('.', '/', $typeIdentifier);
			
			if($typeIdentifier == "flex.messaging.messages.CommandMessage")
			{
				return new CommandMessage();
			}
			if($typeIdentifier == "flex.messaging.messages.RemotingMessage")
			{
				return new RemotingMessage();
			}
			
			if(isset($GLOBALS['amfphp']['incomingClassMappings'][$typeIdentifier]))
			{
				$mappedClass = str_replace('.', '/', $GLOBALS['amfphp']['incomingClassMappings'][$typeIdentifier]);
			}
			
			$include = FALSE;
			if(file_exists($GLOBALS['amfphp']['customMappingsPath'] . $mappedClass . '.php'))
			{
				$include = $GLOBALS['amfphp']['customMappingsPath'] . $mappedClass . '.php';
			}
			elseif(file_exists($GLOBALS['amfphp']['customMappingsPath'] . $mappedClass . '.class.php'))
			{
				$include = $GLOBALS['amfphp']['customMappingsPath'] . $mappedClass . '.class.php';
			}
			
			if($include !== FALSE)
			{
				include_once($include);
				$lastPlace = strrpos('/' . $mappedClass, '/');
				$classname = substr($mappedClass, $lastPlace);
				if(class_exists($classname))
				{
					$clazz = new $classname;
				}
			}
			
			return $clazz; // return the object
			*/
			return null;
		}

		
	}
}