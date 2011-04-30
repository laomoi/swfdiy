package com.swfdiy.data
{
	import com.swfdiy.data.ABC.ClassInfo;
	import com.swfdiy.data.ABC.ConstantPool;
	import com.swfdiy.data.ABC.Global;
	import com.swfdiy.data.ABC.InstanceInfo;
	import com.swfdiy.data.ABC.MNamespace;
	import com.swfdiy.data.ABC.MetadataInfo;
	import com.swfdiy.data.ABC.MethodBody;
	import com.swfdiy.data.ABC.MethodInfo;
	import com.swfdiy.data.ABC.ScriptInfo;
	import com.swfdiy.data.helper.IndexMap;
	
	import flash.utils.ByteArray;

	
	public class ABC
	{
		protected var _stream:ABCStream;
		
		public var minor_version:int;
		public var major_version:int;
		
		public var constant_pool:ConstantPool;
		
		public var method_count:int;
		public var methods:Array;
		
		public var metadata_count:int;
		public var metadatas:Array;
		
		public var class_count:int;
		public var instances:Array;
		public var classes:Array;
		
		public var script_count:int;
		public var scripts:Array;
		
		public var method_body_count:int;
		public var method_bodys:Array;
		
		
		
		
		public function ABC()
		{
		}
		public function get data():ABCStream {
			return _stream;
		}
		public function set data(byteStream:ABCStream):void {
			var i:int;
			_stream = byteStream;
			_stream.pos = 0;
			Global.abc = this; // important to make global refernce
			
			//have bugs, not finish. just return
			//return;
			
			minor_version = _stream.read_u16(); // it should be 16
			major_version = _stream.read_u16(); // it should be 46
			
			constant_pool = new ConstantPool(_stream);
			
			method_count = _stream.read_u32();
			methods =[];
			for (i=0;i<method_count;i++) {
				methods[i] = new MethodInfo( _stream);
			}
			
			metadata_count = _stream.read_u32();
			metadatas =[];
			for (i=0;i<metadata_count;i++) {
				metadatas[i] = new MetadataInfo( _stream);
			}
			
			class_count = _stream.read_u32();			
			
			instances =[];
			for (i=0;i<class_count;i++) {
				instances[i] = new InstanceInfo( _stream);
			}
			
			classes = [];
			for (i=0;i<class_count;i++) {
				classes[i] = new ClassInfo( _stream);
			}
			
			script_count = _stream.read_u32();
			scripts= [];
			for (i=0;i<script_count;i++) {
				scripts[i] = new ScriptInfo( _stream);
			}
			
			method_body_count = _stream.read_u32();
			method_bodys= [];
			for (i=0;i<method_body_count;i++) {
				method_bodys[i] = new MethodBody( _stream);
			}
			trace("hello");
			
		}
		
		
		public function dumpRawData(n:ByteArray):void {
		
			var i:int;
			var newStream:ABCStream = new ABCStream(n);
			newStream.write_u16(minor_version);
			newStream.write_u16(major_version);
			
			constant_pool.dumpRawData(newStream);
		
			newStream.write_u32(method_count);
			for (i=0;i<method_count;i++) {
				methods[i].dumpRawData(newStream);
			}
		
			newStream.write_u32(metadata_count);
			for (i=0;i<metadata_count;i++) {
				metadatas[i].dumpRawData(newStream);
			}
			
			newStream.write_u32(class_count);
			for (i=0;i<class_count;i++) {
				instances[i].dumpRawData(newStream);
			}
			
			for (i=0;i<class_count;i++) {
				classes[i].dumpRawData(newStream);
			}
			
			newStream.write_u32(script_count);
			for (i=0;i<script_count;i++) {
				scripts[i].dumpRawData(newStream);
			}
			
			newStream.write_u32(method_body_count);
			for (i=0;i<method_body_count;i++) {
				method_bodys[i].dumpRawData(newStream);
			}
			/**/
		}
		
		public function dump(pre:String = "", indent:String="    ") :String {	
			//set current abc to be the global abc so that the constant pool can be referered
			Global.abc = this;
			var i :int;
			var str:String = "";
			
			str += constant_pool.dump(pre + indent, indent);
			
			str += pre + "method_count:" + method_count + "\n";
			
			for (i=0;i<method_count;i++) {
				str += pre + indent +  i.toString() + ":" + "\n"; 
				str += methods[i].dump(pre + indent+indent, indent);
			}
			
			str += pre + "metadata_count:" + metadata_count + "\n";
			
			for (i=0;i<metadata_count;i++) {
				str += pre + indent +  i.toString() + ":" + "\n"; 
				str += metadatas[i].dump(pre + indent+indent, indent);
			}
			
			
			str += pre + "class_count:" + class_count + "\n";
			str += pre + "instances:\n";
			for (i=0;i<class_count;i++) {
				str += pre + indent +  i.toString() + ":" + "\n"; 
				str += instances[i].dump(pre + indent+indent, indent);
			}
			
			str += pre + "classes:\n";
			for (i=0;i<class_count;i++) {
				str += pre + indent +  i.toString() + ":" + "\n"; 
				str += classes[i].dump(pre + indent+indent, indent);
			}
			
			
			str += pre + "script_count:" + script_count + "\n";
			str += pre + "scripts:\n";
			for (i=0;i<script_count;i++) {
				str += pre + indent +  i.toString() + ":" + "\n"; 
				str += scripts[i].dump(pre + indent+indent, indent);
			}
			
			str += pre + "method_body_count:" + method_body_count + "\n";
			str += pre + "method_bodys:\n";
			for (i=0;i<method_body_count;i++) {
				str += pre + indent +  i.toString() + ":" + "\n"; 
				str += method_bodys[i].dump(pre + indent+indent, indent);
			}
			
			return str;
		}
		
		
		public function merge(abc:ABC, map:IndexMap):void {
			constant_pool.merge(abc.constant_pool, map);
			
			//merge classes, instances, scripts
			var i:int;
			for (i=0;i<abc.method_count;i++) {
				map.add("method", i, methods.length);
				methods.push(abc.methods[i]); 
				method_count++;
			}
			
		
			
			for (i=0;i<abc.metadata_count;i++) {
				map.add("metadata", i, metadatas.length);
				metadatas.push(abc.metadatas[i]); 
				metadata_count++;
			}
			
			
			for (i=0;i<abc.class_count;i++) {
				map.add("class", i, classes.length);
				map.add("instance", i, classes.length);
				classes.push(abc.classes[i]); 
				instances.push(abc.instances[i]); 
				class_count++;
			}
			
			
			for (i=0;i<abc.script_count;i++) {
				map.add("script", i, scripts.length);
				scripts.push(abc.scripts[i]); 
				script_count++;
			}
			
			for (i=0;i<abc.method_body_count;i++) {
				map.add("methodbody", i, method_bodys.length);
				method_bodys.push(abc.method_bodys[i]); 
				method_body_count++;
			}
			
		}
		
		public function updateIndex(map:IndexMap):void {
			var i:int;
			for (i=0;i<method_count;i++) {
				methods[i].updateIndex(map);
			}
			
			for (i=0;i<metadata_count;i++) {
				metadatas[i].updateIndex(map);
			}
			
			for (i=0;i<class_count;i++) {
				instances[i].updateIndex(map);
			}
			
			for (i=0;i<class_count;i++) {
				classes[i].updateIndex(map);
			}
			
			for (i=0;i<script_count;i++) {
				scripts[i].updateIndex(map);
			}
			
			for (i=0;i<method_body_count;i++) {
				method_bodys[i].updateIndex(map);
			}
		}
		
	}
}