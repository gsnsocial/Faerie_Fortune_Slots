package src.symbols
{

	import flash.events.Event;
	import flash.display.MovieClip;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.*;
	import flash.utils.*;
	
	public class symbol_frame extends MovieClip
	{

		private var blink_count:uint = 0;
		private var timeout:uint;
		
		public function symbol_frame():void{
			this.addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void
			{

			});

			this.addEventListener(Event.REMOVED_FROM_STAGE, function(e:Event):void
			{

			});
			
		}



		public function doHighlight():void
		{
			new Tween(this, "scaleX", Regular.easeOut, .8, 1, .3, true);
			new Tween(this, "scaleY", Regular.easeOut, .8, 1, .3, true);
			blink_count=0;
			this.visible=false;
			timeout = setTimeout(doBlinkOn, 250);
		}
		
		public function doStop():void
		{
			clearTimeout(timeout);
			this.visible=false;
		}
		
		private function doBlinkOn():void
		{
			this.visible=true;
			blink_count++;
			if(blink_count < 2){
				timeout = setTimeout(doBlinkOff, 250);
			}
  		}
		
		private function doBlinkOff():void
		{
			this.visible=false;
			timeout = setTimeout(doBlinkOn, 250);
			
		}

	}
}