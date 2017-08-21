package  src {
	
	import com.adobe.serialization.json.JSON;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.geom.ColorTransform;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.system.SecurityDomain;
	import flash.text.Font;
	import flash.utils.Timer;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	
	import fl.motion.Color;
	import fl.motion.easing.Back;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	
	import src.buffaloSlots;
	import src.gsnSlotsApi;
	import src.blit.*;
	import fl.transitions.easing.*;
	
	public class movie extends MovieClip {

		public var testMode:Boolean = false;
		
		//init
		public var gsnTools:gsnSlotsApi;
		public var __game:buffaloSlots;
		public var __timeline:MovieClip = MovieClip(this);
		public var __controller:* = this;
		public var game_id:int = 521; //521;
		
		//gsn
		public var messagesUrl:String;
		public var mesmoResourceDir:String;
		public var mesmoCheatsEnabled:Boolean;
		public var useFreeSpin:Boolean=false;
		public var pathSlash:String; 
		public var sLanguage:String = "en";
		public var currentGameState:Object;
		public var hideBuyTokens:Boolean = false;
		public var tokenPurchaseUrl:String;
		public var userpref_soundfx:Boolean = true;
		public var userpref_soundmusic:Boolean = true;
		public var start_timer:Number;
		public var heartbeats:uint = 0;
		public var premiumCurrency:Boolean;
		public var mcPaused:MovieClip = null;
		public var isPaused:Boolean = false;
		public var pauseObj:Object = null;
		public var pauseResumeFunction:Function = null;
		
		//objects
		public var oPREFS:Object = new Object();
		public var oSNDS:Object = new Object();
		public var oGAMESTATE:Object = new Object();
		public var oMESSAGES:Object = new Object();
		
		//game
		public var tweenHolders:Array = new Array();
		public var timeoutHolders:Array = new Array();
		public var debugOn:Boolean=true;
		public var ioErrorRetryFunction:Function;
		
		//clips
		public var mcErrorPopup:MovieClip;
		public var mcErrorPopup2:MovieClip;

		//fonts
		public var font_arial_bold:Font = new ArialBold();
		public var font_helv_uc:Font = new HelveticaUltraCompressed();
		
		public var last_coin_snd:Number = 0;
		public var last_coin_channel:Number = 1;

		private var minMaxJson:Object;
		private var betPerLine:Array;
		private var betAmountsArr2:Array;

		//------------------------------
		// platfoerm events
		//------------------------------

		private function doListenForPlatformEvents():void{
			if (ExternalInterface.available){
				ExternalInterface.addCallback('handlePlatformEvent', doHandlePlatformEvent);
			}
		}

		private function doHandlePlatformEvent(args:Object):Object {
			var returnObj:Object = {};
			var type:String = args.type.toLowerCase();
			
			doDebug("handle platform event: " + type);
			
			if (type == "pause"){
				doPause();
				
			}else if (type == "resume"){
				doUnPause();
			 
			}else if (type == "game_capabilities"){
				//quick and dirty hack to see if this is the correct set of calls to integrate with platforms supportIdle capabilities requirement
				returnObj.gf2Version = '0.0.00';
				returnObj.screenGrab = null;
				returnObj.capabilities = {"supportsIdle": true};
				if (ExternalInterface.available){
					ExternalInterface.call("FlashApi.interopCallback", "handlePlatformEvent",returnObj);
				}
			}
			return returnObj;
		}

		
		//------------------------------
		// init
		//------------------------------

		//doHeartbeatPing()
		private function doHeartbeatPing(e=null):void
		{
			heartbeats++;
			gsnTools.logEvent("session", "ping", "", heartbeats);
			var myTimer:Timer = new Timer(60*1000, 1);
			myTimer.addEventListener(TimerEvent.TIMER_COMPLETE, doHeartbeatPing);
			myTimer.start();
			
		}


		//doInit()
		public function movie()
		{

			//stage
			stage.tabChildren = false;
			stage.scaleMode = StageScaleMode.SHOW_ALL;

			gsnTools = new gsnSlotsApi(__timeline, game_id);
			gsnTools.logEvent("session", "start");
			
			//start heartbeat
			var myTimer:Timer = new Timer(60*1000, 1);
			myTimer.addEventListener(TimerEvent.TIMER_COMPLETE, doHeartbeatPing);
			myTimer.start();

			start_timer = getTimer();

			//connection status
			//mcReconnecting.visible=false;
			mcWeb.visible=false;
			//mcDebug.visible=false;
			
			mcBackground.sky2.visible=false;
			mcBackground.sky2.alpha=0;
			
			//sound channels
			blittools_sounds.createChannel("MUSIC");
			blittools_sounds.createChannel("INTERFACE");
			blittools_sounds.createChannel("SFX1");
			blittools_sounds.createChannel("SFX2");
			blittools_sounds.createChannel("SFX3");
			blittools_sounds.createChannel("SFX4");
			blittools_sounds.createChannel("VO");
			blittools_sounds.createChannel("COINS1");
			blittools_sounds.createChannel("COINS2");
			
			blittools_sounds.setVol("COINS1", .1);
			blittools_sounds.setVol("COINS2", .1);
			
			

			//debug
			/*
			mcDebug.debugTextArea.text = "";
			bDebug.addEventListener(MouseEvent.MOUSE_DOWN, function(e:Event) {
				if(debugOn){
					if(mcDebug.visible==true){
						mcDebug.visible=false;
					}else{
						mcDebug.visible=true;
					}
				}
			});

			if(testMode==true){
				bDebug.visible=true;
				debugOn=true;
				mesmoCheatsEnabled = true;
			}else{
				bDebug.visible=false;
				mcDebug.debugTextArea.visible=false;
				debugOn=false;
			}
			*/

			//gsn data
			if(root.loaderInfo.parameters.gameId){
				game_id = root.loaderInfo.parameters.gameId;
			}
			
			if(root.loaderInfo.parameters.mesmoResourceDir){
				mesmoResourceDir = root.loaderInfo.parameters.mesmoResourceDir;
				pathSlash = "/";
			}else{
				mesmoResourceDir = "";
				pathSlash = "";
			}
				
			if(root.loaderInfo.parameters.messageUrl){
				messagesUrl = root.loaderInfo.parameters.messageUrl;
			}else{
				messagesUrl = mesmoResourceDir + pathSlash + "files/messages_en.properties";
			}
			
			if(root.loaderInfo.parameters.mesmoCheatsEnabled){
				mesmoCheatsEnabled = root.loaderInfo.parameters.mesmoCheatsEnabled;
			}else{
				mesmoCheatsEnabled=false;
			}
			
			if (root.loaderInfo.parameters.hideBuyTokens) {
				hideBuyTokens = true;
			}else{
				hideBuyTokens = false;
			}

			if(root.loaderInfo.parameters.tokenPurchaseUrl){
				tokenPurchaseUrl = root.loaderInfo.parameters.tokenPurchaseUrl;
			}else{
				tokenPurchaseUrl = "";
			}
			
			if(root.loaderInfo.parameters.usePremiumCurrencyPurchaseAPI){
				premiumCurrency = Boolean(root.loaderInfo.parameters.usePremiumCurrencyPurchaseAPI);
			}else{
				premiumCurrency = false;
			}
			
			if (root.loaderInfo.parameters.minMaxJson) {
				minMaxJson = JSON.decode(root.loaderInfo.parameters.minMaxJson);
				betPerLine = minMaxJson.betPerLine as Array;
				if (betPerLine) {
					doGenerateBetValues();
				}
			}
			
			//loader
			gsnTools.logEvent("loading", "start");
			loaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void {	
				
				doListenForPlatformEvents();
				
				if(doCheckFlashVersion()){
					doStartLoad();
				}else{
					doShowFlashError();
				}
			});
			
			loaderInfo.addEventListener(ProgressEvent.PROGRESS, function(e:ProgressEvent):void {
				var iLoadedPercent:Number = (e.bytesLoaded / e.bytesTotal);
				mcProgress.mcProgBar.scaleX = iLoadedPercent;
			});


			//get preference for sounds
			var p_sfx = blittools_localsaver.doGetLocal("gsn_" + game_id, "mute_all");

			if(p_sfx){
				if(p_sfx == "yes"){
					blittools_sounds.doSetMute(true);
					doMuteAll();
				}else{
					doUnMuteAll();
				}
			}else{
				doUnMuteAll();
			}
			//fullscreen
			__timeline.mcFullScreen.bFull.addEventListener(MouseEvent.MOUSE_UP, function(e:Event):void {
				doFullscreenOn();
			});
			

		}
		
		private function doGenerateBetValues():void
		{
			var minTotalBet:int = minMaxJson.minTotalBet as int;
			var maxTotalBet:int = minMaxJson.maxTotalBet as int;
			betAmountsArr2 = [];
			for (var i:int = 0; i < betPerLine.length; i++)
			{
				var currBet:int = betPerLine[i];
				if (currBet >= minTotalBet && currBet <= maxTotalBet) {
					betAmountsArr2.push(currBet)
				}
			}
		}
		
		
		//---------------------------
		//  tools
		//---------------------------
				
		//doDebug()
		public function doDebug(myTxt, clearAll:Boolean=false):void
		{
			/*
			if(clearAll){
				mcDebug.debugTextArea.text = "";
			}
			mcDebug.debugTextArea.text = myTxt + "\n" + mcDebug.debugTextArea.text;
			trace(myTxt);
			*/
		}

		//doCheckEnvironment()
		private function doCheckFlashVersion():Boolean
		{
			var versionNumber:String = Capabilities.version;
			var versionArray:Array = versionNumber.split(",");
			var length:Number = versionArray.length;
			var platformAndVersion:Array = versionArray[0].split(" ");
			var majorVersion:Number = parseInt(platformAndVersion[1]);
			var minorVersion:Number = parseInt(versionArray[1]);
			var buildNumber:Number = parseInt(versionArray[2]);
			
			if((majorVersion >= 11) || (majorVersion >= 10 && minorVersion >= 3)){
				return true;
			}else{
				return false;
			}
			
		}

		//---------------------------
		//  mute controls
		//---------------------------
		
		//doMuteAll()
		public function doMuteAll():void
		{
			gsnTools.logEvent("sound", "change", "off");
			blittools_localsaver.doSaveLocal("gsn_" + game_id, "mute_all", "yes");
			__timeline.mcMuteAll.gotoAndStop("off");
			__timeline.mcMuteAll.bMute.addEventListener(MouseEvent.MOUSE_UP, function(e:Event):void {
					blittools_sounds.doSetMute(false);
					doUnMuteAll();
			});
		}
		
		//doUnMuteAll()
		public function doUnMuteAll():void
		{
			gsnTools.logEvent("sound", "change", "on");
			blittools_localsaver.doSaveLocal("gsn_" + game_id, "mute_all", "no");
			__timeline.mcMuteAll.gotoAndStop("on");
			__timeline.mcMuteAll.bMute.addEventListener(MouseEvent.MOUSE_UP, function(e:Event):void {
					blittools_sounds.doSetMute(true);
					doMuteAll();
			});
		}

		//------------------------------
		// full screen controls
		//------------------------------
		
		//doFullscreenOn()
		public function doFullscreenOn():void
		{
			if(mcFullScreen.currentFrame != 2){
				stage.displayState = StageDisplayState.FULL_SCREEN;
				mcFullScreen.gotoAndStop(2);
				mcFullScreen.bFull.addEventListener(MouseEvent.MOUSE_UP, function(e:Event):void {
						doFullscreenOff();
				});
			}
		}
		
		//doFullscreenOff()
		public function doFullscreenOff():void
		{
			if(mcFullScreen.currentFrame != 1){
				stage.displayState=StageDisplayState.NORMAL;
				mcFullScreen.gotoAndStop(1);
				mcFullScreen.bFull.addEventListener(MouseEvent.MOUSE_UP, function(e:Event):void {
						doFullscreenOn();
				});
			}
		}
		
		//------------------------------
		// pausing
		//------------------------------

		
		//doPause()
		public function doPause():void
		{
			if(mcPaused==null){
				mcPaused = new popup_paused();
				__timeline.addChild(mcPaused);
			}
			blittools_sounds.doPause();
			
			for(var myWheel:int = 1; myWheel<=5; myWheel++){
				if(__timeline["mcBlur" + myWheel].visible){
					__timeline["mcBlur" + myWheel].stop();
				}
			}
			
			isPaused=true;
		}
		
		//doUnPause()
		public function doUnPause():void
		{
			if(mcPaused is MovieClip){
				
				__timeline.removeChild(mcPaused);
				mcPaused = null;
			}
			blittools_sounds.doUnPause();
			isPaused=false;
			
			for(var myWheel:int = 1; myWheel<=5; myWheel++){
				if(__timeline["mcBlur" + myWheel].visible){
					__timeline["mcBlur" + myWheel].play();
				}
			}
			
			if(pauseResumeFunction is Function){
				pauseResumeFunction();
				pauseResumeFunction = null;
			}
		}

		//---------------------------
		//  loading
		//---------------------------

		//doStartLoad() 
		public function doStartLoad():void
		{
			trace("doStartLoad()");
			mcProgress.mcProgBar.scaleX = 0;
			ioErrorRetryFunction = doStartLoad;
			gsnTools.loadMessages(messagesUrl, doRecieveMessages);
			
		}
		
		//doRecieveMessages()
		public function doRecieveMessages(myMessages:Object):void
		{
			trace("doRecieveMessages()");
			oMESSAGES = myMessages;
			sLanguage = oMESSAGES.language;
			//blittools_text.doSwapTxt(__timeline.tag_waystowin, oMESSAGES.tag_waystowin, []);
			doLoadSoundsPackage();
		}
		
		//doLoadSoundsPackage()
		public function doLoadSoundsPackage():void
		{
			
			trace("doLoadSoundsPackage()");
			
			var oLoader:Loader = new Loader();
			oLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event) { 
				var mc:MovieClip = e.currentTarget.content as MovieClip;
				mc.visible=false;
				addChild(mc);
				var ok:Boolean = mc.doRegisterSnds();
				

				gsnTools.doGetInitialState();
			});
			
			oLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, function(e:ProgressEvent) { 
				var iLoadedPercent:Number = (e.bytesLoaded / e.bytesTotal);
				mcProgress.mcProgBar.scaleX = iLoadedPercent;
			});
			
			var url:String = mesmoResourceDir + pathSlash + "files/snds.swf";
			oLoader.load(new URLRequest(url));
		}


		
		//doRecieveGameState()
		public function doRecieveGameState(d:Object):void
		{

           	oGAMESTATE = d; 
			//gsnTools.doSetVariable("bank",  2100250 );
			gsnTools.doSetVariable("bank", oGAMESTATE.tokenBalance);
			gsnTools.doSetVariable("bet", -1);
			
			gsnTools.doSetVariable("totalbet", 0);
			gsnTools.doSetVariable("wincount", 0);
			gsnTools.doSetVariable("spinwinnings", 0);
			gsnTools.doSetVariable("extra_winnings", 0);
			
			gsnTools.doSetVariable("bonusspin_winnings", 0);
			gsnTools.doSetVariable("freespin_total", 0);
	
			doLoadXML();
		}

		//doLoadXML()
		public function doLoadXML():void
		{
			ioErrorRetryFunction = doLoadXML;
			var xmlLoader:URLLoader = new URLLoader();
			xmlLoader.addEventListener(Event.COMPLETE, function(e:Event) {
				var myXML:XML = new XML(e.target.data);
				oPREFS = new Object();
				for each (var param:XML in myXML.params.param) {
					oPREFS[param.@id] = param.@value;
				}
				
				oPREFS.hideBuyTokens = hideBuyTokens;
				oPREFS.useFreeSpin = useFreeSpin;
				
				//doDestroyReconnecting();
				
				if(Number(oPREFS.vo) == 0){
			   		blittools_sounds.setVol("VO", 0);
			 	}
			  
				doProceed();
			});

			xmlLoader.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event) {
				doShowServerError(e);
			});
			var url:String = String(mesmoResourceDir + pathSlash + "files/gamedata.xml");
			xmlLoader.load(new URLRequest(url));
		}
		
		//doProceed()
		public function doProceed():void
		{ 
			gsnTools.logEvent("loading", "complete");
			
			blittools_sounds.playSound("vo_title", "VO");
							
			ioErrorRetryFunction = null;
			mcProgress.visible=false;
			__timeline.removeChild(mcSpinner);
			blittools_sounds.setVol("MUSIC", .2, 0);
			var time_left:Number = Math.max(0, (start_timer + Number(oPREFS.splash_holdtime)) - getTimer());
			var myTimer:Timer = new Timer(time_left, 1);
			myTimer.addEventListener(TimerEvent.TIMER_COMPLETE, doStartGame);
			myTimer.start();
			
			
		}

		
		//------------------------------
		// game
		//------------------------------
		
		//doStartGame()
		public function doStartGame(e=null):void
		{
			blittools_sounds.setVol("MUSIC", .2, 0);
			blittools_sounds.playSound("music", "MUSIC", 999, null);
			blittools_transitions.doStartCrossfade(__timeline, .5, 760, 540);
			__timeline.gotoAndStop("init");
			
			__game = new buffaloSlots(__timeline, game_id, betAmountsArr2);
		}
		
		//doGetSpinResults()
		public function doGetSpinResults(res:Object):void
		{
			__game.doGetSpinResults(res);
		}
		

		//------------------------------
		// animations
		//------------------------------

		
		//doGrowIcon()
		public function doGrowIcon(myClip:MovieClip, newScale:Number, newRot:Number):void
		{
			tweenHolders.push(new Tween(myClip, "scaleX", Elastic.easeOut,  1, newScale, 1, true));
			tweenHolders.push(new Tween(myClip, "scaleY", Elastic.easeOut,  1, newScale, 1, true));
		}
		
		//doFadeIn()
		public function doFadeIn(myClip:MovieClip):void
		{
			tweenHolders.push(new Tween(myClip, "alpha", None.easeNone, myClip.alpha, 1, .2, true));
		}
		
		//doFadeOut()
		public function doFadeOut(myClip:MovieClip):void
		{
			clearTimeout(myClip.myTimeout);
			tweenHolders.push(new Tween(myClip, "alpha",  None.easeNone, myClip.alpha, 0, .2, true));
		}
		
		//doPulseIcon()
		public function doPulseIcon(myClip:MovieClip, newScale:Number, newRot:Number=0):void
		{
			var tw:Tween = new Tween(myClip, "scaleX", Elastic.easeOut,  1, newScale, 1.5, true);
			tweenHolders.push(tw);
			tw.addEventListener(TweenEvent.MOTION_FINISH, doPulseIcon3);
			tweenHolders.push(new Tween(myClip, "scaleY", Elastic.easeOut,  1, newScale, 1.5, true));
			
		}
		
		//doPulseIcon3()
		public function doPulseIcon3(e:Event):void
		{
			var myClip:MovieClip = MovieClip(e.currentTarget.obj);
			var tw:Tween =new Tween(myClip, "scaleX", Regular.easeOut,  myClip.scaleX, 1, .3, true);
			tweenHolders.push(tw);
			tw.addEventListener(TweenEvent.MOTION_FINISH, doPulseIcon4);
			tweenHolders.push(new Tween(myClip, "scaleY", Regular.easeOut, myClip.scaleY, 1, .3, true));
		}
		
		//doPulseIcon4()
		public function doPulseIcon4(e:Event):void
		{
			var myClip:MovieClip = MovieClip(e.currentTarget.obj);
			myClip.smallIcon.visible=true;
			__timeline.removeChild(myClip);
		}
		
		//doRestoreIcon()
		public function doRestoreIcon(myClip:MovieClip):void
		{
			var tw:Tween =new Tween(myClip, "scaleX", Regular.easeOut,  myClip.scaleX, 1, .3, true);
			tweenHolders.push(tw);
			tw.addEventListener(TweenEvent.MOTION_FINISH, doRestoreIcon2);
			tweenHolders.push(new Tween(myClip, "scaleY", Regular.easeOut, myClip.scaleY, 1, .3, true));
		}
		
		//doRestoreIcon2()
		public function doRestoreIcon2(e:Event):void
		{
			var myClip:MovieClip = MovieClip(e.currentTarget.obj);
			myClip.smallIcon.visible=true;
			__timeline.removeChild(myClip);
		}
		
		
				
		//------------------------------
		// errors
		//------------------------------
		
		//doShowGeneralError()
		public function doShowGeneralError(e=null):void
		{
			mcErrorPopup = MovieClip(new popup_error_general(__controller, oMESSAGES.title_error, oMESSAGES.error_io_1 + "\n\n" + oMESSAGES.error_io_2, null));
			__timeline.addChild(mcErrorPopup);
		}
		
		//doShowFlashError()
		public function doShowFlashError():void
		{
			mcErrorPopup = MovieClip(new popup_error_flash());
			__timeline.addChild(mcErrorPopup);
			
		}
		
		//doShowServerError()
		public function doShowServerError(e=null):void
		{
			mcErrorPopup = MovieClip(new popup_error_server(__controller, __game));
			__timeline.addChild(mcErrorPopup);
		}
		
		//doDestroyErrorPopup()
		public function doDestroyErrorPopup():void
		{
			try{
				MovieClip(mcErrorPopup.parent).removeChild(mcErrorPopup);
			}catch (e:Error){
				
			}
		}
		
		/*
		//doShowReconnecting
		public function doShowReconnecting():void
		{
			mcReconnecting.visible=true;
		}
		
		//doDestroyReconnecting
		public function doDestroyReconnecting():void
		{
			mcReconnecting.visible=false;
		}
		*/

		

	}
	
}
