package src.symbols
{

	import flash.events.Event;
	import flash.display.MovieClip;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.*;
	import src.blit.*;
	
	public class symbol_S extends MovieClip
	{

		private var my_speed:Number = .25;
		private var my_speedboost:Number = 0;
		private var oMESSAGES:Object;
		
		public function symbol_S():void{
			this.addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void
			{
				mc_sky.visible = false;
				mc_txt.visible = false;
				mc_txt_2.visible=true;
				
				oMESSAGES = MovieClip(root).oMESSAGES;
				
				blittools_text.doSwapTxt(mc_txt.txt, oMESSAGES.symbol_freespins);
				blittools_text.doSwapTxt(mc_txt_2.txt, oMESSAGES.symbol_bonus);
				addEventListener(Event.ENTER_FRAME, doRotateSun);

			});

			this.addEventListener(Event.REMOVED_FROM_STAGE, function(e:Event):void
			{
				removeEventListener(Event.ENTER_FRAME, doRotateSun); 
			});
			
		}




		public function doStopAnimate():void
		{
			removeEventListener(Event.ENTER_FRAME, doRotateSun);
			new Tween(mc_txt_2, "alpha", None.easeNone, mc_txt_2.alpha, 0, .5, true); 
		}
			
			
			
			
		public function doHighlight():void
		{
			mc_sky.alpha = 0;
			mc_sky.visible = true;
			new Tween(mc_sun, "y", Regular.easeInOut, mc_sun.y, mc_sun.y-30, 1, true);
			new Tween(mc_burst, "y", Regular.easeInOut, mc_burst.y, mc_burst.y-30, 1, true);
			new Tween(mc_sky, "alpha", None.easeNone, 0, 1, 1, true);
			
			
			mc_txt.visible = true;
			new Tween(mc_txt, "alpha", None.easeNone, 0, 1, 1, true);
			mc_txt_2.alpha=0;
		}
		
		public function doPulse():void
		{
			new Tween(mc_burst, "rotation", Regular.easeInOut, mc_burst.rotation, mc_burst.rotation-100, 2, true);
		}
		
		
		//rotate sun
		public function doRotateSun(e:Event):void
		{
			
			//my_speed += (my_targetspeed-my_speed)*.2;
			mc_burst.rotation -= my_speed;
			
		}
			
			
			


	}
}