package src.blit
{
 	import flash.utils.getTimer;
	import flash.events.Event;
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	
	public class bg_scroller extends MovieClip
	{
 		private var __this:MovieClip;
		private var myx:int = 0;
		private var myspeed:int = 2;
		
			
		public function bg_scroller():void
		{
			this.addEventListener(Event.ADDED_TO_STAGE, doInit);
			this.addEventListener(Event.REMOVED_FROM_STAGE, function(e:Event):void
			{
				removeEventListener(Event.ENTER_FRAME, doEnterFrame); 
			});
		}

		private function doInit(e:Event):void
		{
			__this = MovieClip(this);
			__this.scrollRect = new Rectangle(myx,0,120,100);
			addEventListener(Event.ENTER_FRAME, doEnterFrame); 
		}

		public function doEnterFrame(e:Event):void
		{
			var rect:Rectangle = e.currentTarget.scrollRect;
			rect.x += myspeed;
			if(rect.x > 211){
				rect.x -= 211;
			}
			  e.currentTarget.scrollRect = rect;
		}

	}
}