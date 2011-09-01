package
{
	import com.swfdiy.data.ABC;
	import com.swfdiy.data.SWFTag.TagDoABC;

	public class ABCWrapper
	{
		private var _tag:TagDoABC;
		private var _abc:ABC;
		private var _scripts:Array;
		
		public var index:int;
		private var _name:String;
		public function ABCWrapper(abcTag:TagDoABC)
		{
			_tag = abcTag;
			_abc = abcTag.abc();
			_name =abcTag.Name;	
			_init();
			
		}
		public function getABC():ABC {
			return _abc;
		}
		public function getName():String {
			return _name;
		}
		public function getTag():TagDoABC {
			return _tag;
		}
		private function _init():void {
			_scripts = [];
			
			/*var i:int;
			for (i=0;i<_abc.script_count;i++) {
				_scripts.push(new ScriptWrapper(_abc, i, _abc.scripts[i]));
			}*/
		}
		public function get scripts():Array {
			return _scripts;
		}
	}
}