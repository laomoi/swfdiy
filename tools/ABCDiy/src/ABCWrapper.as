package
{
	import com.swfdiy.data.ABC;

	public class ABCWrapper
	{
		private var _abc:ABC;
		private var _scripts:Array;
		
		
		
		public function ABCWrapper(abc:ABC)
		{
			_abc = abc;
			
			_init();
			
		}
		public function getABC():ABC {
			return _abc;
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