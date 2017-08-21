package src
{

	import flash.display.*;
	import flash.events.*;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.net.*;
	import flash.utils.*;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.*;
	import fl.motion.easing.Back;
	import flash.events.UncaughtErrorEvent;
	import flash.system.Security;
	import flash.system.SecurityDomain;
	import flash.external.ExternalInterface;

	import com.adobe.serialization.json.JSON;
	import com.gsn.flashgames.GsnApi;
	
	import src.gsnSlotsApi;
	import src.blit.*;
	
	
	public class popup_error_tokens extends MovieClip
	{

		
		private var __timeline:MovieClip;
		private var __controller:*;
		private var __game:*;
		private var game_id:int;
		private var oMESSAGES:Object;
		private var oPREFS:Object;
		private var gsnTools:gsnSlotsApi;
		
		private var msg:String;
		
		public function popup_error_tokens(controller:Object, game:Object)
		{
			__controller = controller;
			__timeline = MovieClip(controller);
			__game = game;
			
			oMESSAGES = __controller.oMESSAGES;
			oPREFS = __controller.oPREFS;
			gsnTools = __controller.gsnTools;
			
			this.addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void
			{
				doInit(); 
			});
		}
		
		
		
		private function doInit():void
		{

			gsnTools.logEvent("lowtoken", "open", "", gsnTools.doGetVariable("bank"));
			
			blittools_text.doSwapTxt(txt_hdr, oMESSAGES.title_tokens, [__controller.font_helv_uc, __controller.font_arial_bold]);

			if (gsnTools.doGetVariable("bank") < __game.betAmountsArr[0]) {
				__controller.doFullscreenOff();
				bLowerBet.enabled = false;
				bLowerBet.visible = false;
				bClose.enabled = false;
				bClose.visible = false;
				bPurchaseTokens.y+=34;
	
				var msg:String = gsnTools.doSubText(oMESSAGES.error_tokens_out, {amt: __game.betAmountsArr[0]});
				blittools_text.doSwapTxt(txt_msg, msg,  [__controller.font_arial_bold]);

			}else {
				blittools_text.doSwapTxt(txt_msg, oMESSAGES.error_tokens, [__controller.font_arial_bold]);
			}
			
			
			blittools_general.doInitButton(bLowerBet);
			blittools_text.doSwapTxt(bLowerBet.txt, oMESSAGES.button_lowerbet, [__controller.font_arial_bold]);
			bLowerBet.buttonMode=true;
			bLowerBet.mouseChildren=false;
			bLowerBet.addEventListener(MouseEvent.MOUSE_UP, function(e:Event) {
				if(e.currentTarget.enabled){
					gsnTools.logEvent("lowtoken", "complete", "decreasebet", gsnTools.doGetVariable("bank"));
					__game.doLowerBet();
					doDestroy();
				}
			});
			
			
			blittools_general.doInitButton(bPurchaseTokens);
			blittools_text.doSwapTxt(bPurchaseTokens.txt, oMESSAGES.button_buytokens, [__controller.font_helv_uc, __controller.font_arial_bold]);
			bPurchaseTokens.buttonMode=true;
			bPurchaseTokens.mouseChildren=false;
			bPurchaseTokens.addEventListener(MouseEvent.MOUSE_UP, function(e:Event) {
				if(e.currentTarget.enabled){
					gsnTools.logEvent("lowtoken", "complete", "purchase", gsnTools.doGetVariable("bank"));
					__game.doBuyTokens();
					doDestroy();
				}
			});
			
			bClose.buttonMode=true;
			bClose.mouseChildren=false;
			bClose.addEventListener(MouseEvent.MOUSE_UP, function(e:Event) {
				gsnTools.logEvent("lowtoken", "complete", "cancel", gsnTools.doGetVariable("bank"));
				__game.doResetTurn();
				doDestroy();
			});
			
		}





		//doDestroy()
		private function doDestroy():void
		{
			MovieClip(this.parent).removeChild(this);
		}

	}
}