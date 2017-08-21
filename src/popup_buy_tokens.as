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
	
	public class popup_buy_tokens extends MovieClip
	{
		private var __timeline:MovieClip;
		private var __controller:*;
		private var __game:*;
		private var __this:MovieClip;
		private var game_id:int;
		private var oMESSAGES:Object;
		private var oPREFS:Object;
		private var gsnTools:gsnSlotsApi;
		private var msg:String;
		
		public function popup_buy_tokens(controller:Object, game:Object)
		{
			__controller = controller;
			__timeline = MovieClip(controller);
			__game = game;
			__this = MovieClip(this);
			
			oMESSAGES = __controller.oMESSAGES;
			oPREFS = __controller.oPREFS;
			gsnTools = __controller.gsnTools;
			
			this.addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void
			{
				doInit(); 
			});
		}


		// doInit()
		private function doInit():void
		{
			__this.gotoAndStop("init");
			for(var i:uint=0;i<10;i++){
				mc_tokensbuttons["mc_buy_" + i].visible=false;
				mc_tokensbuttons["mc_buy_" + i].y = 0;
			}
			gsnTools.requestTokenPricePoints(doShowTokenOptions);
			blittools_text.doSwapTxt(txt_hdr, oMESSAGES.title_buytokens, [__controller.font_helv_uc, __controller.font_arial_bold]);
			bClose.buttonMode=true;
			bClose.mouseChildren=false;
			bClose.addEventListener(MouseEvent.MOUSE_UP, function(e:Event) {
				__game.doResetTurn();
				doDestroy();
			});
		}


		//doShowTokenOptions
		public function doShowTokenOptions(e:Event):void
		{
			__controller.doDebug("doShowTokenOptions()");
			__controller.doDebug(e.target.data);
			
			//[{"tokens":1500,"credits":1,"bonusAmount":0}, 

			var myy:int = 0;
            var res:Object = JSON.decode(e.target.data);


			for(var i:uint=0;i<res.length;i++){
				
				var o:Object = res[i];
				var mc:MovieClip = mc_tokensbuttons["mc_buy_" + i];
				mc.y = myy;
				myy+=39;
				
				mc.mydata = o;
				mc.visible=true;
				
				mc.txtCost.text = String(o.credits);
				
				var msg:String
				if(o.bonusAmount>0){
					msg = gsnTools.doSubText(oMESSAGES.button_purchasetokens, {amt: blittools_general.doFormatNumber(o.tokens)});
					msg = gsnTools.doSubText(msg, {bonus: blittools_general.doFormatNumber(o.bonusAmount)});
				}else{
					msg = gsnTools.doSubText(oMESSAGES.button_purchasetokens_nobonus, {amt: blittools_general.doFormatNumber(o.tokens)});
				}

				blittools_text.doSwapTxt(mc.bBuy.txt, msg,  [__controller.font_arial_bold]);

				blittools_general.doInitButton(mc.bBuy);
				mc.bBuy.buttonMode = true;
				mc.bBuy.mouseChildren=false;
				mc.bBuy.addEventListener(MouseEvent.MOUSE_UP, function(e:Event) {
						__this.gotoAndStop("sending");
						__controller.doFullscreenOff();
						gsnTools.doBuyTokens(e.currentTarget.parent.mydata, doBuyTokenComplete, doBuyTokenCancel, doBuyTokenError);
				});
			}
			
			
			
			mc_tokensbuttons.y = mcSpinner.y - (mc_tokensbuttons.height * .5);
			
			
			__this.removeChild(mcSpinner);
		}


		//doBuyTokenComplete()
		public function doBuyTokenComplete(o:Object):void
		{
			
			__controller.doDebug("doBuyTokenComplete()");
			
			var metadataDesc:String = gsnTools.dumpObj(o);
			
			
			//{tokens:67560,currency:67560,paymentData:{quantity:15000,paymentAmount:2,facebookPaymentStatus:COMPLETED,purchaseSig:919ea244ae03bc5b504be2f14d1a8e9a,itemId:0,productUnitPrice:0.1,productTypeName:Tokens,productSKU:TokenPack.750,productCategory:Tokens,productTypeId:16,productQuantity:20,isTestMode:false,productName:750 Tokens Pack,credits:20}}
			
			
			__controller.doDebug("doReconcileTokensComplete():  o.tokens = " + o.tokens);

			//gsnTools.doSetVariable("bank", Number(o.tokens));
		
			//__game.doUpdateBank(0);
			//__game.doResetTurn();
			//doDestroy();
			
			
			//__controller.doDebug("purchase comeplete: ");
			//__controller.doDebug(metadataDesc);

 			gsnTools.doGetTokensBalance(doReconcileTokensComplete);

			
		}
		
		public function doReconcileTokensComplete(balance:Number):void
		{
			__controller.doDebug("doReconcileTokensComplete():  balance = " + balance);

			gsnTools.doSetVariable("bank", balance);
		
			__game.doUpdateBank(0);
			__game.doResetTurn();
			doDestroy();
		}
		
		//doBuyTokenCancel()
		public function doBuyTokenCancel():void
		{
			trace("purchase cancelled");
			doInit();
		}

		//doBuyTokenError()
		public function doBuyTokenError(msg:String):void
		{
			trace("error: " + msg);
			__game.doResetTurn();
			doDestroy();
		}

		//doDestroy()
		private function doDestroy():void
		{
			MovieClip(this.parent).removeChild(this);
		}



	}
}