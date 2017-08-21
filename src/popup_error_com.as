package src
{

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.*
	
	import src.gsnSlotsApi;
	import src.blit.*;
	
	public class popup_error_com extends MovieClip
	{

		private var __timeline:MovieClip;
		private var __controller:*;
		private var __game:*;
		private var game_id:int;
		private var oMESSAGES:Object;
		private var oPREFS:Object;
		private var gsnTools:gsnSlotsApi;
		
		
		private var callback:Function;
		
		public function popup_error_com(controller:Object, c:Function)
		{
			__controller = controller;
			__timeline = MovieClip(controller);
			
			callback = c;
			oMESSAGES = __controller.oMESSAGES;
			oPREFS = __controller.oPREFS;
			gsnTools = __controller.gsnTools;
			
			this.addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void{
				doInit(); 
			});
		}
		
		
		
		private function doInit():void
		{

			//force exit full screen
			__timeline.doFullscreenOff();
			
			//buttons
			blittools_general.doInitButton(bCancel);
			blittools_general.doInitButton(bTryAgain);
			blittools_text.doSwapTxt(bCancel.txt, oMESSAGES.button_cashout);
			blittools_text.doSwapTxt(bTryAgain.txt, oMESSAGES.button_tryagain);
			
			bTryAgain.buttonMode=true;
			bTryAgain.mouseChildren=false;
			bTryAgain.addEventListener(MouseEvent.MOUSE_UP, function(e:Event) {
				callback();
				doDestroy();
			});
			
			bCancel.buttonMode=true;
			bCancel.mouseChildren=false;
			bCancel.addEventListener(MouseEvent.MOUSE_UP, function(e:Event) {
				gsnTools.logEvent("cashOut", "clicked");
				blittools_sounds.playSound("snd_click", "INTERFACE");
				__controller.doFullscreenOff();
				try{
				   ExternalInterface.call("cashOutFromGame");
				 }catch(e:Error) {
				  __controller.doDebug(e);
				 }
			});
			
			//title
			blittools_text.doSwapTxt(txt_hdr, __timeline.oMESSAGES.title_error);
		
			//message
			var msg:String = oMESSAGES.servererror_io_1 + "\n\n" + oMESSAGES.servererror_io_2;
			blittools_text.doSwapTxt(txt_msg, msg);
		
		
		}

		//doDestroy()
		private function doDestroy(){
			__timeline.removeChild(this);
		}


	}
}