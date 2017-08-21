package src.blit
{

	import flash.events.Event;
	import flash.display.MovieClip;
	
	import src.blit.glowtrail;
	import src.blit.blittools_general;
	
	public class glowtrail_emmiter extends MovieClip
	{

		private var __this:MovieClip;
		private var __parent:MovieClip;
		private var last_x:Number=0;
		private var last_y:Number=0;
		
		public var fade_factor:Number = .6;
		
		[Inspectable]
		public var separation:Number = 4;
		 
		[Inspectable]
		public var blending:String = "normal";
		

		//----------------------

		public function glowtrail_emmiter():void
		{
			
			__this = MovieClip(this);
			
			this.addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void
			{
				last_x = this.x;
				last_y = this.y;
				
				
				__parent = MovieClip(__this.parent);
				
				this.visible=false;
			
				addEventListener(Event.ENTER_FRAME, doEnterFrame); 
			});
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, function(e:Event):void
			{
				removeEventListener(Event.ENTER_FRAME, doEnterFrame); 
			});
		}
		

		public function doEnterFrame(e:Event):void{


			var dist:Number = blittools_general.getDist(this.x, this.y, last_x, last_y);
			var count:Number = Math.floor(dist/separation);
	
			if((this.x==0 && this.y==0) || __parent.visible==false || dist > 100){
				count=0;
			}
			
			var x_offset:Number = (this.x-last_x)/count;
			var y_offset:Number = (this.y-last_y)/count;
			
			for(var i:uint = 1; i<=count; i++){
				var trail:MovieClip = new glowtrail(blending);
				trail.fade_factor = fade_factor;
				trail.x = this.x - (x_offset * (i-1));
				trail.y = this.y - (y_offset * (i-1));
				__parent.addChild(trail);
			}

			last_x = this.x;
			last_y = this.y;

		}

		
	}
}