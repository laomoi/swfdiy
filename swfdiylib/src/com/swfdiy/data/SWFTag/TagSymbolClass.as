package com.swfdiy.data.SWFTag
{
	import com.swfdiy.data.SWF;
	import com.swfdiy.data.SWFStream;
	import com.swfdiy.data.SWFTag;
	
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	

	 
	public class TagSymbolClass extends SWFTag
	{
		static public var ID:int = 76;
		
		
		private var _NumberSymbols:int;
		private var _asscociateSymbolList :Array;
		
		override public function set data(byteStream:SWFStream):void {
			_stream = byteStream;
			_stream.pos = 0;
			
			_asscociateSymbolList = [];
			
			var _NumberSymbols :int = _stream.read_UI16();
			for (var i:int=0;i<_NumberSymbols;i++) {
				var tagID: int = _stream.read_UI16();
				var symbolName:String = _stream.read_string();
				_asscociateSymbolList.push({tagID:tagID,symbolName:symbolName });
			}
			
		}
		
		public function get NumberSymbols() :int {
			return _asscociateSymbolList.length;
		}
	
		
		public function get Symbols():Array {
			var list:Array = [];
			for (var i:int=0;i<_asscociateSymbolList.length;i++) {
				list.push(_asscociateSymbolList[i].symbolName);
			}
			return list;
		}
		
		public function TagSymbolClass() {
			_unknownType = false;
			_id = ID;
		}
		
	}
}