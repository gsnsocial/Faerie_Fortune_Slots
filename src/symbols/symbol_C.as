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
	
	public class symbol_C extends MovieClip
	{

		public function symbol_C():void{
			this.addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void
			{
				var pp:PerspectiveProjection = new PerspectiveProjection();
				pp.fieldOfView=40;
				pp.projectionCenter=new Point(mc_animal.x ,mc_animal.y);
				mc_animal.transform.perspectiveProjection = pp;
			
			});

		}
			
			
		public function doHighlight():void
		{
			mc_animal.rotationX=0;
			new Tween(mc_animal, "scaleX", Regular.easeOut,  1, 1.1, .33, true);
			new Tween(mc_animal, "scaleY", Regular.easeOut,  1, 1.1, .33, true).addEventListener(TweenEvent.MOTION_FINISH, doScale2);
		}
		
		private function doScale2(e:Event){
			new Tween(mc_animal, "scaleX", Regular.easeIn,  mc_animal.scaleX, 1, .33, true);
			new Tween(mc_animal, "scaleY", Regular.easeIn,  mc_animal.scaleY, 1, .33, true).addEventListener(TweenEvent.MOTION_FINISH, doRestore);
		}
		
		private function doRestore(e:Event){
			mc_animal.transform.matrix = new Matrix(1, 0, 0, 1, mc_animal.x, mc_animal.y);
		}

	}
}


