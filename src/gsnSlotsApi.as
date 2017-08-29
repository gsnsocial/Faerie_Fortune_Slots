package src 
{
	import flash.display.*;
	import flash.events.*;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.net.*;
	import flash.utils.*; 
	import flash.events.UncaughtErrorEvent;
	
	import com.adobe.serialization.json.JSON;
	import com.gsn.flashgames.GsnApi;
	import com.gsn.flashgames.EncryptionUtil;
	

	public class gsnSlotsApi {
		
		protected var __timeline:MovieClip;
		protected var __root:*;
		
		private static var GAME_ID:Number;
		private var api:GsnApi;
		private var messages:Object;
		private static var defaultLang = "en";
		private var gameState:Object;
		private var error_timeout:int;
		public var spin_cancelled:Boolean=false;
		public var retry_data:Object = null;
		private var spins_pending:Array = [];
		private var request_waiting:Boolean=false;
		private var requests_pending:Array = [];


		private var last_pluginStates:Array = new Array();
		private var last_gameState:Object = new Object();
		private var last_tokenBalance:Number;
		
		
		private var test_spincount:Number = 0;
		private var test_spincount_total:Number = 0;
		private var test_netchange:Number = 0;
		
		
		
		//-----------------------------
		// init
		//-----------------------------

		public function gsnSlotsApi(theroot:MovieClip, theGameID:int) {
			GAME_ID = theGameID;
			__timeline = MovieClip(theroot);
			__root = theroot;
			api = new GsnApi('JwVVRtprJ2en09z8dUtucRzOrzvcscgmUZlBMM2Q2PmA86HfRc7EFNJ1QuEVO5w1', __timeline);
			//api.setDefaultBaseUrl("http://canvasstaging.mesmo.tv/facebook");
			api.addBalanceUpdateHandler(myUpdateBalanceCallback);
		}

		public function myUpdateBalanceCallback(balance:Number){
			__timeline.doDebug("myUpdateBalanceCallback() " + balance);
			doSetVariable("bank", balance);
			__root.__game.doUpdateBank(false);
			__root.__game.doResetTurn();
		}

		public function doGetInitialState() {
			var params:Object = new Object();
			params.gameId = GAME_ID;
			var paramsJSON:String = JSON.encode(params);
			api.sendJsonRequest('slotsGetInitialState', paramsJSON, doGetInitialStateCallback, "POST");
		}
		
		public function doGetInitialStateCallback(e:Event) {
			last_gameState = JSON.decode(e.target.data);
			last_tokenBalance = last_gameState.tokenBalance;
			__root.doRecieveGameState(last_gameState);
		}

		//-----------------------------
		// get tokens
		//-----------------------------
		
		public function doGetTokensBalance(callback:Function, first_request:Boolean=true):void
		{
			if(first_request){
				request_waiting=true;
			}
			retry_data = new Object();
			retry_data.type = "get_tokens";
			retry_data.handler = doGetTokensBalance;
			retry_data.callback = callback;
			doArmTimeout(4000);
			api.sendRequest('flashTokenBalance', null, doGetTokensBalanceComplete);
		}

		public function doGetTokensBalanceComplete(e:Event):void
		{
			if(!request_waiting){
				return;
			}
			var o:Object = JSON.decode(e.target.data);
			var callback:Function = retry_data.callback;
			doDiffuseTimeout();
			__timeline.doDebug("api.doGetTokensBalanceComplete() " + o.balance);
			callback(o.balance);
		}

		//-----------------------------
		// idle state changes
		//-----------------------------
		
		public function doChangeIdleState(idle_state:String):void
		{
			__timeline.doDebug("api.doChangeIdleState(): idle_state = " + idle_state);

			api.logGameEvent("idle", "change", idle_state, 0);

		}
		
		
		//-----------------------------
		// tracking event
		//-----------------------------
		
		public function logEvent(categoryText:String, actionText:String, labelText:String="", value:Number=0):void
		{
			__timeline.doDebug("api.logEvent()");
			api.logGameEvent(categoryText, actionText, labelText, value);
		}
		
		//-----------------------------
		// badges
		//-----------------------------
		//publishBadgeFeed()
		public function doPublishBadgeFeed(id:int, callback:Function){
			
			__timeline.doDebug("api.publishBadgeFeed() id=" + id);
			
			var obj:Object = {gameId:GAME_ID, badgeId:id};
			api.publishFeed(93, obj, callback);
		}
		
		//-------------------------------------
		// messages
		//-------------------------------------
		
		//loadMessages()
		public function loadMessages(url:String, callback:Function):void
		{
			retry_data = new Object();
			retry_data.type = "load_messages";
			retry_data.handler = loadMessages;
			retry_data.callback = callback;
			
			if (url == "") {
				url = __timeline.mesmoResourceDir + __timeline.pathSlash + "files/messages_" + defaultLang + ".properties";
			}
			var request:URLRequest = new URLRequest(url);
			var loader:URLLoader = new URLLoader();
            loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, doLoadMessagesComplete);
			addStandardHandlers(loader);
			loader.load(request);
		}

		//onLoadMessagesComplete()
		protected function doLoadMessagesComplete(e:Event):void
		{
			messages = GsnApi.i18nParseMessageFile(e.target.data);
			var callback:Function = retry_data.callback;
			doDiffuseTimeout();
			callback(messages);
		}
		
		//doSubText()
		public function doSubText(str:String, subObj:Object)
		{
			return GsnApi.i18nSubstituteArguments(str, subObj);
		}
		
		//-----------------------------
		// get token purchase prices
		//-----------------------------

		public function requestTokenPricePoints(callback:Function, first_request:Boolean=true):void
		{
			__timeline.doDebug("api.requestTokenPricePoints()");
			
			if(first_request){
				request_waiting=true;
			}
			retry_data = new Object();
			retry_data.type = "token_pricepoint";
			retry_data.handler = requestTokenPricePoints;
			retry_data.callback = callback;

			doArmTimeout(4000);

			try{
				api.sendJsonRequest('flashTokenPricePoints', null, requestTokenPricePointsComplete, "POST");
			}catch (e:Error){
				doExecuteTimeout();
			}
			
			
		}
		 
		protected function requestTokenPricePointsComplete(e:Event):void
		{
			__timeline.doDebug("api.requestTokenPricePointsComplete()");
			
			//only accept the last one requested
			if(!request_waiting){
				return;
			}
			
			var callback:Function = retry_data.callback;
			doDiffuseTimeout();
			callback(e);
		}

		//-----------------------------
		// buy tokens
		//-----------------------------
		public function doBuyPremiumTokens(currentWagerAmount:Number, callback:Function=null):void
		{
			api.showPurchaseDialog(currentWagerAmount, function(status:String, errorMessage:String = null){
				__timeline.doDebug("status=" + status + ">, errormessage=" + errorMessage);
			});
		}
		
		
		public function doBuyTokens(o:Object, callback_ok:Function, callback_cancel:Function, callback_fail:Function):void
		{
			retry_data = new Object();
			api.makePurchase(0, 16, (o.tokens + o.bonusAmount), o.credits, callback_ok, callback_cancel, callback_fail);
		}
		
		//-----------------------------
		// slots game
		//-----------------------------
		
		var free_used:Boolean = false;
		

		//sendSpin() - request
		public function sendSpin(bet:int = 1, lines:int = 15, first_request:Boolean=true):void
		{
			if(first_request){
				request_waiting=true;
			}
			
			__timeline.doDebug("api.sendSpin() bet = " + bet + ", lines = " + lines);

			retry_data = new Object();
			retry_data.type = "spin";
			retry_data.handler = sendSpin;
			retry_data.bet = bet;
			retry_data.lines = lines;
			doArmTimeout(6000);

			var params:Object = new Object();
			
			params.engineConfig= "WildSavannahDynamicWaysConfig"; //  "AmericanBuffaloDynamicWaysConfig";    //   
			params.betUnit = bet;
			params.state = last_gameState;
			params.gameId = GAME_ID;
			params.pluginstates = last_pluginStates;
			params.mesmoGameId = GAME_ID;
			params.tokenBalance = last_tokenBalance;
			
			trace("state = " + params.engineConfig);			
			trace("pluginstates = " + JSON.encode(params.pluginstates));
			
			
			
			try{
				if(__timeline.txt_cheatcode.text!=""){
					params.cheatCode = __timeline.txt_cheatcode.text;
				}
			}catch(e){
				
			}

			var paramsJSON:String = JSON.encode(params);
			 
			trace(paramsJSON);
			try{
				api.sendJsonRequest('slotsSpin', paramsJSON, onSpinComplete, "POST");
			}catch (e:Error){
				trace("sendSpin error: doExecuteTimeout");
			}
			
		}
		 
		//onSpinComplete() - recieve
		protected function onSpinComplete(e:Event):void
		{
			__timeline.doDebug("api.onSpinComplete()");
			__timeline.doDebug(e.target.data);
			
			if(!request_waiting){
				return;
			}
	
			doDiffuseTimeout();
			var spinResult:Object = JSON.decode(e.target.data);
			gameState = spinResult.newGameState;
			
			last_gameState = spinResult.newGameState;
			last_tokenBalance = spinResult.newGameState.tokenBalance;
			
			if(spinResult.newGameState.pluginStates){
				last_pluginStates = spinResult.newGameState.pluginStates;
			}else{
				last_pluginStates = [];
			}

			//__timeline.mcDebug.stateTextArea.text = JSON.encode(gameState);
			__timeline.doGetSpinResults(spinResult);

		}

		
		
		//-------------------------------------
		// get/set variables
		//-------------------------------------
 
		 //doSetVariable(): sets a protected value in gsn api
		 public function doSetVariable(key:String, num:Number):void{
			 api.setProtectedValue(key,num);
		 }
		 
		//doGetVariable(): sets a protected value in gsn api
		 public function doGetVariable(key:String):Number{
			 return api.getProtectedValue(key);
		 }
		
		//-----------------------------
		// handlers
		//-----------------------------
		
		//progressHandler()
        private function progressHandler(e:ProgressEvent):void {
            return;
        }
		
		//ioErrorHandler()
        private function ioErrorHandler(e:IOErrorEvent):void {
			__timeline.doDebug("ioErrorHandler " + e);
        }
		
		//securityErrorHandler()
        private function securityErrorHandler(e:SecurityErrorEvent):void {
			__timeline.doDebug("securityErrorHandler " + e);
            __timeline.doShowGeneralError(e);
        }

		//addStandardHandlers()
		protected function addStandardHandlers(loader:URLLoader) {
            loader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		}
		
		//-----------------------------
		// tool
		//-----------------------------
		
		public function dumpObj(value:Object):String {
			if (typeof(value) == "object") {
				var accumulator:String = "{";
				var delim:String = "";
				for(var key:String in value) {
					accumulator += delim;
					accumulator += key + ":" + dumpObj(value[key]);
					delim = ",";
				}
				accumulator += "}";
				return accumulator;
			} else {
				return value.toString();
			}
		}
		
		
		//-----------------------------
		// timeout
		//-----------------------------

		protected function doArmTimeout(delay:Number){
			error_timeout = setTimeout(doExecuteTimeout, delay);
		}
		
		protected function doExecuteTimeout(){
			clearTimeout(error_timeout);
			var mc:MovieClip = MovieClip(new popup_error_com(__root, doRetry));
			__timeline.addChild(mc);

		}
		
		
		//doShowServerError()
		public function doRetry(){
			if(retry_data){
				switch (retry_data.type){
					case "spin":
						retry_data.handler(retry_data.bet, retry_data.lines, false);
						return;
						break;
						
					case "initial_state":
						retry_data.handler(retry_data.callback, false);
						return;
						break;
						
					case "token_pricepoint":
						retry_data.handler(retry_data.callback, false);
						return;
						break;
						
					case "get_tokens":
						retry_data.handler(retry_data.callback, false);
						return;
						break;
			
				}
				
			}
		}
		
		

		protected function doDiffuseTimeout(){
			clearTimeout(error_timeout);
			request_waiting=false;
			retry_data=null;
			//__timeline.doDestroyErrorPopup();
			//__timeline.mcReconnecting.visible=false;
			
		}
		
		
		
	}
}