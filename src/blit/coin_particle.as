package src.blit

{
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.display.MovieClip;
	
	import flash.utils.*;
	import src.blit.*;

	public class coin_particle extends MovieClip
	{

		private var speed_x:Number = 0;
		private var speed_y:Number = 0;
		private var gravity:Number = 0;
		private var spin:Number = 0;
		private var trail_clip:MovieClip = null;
		private var trail_layer:MovieClip = null;
		
		
		private var __controller:*;
		
		public var start_delay:Number = 0;
		public var decel_x:Number = .97;
		
		//constructor:
		public function coin_particle(clip:MovieClip = null, sx:*=null, sy:*=null, g:*=1, s:*=null):void
		{
			
			
			this.visible=false;
			if(sx==null){
				sx = -20 + Math.random()*40;
			}
			if(sy==null){
				sy = -10 - Math.random()*20;
			}
			if(s==null){
				s = -10 + Math.random()*10;
			}
			
			speed_x = sx;
			speed_y = sy;
			gravity = g;
			spin = s;
			trail_layer = clip;
			
			this.addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void{
								  
				__controller = MovieClip(root);
								  
				this.rotation = Math.random()*360;
				var myTimer:Timer = new Timer(start_delay, 1);
				myTimer.addEventListener(TimerEvent.TIMER_COMPLETE, doStart);
				myTimer.start();
			});

			
		}
		
		private function doStart(e:*=null){
			this.visible=true;
			
			if(getTimer() > __controller.last_coin_snd+100){
				if(__controller.last_coin_channel==1){
					__controller.last_coin_channel=2;
				}else{
					__controller.last_coin_channel=1;
				}
				blittools_sounds.playSound("snd_coins_2", "COINS" + __controller.last_coin_channel);
				__controller.last_coin_snd = getTimer();
			}
			
			if(trail_layer){
				trail_clip = new glowtrail_emmiter();
				trail_clip.x = this.x;
				trail_clip.y = this.y;
				trail_clip.visible = false;
				trail_layer.addChild(trail_clip);
			}
			
			this.addEventListener(Event.ENTER_FRAME, doEnterFrame, false, 0, true);
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, function(e:Event):void{
				removeEventListener(Event.ENTER_FRAME, doEnterFrame);  
			});
		}
		
		//doEnterFrame()
		private function doEnterFrame(e:Event):void
		{
			
			this.x += speed_x;
			this.y += speed_y;
			this.rotation += spin;
			
			speed_y += gravity;
			speed_x *= decel_x;
			
			if(trail_clip){
				trail_clip.x = this.x;
				trail_clip.y = this.y;
			}

			if(this.y >= 600){
				if(trail_clip){
					trail_clip.parent.removeChild(trail_clip);
				}
				
				
				
				
				
				this.parent.removeChild(this);
			
			}
		}

		
	}
}