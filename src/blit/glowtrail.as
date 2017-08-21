package src.blit

{
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.MovieClip;
	

	public class glowtrail extends MovieClip
	{

		public var fade_factor:Number = 0.6;

		//constructor:
		public function glowtrail(blending:String):void
		{
			this.addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void{
								  
				if(blending == "overlay"){
					this.blendMode = BlendMode.OVERLAY;
				}else if (blending == "add"){
					this.blendMode = BlendMode.ADD;
				}
								  
				
				addEventListener(Event.ENTER_FRAME, doEnterFrame, false, 0, true);
			});

			this.addEventListener(Event.REMOVED_FROM_STAGE, function(e:Event):void{
				removeEventListener(Event.ENTER_FRAME, doEnterFrame);  
			});
		}
		
		
		
		//doEnterFrame()
		private function doEnterFrame(e:Event):void
		{
			this.alpha *= fade_factor;
			if(this.alpha <= .01){
				removeEventListener(Event.ENTER_FRAME, doEnterFrame);
				this.parent.removeChild(this);
			
			}
		}

		
	}
}