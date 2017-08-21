package src.blit
{

	import flash.events.Event;
	import flash.display.MovieClip;
	
	public class spinner extends MovieClip
	{

		public function spinner():void
		{
			this.addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void
			{
				addEventListener(Event.ENTER_FRAME, doEnterFrame); 
			});
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, function(e:Event):void
			{
				removeEventListener(Event.ENTER_FRAME, doEnterFrame); 
			});
		}
		

		public function doEnterFrame(e:Event):void{
			this.rotation += 15;
			
		}

		
	}
}