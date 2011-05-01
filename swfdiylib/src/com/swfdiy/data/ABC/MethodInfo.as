package com.swfdiy.data.ABC
{
	import com.swfdiy.data.ABC.Global;
	import com.swfdiy.data.ABC.MNamespace;
	import com.swfdiy.data.ABC.NamespaceSet;
	import com.swfdiy.data.ABCStream;
	import com.swfdiy.data.helper.IndexMap;

	
	public class MethodInfo
	{
		public var param_count:int;		
		public var return_type:int;
		public var param_type:Array;
		public var name:int;
		public var flags:int;
		public var option_count:int;
		public var option_info:OptionInfo;
		public var param_names:Array;
		
		private var  options:Array;
		
		public static const 	NEED_ARGUMENTS:int = 0x01;//  Suggests to the run-time that an “arguments” object 
		public static const	NEED_ACTIVATION :int = 0x02;//  Must be set if this method uses the newactivation opcode. 
		public static const	NEED_REST:int =  0x04 ;// This flag creates an ActionScript 3.0 rest arguments array.  Must not beused with NEED_ARGUMENTS. See Chapter 3. 
		public static const	HAS_OPTIONAL:int =  0x08;//  Must be set if this method has optional parameters and the options 		field is present in this method_info structure. 
		public static const	SET_DXNS:int =  0x40;//  Must be set if this method uses the dxns or dxnslate opcodes. 
		public static const	HAS_PARAM_NAMES:int =  0x80 ;// Must be set when the param_names field is present in this method_info 		structure. 
		
		
		public function MethodInfo(stream:ABCStream) : void
		{
			var i:int;
			param_count = stream.read_u32();
			return_type = stream.read_u32();
			param_type = [];
			for (i=0;i<param_count;i++) {
				param_type[i] = stream.read_u32();
			}
			
			name = stream.read_u32();
			flags = stream.read_u8();
			
			if (flags & HAS_OPTIONAL) {
				option_count =  stream.read_u32();
				options = [];
				for (i=param_count - option_count;i<param_count;i++) {// suck!
					options[i] = new OptionDetail(stream.read_u32(), stream.read_u8());					
				}
				option_info = new OptionInfo(option_count, options);	
			}
			
			if (flags & HAS_PARAM_NAMES)
			{
				param_names = [];
				for( i = 0; i < param_count; i++)
				{
					param_names[i] = stream.read_u32();
				}
			}
		}
		
		
		
		public function return_typeStr():String {
			return Global.MULTINAME(return_type);
		}
		public function nameStr() :String {
			return name ? Global.STRING(name): "function";
		}
		public function dumpRawData(_newStream:ABCStream):void {
			_newStream.write_u32(param_count);
			_newStream.write_u32(return_type);
			var i:int;
			
			for (i=0;i<param_count;i++) {
				_newStream.write_u32(param_type[i]);
			}
			_newStream.write_u32(name);
			_newStream.write_u8(flags);
		
			
			if (flags & HAS_OPTIONAL) {
				_newStream.write_u32(option_count);
				for (i=param_count - option_count;i<param_count;i++) {// suck!
					_newStream.write_u32(options[i].val);
					_newStream.write_u8(options[i].kind);
				}
			}
			
			if (flags & HAS_PARAM_NAMES)
			{
				
				for( i = 0; i < param_count; i++)
				{
					_newStream.write_u32(param_names[i]);
				}
			}
		}
		public function dump(pre:String = "", indent:String="    ") :String {	
			//set current abc to be the global abc so that the constant pool can be referered
			
			var str:String = "";
			
			str += pre + "param_count:" + param_count + "\n";
			str += pre + "return_type:" + return_type + ":" + return_typeStr() + "\n";
			str += pre + "name:" + name + ":" + nameStr() + "\n";
			str += pre + "flags:" + flags + "\n";
			
					
			if (option_info) {
				str += pre + "option_info:" + "\n";	
				str += option_info.dump(pre+indent, indent) + "\n";
			}
			if (param_count) {
				str += pre + "param_name:" + "\n";
				var i :int;
				if (flags & HAS_PARAM_NAMES)
				{	
					for (i=0;i<param_count;i++) {
						
						trace(i + "," + param_names[i]);
						str += pre + indent +Global.STRING(param_names[i]) + "\n";
					}
					
				}
				
			}
			
			
			return str;
		}
		
		
		public function updateIndex(map:IndexMap):void {
			return_type = map.multinamesMap[return_type];
			
			var i:int;
			
			for (i=0;i<param_count;i++) {
				param_type[i] = map.multinamesMap[param_type[i]];
			}
			
			name = map.stringsMap[name];
			
			
			if (flags & HAS_OPTIONAL) {
				for (i=param_count - option_count;i<param_count;i++) {// suck!
					options[i].updateIndex(map);
				}
			}
			
			if (flags & HAS_PARAM_NAMES)
			{
				
				for( i = 0; i < param_count; i++)
				{
					param_names[i] = map.stringsMap[param_names[i]];
				}
			}
		}
	}
}