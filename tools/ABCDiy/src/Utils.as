package
{
	import flash.events.Event;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.FileReferenceList;

	public class Utils
	{
		private static var fileCallback:Function;
		
		private static var file:FileReference;
		private static  var file2:FileReference;
		private static  var filelist:FileReferenceList;
		private static  var filelistIndex:int;
		private static  var filenameList:Array;
		private static  var filelistData:Array;
		public function Utils()
		{
		}
		
		
		public static function openAndReadFile(callback:Function, allFilter:FileFilter):void {
			file = new FileReference();
			file.addEventListener(Event.SELECT, fileSelectHandler);
			
			fileCallback = callback;
			file.browse(new Array(allFilter));
		}
		
		private static function fileSelectHandler(event:Event):void {
			file.addEventListener(Event.COMPLETE, onFileLoadComplete);				
			file.load(); 
		}
		
		private static function onFileLoadComplete(event:Event):void {			
			
			if (fileCallback != null) {
				fileCallback.call(null,[file.data],[file.name]);
			}
		}
		
		public  static function openAndReadFiles(callback:Function, allFilter:FileFilter):void {
			filelist = new FileReferenceList();
			filelist.addEventListener(Event.SELECT, filesSelectHandler);
			
			fileCallback = callback;
			filelist.browse(new Array(allFilter));
		}
		
		private  static function filesSelectHandler(event:Event):void {
			filenameList = [];
			filelistData = [];
			filelistIndex = 0;
			loadNextFile();
			
			
		}
		
		private static function loadNextFile():void {
			if (filelistIndex >= filelist.fileList.length ) {
				fileCallback.call(null, filelistData, filenameList );
			} else {
				
				filelist.fileList[filelistIndex].addEventListener(Event.COMPLETE, onFilesLoadComplete);		
				filelist.fileList[filelistIndex].load();
			}
		}
		
		private static function onFilesLoadComplete(event:Event):void {			
			filenameList[filelistIndex] = filelist.fileList[filelistIndex].name;
			filelistData[filelistIndex] = filelist.fileList[filelistIndex].data;
			filelistIndex++;
			loadNextFile();
		}
		
		public static function getLinkEventText(event:String, value:Object, text:String, simple:Boolean=false):String {
			if (!simple) {
				return '<a href="event:' + event + '-' + String(value) + '"><font color="#0000ff">' + String(value) +'</font></a> ' 
					+ quoteString(text);
			} else {
				return getSimpleLinkEventText(event, value, text);
				//return '<a href="event:' + event + '-' + String(value) + '"><font color="#0000ff">' + quoteString(text) +'</font></a> ' ;
			}
			
		}
		
		public static function getSimpleLinkEventText(event:String, value:Object, text:String):String {
			if (text == "") {
				text = '""';
			}
			return '<a href="event:' + event + '-' + String(value) + '"><font color="#0000ff">' + text +'</font></a> ' ;
			
			
		}
		
		public static function quoteString(str:String ):String {
			if (str == "") {
				return str;
			}
			return '(' + str + ')';
		}
	}
}