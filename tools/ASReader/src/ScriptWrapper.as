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
					nsStr = "internal";
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
		
		
		private function _print(str:String, tab:String=""):void{
			_content += tab + str + "\n";
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
			_print("package " + package_name + ' {');
			
			//import	
			for (var k:String in _imports) {
				_print("import " + k + ";", tab);
			}
			
			//class name
			_print(classStringInfo['classStr'] + ' {', tab);
			
			
			var t:Trait ;
			var info:String;
			//instance traits
			for (i=0;i<instance.traits.length;i++) {
				t = Trait(instance.traits[i]);
				info = _get_trait(t);
				_print(info+";", tab + tab_string);
			}
			
			//class traits
			for (i=0;i<classInfo.traits.length;i++) {
				t = Trait(classInfo.traits[i]);
				info = _get_trait(t, true);
				_print(info+";", tab + tab_string);
			}
			
			
			_print('}', tab);
			_print("}//package");
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
			
			
			return def;
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
			//params
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
					param += __multiname_name(method.param_names[i]);	
				}
				
				param += ":" + __multiname_name(method.param_type[i]);
				if (options.length && options[i] != null) {
					var val:* = __val(options[i].kind, options[i].val);
					param += "=" + val;
				}
				params.push(param);
			}
			
			def += '(' + params.join(", ") + ')';
			
			def += " : " + __multiname_name(method.return_type);
			
			return def;			
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