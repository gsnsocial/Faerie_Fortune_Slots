package src
{

	import flash.events.Event;
	import flash.display.MovieClip;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.*;
	import flash.utils.*;
	
	public class freespin_panel extends MovieClip
	{

		private var num_spins:int = 0;
		private var new_spins:int = 0;
		
		public function freespin_panel():void{
			this.addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void
			{
				

			});

			this.addEventListener(Event.REMOVED_FROM_STAGE, function(e:Event):void
			{
				
			});
			
		}


		public function doUpdate(amt:int = 0):void
		{
			
			new_spins = amt;
			mc_coin.play();
			
			if(amt > num_spins){
				var delay:Number = 0;
				for(var i:int = num_spins; i<=new_spins; i++){
					 setTimeout(doAddSpin, delay);
					 delay += 140;
				}
			}else{
				num_spins = amt;
				txt.text = String(num_spins);
			}
			
			
			
			
		}
		
		public function doAddSpin():void
		{
			num_spins = Math.min(new_spins, num_spins + 1);
			txt.text = String(num_spins);
			
		}
		
		

	}
}