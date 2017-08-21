package src.blit{
	
	import flash.display.MovieClip;
	
	public class blittools_text extends MovieClip{
		
		import flash.text.TextField;
		import flash.text.TextFieldAutoSize;
		import flash.text.TextFormat;
		import flash.text.*;
		
		public static var oTxtFormatHolder:Object = new Object();
		public static var myLang:String = "en";
		
		
		
		//------------------------------
		// functions
		//------------------------------
		
		public static function doReplaceString(str:String, search:String, replace:String):String
		{
			var arr:Array = str.split(search);
			var str2:String = arr.join(replace); 
			return str2;
		}
		
		public static function doSwapTxt(myTextField:TextField, str:String=null, fonts:Array=null, lang:String="en"):void
		{
			var i:int;
			
			myLang = lang;
			
			if(str == null){
				return;
			}
			
			//measure
			var myrot:Number = myTextField.rotation;
			myTextField.rotation = 0;
			
			var mywidth:Number = myTextField.width;
			var myheight:Number = myTextField.height;
			var myformat:TextFormat = myTextField.getTextFormat();
			var mysize:Number = Number(myformat.size);
			
			//set text
			myTextField.text = doParseBreaks(str);
			
			myTextField.rotation = myrot;
		}
		
		
		
		
		
		
		public static function doParseBreaks(str:String):String
		{
			var arr:Array = str.split("{*br*}");
			var str2:String = arr.join("\n"); 
			return str2;
		}
		
		
		
		
	}
}

