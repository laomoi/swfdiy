package com.swfdiy.data.ABC
{
	import com.swfdiy.data.ABC.ConstantPool;
	import com.swfdiy.data.ABCStream;
	import com.swfdiy.data.ABC.Constant;
	import com.swfdiy.data.ABC.Global;
	public class MNamespace
	{
		public var kind:int;
		public var name:int;
		
		
		/*public function MNamespace(_stream:ABCStream) :void
		{
			kind = _stream.read_u8();
			name = _stream.read_u32();;		
		
		}*/
		
		public static function get publicNS() :MNamespace {
			return  new MNamespace(Constant.CONSTANT_PackageNamespace, 0);	
		}
		
		public function MNamespace(_kind:int, _name:int) :void {
			kind = _kind;
			name = _name;		
			
		}
		
		public function nameStr() :String {
			return Global.STRING(name);
		}
		
		public function dumpRawData(_newStream:ABCStream):void {
			_newStream.write_u8(kind);
			_newStream.write_u32(name);
		}
		
		public function dump(pre:String = "", indent:String="    ") :String {	
			var str:String = "";
			str += pre + "kind=" + kind + "," + Constant.toStr(kind) + "\n";
			str += pre + "name=" + name + "," + nameStr() + "\n";
			return str;
		}
	}
}