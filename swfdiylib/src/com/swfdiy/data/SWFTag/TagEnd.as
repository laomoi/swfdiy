package com.swfdiy.data.SWFTag
{
	import com.swfdiy.data.SWF;
	import com.swfdiy.data.SWFStream;
	import com.swfdiy.data.SWFTag;
	
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	

	 
	public class TagEnd extends SWFTag
	{
		static public var ID:int = 0;
		
		public function TagEnd() {
			_unknownType = false;
			_id = ID;
		}
		
	}
}