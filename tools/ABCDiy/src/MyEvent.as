package
{
	import mx.events.FlexEvent;
	import spark.components.List;
	
	public class MyEvent extends FlexEvent
	{
		public var data:Object;
		
		public function MyEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}