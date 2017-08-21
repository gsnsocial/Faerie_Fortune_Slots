package src
{

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import src.gsnSlotsApi;
	import src.blit.*;
	
	
	public class popup_error_general extends MovieClip
	{

		private var __timeline:MovieClip;
		private var __controller:*;
		private var __game:*;
		private var game_id:int;
		private var oMESSAGES:Object;
		private var oPREFS:Object;
		private var gsnTools:gsnSlotsApi;
		
		private var msg_title:String;
		private var msg_error:String;
		private var callback:Function;
		
		public function popup_error_general(controller:Object, msg_t:String = "", msg_e:String = "", c:Function = null)
		{

			__controller = controller;
			__timeline = MovieClip(controller);
			
			oMESSAGES = __controller.oMESSAGES;
			oPREFS = __controller.oPREFS;
			gsnTools = __controller.gsnTools;
						
			msg_title=msg_t;
			msg_error=msg_e;
			callback = c;
			
			this.addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void
			{
				doInit(); 
			});
		}
		
		
		
		private function doInit():void
		{
			__timeline.doFullscreenOff();
			
			blittools_text.doSwapTxt(txt_hdr, msg_title);
			blittools_text.doSwapTxt(txt_msg, msg_error);
			
			if(callback is Function){
				bClose.buttonMode=true;
				bClose.mouseChildren=false;
				bClose.addEventListener(MouseEvent.MOUSE_UP, function(e:Event) {
					callback();
					doDestroy();
				});
				
				
				blittools_text.doSwapTxt(bOk.txt, oMESSAGES.button_ok);
				bOk.buttonMode=true;
				bOk.mouseChildren=false;
				bOk.addEventListener(MouseEvent.MOUSE_UP, function(e:Event) {
					callback();
					doDestroy();
				});
			}else{
				bClose.visible=false;
				bOk.visible=false;
			}

		}
		
		private function doDestroy(){
			MovieClip(this.parent).removeChild(this);
		}
		
	}
}