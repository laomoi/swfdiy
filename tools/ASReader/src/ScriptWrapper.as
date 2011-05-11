package
{
	import com.swfdiy.data.ABC;
	import com.swfdiy.data.ABC.Constant;
	import com.swfdiy.data.ABC.InstanceInfo;
	import com.swfdiy.data.ABC.MMultiname;
	import com.swfdiy.data.ABC.MNamespace;
	import com.swfdiy.data.ABC.MQName;
	import com.swfdiy.data.ABC.MTypeName;
	import com.swfdiy.data.ABC.Multiname;
	import com.swfdiy.data.ABC.NamespaceSet;
	import com.swfdiy.data.ABC.RTQName;
	import com.swfdiy.data.ABC.ScriptInfo;
	import com.swfdiy.data.ABC.Trait;
	import com.swfdiy.data.ABC.TraitClass;
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
		
		private function __string(index:int):String {
			return _abc.constant_pool.strings[index];
		}
		
		private function __namespace(index:int):MNamespace {
			return _abc.constant_pool.namespaces[index];
		}
		
		private function __nsset(index:int):NamespaceSet {
			return _abc.constant_pool.ns_sets[index];
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
		
		//find the first trait class(public) in the script
		private function _publicClassInfo():Array {
			var i:int;
			var info:Array = [null, "", "", null, null]; // trait class, packag_name, class_name, qname, ns
			for (i=0;i< _script.traits.length;i++) {
				if ( _script.traits[i].kind == Trait.Trait_Class) {
					var tc:TraitClass = _script.traits[i].data;
					var instance:InstanceInfo = _abc.instances[tc.classi];
					if (__multiname(instance.name).data is MQName) {
						var qname:MQName = MQName(__multiname(instance.name).data);
						var ns:MNamespace = __namespace(qname.ns);
						if (ns.kind == Constant.CONSTANT_PackageNamespace) {
							var package_name:String = __string(ns.name);
							var class_name:String = __string(qname.name);
							info = [tc, package_name, class_name, qname, ns];
							return info;
						}
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
			var classInfo:Object = getClassStringInfo();
			var package_name:String = String(firstClassInfo[1]);
			var tc:TraitClass = TraitClass(firstClassInfo[0]);
			//var qname:MQName = MQName(firstClassInfo[3]);
			// ns:MNamespace = MNamespace(firstClassInfo[4]);
			var instance:InstanceInfo =  _abc.instances[tc.classi];
			
			var i:int;
			_print("package " + package_name + ' {');
			
			//import	
			for (var k:String in _imports) {
				_print("import " + k + ";", tab);
			}
			
			//class name
			_print(classInfo['classStr'] + ' {', tab);
			
			//instance traits
			for (i=0;i<instance.traits.length;i++) {
				var t:Trait = Trait(instance.traits[i]);
				var info:String = _get_trait(t);
				_print(info+";", tab + tab_string);
				//_print_trait(t, tab + tab_string);
			}
			
			
			
			
			_print('}', tab);
			_print("}//package");
		}
		
		private function _get_trait(t:Trait):String {
			//slot, method, getter, setter, class, function, const
			//private/public/protected/internal static var xxx:type
			var str:String = "";
			switch (t.kind) {
				case Trait.Trait_Class:
					str = get_trait_class(t.data);
					break;
				case Trait.Trait_Slot:
					str = get_trait_slot(t.data);
					break;
			}
			return str;
		}
		
		private function get_trait_class(tc:TraitClass):String {
			var instance:InstanceInfo = _abc.instances[tc.classi];
			//instance.name must be a QNAME
			var qname:MQName = MQName(__multiname(instance.name).data);
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
		
		private function get_trait_slot(ts:TraitSlot):String {
			/*
			 public/internal/private/protected static var/const xxx:XXX = xxxx
			*/
			var def:String = "";
			//switch (ts.
			return def;
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
			var tc:TraitClass = TraitClass(firstClassInfo[0]);
				
			obj['classStr'] = get_trait_class(tc);
			
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