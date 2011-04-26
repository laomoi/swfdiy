package com.swfdiy.data.ABC
{
	public class Constant
	{

		
		public static const CONSTANT_Int:int =  0x03;
		public static const CONSTANT_UInt:int =  0x04;
		public static const CONSTANT_Double:int =  0x06;
		public static const CONSTANT_Utf8 :int = 0x01;
		public static const CONSTANT_True :int = 0x0B;
		public static const CONSTANT_False:int =  0x0A ;
		public static const CONSTANT_Null:int =  0x0C;
		public static const CONSTANT_Undefined:int =  0x00;
		
		
		
		
		public static const CONSTANT_Namespace:int =  0x08;
		public static const CONSTANT_PackageNamespace :int =  0x16 ;
		public static const CONSTANT_PackageInternalNs:int =   0x17 ;
		public static const CONSTANT_ProtectedNamespace :int =  0x18 ;
		public static const CONSTANT_ExplicitNamespace :int =  0x19 ;
		public static const CONSTANT_StaticProtectedNs :int =  0x1A ;
		public static const CONSTANT_PrivateNs:int =   0x05 ;
		
		
		public static const CONSTANT_QName :int = 0x07 ;
		public static const CONSTANT_QNameA :int = 0x0D ;
		public static const CONSTANT_RTQName :int = 0x0F ;
		public static const CONSTANT_RTQNameA:int =  0x10 ;
		public static const CONSTANT_RTQNameL:int =  0x11 ;
		public static const CONSTANT_RTQNameLA:int =  0x12; 
		public static const CONSTANT_Multiname:int =  0x09 ;
		public static const CONSTANT_MultinameA :int = 0x0E ;
		public static const CONSTANT_MultinameL :int = 0x1B ;
		public static const CONSTANT_MultinameLA:int =  0x1C ;			
		public static const CONSTANT_NameL				:int = 0x13	// o.[], ns=public implied, rt name
		public static const CONSTANT_NameLA				:int = 0x14 // o.@[], ns=public implied, rt attr-name		
		public static const CONSTANT_TypeName             :int = 0x1D
			
		
		public static function toStr(val:int):String {
			var str:String;
			switch (val) {
				case CONSTANT_Namespace:
					str = "Namespace";
					break;
				case CONSTANT_PackageNamespace:
					str = "PackageNamespace";
					break;
				case CONSTANT_PackageInternalNs:
					str = "PackageInternalNs";
					break;
				case CONSTANT_ProtectedNamespace:
					str = "ProtectedNamespace";
					break;
				case CONSTANT_ExplicitNamespace:
					str = "ExplicitNamespace";
					break;
				case CONSTANT_StaticProtectedNs:
					str = "StaticProtectedNs";
					break;
				case CONSTANT_PrivateNs:
					str = "PrivateNs";
					break;
				
				/* multiname */
				case CONSTANT_QName:
					str = "QName";
					break;
				case CONSTANT_QNameA:
					str = "QNameA";
					break;
				case CONSTANT_RTQName:
					str = "RTQName";
					break;
				case CONSTANT_RTQNameA:
					str = "RTQNameA";
					break;
				case CONSTANT_RTQNameL:
					str = "RTQNameL";
					break;
				case CONSTANT_RTQNameLA:
					str = "RTQNameLA";
					break;
				case CONSTANT_Multiname:
					str = "Multiname";
					break;
				case CONSTANT_MultinameA:
					str = "MultinameA";
					break;
				case CONSTANT_MultinameL:
					str = "MultinameL";
					break;
				case CONSTANT_MultinameLA:
					str = "MultinameLA";
					break;
				case CONSTANT_NameL:
					str = "NameL";
					break;
				case CONSTANT_NameLA:
					str = "NameLA";
					break;
				case CONSTANT_TypeName:
					str = "TypeName";
					break;
				default:
					str = "undefined";
			}
			return str;
		}
		
		
				

			
			
		public static const CONSTANT_ClassSealed:int =   0x01;
		public static const CONSTANT_ClassFinal :int =   0x02;  
		public static const CONSTANT_ClassInterface :int =   0x04;  
		public static const CONSTANT_ClassProtectedNs:int =   0x08;  
		
	}
}