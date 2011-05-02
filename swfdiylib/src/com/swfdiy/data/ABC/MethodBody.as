package com.swfdiy.data.ABC
{
	import com.swfdiy.data.ABCStream;
	import com.swfdiy.data.Opcode;
	import com.swfdiy.data.helper.IndexMap;
	
	import flash.utils.ByteArray;
	
	import mx.controls.Label;

	public class MethodBody
	{
		public var method:int;
		public var max_stack:int;
		public var local_count:int;
		public var init_scope_depth:int;
		public var max_scope_depth:int;
		public var code_length:int;
		public var code:ByteArray;
		public var exception_count:int;
		public var exceptions:Array;

		public var trait_count:int;
		public var traits:Array;
		
		public var opcodes:Array;
		public var opIndexPosMap:Object;
		public var dump_opcodes:Array;
		
		public function MethodBody(stream:ABCStream)
		{
			var i:int;
			method = stream.read_u32();
			max_stack = stream.read_u32();
			local_count = stream.read_u32();
			init_scope_depth = stream.read_u32();
			max_scope_depth = stream.read_u32();
			code_length = stream.read_u32();
			trace("code-len=" + code_length);
			code = stream.read_bytes(code_length);
			exception_count = stream.read_u32();
			exceptions = [];
			for (i=0;i<exception_count;i++) {
				exceptions[i] = new ExceptionInfo(stream.read_u32(),stream.read_u32(),stream.read_u32(),stream.read_u32(),stream.read_u32());
			}
			
			trait_count = stream.read_u32();			
			traits = [];
			for (i=0;i<trait_count;i++) {
				traits[i] = new Trait(stream);
			}
			
			
			_parseCode();
			
			resove_jump_code();
		}
		
		private function resove_jump_code():void {
			//because there are some jump/switch op in the code , we have to resolve 
			//which op index it points to
			var i:int;
			var j:int;
			var params:Array;
			for (i=0;i<opcodes.length;i++) {
				var op:int = opcodes[i][0];
				params = opcodes[i][1];
				for (j=0;j<params.length;j++) {
					if (params[j].extra && params[j].extra['jump_to']) {
						if ( opIndexPosMap[ params[j].extra['jump_to'] ] != null) {
							params[j].extra['jump_to_op_index'] = opIndexPosMap[ params[j].extra['jump_to'] ];
						
						} else {
							trace("error: jump to none op code - " + i + "," + op);
						}
					}
				}
			}
			
			//and update the exception info
			for (i=0;i<exception_count;i++) {
				exceptions[i].op_index_from = opIndexPosMap[exceptions[i].from];
				exceptions[i].op_index_to = opIndexPosMap[exceptions[i].to];
				exceptions[i].op_index_target = opIndexPosMap[exceptions[i].target];
			}
			
		}
		
		/*private function compare(a:ByteArray, b:ByteArray, a_start:int, b_start:int=0):Boolean {
			var i:int;
			for (i=a_start;i<a.length;i++) {
				if (a[i] != b[b_start + i -a_start]) {
					return false;
				}
			}
			return true;
		}*/
		
		public function dumpRawData(_newStream:ABCStream):void {
			var i:int;
			_newStream.write_u32(method);
			_newStream.write_u32(max_stack);
			_newStream.write_u32(local_count);
			_newStream.write_u32(init_scope_depth);
			_newStream.write_u32(max_scope_depth);
			
			
			
			//_newStream.write_bytes(code);//this should be changed in future 
			var tempb:ByteArray = new ByteArray;
			var tempStream:ABCStream = new ABCStream(tempb);
			for (i=0;i<opcodes.length;i++) {
				var op:int = opcodes[i][0];
				var params:Array = opcodes[i][1];
				
				tempStream.write_u8(op);
				for (var j:int =0;j<params.length;j++) {
					var type:String = params[j].type;
					if (type == "u32") {
						tempStream.write_u32(params[j].val);
					}else if (type == "u8") {
						tempStream.write_u8(params[j].val);
					}  else if  (type == "s24") {
						tempStream.write_s24( params[j].val);
					}
				}
				
				/*if (!compare(_newStream.rawdata,code, p)) {
					trace("failed");
				}*/
			}
			code_length = tempb.length;
			
			_newStream.write_u32(code_length);
			_newStream.write_bytes(tempb);
			
			_newStream.write_u32(exception_count);
			
		
			for (i=0;i<exception_count;i++) {
				_newStream.write_u32(exceptions[i].from);
				_newStream.write_u32(exceptions[i].to);
				_newStream.write_u32(exceptions[i].target);
				_newStream.write_u32(exceptions[i].exc_type);
				_newStream.write_u32(exceptions[i].var_name);
			}
			_newStream.write_u32(trait_count);
			for (i=0;i<trait_count;i++) {
				traits[i].dumpRawData(_newStream);
			}
		}
		
		private var _indent :String="    ";
		private function _parseCode():void {
			var i:int;
			var j:int;
			var params:Array = [];
			opcodes = [];
			dump_opcodes = [];
			var stream:ABCStream = new ABCStream(code);
			var labels:LabelManager = new LabelManager();
			opIndexPosMap = {};//store the byte offset for each op index
			var op_start_pos:int = 0;
			while (stream.bytesAvailable > 0)
			{
				op_start_pos = stream.pos;
				var opcode:int = stream.read_u8();
				
				params = [];
				
				
				var s:String = "";
				s += Opcode.opNames[opcode];
				s += Opcode.opNames[opcode].length < 8 ? _indent+_indent:_indent;
				
				if (opcode ==  Opcode.OP_label || (stream.pos-1) in labels ) {
					var label_str:String = labels.labelFor( stream.pos -1);
					s += label_str;
				}
				
				/*if (opcode == OP_label || ((code.position-1) in labels)) {
					sb.append(indent+"\n")
					sb.append(indent + labels.labelFor(code.position-1) + ": \n")
				}
				
				s += opNames[opcode]
				s += opNames[opcode].length < 8 ? "\t\t" : "\t"
				*/
				
				switch(opcode)
				{
					
					case Opcode.OP_debugfile:
					case Opcode.OP_pushstring:
						//s += '"' + abc.strings[readU32()].replace(/\n/g,"\\n").replace(/\t/g,"\\t") + '"'
						params.push(new OpcodeParam("u32", stream.read_u32(), "string"));
						s += '"' + Global.STRING(params[0].val).replace(/\n/g,"\\n").replace(/\t/g,"\\t") + '"' ;

						break
					case Opcode.OP_pushnamespace:
						//s += abc.namespaces[readU32()]
						params.push(new OpcodeParam("u32", stream.read_u32(), "namespace"));
						s +=  Global.NAMESPACE(params[0].val).nameStr();
						
						break
					case Opcode.OP_pushint:
						//var i:int = abc.ints[readU32()]
						//s += i + "\t// 0x" + i.toString(16)
						params.push(new OpcodeParam("u32", stream.read_u32(), "int"));
						var int_val:int = Global.INT(params[0].val);
						
						s +=  int_val + "\t// 0x" + int_val.toString(16);
						
						break
					case Opcode.OP_pushuint:
						//var u:uint = abc.uints[readU32()]
						//s += u + "\t// 0x" + u.toString(16)
						params.push(new OpcodeParam("u32", stream.read_u32(), "uint"));
						var uint_val:int = Global.UINT(params[0].val);
						s +=  uint_val + "\t// 0x" + int_val.toString(16);
						
						break;
					case Opcode.OP_pushdouble:
						//s += abc.doubles[readU32()]
						params.push(new OpcodeParam("u32", stream.read_u32(), "double"));
						s +=  Global.DOUBLE(params[0].val);
						break;
					case Opcode.OP_getsuper: 
					case Opcode.OP_setsuper: 
					case Opcode.OP_getproperty: 
					case Opcode.OP_initproperty: 
					case Opcode.OP_setproperty: 
					case Opcode.OP_getlex: 
					case Opcode.OP_findpropstrict: 
					case Opcode.OP_findproperty:
					case Opcode.OP_finddef:
					case Opcode.OP_deleteproperty: 
					case Opcode.OP_istype: 
					case Opcode.OP_coerce: 
					case Opcode.OP_astype: 
					case Opcode.OP_getdescendants:
						//s += abc.names[readU32()]
						params.push(new OpcodeParam("u32", stream.read_u32(), "multiname"));
						s +=  Global.MULTINAME(params[0].val);
						break;
					case Opcode.OP_constructprop:
					case Opcode.OP_callproperty:
					case Opcode.OP_callproplex:
					case Opcode.OP_callsuper:
					case Opcode.OP_callsupervoid:
					case Opcode.OP_callpropvoid:
						//s += abc.names[readU32()]
						//s += " (" + readU32() + ")"
						
						params.push(new OpcodeParam("u32", stream.read_u32(), "multiname"));
						params.push(new OpcodeParam("u32", stream.read_u32()));
						s +=  Global.MULTINAME(params[0].val);
						s +=  " (" + params[1].val + ")";
						break;
					case Opcode.OP_newfunction: {
						//var method_id = readU32()
						//s += abc.methods[method_id]
						//abc.methods[method_id].anon = true
						params.push(new OpcodeParam("u32", stream.read_u32(), "method"));
						s +=  Global.METHOD(params[0].val).nameStr();
						break;
					}
					case Opcode.OP_callstatic:
						//s += abc.methods[readU32()]
						//s += " (" + readU32() + ")"
						params.push(new OpcodeParam("u32", stream.read_u32(), "method"));
						params.push(new OpcodeParam("u32", stream.read_u32()));
						s +=  Global.METHOD(params[0].val).nameStr();
						s += " (" + params[1].val + ")";
						break;
					case Opcode.OP_newclass: 
						//s += abc.instances[readU32()]
						params.push(new OpcodeParam("u32", stream.read_u32(), "instance"));
						s +=  Global.INSTANCE((params[0].val)).nameStr();
						break;
					case Opcode.OP_lookupswitch:
						var pos:int = stream.pos-1;
						var p1:int = stream.read_s24();
						var target:int = pos + p1;
						var maxindex :int = stream.read_u32();
						
						//jump_to_op_index will be replaced to the op index later
						params.push(new OpcodeParam("s24", p1, "", {jump_to_op_index: -1, jump_to:target, offset_from_op_start: true}));
						params.push(new OpcodeParam("u32", maxindex));
						var l:String = labels.labelFor(target);
						s += "default:" + l; // target + "("+(target-pos)+")"
						
						s += " maxcase:" + maxindex;
						for ( i=0; i <= maxindex; i++) {
							var p2:int = stream.read_s24();
							target = pos + p2;
							s += " " + labels.labelFor(target) // target + "("+(target-pos)+")"
							params.push(new OpcodeParam("s24", p2, "", {jump_to_op_index: -1, jump_to:target, offset_from_op_start: true}));
						}
						break;
					case Opcode.OP_jump:
					case Opcode.OP_iftrue:		case Opcode.OP_iffalse:
					case Opcode.OP_ifeq:		case Opcode.OP_ifne:
					case Opcode.OP_ifge:		case Opcode.OP_ifnge:
					case Opcode.OP_ifgt:		case Opcode.OP_ifngt:
					case Opcode.OP_ifle:		case Opcode.OP_ifnle:
					case Opcode.OP_iflt:		case Opcode.OP_ifnlt:
					case Opcode.OP_ifstricteq:	case Opcode.OP_ifstrictne:
						var offset :int= stream.read_s24();
						var target2:int = stream.pos + offset;
						s += target2 + " ("+offset+")";
						s += labels.labelFor(target2);
						if (!((code.position) in labels)) {
							s += "\n";
						}
						//jump_to_op_index will be replaced to the op index later
						params.push(new OpcodeParam("s24", offset, "", {jump_to_op_index: -1, jump_to:target2, offset_from_op_start: false}));
						break;
					case Opcode.OP_inclocal:
					case Opcode.OP_declocal:
					case Opcode.OP_inclocal_i:
					case Opcode.OP_declocal_i:
					case Opcode.OP_getlocal:
					case Opcode.OP_kill:
					case Opcode.OP_setlocal:
					case Opcode.OP_debugline:
					case Opcode.OP_getglobalslot:
					case Opcode.OP_getslot:
					case Opcode.OP_setglobalslot:
					case Opcode.OP_setslot:
					case Opcode.OP_pushshort:
					case Opcode.OP_newcatch:
						//s += readU32()
						
						params.push(new OpcodeParam("u32", stream.read_u32()));
						s += params[0].val;
						break
					case Opcode.OP_debug:
						//s += code.readUnsignedByte() 
						//s += " " + readU32()
						//s += " " + code.readUnsignedByte()
						//s += " " + readU32()
						
						params.push(new OpcodeParam("u8", stream.read_u8()));
						params.push(new OpcodeParam("u32", stream.read_u32(), "string"));
						params.push(new OpcodeParam("u8", stream.read_u8()));
						params.push(new OpcodeParam("u32", stream.read_u32()));
						
						s += params[0].val;
						s += " " + params[1].val;
						s += " " + params[2].val;
						s += " " + params[3].val;
						break;
					case Opcode.OP_newobject:
						//s += "{" + readU32() + "}"
						params.push(new OpcodeParam("u32", stream.read_u32()));
						s +="{" + params[0].val + "}";
						break;
					case Opcode.OP_newarray:
						//s += "[" + readU32() + "]"
						params.push(new OpcodeParam("u32", stream.read_u32()));
						s +="[" +  params[0].val + "]";
						break;
					case Opcode.OP_call:
					case Opcode.OP_construct:
					case Opcode.OP_constructsuper:
						//s += "(" + readU32() + ")"
						params.push(new OpcodeParam("u32", stream.read_u32()));
						s +="(" + params[0].val + ")";
						break;
					case Opcode.OP_pushbyte:
					case Opcode.OP_getscopeobject:
						//s += code.readByte()
						params.push(new OpcodeParam("u8", stream.read_u8()));
						s += params[0].val;
						break;
					case Opcode.OP_hasnext2:
						//s += readU32() + " " + readU32()
						params.push(new OpcodeParam("u32", stream.read_u32()));
						params.push(new OpcodeParam("u32", stream.read_u32()));
						s += params[0].val + " " + params[1].val;
					default:
						/*if (opNames[opcode] == ("0x"+opcode.toString(16).toUpperCase()))
						s += " UNKNOWN OPCODE"*/
						break;
				}//end of switch
				dump_opcodes.push(s);
				opIndexPosMap[op_start_pos] = opcodes.length;
				opcodes.push([opcode, params]);
			}//end of while
			
			
		}
		
		
		public function dump(pre:String = "", indent:String="    ") :String {
			var str:String = "";
			var i:int;
			str += pre + "{:"   + "\n";
			str += pre + "method:"  + method  + "\n";
			str += pre + "max_stack:"  + max_stack  + "\n";
			
			str += pre + "local_count:"  + local_count  + "\n";
			str += pre + "init_scope_depth:"  + init_scope_depth  + "\n";
			str += pre + "max_scope_depth:"  + max_scope_depth  + "\n";
			str += pre + "code_length:"  + code_length  + "\n";
			
			
			
			//dump code
			
			
			//dump code traits
			var methodInfo:MethodInfo = Global.METHOD(method);
			//methodInfo.nameStr();
			
			for (i=0;i<dump_opcodes.length;i++) {
				var s:String = dump_opcodes[i];
				//multiline?
				var s_list:Array = s.split(/\n/);
				for (var j:int=0;j<s_list.length;j++) {
					str += pre + indent + s_list[j] + "\n";
				}
				
			}
			
		
			
			
			str += pre + "exception_count:"  + exception_count  + "\n";
			for (i=0;i<exception_count;i++) {				
				str += pre + indent + exceptions[i].toString() + "\n";
			}
			
			
			str += pre + "trait_count:"  + trait_count  + "\n";
			
			for (i=0;i<trait_count;i++) {				
				str += traits[i].dump(pre +indent, indent) + "\n";
			}
			str += pre + "}:"   + "\n";
			return str;
		}
		
		public function updateIndex(map:IndexMap):void {
			
			var i:int;
			var j:int;
			var params:Array;
			var op:int ;
			
			method = map.methodsMap[method];
		
			
			//_newStream.write_bytes(code);//this should be changed in future 
			for (i=0;i<opcodes.length;i++) {
				 op = opcodes[i][0];
				 params = opcodes[i][1];
				
				for (j =0;j<params.length;j++) {
					var indexType:String = params[j].indexType;
					if (indexType != "") {
						var ov:* = params[j].val;
						params[j].val = map.getMap(indexType)[params[j].val];
						if (ov != params[j].val) {
							trace(ov + '->' + params[j].val);
						}
					}
				}
			}
			
			//because the code len has been changed after the u32 indexes been replaced
			//we have to unfortunatly re-calculate the jump/switch op params
			//what is lucky is the offset num is s24 not s30....
			
			var tempb:ByteArray = new ByteArray;
			var tempStream:ABCStream = new ABCStream(tempb);
			var op_len:Array = [];
			for (i=0;i<opcodes.length;i++) {
				var p:int = tempStream.pos;
				op = opcodes[i][0];
				params = opcodes[i][1];
				tempStream.write_u8(op);
				for (j=0;j<params.length;j++) {
					var type:String = params[j].type;
					if (type == "u32") {
						tempStream.write_u32(params[j].val);
					}else if (type == "u8") {
						tempStream.write_u8(params[j].val);
					}  else if  (type == "s24") {
						tempStream.write_s24( params[j].val);
					}
				}
				op_len[i] = tempStream.pos - p;
			}
			
			
			
			var offset:int ;
			for (i=0;i<opcodes.length;i++) {
				op = opcodes[i][0];
				params = opcodes[i][1];
			
				for (j=0;j<params.length;j++) {	
					if (params[j].extra && params[j].extra['jump_to']) {
						//so this is jump/switch op, hack it!
						if ( opIndexPosMap[ params[j].extra['jump_to'] ] != null) {
							offset = calculate_offset(op_len, i, params[j].extra['jump_to_op_index'], params[j].extra['offset_from_op_start']);
							if (offset != params[j].val) {
								params[j].val = offset;
								trace("upated offset");
							} else {
								trace("keep offset");
							}
						}
					}
				}
			}
			
			//also we need to update the exceiption from, to, target since the code len has beeen changed
			
			for (i=0;i<exception_count;i++) {
				exceptions[i].from = calculate_offset(op_len, 0, exceptions[i].op_index_from , true);
				exceptions[i].to = calculate_offset(op_len, 0, exceptions[i].op_index_to , true);
				exceptions[i].target = calculate_offset(op_len, 0, exceptions[i].op_index_target , true);
				//!!!!fuck the avm2overview, it says that exc_type & var_name is from string pool
				//but actually it is from multiplename pool
				if (exceptions[i].exc_type) {
					exceptions[i].exc_type = map.multinamesMap[exceptions[i].exc_type];
				}
				if (exceptions[i].var_name) {
					exceptions[i].var_name = map.multinamesMap[exceptions[i].var_name];
				}
				
			}
			
			
			
			
			for (i=0;i<trait_count;i++) {				
				traits[i].updateIndex(map);
			}
		}
		
		private function calculate_offset(op_len:Array, from:int, to:int, offset_from_op_start:Boolean):int {
			var direction:int = to >= from ? 1 : -1;
			var i:int;
			var d:int = 0;
			if (direction > 0) {
				for (i=from;i<to;i++) {
					d+= op_len[i];
				}
				if (!offset_from_op_start) {
					d -= op_len[from];
				}
			} else {
				for (i=to;i<from;i++) {
					d+= op_len[i];
				}
				
				if (!offset_from_op_start) {
					d +=  op_len[from];
				}
				d *= -1;
				
			}
			
			
				
				
			return d;
		}
	}
}
	
	
class OpcodeParam{
	public var type:String;
	public var indexType:String;
	public var val:*;
	public var extra:Object;
	public function OpcodeParam(_type:String, _val:*, _indexType:String="", _extra:Object=null) {
		type = _type;
		val = _val;
		indexType = _indexType;
		extra = _extra;
	}
}

dynamic class LabelManager
{
	private var count:int
	public  function labelFor (target:int):String
	{
		if (target in this)
			return this[target]
		return this[target] = "L" + (++count)
	}
}
