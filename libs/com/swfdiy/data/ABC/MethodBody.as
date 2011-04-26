package com.swfdiy.data.ABC
{
	import com.swfdiy.data.ABCStream;
	import com.swfdiy.data.Opcode;
	
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
		}
		
		private var _indent :String="    ";
		private function _parseCode():void {
			opcodes = [];
			dump_opcodes = [];
			var stream:ABCStream = new ABCStream(code);
			var labels:LabelManager = new LabelManager();
			while (stream.bytesAvailable > 0)
			{
				
				var opcode:int = stream.read_u8();
				var params:Array = [];
				
				
				
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
						params.push(new OpcodeParam("u32", stream.read_u32()));
						s += '"' + Global.STRING(params[0].val).replace(/\n/g,"\\n").replace(/\t/g,"\\t") + '"' ;

						break
					case Opcode.OP_pushnamespace:
						//s += abc.namespaces[readU32()]
						params.push(new OpcodeParam("u32", stream.read_u32()));
						s +=  Global.NAMESPACE(params[0].val).nameStr();
						
						break
					case Opcode.OP_pushint:
						//var i:int = abc.ints[readU32()]
						//s += i + "\t// 0x" + i.toString(16)
						params.push(new OpcodeParam("u32", stream.read_u32()));
						var int_val:int = Global.INT(params[0].val);
						
						s +=  int_val + "\t// 0x" + int_val.toString(16);
						
						break
					case Opcode.OP_pushuint:
						//var u:uint = abc.uints[readU32()]
						//s += u + "\t// 0x" + u.toString(16)
						params.push(new OpcodeParam("u32", stream.read_u32()));
						var uint_val:int = Global.UINT(params[0].val);
						s +=  uint_val + "\t// 0x" + int_val.toString(16);
						
						break;
					case Opcode.OP_pushdouble:
						//s += abc.doubles[readU32()]
						params.push(new OpcodeParam("u32", stream.read_u32()));
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
						params.push(new OpcodeParam("u32", stream.read_u32()));
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
						
						params.push(new OpcodeParam("u32", stream.read_u32()));
						params.push(new OpcodeParam("u32", stream.read_u32()));
						s +=  Global.MULTINAME(params[0].val);
						s +=  " (" + params[1].val + ")";
						break;
					case Opcode.OP_newfunction: {
						//var method_id = readU32()
						//s += abc.methods[method_id]
						//abc.methods[method_id].anon = true
						params.push(new OpcodeParam("u32", stream.read_u32()));
						s +=  Global.METHOD(params[0].val).nameStr();
						break;
					}
					case Opcode.OP_callstatic:
						//s += abc.methods[readU32()]
						//s += " (" + readU32() + ")"
						params.push(new OpcodeParam("u32", stream.read_u32()));
						params.push(new OpcodeParam("u32", stream.read_u32()));
						s +=  Global.METHOD(params[0].val).nameStr();
						s += " (" + params[1].val + ")";
						break;
					case Opcode.OP_newclass: 
						//s += abc.instances[readU32()]
						params.push(new OpcodeParam("u32", stream.read_u32()));
						s +=  Global.INSTANCE((params[0].val)).nameStr();
						break;
					case Opcode.OP_lookupswitch:
						var pos:int = stream.pos-1;
						var p1:int = stream.read_s24();
						var target:int = pos + p1;
						var maxindex :int = stream.read_u32();
						
						params.push(new OpcodeParam("s24", p1));
						params.push(new OpcodeParam("u32", maxindex));
						s += "default:" + labels.labelFor(target); // target + "("+(target-pos)+")"
						s += " maxcase:" + maxindex;
						for (var i:int=0; i <= maxindex; i++) {
							var p2:int = stream.read_s24();
							target = pos + stream.read_s24();
							s += " " + labels.labelFor(target) // target + "("+(target-pos)+")"
							params.push(new OpcodeParam("s24", p2));
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
						s += target2 + " ("+offset+")"
						s += labels.labelFor(target2)
						if (!((code.position) in labels)) {
							s += "\n";
						}
						
						params.push(new OpcodeParam("s24", offset));
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
						
						params.push(new OpcodeParam("u32", stream.read_u8()));
						params.push(new OpcodeParam("u32", stream.read_u32()));
						params.push(new OpcodeParam("u32", stream.read_u8()));
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
						params.push(new OpcodeParam("u32", stream.read_u8()));
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
	}
}
	
	
class OpcodeParam{
	public var type:String;
	public var val:*;
	public function OpcodeParam(_type:String, _val:*) {
		type = _type;
		val = _val;
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
