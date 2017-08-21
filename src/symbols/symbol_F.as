package src.symbols
{

	import flash.events.Event;
	import flash.display.MovieClip;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.*;
	import flash.geom.Point;
	import flash.geom.Matrix;
	import flash.geom.PerspectiveProjection;
	
	public class symbol_F extends MovieClip
	{

		public function symbol_F():void{
			this.addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void
			{
				//new Tween(mc_animal, "x", Regular.easeOut,  171, 52, 1, true);
			});

		}
			
		public function doStop():void
		{
			mc_animal.stop();
		}
		
		public function doHighlight():void
		{
			new Tween(mc_animal, "scaleX", Regular.easeOut,  1, 1.2, .33, true);
			new Tween(mc_animal, "scaleY", Regular.easeOut, 1, 1.5, .33, true).addEventListener(TweenEvent.MOTION_FINISH, doScale2);
		}
		
		private function doScale2(e:Event){
			new Tween(mc_animal, "scaleX", Regular.easeIn,  mc_animal.scaleX, 1, .33, true);
			new Tween(mc_animal, "scaleY", Regular.easeIn,  mc_animal.scaleY, 1, .33, true);
		}
	}
}