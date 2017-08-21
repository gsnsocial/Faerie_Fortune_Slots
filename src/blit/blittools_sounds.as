package src.blit {
	
	import flash.display.Sprite;
	import flash.media.Sound;
	import flash.media.SoundChannel;
    import flash.media.SoundTransform;
	import flash.events.*;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.display.MovieClip;
	
	public class blittools_sounds extends Sprite
	{
   
		 protected static var sndObj:Object = new Object;
		 protected static var sndLib:Object = new Object;
		 protected static var sndLoaderArr:Array = new Array;
		 protected static var sndLoaderCallback:Function;
		 protected static var sndLoaderCount:Number;
		 protected static var channelArr:Array = new Array;
		 protected static var isMusMute:Boolean = false;
		 protected static var isSfxMute:Boolean = false;
		 protected static var masterVolume:Number = 1;
		 protected static var masterMuteToggle:int = 1;
		 
		  protected static var isPausedMute:Boolean = false;
		   protected static var paused_mute_factor:Number = 1;
			
			//setMasterVolume()
			public static function setMasterVolume(theVolume:Number):void{
				masterVolume = theVolume;
				for(var i:int = 0; i<channelArr.length; i++){
					var ch:Object = channelArr[i];
					ch.myChannel.soundTransform = new SoundTransform(ch.myVol * masterVolume * masterMuteToggle * ch.myMuteToggle, ch.myPan);
				}
			}
			public static function doPause():void{
				var ch:Object;
				isPausedMute = true;
				paused_mute_factor = 0;
				for(var i:int = 0; i<channelArr.length; i++){
					ch = channelArr[i];
					ch.myChannel.soundTransform = new SoundTransform(0, ch.myPan);
				}
			}
			
			public static function doUnPause():void{
				var ch:Object;
				isPausedMute = false;
				paused_mute_factor = 1;
				for(var i:int = 0; i<channelArr.length; i++){
					ch = channelArr[i];
					ch.myChannel.soundTransform = new SoundTransform(ch.myVol * masterVolume * masterMuteToggle, ch.myPan);
				}
			}
			
			//doToggleMute()
			public static function doSetMute(isMute:Boolean):void{
				var ch:Object;
				if(isMute){
					masterMuteToggle=0;
				}else{
					masterMuteToggle=1;
				}
				for(var i:int = 0; i<channelArr.length; i++){
					ch = channelArr[i];
					ch.myChannel.soundTransform = new SoundTransform(ch.myVol * masterVolume * masterMuteToggle * ch.myMuteToggle, ch.myPan);
				}
			}			
			
			
			
			
			//doToggleMute()
			public static function doToggleMute(theChannelName:String = null):void{	
				var ch:Object;
				if(theChannelName==null){
					if(masterMuteToggle==1){
						masterMuteToggle=0;
					}else{
						masterMuteToggle=1;
					}
					for(var i:int = 0; i<channelArr.length; i++){
						ch = channelArr[i];
						ch.myChannel.soundTransform = new SoundTransform(ch.myVol * masterVolume * masterMuteToggle * ch.myMuteToggle, ch.myPan);
					}
				}else{
					ch = sndObj["sc_" + theChannelName];
					
					if(ch.myMute){
						ch.myMute = false;
						ch.myMuteToggle = 1;
					}else{
						ch.myMute = true;
						ch.myMuteToggle = 0;
					}
					ch.myChannel.soundTransform = new SoundTransform(ch.myVol * masterVolume * masterMuteToggle * ch.myMuteToggle, ch.myPan);
				}
				
			}
			
			//doGetCurrentSound()
			public static function doGetCurrentSound(theChannelName:String):String{
				var current_snd:String = "";
				try{
					var theChannel:Object = sndObj["sc_" + theChannelName];
					current_snd = theChannel.myQueue[0].myName;
				}catch(e:Error){
					
				}
				
				return current_snd;	
				
			}
			
						
					

			//addSound()
			public static function addSound(theSoundName:String, theSound:Sound):void{
				sndLib["s_" + theSoundName] = theSound;
			}

   			//createChannel()
			public static function createChannel(theChannelName:String):void{
				sndObj["sc_" + theChannelName] = new Object();
				sndObj["sc_" + theChannelName].myName = theChannelName;
				sndObj["sc_" + theChannelName].myChannel = new SoundChannel();
				sndObj["sc_" + theChannelName].myVol = 1;
				sndObj["sc_" + theChannelName].myPan = 0;
				sndObj["sc_" + theChannelName].myMuteToggle = 1;
				sndObj["sc_" + theChannelName].myQueue = new Array();
				sndObj["sc_" + theChannelName].myFaderClip = new MovieClip();
				sndObj["sc_" + theChannelName].isFading = false;
				channelArr.push(sndObj["sc_" + theChannelName]);
			}

		   //playSound()
			public static function playSound(theSoundName:String, theChannelName:String, theLoopCount:int=1, theCallback:Function=null):void{
				if (! sndLib["s_" + theSoundName]){return;}  
				if (! sndLib["s_" + theSoundName] is Sound){return;}

				var sndHolder:Object = new Object();
				sndHolder.mySound = sndLib["s_" + theSoundName];
				sndHolder.myName = theSoundName;
				sndHolder.myLoops = theLoopCount;
				sndHolder.myCallback = theCallback;
				var theChannel:Object = sndObj["sc_" + theChannelName];
				theChannel.myChannel.stop();
				theChannel.myQueue = new Array();
				theChannel.myQueue.push(sndHolder);
				playNextSound(theChannel);
			}

			//queueSound()
			public static function queueSound(theSoundName:String, theChannelName:String, theLoopCount:int=1, theCallback:Function=null):void{
				if (! sndLib["s_" + theSoundName]){return;}  
				if (! sndLib["s_" + theSoundName] is Sound){return;} 
				var sndHolder:Object = new Object();
				sndHolder.mySound = sndLib["s_" + theSoundName];
				sndHolder.myLoops = theLoopCount;
				sndHolder.myName = theSoundName;
				sndHolder.myCallback = theCallback;
				var theChannel:Object = sndObj["sc_" + theChannelName];
				theChannel.myQueue.push(sndHolder);
				if(theChannel.myQueue.length==1){
					playNextSound(theChannel);
				}
			}
			
			//stopSound()
			public static function stopSound(theChannelName:String):void{
				var theChannel:Object = sndObj["sc_" + theChannelName];
				theChannel.myChannel.stop();
				theChannel.myQueue = new Array();
			}

			//setVol()
			public static function setVol(theChannelName:String, theVol:Number, thePan:Number = 0):void{
				var ch:Object = sndObj["sc_" + theChannelName];
				
				//stop and residual fading
				if(ch.isFading){
					ch.myFaderClip.removeEventListener(Event.ENTER_FRAME , doFadeStep);
					ch.isFading = false;
				}
				
				
				ch.myVol = theVol;
				ch.myPan = thePan;
				
				trace("setVol()" + theChannelName + ": " + (ch.myVol * masterVolume * masterMuteToggle * ch.myVol));
				
				ch.myChannel.soundTransform = new SoundTransform(ch.myVol * masterVolume * masterMuteToggle * ch.myMuteToggle, thePan);
				
			}

			//fadeSound()
			public static function fadeSound(theChannelName:String, theVol:Number, theTime:Number):void{
				var theChannel:Object = sndObj["sc_" + theChannelName];
				var totalChange:Number = (theVol - theChannel.myVol);
				theChannel.myFaderClip = new MovieClip();
				theChannel.myFaderClip.targetVol = theVol;
				theChannel.myFaderClip.numSteps = Math.ceil(theTime*20);
				theChannel.myFaderClip.fadeStep = (totalChange/(theTime*20));
				theChannel.myFaderClip.myChannel = theChannel;
				theChannel.myFaderClip.mySoundChannel = theChannel.myChannel;
				theChannel.isFading = true;
				theChannel.myFaderClip.addEventListener(Event.ENTER_FRAME , doFadeStep);
			}
			

			//====================================================================

			
			//playNextSound()
			protected static function playNextSound(theChannel:Object):void{
				if(theChannel.myQueue.length>=1){
					theChannel.myChannel = theChannel.myQueue[0].mySound.play(0, theChannel.myQueue[0].myLoops);
					
					//start callback
					if(theChannel.myQueue[0].myCallback is Function){
						theChannel.myQueue[0].myCallback(theChannel.myQueue[0].myName, "start");
					}
					
					theChannel.myChannel.soundTransform = new SoundTransform(theChannel.myVol * paused_mute_factor * masterVolume * masterMuteToggle * theChannel.myMuteToggle, theChannel.myPan);
					
					//complete callback
					theChannel.myChannel.addEventListener(Event.SOUND_COMPLETE, function(e:Event):void {
						try{
							if(theChannel.myQueue[0].myCallback is Function){
								theChannel.myQueue[0].myCallback(theChannel.myQueue[0].myName, "complete");
							}
						}catch(e:Error){
							
						}
						theChannel.myQueue.shift();
						playNextSound(theChannel);
					});
					
				}
			}
			
			
			//doFadeStep()
			protected static function doFadeStep(e:Event):void{
				var me:MovieClip = MovieClip(e.currentTarget);
				me.myChannel.myVol += me.fadeStep;
				me.mySoundChannel.soundTransform = new SoundTransform(me.myChannel.myVol * masterVolume * masterMuteToggle * me.myChannel.myMuteToggle, me.myChannel.myPan);
				me.numSteps--;
				if(me.numSteps<=0){
					me.myChannel.myVol = me.targetVol;
					me.mySoundChannel.soundTransform = new SoundTransform(me.myChannel.myVol * masterVolume * masterMuteToggle * me.myChannel.myMuteToggle, me.myChannel.myPan);
					me.removeEventListener(Event.ENTER_FRAME , doFadeStep);
					me.myChannel.isFading = false;
				}
			}
			
			//sndLoaderLoadNext()			
			protected static function sndLoaderLoadNext():void{
				var tSnd:Sound = new Sound();  
				tSnd.load(new URLRequest(sndLoaderArr[0].mySoundURL));
				tSnd.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event):void {  
					sndLoaderArr[0].myLoadPercent = 1;
					if(sndLoaderArr.length>1){
						sndLoaderArr.shift();
						sndLoaderCallback(sndLoaderGetProg());
						sndLoaderLoadNext();
					}else{
						sndLoaderCallback(-1);
					}
				}); 
				
				tSnd.addEventListener(ProgressEvent.PROGRESS, function(e:ProgressEvent):void {
					sndLoaderArr[0].myLoadPercent = (e.bytesLoaded / e.bytesTotal);
					sndLoaderCallback(sndLoaderGetProg());
				});
				
				tSnd.addEventListener(Event.COMPLETE, function(e:Event):void {
					addSound(sndLoaderArr[0].mySoundName, e.target as Sound)
					sndLoaderArr[0].myLoadPercent = 1;
					if(sndLoaderArr.length>1){
						sndLoaderArr.shift();
						sndLoaderCallback(sndLoaderGetProg());
						sndLoaderLoadNext();
					}else{
						sndLoaderCallback(-1);
					}
				}); 
		 	}
			
			//sndLoaderGetProg()
		 	protected static function sndLoaderGetProg():Number{
				var tLoadPercent:Number = 0;
				for(var i:int=0; i<sndLoaderArr.length; i++){
					tLoadPercent += (sndLoaderArr[i].myLoadPercent);
				}
				
				var tSeedCounter:Number = sndLoaderCount - sndLoaderArr.length
				return ((tLoadPercent + tSeedCounter)/sndLoaderCount);
			}
		 

			

   
	}
}