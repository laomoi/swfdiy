package com.swfdiy.data.ABC
{
	import com.swfdiy.data.ABC;

	public class Global
	{
		public static var abc:ABC;
		
		public static function STRING(index:int):String {
			return index ? abc.constant_pool.strings[index] :"*";			
		}
		
		public static function NAMESPACE(index:int):MNamespace {
			return  abc.constant_pool.namespaces[index] ;	
		}
		
		public static function INT(index:int):int {
			return index ? abc.constant_pool.ints[index] : 0;			
		}
		
		public static function UINT(index:int):int {
			return index ? abc.constant_pool.uints[index] : 0;			
		}
		
		public static function DOUBLE(index:int):Number {
			return index ? abc.constant_pool.doubles[index] : NaN;			
		}
		
		public static function MULTINAME(index:int):String {
			return (index && Global.abc.constant_pool.multinames[index]) ?  Global.abc.constant_pool.multinames[index].fullNameStr():"*";	
		}
		
		public static function CLASS(index:int):ClassInfo {
			return  abc.classes[index];	
		}
		public static function INSTANCE(index:int):InstanceInfo {
			return  abc.instances[index];	
		}
		
		public static function METHOD(index:int):MethodInfo {
			return  abc.methods[index];
		}
		
		public static function METADATA(index:int):MetadataInfo {
			return  abc.metadatas[index];
		}
	}
}