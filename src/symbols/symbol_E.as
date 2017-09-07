package src.symbols
{

	import flash.events.Event;
	import flash.display.MovieClip;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.*;
	
	public class symbol_E extends MovieClip
	{

		public function symbol_E():void{
			this.addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void
			{
				

			});

			this.addEventListener(Event.REMOVED_FROM_STAGE, function(e:Event):void
			{
				
			});
			
		}
			
			
		public function doHighlight():void
		{
			/*new Tween(mc_circle, "scaleX", Regular.easeOut,  1, 1.2, .5, true);
			new Tween(mc_circle, "scaleY", Regular.easeOut,  1, 1.2, .5, true).addEventListener(TweenEvent.MOTION_FINISH, function(e:Event){
				new Tween(mc_circle, "scaleX", Regular.easeIn,  mc_circle.scaleX, 1, .3, true);
				new Tween(mc_circle, "scaleY", Regular.easeIn,  mc_circle.scaleY, 1, .3, true);
			});  */
			
			var __this = this;
			__this.gotoAndPlay(2);
		}

	}
}