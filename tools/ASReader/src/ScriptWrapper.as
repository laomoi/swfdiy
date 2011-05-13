package
{
	import com.swfdiy.data.ABC;
	import com.swfdiy.data.ABC.ClassInfo;
	import com.swfdiy.data.ABC.Constant;
	import com.swfdiy.data.ABC.InstanceInfo;
	import com.swfdiy.data.ABC.MMultiname;
	import com.swfdiy.data.ABC.MNamespace;
	import com.swfdiy.data.ABC.MQName;
	import com.swfdiy.data.ABC.MTypeName;
	import com.swfdiy.data.ABC.MethodBody;
	import com.swfdiy.data.ABC.MethodInfo;
	import com.swfdiy.data.ABC.Multiname;
	import com.swfdiy.data.ABC.NamespaceSet;
	import com.swfdiy.data.ABC.RTQName;
	import com.swfdiy.data.ABC.ScriptInfo;
	import com.swfdiy.data.ABC.Trait;
	import com.swfdiy.data.ABC.TraitClass;
	import com.swfdiy.data.ABC.TraitMethod;
	import com.swfdiy.data.ABC.TraitSlot;
	import com.swfdiy.data.Opcode;

	public class ScriptWrapper
	{
		private var _abc:ABC;
		private var _scriptIndex:int;
		private var _script:ScriptInfo;
		private var _content:String;
		private var _imports:Object;
		private var  firstClassInfo:Array;
		private static var tab_string:String = "    ";
		public function ScriptWrapper(abc:ABC, scriptIndex:int, script:ScriptInfo)
		{
			_abc = abc;
			_scriptIndex = scriptIndex;
			_script = script;
			_content = "";
			_imports = {};
			
			//init
			firstClassInfo = _publicClassInfo();
		}
		
		private function __multiname(index:int):Multiname {
			return _abc.constant_pool.multinames[index];
		}
		
		private function __multiname_name(index:int):String {
			var mm:Multiname = __multiname(index);
			if (mm == null) {
				return "*";
			}
			return __string(mm.data.name);
		}
		
		private function __string(index:int):String {
			return _abc.constant_pool.strings[index];
		}
		private function __int(index:int):int {
			return _abc.constant_pool.ints[index];
		}
		private function __uint(index:int):uint {
			return _abc.constant_pool.uints[index];
		}
		private function __double(index:int):Number {
			return _abc.constant_pool.doubles[index];
		}
		private function __namespace(index:int):MNamespace {
			return _abc.constant_pool.namespaces[index];
		}
		
		private function __nsset(index:int):NamespaceSet {
			return _abc.constant_pool.ns_sets[index];
		}
		private function __method(index:int):MethodInfo {
			return _abc.methods[index];
		}
		private function __method_body(index:int):MethodBody {
			return _abc.method_bodys[index];
		}
		private function __namespaceStr(ns:MNamespace):String {
		
			var nsStr:String = "";
			switch (ns.kind ) {
				case Constant.CONSTANT_Namespace:
					//custome namespace
					nsStr = __string(ns.name);
					break;
				case Constant.CONSTANT_PackageNamespace:
					nsStr = "public";
					break;
				case Constant.CONSTANT_PackageInternalNs:
					//nsStr = "internal";
					nsStr = "";
					break;
				case Constant.CONSTANT_ProtectedNamespace:
					nsStr = "protected";
					break;
				case Constant.CONSTANT_ExplicitNamespace:
					nsStr = __string(ns.name);
					break;
				case Constant.CONSTANT_StaticProtectedNs:
					nsStr = "static";
					break;
				case Constant.CONSTANT_PrivateNs:
					nsStr = "private";
					break;
			}
		
			
			return nsStr;
		}
		
		private function __val(vkind:int,vindex:int ):String {
			var val:*;
			switch (vkind) {
				case Constant.CONSTANT_Int:
					val = __int(vindex);
					break;
				case Constant.CONSTANT_UInt:
					val = __uint(vindex);
					break;
				case Constant.CONSTANT_Double:
					val = __double(vindex);
					break;
				case Constant.CONSTANT_Utf8:
					val =  _quoteString(__string(vindex));
					break;
				case Constant.CONSTANT_Namespace:
				case Constant.CONSTANT_PackageNamespace:
				case Constant.CONSTANT_PackageInternalNs:
				case Constant.CONSTANT_ProtectedNamespace:
				case Constant.CONSTANT_ExplicitNamespace:
				case Constant.CONSTANT_StaticProtectedNs:
				case Constant.CONSTANT_PrivateNs:
					val =  __namespaceStr(__namespace(vindex));
					break;
				case Constant.CONSTANT_False:
					val = "false";
					break;
				case Constant.CONSTANT_True:
					val = "true";
					break;
			}
			return val;
		}
		
		//find the first trait class(public) in the script
		private function _publicClassInfo():Array {
			var i:int;
			var info:Array = [null, "", "", null, null]; // trait class, packag_name, class_name, qname, ns
			for (i=0;i< _script.traits.length;i++) {
				if ( _script.traits[i].kind == Trait.Trait_Class) {
					//trait.name must be a QName
					var qname:MQName = MQName(__multiname(_script.traits[i].name).data);
					var tc:TraitClass = _script.traits[i].data;
					var instance:InstanceInfo = _abc.instances[tc.classi];
					var ns:MNamespace = __namespace(qname.ns);
					if (ns.kind == Constant.CONSTANT_PackageNamespace) {
						var package_name:String = __string(ns.name);
						var class_name:String = __string(qname.name);
						info = [tc, package_name, class_name, qname, ns, _script.traits[i]];
						return info;
					}
					
				}
			}
			
			//error!
			return info;
		}
		
		public function getScriptName():Array {
			//Global.abc = _abc;
			
			//ok, return the first trait public class name
			var class_name:String = firstClassInfo[2];
			if (class_name == "") {
				return [];
			}
			var filename:String = class_name + ".as"; // xxx.xxx.xxx::name
			var package_name:String = firstClassInfo[1];
			
			var ns:Array = [];
			if (package_name != "") {
				ns = package_name.split(".");
			} 
			ns.push(filename);	
			
			return ns;
		}
		
		
		private function _print(str:String, tab:String=""):String{
			return tab + str + "\n";
		}
		public function parse(force:Boolean = false):void {
			if (!force && _content != "") {
				return;
			} 
			
			var tab:String = tab_string;
			//Global.abc = _abc;
			
			
			
			
			//class
			_print_package(tab);
			
		
			
		}
		
		private function _print_package(tab:String):void {
			//Global.abc = _abc;
			var classStringInfo:Object = getClassStringInfo();
			var package_name:String = String(firstClassInfo[1]);
			var tc:TraitClass = TraitClass(firstClassInfo[0]);
			//var qname:MQName = MQName(firstClassInfo[3]);
			// ns:MNamespace = MNamespace(firstClassInfo[4]);
			var instance:InstanceInfo =  _abc.instances[tc.classi];
			var classInfo:ClassInfo =  _abc.classes[tc.classi];
			var i:int;
			var j:int;
			_content +=_print("package " + package_name + ' {');
			
			
			var classBlockStr:String = "";
			
			//class name
			classBlockStr += _print(classStringInfo['classStr'] + ' {', tab);
			
			
			var t:Trait ;
			var info:String;
			var method_body_str:Array;
			//instance traits
			for (i=0;i<instance.traits.length;i++) {
				t = Trait(instance.traits[i]);
				info = _get_trait(t);
				classBlockStr += _print(info, tab + tab_string);
				
				if (t.kind == Trait.Trait_Getter || 
					t.kind == Trait.Trait_Setter ||
					t.kind == Trait.Trait_Method) {
					method_body_str = _get_method_body(t.data.method);
					classBlockStr += _print("{", tab + tab_string);
					for (j=0;j<method_body_str.length;j++) {
						classBlockStr += _print(method_body_str[j], tab + tab_string + tab_string);
					}
					classBlockStr += _print("}", tab + tab_string);
				}
			}
			
			//class traits
			for (i=0;i<classInfo.traits.length;i++) {
				t = Trait(classInfo.traits[i]);
				info = _get_trait(t, true);
				classBlockStr += _print(info, tab + tab_string);
				if (t.kind == Trait.Trait_Getter || 
					t.kind == Trait.Trait_Setter ||
					t.kind == Trait.Trait_Method) {
					method_body_str = _get_method_body(t.data.method);
					classBlockStr += _print("{", tab + tab_string);
					for (j=0;j<method_body_str.length;j++) {
						classBlockStr += _print(method_body_str[j], tab + tab_string + tab_string);
					}
					classBlockStr += _print("}", tab + tab_string);
				}
			}
			
			//import	
			for (var k:String in _imports) {
				_content += _print("import " + k + ";", tab);
			}
			_content += classBlockStr;
			
			//instance construct
			if (instance.iint) {
				_content += _print(_get_class_construct(__method(instance.iint)), tab + tab_string);
				method_body_str = _get_method_body(instance.iint);
				_content += _print("{", tab + tab_string);
				for (j=0;j<method_body_str.length;j++) {
					_content += _print(method_body_str[j], tab + tab_string + tab_string);
				}
				_content += _print("}", tab + tab_string);
			
			}
			
			
			
			_content += _print('}', tab);
			_content += _print("}//package");
		}
		
		private function _get_trait(t:Trait, isClassTrait:Boolean=false):String {
			//slot, method, getter, setter, class, function, const
			//private/public/protected/internal static var xxx:type
			var str:String = "";
			switch (t.kind) {
				case Trait.Trait_Class:
					str = _get_trait_class(t, t.data, isClassTrait);
					break;
				case Trait.Trait_Slot:
				case Trait.Trait_Const:
					str = _get_trait_slot(t, t.data, isClassTrait);
					break;
				case Trait.Trait_Function:
					str = "FUNCTION--TBD";
					break;
				case Trait.Trait_Getter:
				case Trait.Trait_Setter:
				case Trait.Trait_Method:
					str = _get_trait_method(t, t.data, isClassTrait);
					break;
			}
			return str;
		}
		
		private function _get_trait_class(t:Trait, tc:TraitClass, isClassTrait:Boolean = false):String {
			var instance:InstanceInfo = _abc.instances[tc.classi];
			//instance.name must be a QNAME
			var qname:MQName = MQName(__multiname(t.name).data);
			var ns:MNamespace = __namespace(qname.ns);
			var package_name:String = __string(ns.name);
			var class_name:String = __string(qname.name);
			var i:int;
			
			/*
			final dynamic  public/internal/private/protected  class/interface class_name   
			-> extends xxxx   implements xxxxxx
			*/
			
			
			var def:String = "";
			if (!(instance.flags & Constant.CONSTANT_ClassSealed)) {
				def = "dynamic " + def;
			}
			
			if (instance.flags & Constant.CONSTANT_ClassFinal) {
				def = "final " + def;
			}
			
			def += __namespaceStr(ns) + " ";
			
			//if (isClassTrait) {
			//	def += "static ";
			//}
			
			if (instance.flags & Constant.CONSTANT_ClassInterface) {
				def += "interface"
			}  else {
				def += "class";
			}	
			def += " " + class_name;
			
			var super_name_index:int = instance.super_name;
			if (super_name_index) {
				//it should be a multiname
				var super_qname:Multiname = __multiname(super_name_index);
				var super_class_name:String = __string(super_qname.data.name);
				_addImport(super_qname);
				def += " extends " + super_class_name;
			}
			
			
			if (instance.intrf_count) {
				var itfs_list:Array = [];
				for (i=0;i<instance.interfaces.length;i++) {
					//it should be a multiname
					var interface_qname:Multiname = __multiname(instance.interfaces[i]);
					var interface_class_name:String = __string(interface_qname.data.name);
					_addImport(interface_qname);
					itfs_list.push(interface_class_name);
				}
				def += " implements " + itfs_list.join(",");
			}
			return def;
		}
		
		private function _get_trait_slot(t:Trait, ts:TraitSlot, isClassTrait:Boolean=false):String {
			/*
			 public/internal/private/protected static var/const xxx:XXX = xxxx
			*/
			var qname:MQName = MQName(__multiname(t.name).data);
			var ns:MNamespace = __namespace(qname.ns);
			var def:String =  __namespaceStr(ns) + " ";
			if (isClassTrait) {
				def += "static ";
			}
			
			if (t.kind == Trait.Trait_Const) {
				def += "const ";
			} else {
				def += "var ";
			}
			var slot_name:String = __string(qname.name);
			def += slot_name + ":" + __multiname_name(ts.type_name);
			_addImport(__multiname(ts.type_name));
			
			if (ts.vindex) {
				var val:* = __val(ts.vkind, ts.vindex);
				
				def += " = " + val;
			}
			
			
			return def + ";";
		}
		
		private function _get_trait_method(t:Trait, tm:TraitMethod, isClassTrait:Boolean=false):String {
			/*
				final/override public/private/..  static function xxxx(xx:xx=??, xx:xx=??, xxxx=??):YYYY 
			*/
			
			var qname:MQName = MQName(__multiname(t.name).data);
			var ns:MNamespace = __namespace(qname.ns);
			var def:String = "";
			var trait_attr:int = t.kind_byte >>4;
			if (trait_attr & Trait.ATTR_Final) {
				def += "final ";
			}
			if (trait_attr & Trait.ATTR_Override) {
				def += "override ";
			}
			def +=  __namespaceStr(ns) + " ";
			
			
			if (isClassTrait) {
				def += "static ";
			}
			
			if (t.kind == Trait.Trait_Getter) {
				def += "get ";
			} else if (t.kind == Trait.Trait_Setter) {
				def += "set ";
			}
			
			def += "function ";
			
			var slot_name:String = __string(qname.name);
			def += slot_name;
			
			var method:MethodInfo = __method(tm.method);
			
			def += _get_method_param_part(method);
			
			def += " : " + __multiname_name(method.return_type);
			
			return def;			
		}
		private function _get_method_param_part(method:MethodInfo):String {
			var params:Array = [];
			var i:int;
			var param:String = "";
			var options:Array =[];
			if (method.option_count) {
				options = method.option_info.option_details;
			}
			
			for (i=0;i<method.param_count;i++) {
				param = "";
				if (method.param_names.length) {
					param += __string(method.param_names[i]);	
				}
				
				param += ":" + __multiname_name(method.param_type[i]);
				if (options.length && options[i] != null) {
					var val:* = __val(options[i].kind, options[i].val);
					param += "=" + val;
				}
				params.push(param);
			}
			
			return '(' + params.join(", ") + ')';
		}
		private function _get_class_construct(method_info:MethodInfo):String {
			var def:String = "public function ";
			def += firstClassInfo[2];
			def += _get_method_param_part(method_info);
			return def;
		}
		private function _get_method_body(methodIndex:int):Array {
			var list:Array = [];
			var body:MethodBody =  __method_body(methodIndex);
			//first 2 opcode should be 
			//getlocal0         
			//pushscope 
			if (body.opcodes.length < 2) {
				return list;
			}
			
			
			
			var operator_stack:Array = [];
			var locals:Array = [];
			var scope_stack :Array = [];
			
			locals.push({type: "this", val :"this"});
			
			
			
			
			var i:int;
			var j:int;
			var temp:*;
			var temp2:*;
			var mindex:int;
			var mname:Multiname;
			var mname_name:String;
			var args:Array;
			var obj:*;
			var str:String;
			
			for (i=1;i < body.local_count;i++) {
				list.push("var _loc" + i +":*;");
				locals[i] = {type: "null", val :"null"};
			}
			
			
			for (i=0;i<body.opcodes.length;i++) {
				var data:Array = body.opcodes[i];
				var opcode:int = data[0];
				var params:Array = data[1];
				switch (opcode) {
					case Opcode.OP_debug:
					case Opcode.OP_debugfile:
					case Opcode.OP_pushstring:
					case Opcode.OP_debugline:
						//ignore all debug opcode
						break;
					case Opcode.OP_getlocal0:
						operator_stack.push(locals[0]);
						break;
					case Opcode.OP_getlocal1:
						operator_stack.push(locals[1]);
						break;
					case Opcode.OP_getlocal2:
						operator_stack.push(locals[2]);
						break;
					case Opcode.OP_getlocal3:
						operator_stack.push(locals[3]);
						break;
					case Opcode.OP_setlocal0:
						set_local( locals,0, operator_stack.pop(), list );
						
						break;
					case Opcode.OP_setlocal1:
						set_local( locals,1, operator_stack.pop(), list );
						break;
					case Opcode.OP_setlocal2:
						set_local( locals,2, operator_stack.pop(), list );
						break;
					case Opcode.OP_setlocal3:
						set_local( locals,3, operator_stack.pop(), list );
						break;
					case Opcode.OP_getlocal:
						operator_stack.push(locals[params[0].val]);
						break;
					case Opcode.OP_setlocal:
						set_local( locals, params[0].val, operator_stack.pop(), list );
						break;
					case Opcode.OP_pushscope:
						scope_stack.push( operator_stack.pop() );
						break;
					case Opcode.OP_popscope:
						scope_stack.pop();
						break;
					
					case Opcode.OP_pushbyte:
						operator_stack.push( {type: "int", val: params[0].val.toString()} );
						break;
					case Opcode.OP_convert_i:
						temp = operator_stack.pop();
						temp = {type:"int", val:  temp.val };
						operator_stack.push(temp);
						break;
					case Opcode.OP_convert_u:
						temp = operator_stack.pop();
						temp = {type:"uint", val:  temp.val};
						operator_stack.push(temp);
						break;
					case Opcode.OP_convert_s:
						temp = operator_stack.pop();
						temp = {type:"String", val:  temp.val};
						operator_stack.push(temp);
						break;
					case Opcode.OP_convert_d:
						temp = operator_stack.pop();
						temp = {type:"double", val:  temp.val};
						operator_stack.push(temp);
						break;
					case Opcode.OP_convert_b:
						temp = operator_stack.pop();
						temp = {type:"Boolean", val:  temp.val};
						operator_stack.push(temp);
						break;
					case Opcode.OP_convert_o:
						temp = operator_stack.pop();
						temp = {type:"Object", val:  temp.val};
						operator_stack.push(temp);
						break;
					case Opcode.OP_add:
						temp = operator_stack.pop();
						temp2 = operator_stack.pop();
						operator_stack.push({type:"unknown", val: temp2.val + " + " + temp.val});
						break;
					case Opcode.OP_add_i:
						temp = operator_stack.pop();
						temp2 = operator_stack.pop();
						operator_stack.push({type:"int", val: temp2.val + " + " + temp.val});
						break;
					case Opcode.OP_add_d:
						temp = operator_stack.pop();
						temp2 = operator_stack.pop();
						operator_stack.push({type:"double", val: temp2.val + " + " + temp.val});
						break;
					case Opcode.OP_findpropstrict:
						mname_name = _resolve_multiname_in_methodbody(params[0].val, operator_stack);
						
						//operator_stack.push({type:"property", val: mname_name});
						operator_stack.push({type:"property", val: ""});
						break;
					case Opcode.OP_pushstring:
						operator_stack.push({type:"String", val: _quoteString( __string(params[0].val) )});
						break;
					case Opcode.OP_callproperty:
					case Opcode.OP_constructprop:
						temp = params[0].val; // index
						temp2 = params[1].val; //args count
						args = [];
						for (j=0;j<temp2;j++) {
							args.unshift( operator_stack.pop().val );
						}
						
						mname_name = _resolve_multiname_in_methodbody(temp, operator_stack);
						
						obj = operator_stack.pop();//object
						str = mname_name + "(" + args.join(", ") + ')';
						if (opcode == Opcode.OP_callproperty) {
							if (obj.val) {
								str = obj.val + "." + str;
							}
						} else if (opcode == Opcode.OP_constructprop) {
							str = "new " + str;
						}
						
						
						operator_stack.push({type:"unknown", val: str });
						break;
					case Opcode.OP_constructsuper:
						temp = params[0].val; // args count
						args = [];
						for (j=0;j<temp;j++) {
							args.unshift( operator_stack.pop().val );
						}
						
						obj = operator_stack.pop();//object
						str = "super(" + args.join(", ") + ')';
						if (obj.val) {
							str = obj.val + "." + str;
						}
						list.push( str + ";");
						//operator_stack.push({type:"unknown", val: str });
						break;
					
					case Opcode.OP_coerce:
						
						break;
					case Opcode.OP_pop:
						list.push( operator_stack.pop().val + ";");
						break;
				}
			}
			
			
			
			/*
			
			
			*/
			/*
			 * 
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
			if (opNames[opcode] == ("0x"+opcode.toString(16).toUpperCase()))
			s += " UNKNOWN OPCODE"
			break;
			*/
			
			
			
			return list;
		}
		
		
		private function set_local(locals:Array, index:int, obj:Object, list:Array): void{
			locals[index] = obj;
			if (index >=1) {
				list.push("_loc" + index + " = " + obj.val + ";");
				locals[index] = {type:"local", val: "_loc" + index};
			}
		}
		private function _resolve_multiname_in_methodbody(mindex:int, operator_stack:Array):String {
			var mname:Multiname = __multiname(mindex);
			var mname_name:String = "";
			switch (mname.kind)
			{
				case Constant.CONSTANT_QName:
				case Constant.CONSTANT_QNameA:
					//name ns not in stack
					mname_name = __multiname_name(mindex);
					break;
				
				case Constant.CONSTANT_RTQName:
				case Constant.CONSTANT_RTQNameA:
					//ns in stack
					 operator_stack.pop();
					mname_name = __multiname_name(mindex);
					break;
				
				case Constant.CONSTANT_RTQNameL:
				case Constant.CONSTANT_RTQNameLA:
					//name ns  in stack
					operator_stack.pop();
					operator_stack.pop();
					break;
				
				case Constant.CONSTANT_Multiname:
				case Constant.CONSTANT_MultinameA:
					//name nsset not in stack
					mname_name = __multiname_name(mindex);
					break;
				
				case Constant.CONSTANT_MultinameL:
				case Constant.CONSTANT_MultinameLA:
					//name in stack
					operator_stack.pop();
					break;
				/*NOT MENTION IN AVM2, COPRY FROM adbdump.as*/
				case Constant.CONSTANT_NameL:
				case Constant.CONSTANT_NameLA:
					break;
				case Constant.CONSTANT_TypeName:
					break;
				default:
			}
			return mname_name;
		}
		private function _quoteString(str:String ):String {
			return '"' + str + '"';
		}
		private function _addImportPackage(package_name:String, class_name:String):void {
			if (package_name == "") {
				return;
			}
			
			var current_package_name:String = String(firstClassInfo[1]);
			
			if (package_name == current_package_name) {
				return;
			}
			
			var full_name:String =  package_name + "." + class_name;
			
			_imports[full_name]= true;
		}
		private function _addImport(mname:Multiname):void {
			if (mname == null) {
				//must be index = 0
				return;
			}
			var class_name:String = __string(mname.data.name);
			
			var ns:MNamespace;
			var full_name:String;
			var package_name:String;
			var i:int;
			if (mname.data is MQName) {
				ns = __namespace(mname.data.ns);
				package_name = __string(ns.name);
				_addImportPackage(package_name, class_name);
			} else if (mname.data is MMultiname) {
				var nsset:Array = __nsset(mname.data.ns_set).ns;
				for (i=0;i<nsset.length;i++) {
					ns = __namespace(nsset[i]);
					package_name = __string(ns.name);
					_addImportPackage(package_name, class_name);
				}
			} else if (mname.data is MTypeName) {
				
			} else if (mname.data is RTQName) {
				
			}
			
		}
		
		private function getClassStringInfo():Object {
			//Global.abc = _abc;
			var obj:Object = {};
			var t:Trait = Trait(firstClassInfo[5]);
			var tc:TraitClass = TraitClass(firstClassInfo[0]);
				
			obj['classStr'] = _get_trait_class(t, tc);
			
			return obj;
		}
		
		public function content():String {
			return _content;
		}
		
		
		/*
		 package {
			import ...
		   
		    class  extends .. {
				var ...
		        static var ...
		        function() {}...
		        static function()...
			
			}
		
		 }
		
		 class ...
		 class ...
		
		
		*/
	}
}