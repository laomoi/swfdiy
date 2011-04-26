package com.swfdiy.data.ABC
{
	public class OptionInfo
	{
		public var option_count:int;
		public var option_details:Array;
		public function OptionInfo(count:int, details:Array)
		{
			option_count = count;
			option_details = details;
		}
		
		
		public function  dump(pre:String = "", indent:String="    "):String {
			var i:int =0;
			var str:String = "";
			
			str += pre + "option_count=" + option_count + "\n";
			for (i=option_details.length  - option_count;i<option_details.length;i++) {// suck!
				str += pre+indent +i.toString() + ':' + option_details[i].toString();					
			}
			return str;
		}
	}
}