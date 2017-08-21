package src.symbols
{

	import flash.events.Event;
	import flash.display.MovieClip;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.*;
	
	public class symbol_A extends MovieClip
	{
		
		
		public function symbol_A():void{}

		public function doHighlight():void
		{
			var __this = this;
			
			mc_sheen.visible = true;
			new Tween(mc_sheen, "x", None.easeNone,  -150, 54, 1, true).addEventListener(TweenEvent.MOTION_FINISH, function(e:Event){
				mc_sheen.visible = false;
			});
			
			new Tween(__this, "scaleX", Regular.easeOut,  1, 1.1, .33, true);
			new Tween(__this, "scaleY", Regular.easeOut,  1, 1.1, .33, true).addEventListener(TweenEvent.MOTION_FINISH, function(e:Event){
				new Tween(__this, "scaleX", Regular.easeIn,  1.1, 1, .33, true);
				new Tween(__this, "scaleY", Regular.easeIn,  1.1, 1, .33, true);
			});
		}

	}
}