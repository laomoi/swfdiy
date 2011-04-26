package com.swfdiy.net
{
	import flash.events.Event;
	
	public class NetworkEvent extends Event
	{
		public static const NET_CONNECTED:String = "NET_CONNECTED";
		public static const NET_MESSAGE_RAW:String = "NET_MESSAGE_RAW";
		public static const NET_MESSAGE_PARSED:String = "NET_MESSAGE_PARSED";
		public static const NET_ERROR:String = "NET_ERROR";
		public static const NET_SESSION_CREATED:String = "NET_SESSION_VALID";
		public static const NET_SESSION_CREATION_FAILED:String = "NET_SESSION_CREATION_FAILED";
		
		private var _rawMsg:Object;
		
		public function NetworkEvent(rawMsg:Object,  evtType:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(evtType, bubbles, cancelable);
			_rawMsg = rawMsg;
		}
		
		public function getRawMessage():Object { return _rawMsg; }
	}
}