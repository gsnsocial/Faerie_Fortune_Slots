package src.symbols
{

	import flash.events.Event;
	import flash.display.MovieClip;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.*;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.geom.Matrix;
	import flash.geom.PerspectiveProjection;
	
	public class symbol_W extends MovieClip
	{

		private var my_speed:Number = 1;
		private var myx:int = 0;
		
		
		public function symbol_W():void{
			this.addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void
			{
				mc_sky.scrollRect = new Rectangle(myx,0,120,100);
				mc_sky.addEventListener(Event.ENTER_FRAME, doScrollSky);
				
				var pp:PerspectiveProjection = new PerspectiveProjection();
				pp.fieldOfView=40;
				pp.projectionCenter=new Point(mc_txt.x ,mc_txt.y);
				mc_txt.transform.perspectiveProjection = pp;
			
			});

			this.addEventListener(Event.REMOVED_FROM_STAGE, function(e:Event):void
			{
				mc_sky.removeEventListener(Event.ENTER_FRAME, doScrollSky);
			});
			
		}
		
		public function doStop():void
		{
			mc_sky.removeEventListener(Event.ENTER_FRAME, doScrollSky);
		}

		public function doHighlight():void
		{
			new Tween(mc_txt, "rotationY", Regular.easeIn,  0, -90, .35, true).addEventListener(TweenEvent.MOTION_FINISH, doFlip2);
		}
		
		private function doFlip2(e:Event){
			new Tween(mc_txt, "rotationY", Regular.easeOut,  -90, 0, .35, true).addEventListener(TweenEvent.MOTION_FINISH, doFlip3);
		}
		
		private function doFlip3(e:Event){
			mc_txt.transform.matrix = new Matrix(1, 0, 0, 1, mc_txt.x, mc_txt.y);
		}
		
		
		

		public function doScrollSky(e:Event):void
		{
			var rect:Rectangle = e.currentTarget.scrollRect;
			rect.x += my_speed;
			if(rect.x > 211){
				rect.x -= 211;
			}
			e.currentTarget.scrollRect = rect;
		}
			
			


	}
}