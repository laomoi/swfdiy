package
{
	import flash.events.Event;
	
	public class CustomEvent extends Event
	{
		
		static public var EVENT_RECT_CHAGNE:String = "rect_change";
		
		public var data:Object = {};
		public function CustomEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}