package src
{

	import flash.events.Event;
	import flash.display.MovieClip;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.*;
	import flash.utils.*;
	
	public class bigwin_msg extends MovieClip
	{

		private var msg_frame:String;
		private var destroy:Number;
		private var timeout:uint;
		private var __this;
		private var on_stage:Boolean;
		
		public function bigwin_msg(str:String, t:Number):void{
			
			msg_frame = str;
			destroy  = t;
			__this = this;
			
			this.addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void
			{
				 doInit();

			});

			this.addEventListener(Event.REMOVED_FROM_STAGE, function(e:Event):void
			{
				on_stage=false;
			});
			
		}


		public function doInit():void
		{
			
			on_stage=true;
			mc_msg.gotoAndStop(msg_frame);
			
			new Tween(__this, "scaleX", Elastic.easeOut,  .5, 1, 1.5, true);
			new Tween(__this, "scaleY", Elastic.easeOut,  .5, 1, 1.5, true);
			//new Tween(mc_msg.mc_sheen, "x", None.easeNone,  -440, 440, 2, true);
			
			timeout = setTimeout(doDestroy, destroy*1000);
			
		}
		
		public function doDestroy():void
		{
			clearTimeout(timeout);
			if(on_stage){
				new Tween(__this, "alpha", None.easeNone,  1, 0, .3, true);
				new Tween(__this, "scaleX", None.easeNone,  1, 1.3, .3, true);
				new Tween(__this, "scaleY", None.easeNone,  1, 1.3, .3, true).addEventListener(TweenEvent.MOTION_FINISH, function(e:Event){
					__this.parent.removeChild(__this);
				});
			}
		}

	}
}