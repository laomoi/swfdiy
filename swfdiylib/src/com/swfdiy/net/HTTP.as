package com.swfdiy.net
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	public class HTTP extends EventDispatcher
	{
		private var _service:HTTPService;
		private var _netID:int = 0;
		private var _headers:Object;
		public function HTTP(target:IEventDispatcher=null)
		{
			super(target);
			_headers = {
				'User-Agent': 'Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US; rv:1.9.1.5) Gecko/20091102 Firefox/3.5.5'
			};
			_service = new HTTPService();
			this._service.addEventListener(FaultEvent.FAULT,this.onFaultEvent,false,int.MAX_VALUE,false);
			this._service.addEventListener(ResultEvent.RESULT,this.onResultEvent,false,int.MAX_VALUE,false);
			_service.headers = _headers;
			
		}
		public function addHeader(key:String, value:String) :void {
			_headers[key] = value;
		}
		public function onResultEvent(event:ResultEvent):void
		{
			trace("HttpConnection: Got a Response:");
			var rawData:String = String(event.result);
		
			var evt:Event;
			evt = new NetworkEvent({rawData:rawData,token:event.token},NetworkEvent.NET_MESSAGE_RAW);
			dispatchEvent(evt);
		}
		
		public function onFaultEvent(event:FaultEvent): void
		{
			trace("HttpConnection:Got an Error" + event.toString());
			var evt:Event;
			
			evt = new NetworkEvent(event.toString(),NetworkEvent.NET_ERROR);
			dispatchEvent(evt);
		}
		
		public function get(url:String ,params:Object=null):AsyncToken
		{

			this._service.url = url;
			this._service.resultFormat = "text";
			this._service.method = "GET"; //params[PARAM_METHOD];
			var token:AsyncToken = this._service.send(params);
			return token;
		}	
		
		public function post(url:String ,params:Object=null):AsyncToken
		{
			this._service.url = url;
			this._service.resultFormat = "text";
			this._service.method = "POST"; //params[PARAM_METHOD];
			var token:AsyncToken = this._service.send(params);
			return token;
		}
	}
}