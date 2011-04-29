package com.swfdiy.data.ABC
{
	import com.swfdiy.data.ABC.Constant;
	import com.swfdiy.data.ABCStream;
	public class Trait
	{
		public var name:int;
		public var kind:int;
		public var kind_byte:int;
		public var data:*;
		public var metadata_count:int;
		public var metadatas:Array;
		
		
		private var u1:int;
		private var u2:int;
		private var u3:int;
		private var u4:int;
		
	
		
		
		public static const Trait_Slot:int = 0;
		public static const Trait_Method:int = 1;
		public static const Trait_Getter:int = 2;
		public static const Trait_Setter:int = 3;
		public static const Trait_Class:int = 4;
		public static const Trait_Function:int = 5;
		public static const Trait_Const:int = 6;
		
		
		public static const ATTR_Final :int = 1;
		public static const ATTR_Override :int = 2;
		public static const ATTR_Metadata :int = 4;
		
		
		public function kindStr():String {
			var str:String = "";
			switch (kind) {
				case Trait_Slot:
					str = "Slot";
					break;
				case Trait_Method:
					str = "Method";
					break;
				case Trait_Getter:
					str = "Getter";
					break;
				case Trait_Setter:
					str = "Setter";
					break;
				case Trait_Class:
					str = "Class";
					break;
				case Trait_Function:
					str = "Function";
					break;
				case Trait_Const:
					str = "Const";
					break;
				
			}
			return str;
		}

		public function Trait(stream:ABCStream)
		{
			var i:int;
			name = stream.read_u32();
			kind_byte = stream.read_u8();
			kind = kind_byte & 0xf;
			var trait_attr:int = kind_byte >>4;
			
			switch (kind) {
				case Trait.Trait_Slot:
				case Trait.Trait_Const:
					u1 = stream.read_u32();
					u2 = stream.read_u32();
					u3 = stream.read_u32();
					u4 = 0;
					if (u3) {
						u4 = stream.read_u8();
					}
					data = new TraitSlot( u1, u2,u3, u4);
					break;						
				
				case Trait.Trait_Class:
					data = new TraitClass(stream.read_u32(), stream.read_u32());
					
					break;
				case Trait.Trait_Function:
					data = new TraitFunction(stream.read_u32(), stream.read_u32());
					break;
				case Trait.Trait_Method:	
				case Trait.Trait_Getter:
				case Trait.Trait_Setter:
					data = new TraitMethod( stream.read_u32(), stream.read_u32());
					break;
				
				
			}
			
			
			
			if (trait_attr & Trait.ATTR_Metadata  ) {
				metadata_count = stream.read_u32();
				metadatas = [];
				for (i=0;i<metadata_count;i++) {
					metadatas[i] = stream.read_u32();
				}
			}
			
		}
		
		public function dumpRawData(_newStream:ABCStream):void {
			_newStream.write_u32(name);
			_newStream.write_u8(kind_byte);
			var trait_attr:int = kind_byte >>4;
			var i:int;
			switch (kind) {
				case Trait.Trait_Slot:
				case Trait.Trait_Const:
					_newStream.write_u32(u1);
					_newStream.write_u32(u2);
					_newStream.write_u32(u3);
					if (u3) {
						_newStream.write_u8(u4);
					}
					break;						
				
				case Trait.Trait_Class:
					_newStream.write_u32(data.slot_id);
					_newStream.write_u32(data.classi);
					break;
				case Trait.Trait_Function:
					_newStream.write_u32(data.slot_id);
					_newStream.write_u32(data.mfunction);
					break;
				case Trait.Trait_Method:	
				case Trait.Trait_Getter:
				case Trait.Trait_Setter:
					_newStream.write_u32(data.disp_id);
					_newStream.write_u32(data.method);
					break;
				
			}
			
			if (trait_attr & Trait.ATTR_Metadata  ) {
				_newStream.write_u32(metadata_count);
				for (i=0;i<metadata_count;i++) {
					_newStream.write_u32(metadatas[i]);
				}
			}
		}
		
		public function dump(pre:String = "", indent:String="    ") :String {
			var str:String = "";
			
			str += pre + "name:" + Global.MULTINAME(name) + "\n";
			str += pre + "kind:" + kindStr() + "\n";
			if (data) {
				str += pre + data.toString() + "\n";
			}
			
			
			str += pre + "metadata_count:"  + metadata_count  + "\n";
			var i:int;
			for (i=0;i<metadata_count;i++) {	
				str += pre + indent +  i.toString() + ":" + "\n"; 
				str += Global.METADATA(metadatas[i]).dump(pre +indent+ indent, indent) + "\n";
			}
			
			return str;
		}
		
	}
}