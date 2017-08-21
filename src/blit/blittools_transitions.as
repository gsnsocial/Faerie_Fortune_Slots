package src.blit {
	
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.ColorTransform;
	
	import fl.motion.Color;
	
	import flash.display.MovieClip;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PixelSnapping;
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.events.*;
	import flash.display.Stage;
	import flash.display.StageQuality;
	
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.*;
			
	public class blittools_transitions{
		
			
			
			public static var tweenHolder:Array = new Array();

			//doStartCrossfade()
			public static function doStartCrossfade(myClip:MovieClip, duration:Number, w:Number = 0, h:Number = 0):MovieClip
			{

				var myBitmap:Bitmap = new Bitmap();
				var transition_w:Number = myClip.width;
				var transition_h:Number = myClip.height;
				
				if(w>0){
					transition_w = w;
				}
				if(h>0){
					transition_h = h;
				}
				
				
				var bd:BitmapData = new BitmapData(transition_w,transition_h, false, 0x000000);
				bd.draw(myClip);
				myBitmap.bitmapData = bd;
				myBitmap.pixelSnapping = PixelSnapping.AUTO;
				myBitmap.smoothing = false;
				var newClip:MovieClip = new MovieClip();
				newClip.addChild(myBitmap);
				newClip.myBitmap = myBitmap;
				
				//add to screen
				var myHolder:MovieClip = myClip;
				myHolder.addChild(newClip);
				
				//fade out
				if(duration > 0){
					var tw:Tween = new Tween(newClip, "alpha", None.easeNone,  1, 0, duration, true);
					tweenHolder.push(tw);
					tw.addEventListener(TweenEvent.MOTION_FINISH, doDestroy);
				}
				
				return newClip;
				
			}
			
			//doDestroy()
			private static function doDestroy(e:Event):void{
				var me:MovieClip = MovieClip(e.currentTarget.obj);
				me.parent.removeChild(me);
			}

			
			
	}
}