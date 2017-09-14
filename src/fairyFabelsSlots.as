package src 
{
	import com.adobe.serialization.json.JSON;
	import com.gsn.flashgames.GsnApi;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Matrix;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;
	import flash.system.Security;
	import flash.system.SecurityDomain;
	import flash.utils.Timer;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import fl.motion.easing.Back;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	
	import src.gsnSlotsApi;
	import src.blit.*;
	import fl.transitions.easing.*;

	public class fairyFabelsSlots {
		
		private var gsnTools:gsnSlotsApi;
		public var __game:fairyFabelsSlots;

		private var __timeline:MovieClip;
		private var __controller:*;
		private var game_id:int;

		private var oMESSAGES:Object;
		private var oGAMESTATE:Object;
		private var oRES:Object;
		
		
		private var oGAME:Object;
		private var oSPIN:Object;

		public var hasWinnings:Boolean;
		public var resultsQueue:Array;
		public var recapLines:Array;
		public var extra_icons:Array;
		public var reelItems:Array;
		public var wheelSpinning:Boolean;
		public var reelsActive:Array;
		public var userLocked:Boolean;
		public var resultsObject:Object;
		public var cashoutOk:Boolean;
		public var bigIcon:MovieClip;
		public var cardLineLookup:Array;
		public var spinStartTime:Number;
		public var obj_winlines:Object;
		
		public var badges_earned:Array;
		
		public var timeoutHolders:Array = new Array();
		public var tweenHolders:Array = new Array();
		public var tweenHolders2:Array = new Array();
		
		
		public var betAmountsArr:Array = new Array(400,1000,2000,5000,10000,20000,50000,100000,200000,500000,1000000,2000000,5000000,10000000);
		//public var betAmountsArr:Array = new Array(40,80,200,400,1000,2000,5000,10000,20000,50000,100000,200000,500000,1000000,2000000,5000000,10000000);
 		
		public var betAmountId:uint = 0;
		public var last_betid:int = -1;
		
		private var res_reels:Array;

		public var spin_count:uint = 0;
		public var override_for_freespin:Boolean=false;
		public var doing_bonusspin:Boolean = false;
		public var bonusspin_icons:Array = new Array();
		public var bonusspin_coins:Array = new Array();
		
		private var remind_mode:Boolean = false;
		
		private var reelstop_next:int;
		
		public var remind_spin_timeout:int = -1;
		public var fade_music_timeout:int = -1;
		
		public var need_freespin_panel:Boolean = false;
		public var has_freespin_panel:Boolean = false;
		
		
		
		public var tokens_from_winnings:Boolean = true;
		
		
		public var started_freespins:Boolean = false;
		private var stopBtnClicked:Boolean = false;
		private var myTimer:Timer;
		
		private var autoSpinCount:int = 0;
		private var waitingforAutoSpin:Boolean = false;
		private var autospin_grace:Number = 0;
		private var autoSpinToggle:Boolean;
		
		private var fairyAnimCountToRun:int = 0;
		private var fairyCountTimer:Timer;
	
		//-----------------------------
		// init
		//-----------------------------

		public function fairyFabelsSlots(controller:*, id:int, betAmountsArr2:Array = null)
		{

			var pp:PerspectiveProjection;
			

			__controller = controller;
			__timeline = MovieClip(controller);
			__game = this;
			game_id = id;
			
			if (betAmountsArr2 != null) {
				betAmountsArr = betAmountsArr2;
			}
			
			//game variables
			oGAME = new Object();
			oGAME.freespins = 0;
			oGAME.freespinwinnings = 0;
			oGAME.freespinmode = false;
			oGAME.autospinmode = false;

			oMESSAGES = __controller.oMESSAGES;
			oGAMESTATE = __controller.oGAMESTATE;
			gsnTools = __controller.gsnTools;

			hasWinnings = false;
			extra_icons = new Array();
			reelItems = ["9","10","J","Q","K","A","B","C","D","E","F","S","W"];
			wheelSpinning = false;
			reelsActive = [null,false,false,false,false,false];
			userLocked = false;
			resultsObject = new Object();
			cashoutOk = false;
			spinStartTime=0;
			
			doChangeMessage();
			
			betAmountId = Math.min(doGetMaxBetId(), doGetDefaultBetId());
			gsnTools.doSetVariable("bet", betAmountsArr[betAmountId]);

			__timeline.mcReels.mask = __timeline.mcReelMask;
			__timeline.mcDimmer.alpha = 0;

			//win panel
			blittools_text.doSwapTxt(__timeline.mcPanelWin.txt_hdr, oMESSAGES.label_win, [__timeline.font_helv_uc]);
			pp = new PerspectiveProjection();
			pp.fieldOfView=40;
			pp.projectionCenter=new Point(__timeline.mcPanelWin.x,__timeline.mcPanelWin.y);
			__timeline.mcPanelWin.transform.perspectiveProjection = pp;
				
				

			gsnTools.doChangeIdleState("on");

					
			__timeline.mcFreeSpinCount.visible=false;
			__timeline.mc_spingroup.bSpin.visible=true;
 
			//line bet up
			__timeline.bBetUp.addEventListener(MouseEvent.CLICK, function(e:Event) {
				if(e.currentTarget.enabled){
					var proposedBetId:Number = Math.min(betAmountsArr.length-1, betAmountId+1); 
					blittools_sounds.playSound("snd_click_up", "INTERFACE");
					betAmountId = proposedBetId;
					gsnTools.doSetVariable("bet", betAmountsArr[betAmountId]);
					if(betAmountId < doGetMaxBetId()){
						__timeline.bBetUp.enabled=true;
						__timeline.bBetUp.alpha=1;
					}else{
						__timeline.bBetUp.enabled=false;
						__timeline.bBetUp.alpha=.3;
					}
					__timeline.bBetDn.enabled=true;
					__timeline.bBetDn.alpha=1;
					last_betid = betAmountId;
					gsnTools.logEvent("betvalue", "change",  "increase", gsnTools.doGetVariable("bet"));
					doUpdateBetDisplay();
				}
			});
	
			//line bet dn
			__timeline.bBetDn.addEventListener(MouseEvent.CLICK, function(e:Event) {
				if(e.currentTarget.enabled){
					betAmountId = Math.min(Math.max(0, betAmountId-1), doGetMaxBetId()); 
					gsnTools.doSetVariable("bet", betAmountsArr[betAmountId]);
					blittools_sounds.playSound("snd_click_dn", "INTERFACE");
					if(betAmountId <= 0){
						__timeline.bBetDn.enabled=false;
						__timeline.bBetDn.alpha=.3;
					}else{
						__timeline.bBetDn.enabled=true;
						__timeline.bBetDn.alpha=1;
					}
					__timeline.bBetUp.enabled=true;
					__timeline.bBetUp.alpha=1;
					last_betid = betAmountId;
					gsnTools.logEvent("betvalue", "change",  "decrease", gsnTools.doGetVariable("bet"));
					doUpdateBetDisplay();
				}
			});
			
			
			doUpdateBetDisplay();
	
			if (Math.min(doGetMaxBetId(), doGetDefaultBetId()) >= (betAmountsArr.length-1)){
				__timeline.bBetUp.enabled = false;
				__timeline.bBetUp.alpha = .3;
			}else if (doGetDefaultBetId() <= 0){
				__timeline.bBetDn.enabled = false;
				__timeline.bBetDn.alpha = .3;
			}
	
			//cash out
			blittools_text.doSwapTxt(__timeline.bCashOut.txt, oMESSAGES.button_cashout, [__timeline.font_arial_bold]);
			blittools_general.doInitButton(__timeline.bCashOut);
			__timeline.bCashOut.addEventListener(MouseEvent.CLICK, function(e:Event):void {
				if(e.currentTarget.enabled){
					gsnTools.logEvent("cashOut", "clicked");
					blittools_sounds.playSound("snd_click", "INTERFACE");
					__controller.doFullscreenOff();
					try{
					   ExternalInterface.call("cashOutFromGame");
					 }catch(e:Error) {
					  __controller.doDebug(e);
					 }
				}
			});
			
			//pay tables
			blittools_text.doSwapTxt(__timeline.bPaytable.txt, oMESSAGES.button_paytables, [__timeline.font_arial_bold]);
			blittools_general.doInitButton(__timeline.bPaytable);
			__timeline.bPaytable.addEventListener(MouseEvent.MOUSE_DOWN, function(e:Event) {
				var me:MovieClip = MovieClip(e.currentTarget);
				if(me.enabled){
					blittools_sounds.playSound("snd_click", "INTERFACE");
					var mc:MovieClip = new popup_paytable(__controller);
					__timeline.addChild(mc);
				}
			});

			//buy tokens
			blittools_text.doSwapTxt(__timeline.bBuy.txt, oMESSAGES.button_buy, [__timeline.font_arial_bold]);
			blittools_general.doInitButton(__timeline.bBuy);
			__timeline.bBuy.addEventListener(MouseEvent.CLICK, function(e:Event) {
				if(e.currentTarget.enabled && cashoutOk){
					__controller.doFullscreenOff();
					blittools_sounds.playSound("snd_click", "INTERFACE");
					if(__controller.premiumCurrency){
						gsnTools.doBuyPremiumTokens(Number(gsnTools.doGetVariable("bet")));
					}else{
						var mc:MovieClip = new popup_buy_tokens(__controller, __game);
						__timeline.addChild(mc);
					}
				}
			});
			
			
			
			//auto spin
			__timeline.mc_spingroup.mcAutoSpinSelect.visible = false;
			blittools_text.doSwapTxt(__timeline.mc_spingroup.bAutoSpin.txt, oMESSAGES.button_autospin, [__controller.font_helv_uc, __timeline.font_arial_bold]);
			blittools_text.doSwapTxt(__timeline.mc_spingroup.bAutoSpinStop.txt, oMESSAGES.button_stop, [__controller.font_helv_uc, __timeline.font_arial_bold]);
			blittools_general.doInitButton(__timeline.mc_spingroup.bAutoSpin);
			blittools_general.doInitButton(__timeline.mc_spingroup.bAutoSpinStop);
			blittools_general.doInitButton(__timeline.mc_spingroup.mcAutoSpinSelect.b5);
			blittools_general.doInitButton(__timeline.mc_spingroup.mcAutoSpinSelect.b10);
			blittools_general.doInitButton(__timeline.mc_spingroup.mcAutoSpinSelect.b25);
			blittools_general.doInitButton(__timeline.mc_spingroup.mcAutoSpinSelect.b50);
			
			__timeline.mc_spingroup.bAutoSpin.enabled = false;
			__timeline.mc_spingroup.bAutoSpinStop.visible = false;
			
			__timeline.mc_spingroup.bAutoSpin.addEventListener(MouseEvent.CLICK, function(e:Event) {
				if(!__controller.isPaused && __controller.can_play && e.currentTarget.enabled){
					var me:MovieClip = MovieClip(e.currentTarget);
					if(__timeline.mc_spingroup.bSpin.enabled && autoSpinCount==0){
						blittools_sounds.playSound("snd_click", "INTERFACE");
  						
						if(!autoSpinToggle){
							__timeline.mc_spingroup.mcAutoSpinSelect.visible=true;
							autoSpinToggle = true;
  						}else{
							__timeline.mc_spingroup.mcAutoSpinSelect.visible=false;
							autoSpinToggle = false;
						}
						
						//__timeline.mc_spingroup.bAutoSpin.visible=false;
						
						return;
					}
				}
			});			
			
 			//stop button
			__timeline.mc_spingroup.bAutoSpinStop.addEventListener(MouseEvent.CLICK, function(e:Event) {
				if(!__controller.isPaused && __controller.can_play && e.currentTarget.enabled){
					blittools_text.doSwapTxt(__timeline.mc_spingroup.bAutoSpinStop.txt, oMESSAGES.button_stopping, [__controller.font_helv_uc, __timeline.font_arial_bold]);
					__timeline.mc_spingroup.bAutoSpinStop.enabled = false;
					__timeline.mc_spingroup.bAutoSpinStop.visible = false;
					__timeline.mc_spingroup.bAutoSpin.visible = true;
					autoSpinCount = 0;
				}
			});
			
			
			//auto spin options
			__timeline.mc_spingroup.mcAutoSpinSelect.visible = false;
			__timeline.mc_spingroup.mcAutoSpinSelect.b5.addEventListener(MouseEvent.CLICK, function(e:Event) {
				doStartAutoSpin(5); 
			});
			__timeline.mc_spingroup.mcAutoSpinSelect.b10.addEventListener(MouseEvent.CLICK, function(e:Event) {
				doStartAutoSpin(10); 
			});
			__timeline.mc_spingroup.mcAutoSpinSelect.b25.addEventListener(MouseEvent.CLICK, function(e:Event) {
				doStartAutoSpin(25); 
			});
			__timeline.mc_spingroup.mcAutoSpinSelect.b50.addEventListener(MouseEvent.CLICK, function(e:Event) {
				doStartAutoSpin(50); 
			});
			
			
			
	
			//spin;
			blittools_text.doSwapTxt(__timeline.mc_spingroup.bSpin.txt, oMESSAGES.button_spin, [__controller.font_helv_uc, __timeline.font_arial_bold]);
			blittools_general.doInitButton(__timeline.mc_spingroup.bSpin);
			blittools_general.doInitButton(__timeline.mc_spingroup.bStop);
			__timeline.mc_spingroup.bSpin.addEventListener(MouseEvent.CLICK, function(e:Event) {
				if(e.currentTarget.enabled){

					//cancel autospin
					if(!oGAME.autospinmode){
						doStopAutoSpin();
					}
					
					started_freespins = false;
					if(gsnTools.doGetVariable("bet") <= gsnTools.doGetVariable("bank")){
						doChangeMessage();
						doRequestSpin();
					}else{
						
						if(oGAME.autospinmode){
							doStopAutoSpin();
						}
 						
						blittools_sounds.playSound("snd_error", "INTERFACE");
						var mc:MovieClip = new popup_error_tokens(__controller, __game);
						__timeline.addChild(mc);
						__timeline.mc_spingroup.bSpin.enabled = false;
					}
				}
			});
	
			// stop button
			__timeline.mc_spingroup.bStop.addEventListener(MouseEvent.CLICK, stopAllReels);
			
			//setup bank
			__timeline.mcBank.isUpdating = false;
			__timeline.mcBank.targetValue = gsnTools.doGetVariable("bank");
			__timeline.mcBank.currentValue = gsnTools.doGetVariable("bank");
			__timeline.mcBank.txt.text = String(blittools_general.doFormatNumber(gsnTools.doGetVariable("bank")));

			doInitWheels();
			
			//start in 1 second
			var myTimer:Timer = new Timer(1000, 1);
			myTimer.addEventListener(TimerEvent.TIMER_COMPLETE, doResetTurn);
			myTimer.start();
			
			//set spin reminder
			fade_music_timeout = setTimeout(doFadeMusic, 5 * 60000);
			remind_spin_timeout = setTimeout(doRemindSpin, 5000);
		
			__controller.can_play = true;
		}
		

		public function doRemindSpin():void{
			if(remind_spin_timeout != -1){
				remind_spin_timeout = -1;
				tweenHolders.push(new Tween(__timeline.mc_spingroup.bSpin.mc_sheen, "x", None.easeNone, -100, 122, 2, true));
				remind_spin_timeout = setTimeout(doRemindSpin, 5000);
			
			}
		}
		
		public function doFadeMusic():void{
			if(fade_music_timeout != -1){
				fade_music_timeout = -1;
				trace("fade music");
				blittools_sounds.fadeSound("MUSIC", 0, 2);
			
			}
		}
		
		//doInitWheels()
		public function doInitWheels():void
		{
			for (var col:int = 1; col<=5; col++){
				for (var row:int = 1; row<=4; row++){
					var myClip:MovieClip = __timeline.mcReels["mcItems_" + col + "_" + row];
					var id:int = Math.floor(Math.random()*(9));
					var key:String = reelItems[id];
					myClip.gotoAndStop("symbol_" + key);
					myClip.visible = true;
					myClip.scaleX = 1;
					myClip.myy = myClip.y;
					
					
					var myFrameClip:MovieClip = __timeline.mcReelFrames["mcItems_" + col + "_" + row];
					myFrameClip.visible = false;
				}
			}

			__timeline.mcBlur1.gotoAndStop(1);
			__timeline.mcBlur1.visible=false;
			__timeline.mcBlur2.gotoAndStop(1);
			__timeline.mcBlur2.visible=false;
			__timeline.mcBlur3.gotoAndStop(1);
			__timeline.mcBlur3.visible=false;
			__timeline.mcBlur4.gotoAndStop(1);
			__timeline.mcBlur4.visible=false;
			__timeline.mcBlur5.gotoAndStop(1);
			__timeline.mcBlur5.visible=false;
			
			
			//remove the extra icons
			for (var i:int = 0; i<extra_icons.length; i++){
				__timeline.removeChild(extra_icons[i]);
				extra_icons[i]=null;
			}
			extra_icons = [];
 			
   		}
		 
		//--------------------------------------
		// general
		//--------------------------------------
		
		//doUpdateBetDisplay()
		private function doUpdateBetDisplay():void
		{
			var newStr:String = blittools_general.doFormatNumber(gsnTools.doGetVariable("bet"));
			if (__timeline.mcPanelBet.txt.text != newStr){
				//__timeline.mcPanelBet.gotoAndPlay("flash");
			}
			__timeline.mcPanelBet.txt.text = newStr;

		}

		//doChangeMessage()
		public function doChangeMessage(symbols:Array = null, newMessage:String=null, animate:Boolean = true):void
		{
			var i:int;
			if(symbols == null){
				symbols = [];
			}
			
			//clear symbols
			for(i=0; i<5; i++){
				__timeline.mcResults["symbol_" + i].visible=false;
				__timeline.mcResults["symbol_" + i].gotoAndStop("clear");
			}

			if(newMessage==null){
				__timeline.mcResults.visible=false;
			}else{
				
				for(i=0; i<symbols.length; i++){
					__timeline.mcResults["symbol_" + i].visible=true;
					__timeline.mcResults["symbol_" + i].gotoAndStop("symbol_" + symbols[i]);
				}

				blittools_text.doSwapTxt(__timeline.mcResults.txt, newMessage, [__timeline.font_arial_bold]);
				__timeline.mcResults.visible=true;
				
				if(animate){
					new Tween(__timeline.mcResults, "scaleX", Regular.easeOut, .8, 1, .3, true);
					new Tween(__timeline.mcResults, "scaleY", Regular.easeOut,.8, 1, .3, true);
				}
 			}
		}
		
 
 		//doUpdateBank()
		public function doUpdateBank(from_win:Boolean = true):Number
		{
			var new_bank:Number = gsnTools.doGetVariable("bank");
			var cur_bank:Number = __timeline.mcBank.currentValue;
			var mc_msg:MovieClip;
			var anim_time:Number = 0;
			
			if(new_bank > cur_bank){
				
				if(new_bank - __timeline.mcBank.currentValue < 50){
					blittools_sounds.playSound("snd_payout_2", "SFX1");
					__timeline.mcBank.currentValue = new_bank;
					__timeline.mcBank.targetValue = new_bank;
					__timeline.mcBank.txt.text = blittools_general.doFormatNumber(new_bank);
					anim_time = .5;
				
				}else{

					var win_multiple:Number = (new_bank - cur_bank) / gsnTools.doGetVariable("bet");
					anim_time = Math.max(.5, Math.min(10, win_multiple));
					
					
					if(from_win){
						__timeline.mcBank.need_coins = true;
							
						if(win_multiple > 10){
							if(win_multiple > 50){
								mc_msg = new bigwin_msg("incredible", anim_time);
								blittools_sounds.playSound("vo_incredible", "VO");
								blittools_sounds.playSound("snd_payout_1", "SFX3");
							}else if(win_multiple > 25){
								mc_msg = new bigwin_msg("hugewin", anim_time);
								blittools_sounds.playSound("vo_hugewin", "VO");
							}else{
								mc_msg = new bigwin_msg("bigwin", anim_time);
								blittools_sounds.playSound("vo_bigwin", "VO");
							}
							mc_msg.x = 380;
							mc_msg.y = 260;
							__timeline.mcBank.mc_msg = __timeline.addChild(mc_msg);
//							mc_msg.addEventListener(Event.ENTER_FRAME, onSparkleAnimation);
						 
						}
					}
					
					
					if(from_win==false || win_multiple < 1 ){
						__timeline.mcBank.need_coins = false;
					}
					
					__timeline.mcBank.targetValue = new_bank;
					__timeline.mcBank.stepValue = Math.ceil((__timeline.mcBank.targetValue-__timeline.mcBank.currentValue)/(anim_time*30) );
					if(__timeline.mcBank.hasEventListener(Event.ENTER_FRAME)==false ) {
						blittools_sounds.playSound("snd_payout_loop", "SFX1", 100);
						__timeline.mcBank.frame_counter = 0;
						__timeline.mcBank.addEventListener(Event.ENTER_FRAME, doAnimateBank);
					}
				}
			}else if(new_bank <__timeline.mcBank.currentValue){
				__timeline.mcBank.currentValue = new_bank;
				__timeline.mcBank.targetValue = new_bank;
				__timeline.mcBank.txt.text = blittools_general.doFormatNumber(new_bank);
			}else{
				__timeline.mcBank.txt.text = blittools_general.doFormatNumber(new_bank);
			}
			
			return anim_time;
		}
		
		/*private function onSparkleAnimation(eve:Event):void
		{
			trace("coming here ::")
			var me:MovieClip = MovieClip(eve.target);
			
			if(__timeline.mcBank.currentValue == __timeline.mcBank.targetValue)
			{
				me.removeEventListener(Event.ENTER_FRAME, onSparkleAnimation);
				__timeline.removeChild(me);
			}
 		} */
		
 		
		//doUpdateBank()
		public function doSnapBank():void
		{
	
			if(__timeline.mcBank.hasEventListener(Event.ENTER_FRAME)) {
				__timeline.mcBank.removeEventListener(Event.ENTER_FRAME, doAnimateBank);
			}
			
			blittools_sounds.stopSound("SFX1");
			
			try{
				__timeline.mcBank.mc_msg.doDestroy();
			}catch(e){
				
			}
 			
			var new_bank:Number = gsnTools.doGetVariable("bank");
			__timeline.mcBank.currentValue = new_bank;
			__timeline.mcBank.targetValue = new_bank;
			__timeline.mcBank.txt.text = blittools_general.doFormatNumber(new_bank);
		}
		
		//doAnimateBank()
		public function doAnimateBank(e:Event):void
		{
			var me:MovieClip = MovieClip(e.currentTarget);
			if (me.targetValue > me.currentValue){
				me.currentValue = Math.floor(Math.min(me.targetValue, me.currentValue + me.stepValue));
				me.txt.text = blittools_general.doFormatNumber(me.currentValue);
				
				if(me.need_coins){
					if(me.frame_counter <=0){
						me.frame_counter=8;
						var coin:MovieClip = new coin_particle();
						coin.decel_x = .8;
						coin.x = __timeline.mcResults.x - 100 + (Math.random()*200);
						coin.y = __timeline.mcResults.y - 50;
						coin.scaleX=coin.scaleY=.7;
						__timeline.addChild(coin);
					}
					me.frame_counter--;
				}
 				
			}else{
				me.currentValue = me.targetValue;
				me.txt.text = blittools_general.doFormatNumber(me.currentValue);
			}
			if (me.currentValue == me.targetValue){
				blittools_sounds.stopSound("SFX1");
				me.removeEventListener(Event.ENTER_FRAME, doAnimateBank);
  				//__timeline.removeChild(me);
  			}
		}
		
		//doGetDefaultBetId()
		public function doGetDefaultBetId():int
		{
			if(last_betid != -1){
				return last_betid;
			}
			var i:int;
			var b:Number = gsnTools.doGetVariable("bank");
			var target:Number;
			target = b * .0375;

			var next_lowest_id:int = 0;
			var next_highest_id:int = betAmountsArr.length-1;
			var target_id:int;

			for(i=next_lowest_id; i<(betAmountsArr.length-1); i++){
				if(betAmountsArr[i]<target){
					next_lowest_id=i;
				}else{
					break;
				}
			}
			for(i=next_highest_id; i>=0; i--){
				if(betAmountsArr[i]>target){
					next_highest_id=i;
				}else{
					break;
				}
			}

			if(target - betAmountsArr[next_lowest_id] < betAmountsArr[next_highest_id] - target){
				target_id = next_lowest_id;
			}else{
				target_id = next_highest_id;
			}

			return target_id;
		}
		
		//doGetMaxBetId()
		public function doGetMaxBetId():int
		{
			return betAmountsArr.length-1;
		}
		
		public function doGetMaxValidBet():int
		{
			var i:int;
			var b:Number = gsnTools.doGetVariable("bank");
			for(i=(betAmountsArr.length-1); i>=0; i--){
				if(b >= betAmountsArr[i]){
					return i;
					break;
				}
			}
			return 0;
		}
		
		//----------------------------------------
		// spin sequence
		//----------------------------------------
		
		//doLockGame()
		public function doLockGame():void
		{
			userLocked = true;
			cashoutOk = false;
			__timeline.bBetUp.enabled = false;
			__timeline.bBetDn.enabled = false;
			__timeline.mc_spingroup.bSpin.enabled = false;
			__timeline.mc_spingroup.bAutoSpin.enabled = false;
			__timeline.bCashOut.enabled = false;
			__timeline.bPaytable.enabled = false;
			
			if(oGAME.autospinmode){
				__timeline.mc_spingroup.bSpin.txt.alpha = 1;
			}else{
				__timeline.mc_spingroup.bSpin.txt.alpha = .5;
				__timeline.mc_spingroup.bAutoSpin.txt.alpha = .5;
			}
			
			gsnTools.doChangeIdleState("off");
			
		}
		
		public function doUnLockGame():void
		{
			userLocked = false;
			cashoutOk = true;
			__timeline.bBetUp.enabled = true;
			__timeline.bBetDn.enabled = true;
			tweenHolders = new Array();
			timeoutHolders = new Array();
			__timeline.bCashOut.enabled = true;
			__timeline.bPaytable.enabled = true;
			__timeline.mc_spingroup.bSpin.visible = true;
			__timeline.mc_spingroup.bSpin.enabled = true;
			__timeline.mc_spingroup.bAutoSpin.enabled = true;
			autoSpinToggle = false;
			
			__timeline.mc_spingroup.bSpin.txt.alpha = 1;
			__timeline.mc_spingroup.bAutoSpin.txt.alpha = 1;

			clearTimeout(fade_music_timeout);
			clearTimeout(remind_spin_timeout);
			fade_music_timeout = setTimeout(doFadeMusic, 5 * 60000);
			remind_spin_timeout = setTimeout(doRemindSpin, 1000);
			
			gsnTools.doChangeIdleState("on");
			
			
		}



		public function doRecapTurn(e=null):void
		{
 			 var anim_time:Number;
			
			if(__controller.isPaused){
				__controller.pauseResumeFunction = doRecapTurn;
				return;
			}
			
			if(oGAME.freespinmode==true && oGAME.freespins > 0){
				
				if(started_freespins==false){
					started_freespins=true;
					anim_time  = doUpdateBank();
					__timeline.doDebug("anim_time = " + anim_time);
					setTimeout(doResetTurn, anim_time*1000);
				}else{
					doResetTurn();
				}
				
			}else if (hasWinnings==false){
				//reset
				__timeline.mcBank.txt.text = blittools_general.doFormatNumber(gsnTools.doGetVariable("bank"));
				doUpdateBank();
				doResetTurn();
				
			}else{
				//award winngins
				anim_time = doUpdateBank();
				doResetTurn(anim_time*1000);
			}
	
		}

		//doResetTurn()
		public function doResetTurn(extra_delay:Number = 0):void
		{
 			//---paused-------
			if(__controller.isPaused){
				__controller.pauseResumeFunction = doResetTurn;
				return;
			}
			//---------------			
  			
			gsnTools.doSetVariable("spinwinnings", 0);
 			var delay:Number = 0;
			var need_unlock:Boolean = false;
			
			if(oGAME.freespinmode){
 				if(oGAME.freespins > 0){
					delay += extra_delay;
 					oGAME.freespins--;
					__timeline.mcFreeSpinCount.doUpdate(oGAME.freespins);
					doRequestSpin(true);
					return;
 				}else{
					
					 blittools_sounds.setVol("MUSIC", .2, 0);
					 blittools_sounds.playSound("music", "MUSIC", 999, null);
					 oGAME.freespinmode = false;
					 __timeline.mc_spingroup.bSpin.enabled = true;
					 __timeline.mc_spingroup.bSpin.visible = true;
					 __timeline.mcFreeSpinCount.visible=false;
				 
 					 new Tween(__timeline.mc_spingroup.bSpin, "y", Regular.easeIn, __timeline.mc_spingroup.bSpin.y, 0.45, .5, true);
					 new Tween(__timeline.mc_spingroup.bSpin, "alpha", None.easeNone, __timeline.mc_spingroup.bSpin.alpha, 1, 1, true);
					 new Tween(__timeline.mc_spingroup.bStop, "y", Regular.easeIn, __timeline.mc_spingroup.bStop.y, 0.45, .5, true);
					 new Tween(__timeline.mc_spingroup.bStop, "alpha", None.easeNone, __timeline.mc_spingroup.bStop.alpha, 1, 1, true);
					new Tween(__timeline.mcBackground.sky2, "alpha", None.easeNone,  1, 0, 1, true).addEventListener(TweenEvent.MOTION_FINISH, function(e:Event){
						__timeline.mcBackground.sky2.visible=false;
					});
					
					delay += 1000;
  
				}
				
 			}
			
			//autospin
			if(oGAME.autospinmode){
				if(autoSpinCount > 0){
					//keep autospinning
					autoSpinCount--;
					delay += extra_delay;
					__timeline.mc_spingroup.bAutoSpinStop.txt.text = autoSpinCount;
					setTimeout(doResumeAutoSpin, delay);
					return;
				}else{
					//autospins depleated
					setTimeout(doStopAutoSpin, delay);
				}
			}
  				
					wincycle_id = 0;
					if(wincycle_arr.length > 0){
						wincycle_timeout = setTimeout(doCycleNextWin, 5000);			
					}
			
				   setTimeout(doUnLockGame, delay);
 		}
  
		//doResumeAutoSpin()
		private function doResumeAutoSpin(){
			
			//---paused-------
			if(__controller.isPaused){
				__controller.pauseResumeFunction = doResumeAutoSpin;
				return;
			}
			//---------------
			
			doUnLockGame();
			__timeline.mc_spingroup.bSpin.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		}
  		
		private var wincycle_timeout:int;
		private var wincycle_id:int;
		private var wincycle_arr:Array = [];
		
		private function doCycleNextWin(){
			clearTimeout(wincycle_timeout);
			
			//init reels
			var reel_col:uint;
			var reel_row:uint;
			for (reel_col = 1; reel_col<=5; reel_col++){
				for (reel_row = 1; reel_row<=4; reel_row++){
					var myFrameClip:MovieClip = __timeline.mcReelFrames["mcItems_" + reel_col + "_" + reel_row];
					myFrameClip.doStop();
					myFrameClip.visible = false;
				}
			}
			
			var o:Object =  wincycle_arr[wincycle_id];
			var symbols:Array = o.symbols;
			var icons:Array = o.icons;
			var msg:String = o.msg;
			
			for(var i:int = 0; i<icons.length; i++){
				var mc:MovieClip = icons[i];
				mc.my_iconclip.doHighlight();
				mc.my_frameclip.visible = true;
				mc.my_frameclip.doHighlight();
			}
			
			doChangeMessage(symbols, msg, false);
			
			wincycle_id++;
			if(wincycle_id >= wincycle_arr.length){
				wincycle_id = 0;
			}
			wincycle_timeout = setTimeout(doCycleNextWin, 2000);
		}
		
		
				//doStartAutoSpin()
		public function doStartAutoSpin(count:int):void
		{
 			
			trace("AUTO SPIN STARTED >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"+count);
			
			waitingforAutoSpin = false;
			autoSpinCount = (count-1);
			oGAME.autospinmode = true;
			
			//manage buttons
			__timeline.mc_spingroup.mcAutoSpinSelect.visible=false;
			__timeline.mc_spingroup.bAutoSpin.visible=false;
			__timeline.mc_spingroup.bAutoSpin.enabled=false;
			
			//stop button
			__timeline.mc_spingroup.bAutoSpinStop.visible = true;
			__timeline.mc_spingroup.bAutoSpinStop.enabled = false;
			__timeline.mc_spingroup.bAutoSpinStop.txt.alpha = .5;
			blittools_text.doSwapTxt(__timeline.mc_spingroup.bAutoSpinStop.txt, oMESSAGES.button_stop, [__controller.font_helv_uc, __timeline.font_arial_bold]);
			
			__timeline.mc_spingroup.bAutoSpinStop.txt.text = autoSpinCount;
			
			//automate spin
			__timeline.mc_spingroup.bSpin.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			
			setTimeout(doEnableAutoSpinStop, 500);
			
		}
		
		private function doEnableAutoSpinStop():void
		{
			__timeline.mc_spingroup.bAutoSpinStop.enabled = true;
			__timeline.mc_spingroup.bAutoSpinStop.txt.alpha = 1;	
			autoSpinToggle = false;
		}

		//doStartAutoSpin()
		public function doStopAutoSpin():void
		{
			
			waitingforAutoSpin = false;
			autoSpinCount = 0;
			oGAME.autospinmode = false;
			
			//manage buttons
			__timeline.mc_spingroup.mcAutoSpinSelect.visible=false;
			__timeline.mc_spingroup.bAutoSpin.visible=true;
			__timeline.mc_spingroup.bAutoSpinStop.visible=false;
			
			__timeline.mc_spingroup.bAutoSpin.enabled = false;
			__timeline.mc_spingroup.bAutoSpin.txt.alpha = 1;	
			
			blittools_text.doSwapTxt(__timeline.mc_spingroup.bSpin.txt, oMESSAGES.button_spin, [__controller.font_helv_uc, __timeline.font_arial_bold]);
			
			setTimeout(doEnableAutoSpin, 200);
			
		}
		
				
		private function doEnableAutoSpin():void
		{
			__timeline.mc_spingroup.bAutoSpin.enabled = true;
			__timeline.mc_spingroup.bAutoSpin.txt.alpha = 1;	
			autoSpinToggle = false;
			
		}

		//doRequestSpin()
		private function doRequestSpin(is_free:Boolean = false):void
		{
			stopBtnClicked = false;
			doLockGame();
			wincycle_arr = [];
			clearTimeout(wincycle_timeout);
			clearTimeout(fade_music_timeout);
			clearTimeout(remind_spin_timeout);

			//init
			var i:int;
			var reel_col:uint;
			var reel_row:uint;
			spinStartTime = getTimer();

			gsnTools.doSetVariable("spinwinnings", 0);
			gsnTools.doSetVariable("extra_winnings", 0);
			
			if(!is_free){
				
				doSnapBank();
				
				blittools_sounds.setVol("MUSIC", .2, 0);
				
				//update bank
				var new_bank:Number = gsnTools.doGetVariable("bank") - gsnTools.doGetVariable("bet");
				gsnTools.doSetVariable("bank", new_bank);
				doUpdateBank();
				
				if(need_freespin_panel==false && has_freespin_panel==true){
					has_freespin_panel=false;
					blittools_text.doSwapTxt(__timeline.mcPanelWin.txt_hdr, oMESSAGES.label_win, [__timeline.font_helv_uc]);
					new Tween(__timeline.mcPanelWin, "rotationX", None.easeOut,  -90, 0, .35, true).addEventListener(TweenEvent.MOTION_FINISH, function(e:Event){
						__timeline.mcPanelWin.transform.matrix = new Matrix(1, 0, 0, 1, __timeline.mcPanelWin.x, __timeline.mcPanelWin.y);
					});
				}
				
				blittools_text.doSwapTxt(__timeline.mcPanelWin.txt_hdr, oMESSAGES.label_win, [__timeline.font_helv_uc]);
				blittools_text.doSwapTxt(__timeline.mcPanelWin.txt, "0");
				
			}else{
				
				//set free spin totals panel
				if(need_freespin_panel==true && has_freespin_panel==false){
					has_freespin_panel=true;
					blittools_text.doSwapTxt(__timeline.mcPanelWin.txt_hdr, oMESSAGES.label_total, [__timeline.font_helv_uc]);
					var newStr:String = blittools_general.doFormatNumber(gsnTools.doGetVariable("bonusspin_winnings"));
					__timeline.mcPanelWin.txt.text = newStr;
					
					new Tween(__timeline.mcPanelWin, "rotationX", Regular.easeOut,  -90, 0, .35, true).addEventListener(TweenEvent.MOTION_FINISH, function(e:Event){
						__timeline.mcPanelWin.transform.matrix = new Matrix(1, 0, 0, 1, __timeline.mcPanelWin.x, __timeline.mcPanelWin.y);
					});
				
				}
 				
			}
  			
			//clear message
			doChangeMessage();
			

			//clear tween holder
			for(i=0; i<tweenHolders.length;i++){
				tweenHolders[i]=null;
			}
			tweenHolders = new Array();

			//remove the extra icons
			for (i = 0; i<extra_icons.length; i++){
				__timeline.removeChild(extra_icons[i]);
			}
			extra_icons = new Array();
		
			//init reels
			for (reel_col = 1; reel_col<=5; reel_col++){
				for (reel_row = 1; reel_row<=4; reel_row++){
					var myClip:MovieClip = __timeline.mcReels["mcItems_" + reel_col + "_" + reel_row];
					myClip.visible = true;
					myClip.myItem = -1;
					tweenHolders.push(new Tween(myClip, "y", None.easeNone,  myClip.y,  myClip.y-22, .25, true));
					
					var myFrameClip:MovieClip = __timeline.mcReelFrames["mcItems_" + reel_col + "_" + reel_row];
					
					myFrameClip.doStop();
					myFrameClip.visible = false;
				}
			}

			//start wheels spinning animations
			blittools_sounds.playSound("snd_spin", "SFX4");

			setTimeout(doSpinWheels, 250);
			
			//send spin
			gsnTools.sendSpin(gsnTools.doGetVariable("bet"));

		}
		

		//doSpinWheels()
		private function doSpinWheels():void
		{
			__timeline.mcBlur1.gotoAndPlay(1);
			__timeline.mcBlur1.visible=true;
			__timeline.mcBlur2.gotoAndPlay(3);
			__timeline.mcBlur2.visible=true;
			__timeline.mcBlur3.gotoAndPlay(2);
			__timeline.mcBlur3.visible=true;
			__timeline.mcBlur4.gotoAndPlay(1);
			__timeline.mcBlur4.visible=true;
			__timeline.mcBlur5.gotoAndPlay(3);
			__timeline.mcBlur5.visible=true;
			
			for(var col:int = 1; col<=5; col++){
				for(var row:int = 1; row<=4; row++){
 					__timeline.mcReels["mcItems_" + col + "_" + row].gotoAndStop("clear");
 					__timeline.mcReels["mcItems_" + col + "_" + row].visible=false;
				}
			}
		}
		
		//doGetSpinResults()
		public function doGetSpinResults(res:Object):void
		{
			var i:uint;
			
			__controller.doDebug("doGetSpinResults()");
			
			oSPIN = new Object();
			
			oSPIN.scatter_win = false;
			oSPIN.scatter_reels = 0;
			oSPIN.scatter_icons = new Array();
			
			oSPIN.fairy_possible = true;
			oSPIN.fairy_win = false;
			oSPIN.fairy_icons = new Array();
			
			oSPIN.wild_icons = new Array();
			
			oSPIN.free_spins = 0;
			oSPIN.accum_win = 0;
			
			oSPIN.tease_scatter = true;
			
			oSPIN.badges_won = new Array();
			
			wincycle_arr = new Array();
			
			resultsQueue = new Array();
			
			//get reel symbols
			res_reels = res.reels.slice();
			for (var reel_col:uint = 0; reel_col<5; reel_col++){
				for (var reel_row:uint = 0; reel_row<4; reel_row++){
					var tile_id:String = res.reels[reel_col][reel_row];
					var m:MovieClip = __timeline.mcReels["mcItems_" + (reel_col + 1) + "_" + (reel_row + 1)];
					m.myItem = tile_id;
					m.mykey = tile_id;
					m.inOutcome = false;
					if(oGAME.freespinmode && tile_id == "W"){
						m.myItem = "2W";
					}
				}
			}


			//queue outcomes
			if(res.outcomes.length > 0){
				for (i = 0; i < res.outcomes.length; i++){
					var outcome:Object = res.outcomes[i];
					if(outcome.symbols[0] == "S"){
						outcome.type = "scatter";
						oSPIN.scatter_win = true;
					}else if(outcome.symbols[0] == "F"){
						oSPIN.fairy_win = true;
					}
					
					var icons_arr:Array = new Array();
					//assign inOutcome to symbols
					for (var icon_col = 0; icon_col < 5; icon_col++){
						for (var icon_row = 0; icon_row < 4; icon_row++){
							if(outcome.outcomeIndicators[icon_col][icon_row] == 1){
								__timeline.mcReels["mcItems_" + (icon_col + 1) + "_" + (icon_row + 1)].inOutcome = true;
								
								icons_arr.push(__timeline.mcReels["mcItems_" + (icon_col + 1) + "_" + (icon_row + 1)]);
							}
						}
					}
					
					var my_msg:String;
					if(outcome.multiplier > 1){
						my_msg = "X " + outcome.multiplier + " PAYS " +  blittools_general.doFormatNumber(outcome.payout);
					}else{
						my_msg = "PAYS " + blittools_general.doFormatNumber(outcome.payout);
					}
					
					
					wincycle_arr.push({symbols:outcome.symbols, icons:icons_arr, msg:my_msg});
					resultsQueue.push(outcome);
				}
			}
			
			//check for new badges
			if(res.badgesWon.length > 0){
				for (i = 0; i < res.badgesWon.length; i++){
					var badge_obj:Object = res.badgesWon[i];
					badge_obj.type = "badge";
					resultsQueue.push(badge_obj);
					oSPIN.badges_won.push(badge_obj);
				}
			}
			
			//check for new free spins
			if(res.newGameState.pluginStates){
				for (i = 0; i < res.newGameState.pluginStates.length; i++){
					var pluginState:Object = res.newGameState.pluginStates[i];
					if(pluginState.type == "FreeSpin"){
						oSPIN.free_spins = pluginState.freeSpinsAwardedThisTurn;
						oGAME.freespins = pluginState.remainingFreePlays;
						gsnTools.doSetVariable("freespin_total", pluginState.totalTokensEarned);
					}
				}
			}
			
			//new token balance
			gsnTools.doSetVariable("bank", res.newGameState.tokenBalance);

			//stop spinning
			reelstop_next=1;
			var reelstop_delay = Math.max(0, (spinStartTime + (__controller.oPREFS.spin_holdtime - __controller.oPREFS.spin_stopinterval)) - getTimer());
			var myTimer:Timer = new Timer(reelstop_delay, 1);
			//myTimer.addEventListener(TimerEvent.TIMER_COMPLETE, doLandWheel);
			myTimer.addEventListener(TimerEvent.TIMER_COMPLETE, doStopWheels);
			myTimer.start();
			
			if (!oGAME.autospinmode) {
			   enableStopBtn();
			}
		}
		


		//stop each wheel
		private function doLandWheel(e:TimerEvent=null):void
		{
			trace("------------- DO LAND WHEEL ----------- " + reelstop_next)
			trace("doLandWheel(): " + reelstop_next);
			

			var myWheel:int = reelstop_next;
			var next_delay:Number = __controller.oPREFS.spin_stopinterval;
			
			var r:uint = Math.ceil(Math.random()*3);
			blittools_sounds.playSound("snd_gallop_" + myWheel, "SFX4");
			
			var i:int;
			var o:Object;
			
			var id:int = Math.floor(Math.random() * 12);
			var myClip:MovieClip;
			reelsActive[myWheel] = false;
			
			__timeline["mcBlur" + myWheel].gotoAndStop(1);
			__timeline["mcBlur" + myWheel].visible=false;
			
			var reel_has_scatter:Boolean = false;
			var reel_has_fairy:Boolean = false;
			var reel_has_wild:Boolean = false;
			
			//show reel symbols
			for(var row:uint=1; row<=4; row++){

				myClip = __timeline.mcReels["mcItems_" + myWheel + "_" + row];
				myClip.visible=true;
				myClip.gotoAndStop("symbol_" + myClip.myItem);

				tweenHolders.push(new Tween(myClip, "y", Elastic.easeOut,  myClip.myy-60,  myClip.myy, .8, true));

				//animate scatters
				if(myClip.myItem == "S"){
					reel_has_scatter = true;
					oSPIN.scatter_icons.push(myClip);
				}

				//log fairy icons
				if(myClip.myItem == "F"){
					if(myWheel == 1 || myClip.inOutcome){
						reel_has_fairy = true;
						oSPIN.fairy_icons.push(myClip);
					}else{
						myClip.iconF.doStop();
					}
				}
				
				//log wild icons
				if(myClip.myItem == "W" || myClip.myItem == "2W"){
					reel_has_wild = true;
					oSPIN.wild_icons.push(myClip);
				}
				
				
			}
 


			//----fairy----------------------
			if(reel_has_fairy){
				blittools_sounds.playSound("snd_fairy2", "SFX1");
			}else{
				if(oSPIN.fairy_win == false){
					for(i = 0; i <oSPIN.fairy_icons.length; i++){
						oSPIN.fairy_icons[i].iconF.doStop();
					}
				}
			}
			
			//----wilds----------------------
			if(myWheel==5 && oSPIN.wild_icons.length>0){
				for(i = 0; i <oSPIN.wild_icons.length; i++){
					if(oSPIN.wild_icons[i].inOutcome == false){
						var icon_name:String = "icon" + oSPIN.wild_icons[i].myItem;
						oSPIN.wild_icons[i][icon_name].doStop();
					}
				}
			}

			//----scatter----------------------
			if(reel_has_scatter){
				oSPIN.scatter_reels++;
				blittools_sounds.playSound("snd_bonus_" + oSPIN.scatter_reels, "SFX2");
			}
			
			//longer delay if scatter is possible
			if(oSPIN.scatter_reels >= 2){
				next_delay = __controller.oPREFS.spin_stopinterval*2;
			}
			
			
			if(myWheel==5 && oSPIN.scatter_icons.length > 0){
				for(i = 0; i <oSPIN.scatter_icons.length; i++){
					if(oSPIN.scatter_icons[i].inOutcome == false){
						oSPIN.scatter_icons[i].myicon.doStopAnimate();
					}
				}
			}
			
	
			//finish last reel
			if(myWheel==5){
				if(oSPIN.free_spins > 0){
					blittools_sounds.playSound("snd_firebell", "SFX3");
					for(i = 0; i <oSPIN.scatter_icons.length; i++){
						oSPIN.scatter_icons[i].myicon.doPulse();
					}
				}
				if (resultsQueue.length > 0){
					hasWinnings = true;
					disableStopBtn();
				}else{
					hasWinnings = false;
				}
				doNextResult();
			}else{
				if (reelstop_next < 5)
					reelstop_next++;
				/*var myTimer:Timer = new Timer(next_delay, 1);
				myTimer.addEventListener(TimerEvent.TIMER, doLandWheel);
				myTimer.start();*/
			}

		}
		
		
		// -----------------------------------
		// show spin results one after another
		// -----------------------------------
		//doNextResult()
		private function doNextResult():void
		{
			var myTimer:Timer;
			
			
			//--pause----
			if(__controller.isPaused){
				__controller.pauseResumeFunction = doNextResult;
				return;
			}
			//------------
			
			if (resultsQueue.length == 0){
				myTimer = new Timer(500, 1);
				myTimer.addEventListener(TimerEvent.TIMER_COMPLETE, doRecapTurn);
				myTimer.start();
			}else{
				myTimer = new Timer(500, 1);
				myTimer.addEventListener(TimerEvent.TIMER_COMPLETE, doNextResult2);
				myTimer.start();
			}

		}
		
		//display all results in turn
		public function doNextResult2(e=null):void
		{
			var res:Object = resultsQueue.shift();
			switch (res.type){
				
				case "way" :
					doShowWayResult(res);
					break;
					
				case "scatter" :
					doShowScatterResult(res);
					break;
					
				case "badge":
					doShowBadge(res);
					break;
					
	
			}
		}
		
		
		

		//-----------------------------
		// results
		//-----------------------------
		//doBadges()
		public function doShowBadge(res:Object):void
		{
			__controller.doDebug("doShowBadge()");
			
			/*
			"id": 878,
            "localizedName": "Wolf Pack",
            "imageUrl130": "https://cdn.mesmo.tv/uploads/badges/s130/b7204497561070177232.png",
            "imageUrl200": "https://cdn.mesmo.tv/uploads/badges/s200/b7204497561070177232.png",
            "imageUrl": "https://cdn.mesmo.tv/uploads/badges/s75/b7204497561070177232.jpg",
            "tokenAward": 1000,
            "localizedDescription": "Match 3 wolf symbols."
			*/

			gsnTools.doSetVariable("extra_winnings", gsnTools.doGetVariable("extra_winnings") + res.tokenAward);

			blittools_sounds.playSound("snd_badge", "SFX2");
			var mc:popup_badge = new popup_badge(__controller, __game, res, doNextResult);
			__timeline.addChild(mc);
			
		}

		
		public function doShowWayResult(res:Object):void
		{
			trace("doShowWayResult()");
			
			//indicate icons
			var winning_symbol:String = res.symbols[0];
			var icons:Array = res.outcomeIndicators;
			for(var col:int = 0; col < icons.length; col++){
				var col_array:Array = icons[col];
				for(var row:int = 0; row < col_array.length; row++){
					var myFrameClip:MovieClip = __timeline.mcReelFrames["mcItems_" + (col+1) + "_" + (row+1)];
					
					if(col_array[row] == 1){
						var mc:MovieClip = __timeline.mcReels["mcItems_" + (col+1) + "_" + (row+1)];
						mc.my_iconclip = mc["icon" + mc.myItem];
						mc.my_frameclip = myFrameClip;
						mc["icon" + mc.myItem].doHighlight();
						
						myFrameClip.visible = true;
						myFrameClip.doHighlight();
					}else{
 	 					myFrameClip.doStop();
 						myFrameClip.visible = false;
					}
				}
			}
			
			//play sound
			if(winning_symbol == "C"){
				blittools_sounds.playSound("snd_wolf", "INTERFACE");
			}else if(winning_symbol == "D"){
				blittools_sounds.playSound("snd_eagle", "INTERFACE");
			}else if(winning_symbol == "E"){
				blittools_sounds.playSound("snd_bear", "INTERFACE");
			}else if(winning_symbol == "B"){
				blittools_sounds.playSound("snd_bobcat", "INTERFACE");
			}else if(winning_symbol == "F"){
				blittools_sounds.playSound("snd_fairy", "INTERFACE");
			}else{
				blittools_sounds.playSound("snd_coins_2", "INTERFACE");
			}

			//show win message
			if(res.multiplier > 1){
				doChangeMessage(res.symbols, "X " + res.multiplier + " PAYS " +  blittools_general.doFormatNumber(res.payout));
			}else{
				doChangeMessage(res.symbols, "PAYS " + blittools_general.doFormatNumber(res.payout));
			}

			var next_delay = 1000;

			//animate bison
			if(winning_symbol == "F" && res.symbols.length >= 2){
				
				next_delay = 3000;
					
				if(res.symbols.length >= 5){
					var mc_msg:MovieClip = new bigwin_msg("stampede", 2);
					mc_msg.x = 380;
					mc_msg.y = 260;
					__timeline.mcBank.mc_msg = __timeline.addChild(mc_msg);
 					blittools_sounds.playSound("vo_stampede", "VO");
				}
    				
				fairyAnimCountToRun = res.symbols.length;
 				fairyCountTimer = new Timer(1000, res.symbols.length);
				fairyCountTimer.addEventListener(TimerEvent.TIMER, addFairyAnimInTimer);
				fairyCountTimer.start();
  			}

			//update freespin total
			if(oGAME.freespinmode){
				gsnTools.doSetVariable("bonusspin_winnings", gsnTools.doGetVariable("bonusspin_winnings") + res.payout);
				var newStr:String = blittools_general.doFormatNumber(gsnTools.doGetVariable("bonusspin_winnings"));
				__timeline.mcPanelWin.txt.text = newStr;
			}else{
				
				oSPIN.accum_win += res.payout;
				__timeline.mcPanelWin.txt.text = blittools_general.doFormatNumber(oSPIN.accum_win);
			}
			
			setTimeout(doNextResult, next_delay);
		}
 
	 
		
         //Timer to add the Fairy Animation one by one to cross the screen.
		private function addFairyAnimInTimer(eve:TimerEvent):void
		{

              if(fairyCountTimer.currentCount == fairyAnimCountToRun)	{
						
						fairyCountTimer.removeEventListener(TimerEvent.TIMER, addFairyAnimInTimer);
						fairyCountTimer.stop();
				}					
				
				blittools_sounds.playSound("stampede", "SFX3");

				var bisonclip:MovieClip = MovieClip(new bison());
				__timeline.addChild(bisonclip);
				
				bisonclip.x = -337.95;
				bisonclip.y = 364.95;
				bisonclip.addEventListener(Event.ENTER_FRAME, onEnterFrameCompleted);
 		}
		
 		
		
		
		private function onEnterFrameCompleted(eve:Event):void
		{
			 if(MovieClip(eve.target).currentFrameLabel == "End"){
				 MovieClip(eve.target).removeEventListener(Event.ENTER_FRAME, onEnterFrameCompleted);
				 __timeline.removeChild(MovieClip(eve.target));
			 }
		}

		public function doShowScatterResult(res:Object):void
		{
			trace("doShowScatterResult()");
			
			//hilite icons
			var icons:Array = res.outcomeIndicators;
			for(var col:int = 0; col < icons.length; col++){
				var col_array:Array = icons[col];
				for(var row:int = 0; row < col_array.length; row++){
					
					var myFrameClip:MovieClip = __timeline.mcReelFrames["mcItems_" + (col+1) + "_" + (row+1)];
					
					if(col_array[row] == 1){
						var mc:MovieClip = __timeline.mcReels["mcItems_" + (col+1) + "_" + (row+1)];
						mc.my_iconclip = mc.myicon;
						mc.my_frameclip = myFrameClip;
						mc.myicon.doHighlight();

						myFrameClip.visible = true;
						myFrameClip.doHighlight();
					}else{
						myFrameClip.doStop();
						myFrameClip.visible = false;
					}
				}
			}
			
			blittools_sounds.playSound("vo_freespins", "VO");

			//enter freespin mode
			if(oGAME.freespinmode == false){
				
				blittools_sounds.setVol("MUSIC", .7, 0);
				blittools_sounds.playSound("music_fast", "MUSIC", 999, null);
				oGAME.freespinmode = true;
				need_freespin_panel = true;
				started_freespins = false;

				gsnTools.doSetVariable("bonusspin_winnings", 0);


				__timeline.mcFreeSpinCount.visible=true;
				
				__timeline.mcBackground.sky2.visible=true;
				new Tween(__timeline.mcBackground.sky2, "alpha", None.easeNone,  0, 1, 1, true);
				
				//start freespin mode
				__timeline.mc_spingroup.bAutoSpin.enabled = false;
				__timeline.mc_spingroup.bSpin.enabled = false;
				new Tween(__timeline.mc_spingroup.bSpin, "y", Regular.easeIn, __timeline.mc_spingroup.bSpin.y, 10, 1, true);
				new Tween(__timeline.mc_spingroup.bSpin, "alpha", None.easeNone, __timeline.mc_spingroup.bSpin.alpha, 0, 1, true);
				new Tween(__timeline.mc_spingroup.bStop, "y", Regular.easeIn, __timeline.mc_spingroup.bStop.y, 10, 1, true);
				new Tween(__timeline.mc_spingroup.bStop, "alpha", None.easeNone, __timeline.mc_spingroup.bStop.alpha, 0, 1, true);
				
				oSPIN.accum_win += res.payout;
				__timeline.mcPanelWin.txt.text = blittools_general.doFormatNumber(oSPIN.accum_win);
			}else{
				//increment total
				gsnTools.doSetVariable("bonusspin_winnings", gsnTools.doGetVariable("bonusspin_winnings") + res.payout);
				var newStr2:String = blittools_general.doFormatNumber(gsnTools.doGetVariable("bonusspin_winnings"));
				__timeline.mcPanelWin.txt.text = newStr2;
			}
			
			
			//show win message
			if(res.multiplier > 1){
				doChangeMessage(res.symbols, "X " + res.multiplier + " PAYS " +  blittools_general.doFormatNumber(res.payout));
			}else if(res.payout==0){
				doChangeMessage(res.symbols, oMESSAGES.msg_win5spins);
			}else{
				doChangeMessage(res.symbols, "PAYS " + blittools_general.doFormatNumber(res.payout));
			}
			
			
				
			//play win sound
			blittools_sounds.playSound("snd_blink", "SFX3", oSPIN.free_spins);
			__timeline.mcFreeSpinCount.doUpdate(oGAME.freespins);
			
			
			setTimeout(doNextResult, 2000);
		}
		





		
		
		//-----------------------------
		// game
		//-----------------------------
		
		//doLowerBet()
		public function doLowerBet():void
		{
			
			trace("doLowerBet()");
			
			betAmountId = Math.min(betAmountId, doGetMaxValidBet());
			
			trace("betAmountId = " + betAmountId);
			gsnTools.doSetVariable("bet",  betAmountsArr[betAmountId]);
			
			
			trace("new bet = " + betAmountsArr[betAmountId]);
			doUpdateBetDisplay();
			doResetTurn();			
		}


		//doBuyTokens()
		public function doBuyTokens():void
		{
			__controller.doFullscreenOff();
			if(__controller.premiumCurrency){
				gsnTools.doBuyPremiumTokens(Number(gsnTools.doGetVariable("bet")));
			}else{
				var mc:MovieClip = new popup_buy_tokens(__controller, __game);
				__timeline.addChild(mc);
			}
			__timeline.mc_spingroup.bSpin.enabled = true;
		}
		
		
		
		private function enableStopBtn():void
		{
			__timeline.mc_spingroup.bSpin.visible = false;
			__timeline.mc_spingroup.bStop.txt.mouseEnabled = false;
			__timeline.mc_spingroup.bStop.enabled = true;
			__timeline.mc_spingroup.bStop.txt.alpha = 1;
			__timeline.mc_spingroup.bStop.buttonMode = true;
			__timeline.mc_spingroup.bStop.addEventListener(MouseEvent.CLICK, stopAllReels);
		}
		
		private function disableStopBtn():void
		{
			__timeline.mc_spingroup.bStop.enabled = false;
			__timeline.mc_spingroup.bStop.txt.alpha = .5;
			__timeline.mc_spingroup.bStop.buttonMode = false;
			__timeline.mc_spingroup.bStop.removeEventListener(MouseEvent.CLICK, stopAllReels);
		}
		
		public function doStopWheels(e:TimerEvent=null):void
		{
			myTimer = new Timer(__controller.oPREFS.spin_stopinterval, 5);
			myTimer.addEventListener(TimerEvent.TIMER, doLandWheel);
			myTimer.start();
			
			if (stopBtnClicked) {
				stopBtnClicked = false
				myTimer.stop()
				myTimer.removeEventListener(TimerEvent.TIMER, doLandWheel);
			}
		}
		
		public function doStopWheels2(e:TimerEvent=null):void
		{
			var reelCount:int = int(6-reelstop_next);
			for (var i:int = 1; i <= reelCount; i++)
			{
				doLandWheel();
			}
		}
		
		private function stopAllReels(e:MouseEvent):void
		{
			stopBtnClicked = true
			disableStopBtn()
			trace("MY TIMER ==== " + myTimer)
			if (myTimer) {
				myTimer.stop();
				myTimer.removeEventListener(TimerEvent.TIMER, doLandWheel);
			}
			doStopWheels2()
		}
	}
}