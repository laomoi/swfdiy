package com.swfdiy.data.helper
{
	public class IndexMap extends Object
	{
		public var intsMap:Object = {};
		public var uintsMap:Object = {};
		public var doublesMap:Object = {};
		public var stringsMap:Object = {};
		public var namespaceMap:Object = {};
		public var ns_setsMap:Object = {};
		public var multinamesMap:Object = {};
		
		public var classesMap:Object = {};
		public var instancesMap:Object = {};
		public var scriptsMap:Object = {};
		public var methodsMap:Object = {};
		public var metadatasMap:Object = {};
		public var methodbodysMap:Object = {};
		public function IndexMap()
		{
			super();
		}
		
		public function add(type:String, oldIndex:int, newIndex:int):void {
			var m:Object = getMap(type);
			m[oldIndex] = newIndex;
		}
		
		
		public function getMap(type:String):Object {
			var m:Object;
			switch (type) {
				case "int": 		m = intsMap; break;
				case "uint": 		m = uintsMap; break;
				case "double": 		m = doublesMap; break;
				case "string": 		m = stringsMap; break;
				case "namespace": 	m = namespaceMap; break;
				case "ns_set": 		m = ns_setsMap; break;
				case "multiname": 	m = multinamesMap; break;
				case "class": 		m = classesMap; break;
				case "instance": 	m = instancesMap; break;
				case "script": 		m = scriptsMap; break;
				case "method": 		m = methodsMap; break;
				case "metadata": 	m = metadatasMap; break;
				case "methodbody": 	m = methodbodysMap; break;
			}
			return m;
		}
		
	}
}