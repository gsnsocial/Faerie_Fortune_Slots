package src.blit{

	public class blittools_general{
		
			import flash.display.MovieClip;
			import flash.events.*;

			public static function degFromRad( p_radInput:Number ):Number
			{
				var degOutput:Number = ( 180 / Math.PI ) * p_radInput;
				return degOutput;
			}
			 
			public static function radFromDeg( p_degInput:Number ):Number
			{
				var radOutput:Number = ( Math.PI / 180 ) * p_degInput;
				return radOutput;
			}

			public static function doReplaceString(str:String, search:String, replace:String):String
			{
				var arr:Array = str.split(search);
				var str2:String = arr.join(replace); 
				return str2;
			}
			
			//doInitButton()
			public static function doInitButton(myButton:MovieClip):void{
				myButton.myOrigin = [myButton.x, myButton.y];
				
				myButton.mouseChildren=false;
				myButton.buttonMode = true;
				myButton.addEventListener(MouseEvent.ROLL_OVER, function(e:Event):void {
					if(e.currentTarget.enabled){
						e.currentTarget.gotoAndStop(2);
					}
				});
				
				myButton.addEventListener(MouseEvent.ROLL_OUT, function(e:Event):void {
					if(e.currentTarget.enabled){
						e.currentTarget.y = e.currentTarget.myOrigin[1];
						e.currentTarget.gotoAndStop(1);
					}
				});
				
				myButton.addEventListener(MouseEvent.MOUSE_DOWN, function(e:Event):void {
					if(e.currentTarget.enabled){
						e.currentTarget.y = e.currentTarget.myOrigin[1] + 2;
						e.currentTarget.gotoAndStop(2);
					}
				});
				
				myButton.addEventListener(MouseEvent.MOUSE_UP, function(e:Event):void {
					 if(e.currentTarget.enabled){
						e.currentTarget.y = e.currentTarget.myOrigin[1];
						e.currentTarget.gotoAndStop(1);
					}
				});
				
			}


			//doFormatNumber(): simply add commas and return string
			public static function doFormatNumber(myNumber:Number, comma:String = ","):String{
				myNumber = Math.floor(myNumber);
				var myStr1:String = String(myNumber);
				var myStr2:String = "";
				var count:int = 0;
				for(var i:int=(myStr1.length-1); i>=0; i--){
					myStr2 = myStr1.charAt(i) + myStr2;
					count++;
					if(count==3){
						count=0;
						myStr2 = comma + myStr2;
					}
				}
				if(myStr2.charAt(0) == comma){
					myStr2 = myStr2.substring(1,myStr2.length);
				}
				myStr2 ="" + myStr2;
				return myStr2;
			}
			

			//doFormatTime
			public static function doGetMinSecHunds(ms:Number):Object{
				
				var s:int = Math.floor(ms * .001);
				var m:int = Math.floor(s/60);
				var hunds:int = Math.floor((ms-(s*1000))*.1);
				
				s = s-(m*60);
				
				var s_hunds:String;
				var s_min:String;
				var s_sec:String;
				
				if(hunds<10){
					s_hunds = String("0" + hunds);
				}else{
					s_hunds = String(hunds);
				}
			
				s_min = String(m);
				
				if(s<10){
					s_sec = String("0" + s);
				}else{
					s_sec= String(s);
				}
				
				return {m:s_min, s:s_sec, h:s_hunds};
			}

			//getDist(): returns distance between two 2d points
			public static function getDist(x1:Number,y1:Number,x2:Number,y2:Number):Number{
				 var dist:Number;
				 var dx:Number;
				 var dy:Number;
				 dx = x2-x1;
				 dy = y2-y1;
				 dist = Math.sqrt(dx*dx + dy*dy);
				 return dist;
			}
			
			//doRandomizeArr()
			public static function doRandomizeArr(theArray:Array):Array{
				var arrayLength:int = theArray.length;
				var oldArray:Array = theArray.slice();
				var newArray:Array = new Array();
				while (oldArray.length>0){
					var tId:int = Math.floor(Math.random() * oldArray.length);
					var tItem:Object = oldArray[tId];
					oldArray.splice(tId, 1);
					newArray.push(tItem);
				}
				return newArray;
			}
			
			

			
			

	}
}