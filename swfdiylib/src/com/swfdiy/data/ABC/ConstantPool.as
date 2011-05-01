package com.swfdiy.data.ABC
{
	import com.swfdiy.data.ABC.Constant;
	import com.swfdiy.data.ABC.MNamespace;
	import com.swfdiy.data.ABC.NamespaceSet;
	import com.swfdiy.data.ABCStream;
	import com.swfdiy.data.helper.IndexMap;

	public class ConstantPool
	{
		public var int_count:int;
		public var ints:Array;
		
		public var uint_count:int;
		public var uints:Array;
		
		public var double_count:int;
		public var doubles:Array;
		
		
		public var string_count:int;
		public var strings:Array;
		
		public var namespace_count:int;
		public var namespaces:Array;
		
		public var ns_set_count:int;
		public var ns_sets:Array;
		
		public var multiname_count:int;
		public var multinames:Array;
		
		public function ConstantPool(stream:ABCStream):void
		{
			var i:int;
			var j:int;
			// ints
			int_count = stream.read_u32();
			ints = [0]
			for (i=1; i < int_count; i++) {
				ints[i] = stream.read_u32();
			}
				
			
			// uints
			uint_count = stream.read_u32();
			uints = [0]
			for (i=1; i < uint_count; i++) {
				uints[i] = stream.read_u32();
			}
			
			// doubles
			double_count = stream.read_u32();
			doubles = [NaN]
			for (i=1; i < double_count; i++) {
				doubles[i] = stream.readDouble();
			}
				
			
			// strings
			string_count = stream.read_u32();
			strings = ["*"]
			for (i=1; i < string_count; i++) {
				strings[i] = stream.read_string();
			}
			
			// namespaces
			namespace_count = stream.read_u32();			
			namespaces = [MNamespace.publicNS];
			for (i=1; i < namespace_count; i++) {
				namespaces[i] = new MNamespace( stream.read_u8(), stream.read_u32());				
			}
				
			// namespace sets
			ns_set_count = stream.read_u32();
			ns_sets = [null];
			for (i=1; i < ns_set_count; i++)
			{
				
				var count:int = stream.read_u32();
				var ns:Array = [];
				for ( j=0;j<count;j++) {
					ns.push(stream.read_u32());
				}
				
				
				ns_sets[i] = new NamespaceSet(count, ns);
				
				
				
			}
			
			
			// multinames
			multiname_count = stream.read_u32();
			multinames = [null];
			//namespaces[0] = anyNs
			//strings[0] = "*" // any name
			for (i=1; i < multiname_count; i++) {
				var kind:int = stream.read_u8();
				switch (kind)
				{
					case Constant.CONSTANT_QName:
					case Constant.CONSTANT_QNameA:
						multinames[i] = new Multiname(kind, new MQName(stream.read_u32(), stream.read_u32()));
						break;
					
					case Constant.CONSTANT_RTQName:
					case Constant.CONSTANT_RTQNameA:
						multinames[i] = new Multiname(kind, new RTQName(stream.read_u32()));
						break;
					
					case Constant.CONSTANT_RTQNameL:
					case Constant.CONSTANT_RTQNameLA:
						multinames[i] = null;
						break;
					
					
					case Constant.CONSTANT_Multiname:
					case Constant.CONSTANT_MultinameA:
						var tempname :int = stream.read_u32();
						multinames[i] = new Multiname(kind, new MMultiname(stream.read_u32(), tempname));					
						break;
					
					case Constant.CONSTANT_MultinameL:
					case Constant.CONSTANT_MultinameLA:
						multinames[i] = new Multiname(kind, new MMultiname(stream.read_u32(), 0));			
						break;
					/*NOT MENTION IN AVM2, COPRY FROM adbdump.as*/
					case Constant.CONSTANT_NameL:
					case Constant.CONSTANT_NameLA:
						multinames[i] = new Multiname(kind, new MQName(0, 0));
					break;
					case Constant.CONSTANT_TypeName:
						var name:int = stream.read_u32();
						var type_count:int = stream.read_u32();
						var types :Array = [];
						for( var t:int=0; t < type_count; ++t ) {
							types.push(stream.read_u32());
						}
							
						multinames[i] = new Multiname(kind, new MTypeName(name, types));
						break;
					
					default:
						
				}
				
			}
				
			
			//namespaces[0] = publicNs
			//strings[0] = "*"
		}
		
		
		public function dumpRawData(_newStream:ABCStream):void {
			var i:int;
			// ints
			_newStream.write_u32(int_count);
			for (i=1; i < int_count; i++) {
				_newStream.write_u32(ints[i]);
			}
			
			
			// uints
			_newStream.write_u32(uint_count);
			for (i=1; i < uint_count; i++) {
				_newStream.write_u32(uints[i]);
			}
			
			
			// doubles
			_newStream.write_u32(double_count);
			for (i=1; i < double_count; i++) {
				_newStream.writeDouble(doubles[i]);
			}
			
			
			// strings
			_newStream.write_u32(string_count);
			for (i=1; i < string_count; i++) {
				_newStream.write_string(strings[i]);
			}
			
			// namespaces
			_newStream.write_u32(namespace_count);
			for (i=1; i < namespace_count; i++) {
				namespaces[i].dumpRawData(_newStream);
			}
			
			// namespace sets
			_newStream.write_u32(ns_set_count);
		
			for (i=1; i < ns_set_count; i++)
			{
				ns_sets[i].dumpRawData(_newStream);
			}
			
			
			// multinames
			_newStream.write_u32(multiname_count);
			for (i=1; i < multiname_count; i++) {
				var kind:int = multinames[i].kind;
				_newStream.write_u8(kind);
		
				switch (kind)
				{
					case Constant.CONSTANT_QName:
					case Constant.CONSTANT_QNameA:
						_newStream.write_u32(multinames[i].data.ns);
						_newStream.write_u32(multinames[i].data.name);
						break;
					
					case Constant.CONSTANT_RTQName:
					case Constant.CONSTANT_RTQNameA:
						_newStream.write_u32(multinames[i].data.name);
						break;
					
					case Constant.CONSTANT_RTQNameL:
					case Constant.CONSTANT_RTQNameLA:
						//
						break;
					
					
					case Constant.CONSTANT_Multiname:
					case Constant.CONSTANT_MultinameA:
						_newStream.write_u32(multinames[i].data.name);
						_newStream.write_u32(multinames[i].data.ns_set);
						
						
						break;
					
					case Constant.CONSTANT_MultinameL:
					case Constant.CONSTANT_MultinameLA:
						_newStream.write_u32(multinames[i].data.ns_set);			
						break;
					/*NOT MENTION IN AVM2, COPRY FROM adbdump.as*/
					case Constant.CONSTANT_NameL:
					case Constant.CONSTANT_NameLA:
						//multinames[i] = new Multiname(kind, new MQName(0, 0));
						break;
					case Constant.CONSTANT_TypeName:
						_newStream.write_u32(multinames[i].data.name);	
						var types :Array = multinames[i].data.types;
						_newStream.write_u32(types.length);
						
						for( var t:int=0; t < types.length; ++t ) {
							_newStream.write_u32(types[i]);
						}
						
						break;
					
					default:
						
				}
				
			}
		}
			
		
		
		public function dump(pre:String = "", indent:String="    ") :String {	
			var str:String = "";
			var i:int =0;
			str += pre + "ConstantPool:\n";
			
			str += pre + indent + "int_count:" + int_count + "\n";
			for (i=1;i<int_count;i++) {
				str += pre + indent + indent + i.toString() + ":" + ints[i] + "\n"; 
			}
			
			
			str += pre + indent + "uint_count:" + uint_count + "\n";
			for (i=1;i<uint_count;i++) {
				str += pre + indent + indent + i.toString() + ":" + uints[i] + "\n"; 
			}
			
			str += pre + indent + "double_count:" + double_count + "\n";
			for (i=1;i<double_count;i++) {
				str += pre + indent + indent + i.toString() + ":" + doubles[i] + "\n"; 
			}
			
			str += pre + indent + "string_count:" + string_count + "\n";
			for (i=1;i<string_count;i++) {
				str += pre + indent + indent + i.toString() + ":" + strings[i] + "\n"; 
			}
			
			str += pre + indent + "namespace_count:" + namespace_count + "\n";
			for (i=1;i<namespace_count;i++) {
				str += pre + indent + indent + i.toString()  + "\n"; 
				str += namespaces[i].dump(pre + indent + indent + indent, indent); 
			}
			
			
			str += pre + indent + "ns_set_count:" + ns_set_count + "\n";
			for (i=1;i<ns_set_count;i++) {
				str += pre + indent + indent + i.toString()  + "\n"; 
				str += ns_sets[i].dump(pre + indent + indent + indent, indent); 
			}
			
			str += pre + indent + "multiname_count:" + multiname_count + "\n";
			for (i=1;i<multiname_count;i++) {
				str += pre + indent + indent + i.toString()  + "\n"; 
				if (multinames[i]) {
					str += multinames[i].dump(pre + indent + indent + indent, indent); 
				} else {
					str += "NULL";
				}
				
			}
			
			return str;
		}
		
		
		private function addConstant(type:String, old:int,map:IndexMap):void {
			var n:int;
			if (type == "int") {
				if (int_count == 0) {
					int_count++;
				} 
				n = int_count++;
			} else if (type == "uint") {
				if (uint_count == 0) {
					uint_count++;
				}
				n = uint_count++;
			}else if (type == "double") {
				if (double_count == 0) {
					double_count++;
				}
				n = double_count++;
			}else if (type == "string") {
				if (string_count == 0) {
					string_count++;
				}
				n = string_count++;
			}else if (type == "namespace") {
				if (namespace_count == 0) {
					namespace_count++;
				}
				n = namespace_count++;
			}else if (type == "multiname") {
				if (multiname_count == 0) {
					multiname_count++;
				}
				n = multiname_count++;
			}else if (type == "ns_set") {
				if (ns_set_count == 0) {
					ns_set_count++;
				}
				n = ns_set_count++;
			}
			map.add(type, old, n);
		}
		public function merge(pool:ConstantPool, map:IndexMap):void {
			
			var i:int;
			var j:int;
			
			for (i=1;i<pool.int_count;i++) {
				addConstant("int", i ,map );
				ints.push(pool.ints[i]);
			}
			
			for (i=1;i<pool.uint_count;i++) {
				addConstant("uint", i ,map);
				uints.push(pool.uints[i]);
			}
			
			for (i=1;i<pool.double_count;i++) {
				addConstant("double", i,map );
				doubles.push(pool.doubles[i]);
			}
			
			for (i=1;i<pool.string_count;i++) {
				addConstant("string", i ,map);
				strings.push(pool.strings[i]);
			}
			
			for (i=1;i<pool.namespace_count;i++) {
				addConstant("namespace", i ,map);
				
				//update namespace inner index
				pool.namespaces[i].updateIndex(map);
				namespaces.push(pool.namespaces[i]);
			}
			
			for (i=1;i<pool.ns_set_count;i++) {
				addConstant("ns_set", i ,map);
				pool.ns_sets[i].updateIndex(map);
				ns_sets.push(pool.ns_sets[i]);
			}
			
			for (i=1;i<pool.multiname_count;i++) {
				addConstant("multiname", i,map );
				pool.multinames[i].updateIndex(map);
				multinames.push(pool.multinames[i]);
			}
			
			
		}
	}
}