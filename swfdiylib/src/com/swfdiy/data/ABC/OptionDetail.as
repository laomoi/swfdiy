package com.swfdiy.data.ABC
{
	import com.swfdiy.data.ABC.Constant;
	import com.swfdiy.data.ABC.Global;
	import com.swfdiy.data.helper.IndexMap;

	public class OptionDetail
	{
		
		public var kind:int;
		public var val:int;
		public function OptionDetail(_kind:int, _val:int)
		{
			kind = _kind;
			val = _val;
		}
		
		public function toString():String {
			var str:String = "";
			
			
			switch (kind) {
				case 	Constant.CONSTANT_Int:
					str = Constant.toStr(kind) + "," + Global.INT(val);
					break;
				case	Constant.CONSTANT_UInt:
					str = Constant.toStr(kind) + "," + Global.UINT(val);
					break;
				case	Constant.CONSTANT_Double:
					str = Constant.toStr(kind) + "," + Global.DOUBLE(val);
					break; 
				case	Constant.CONSTANT_Utf8:
					str = Constant.toStr(kind) + "," + Global.STRING(val);
					break;
				case	Constant.CONSTANT_True:
					str = Constant.toStr(kind) + ",true";
					break;
				case	Constant.CONSTANT_False:
					str = Constant.toStr(kind) + ",false";
					break;
				case	Constant.CONSTANT_Null:
					str = Constant.toStr(kind) + ",null";
					break;
				case	Constant.CONSTANT_Undefined:
					str = Constant.toStr(kind) + ",undefined";
					break;
				case	Constant.CONSTANT_Namespace :
					str = Constant.toStr(kind) + "," + Global.NAMESPACE(val).nameStr();
					break;
				case	Constant.CONSTANT_PackageNamespace:
					str = Constant.toStr(kind) + "," + Global.NAMESPACE(val).nameStr();
					break;
				case	Constant.CONSTANT_PackageInternalNs:
					str = Constant.toStr(kind) + "," + Global.NAMESPACE(val).nameStr();
					break;
				case	Constant.CONSTANT_ProtectedNamespace:
					str = Constant.toStr(kind) + "," + Global.NAMESPACE(val).nameStr();
					break;
				case	Constant.CONSTANT_ExplicitNamespace:
					str = Constant.toStr(kind) + "," + Global.NAMESPACE(val).nameStr();
					break;
				case	Constant.CONSTANT_StaticProtectedNs:
					str = Constant.toStr(kind) + "," + Global.NAMESPACE(val).nameStr();
					break;
				case	Constant.CONSTANT_PrivateNs:
					str = Constant.toStr(kind) + "," + Global.NAMESPACE(val).nameStr();
					break;
			}
			
			return str;
		}
		
		public function updateIndex(map:IndexMap):void {
			switch (kind) {
				case 	Constant.CONSTANT_Int:
					val = map.intsMap[val];
					break;
				case	Constant.CONSTANT_UInt:
					val = map.uintsMap[val];
					break;
				case	Constant.CONSTANT_Double:
					val = map.doublesMap[val];
					break; 
				case	Constant.CONSTANT_Utf8:
					val = map.stringsMap[val];
					break;
				case	Constant.CONSTANT_True:
					break;
				case	Constant.CONSTANT_False:
					break;
				case	Constant.CONSTANT_Null:
					break;
				case	Constant.CONSTANT_Undefined:
					break;
				case	Constant.CONSTANT_Namespace :
					val = map.namespaceMap[val];
					break;
				case	Constant.CONSTANT_PackageNamespace:
					val = map.namespaceMap[val];
					break;
				case	Constant.CONSTANT_PackageInternalNs:
					val = map.namespaceMap[val];
					break;
				case	Constant.CONSTANT_ProtectedNamespace:
					val = map.namespaceMap[val];
					break;
				case	Constant.CONSTANT_ExplicitNamespace:
					val = map.namespaceMap[val];
					break;
				case	Constant.CONSTANT_StaticProtectedNs:
					val = map.namespaceMap[val];
					break;
				case	Constant.CONSTANT_PrivateNs:
					val = map.namespaceMap[val];
					break;
			}
		}
		
		
		
	}
}