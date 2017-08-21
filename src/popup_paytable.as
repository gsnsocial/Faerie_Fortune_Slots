package src
{

	import flash.display.MovieClip;
	import flash.events.*;
	
	
	import src.blit.*;
	
	
	public class popup_paytable extends MovieClip
	{

		

		private var __timeline:MovieClip;
		private var __controller:*;
		private var __game:*;
		private var __this:MovieClip;
		
		private var oMESSAGES:Object;
		private var oPREFS:Object;
		private var gsnTools:gsnSlotsApi;
		private var msg:String;
		
		
		public function popup_paytable(controller:Object):void
		{

			__controller = controller;
			oMESSAGES = __controller.oMESSAGES;
			__timeline = MovieClip(controller);

			oPREFS = __controller.oPREFS;
			gsnTools = __controller.gsnTools;
			
			
			this.addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void
			{
				doInit(); 
			});
		}
		
		
		
		private function doInit():void
		{

			gsnTools.logEvent("paytable", "open");


			bClose.buttonMode=true;
			bClose.mouseChildren=false;
			bClose.addEventListener(MouseEvent.MOUSE_UP, function(e:Event):void {
				gsnTools.logEvent("paytable", "close");
				blittools_sounds.playSound("snd_click", "INTERFACE");
				doDestroy();
			});

			doGotoPage1();
			
		}
		
		
		
		
		private function doGotoPage1():void
		{
			this.gotoAndStop("p1");
			
			txt_page.text = "1/3";
			
			blittools_text.doSwapTxt(hdr_paytable, oMESSAGES.hdr_paytable, []);
			blittools_text.doSwapTxt(msg_paytable, oMESSAGES.msg_paytable, []);

			blittools_general.doInitButton(bNext);
			bNext.addEventListener(MouseEvent.CLICK, function(e:Event):void {
				blittools_sounds.playSound("snd_click", "INTERFACE");
				doGotoPage2();
			});
			
			bPrev.alpha=.5;

			
		}

		private function doGotoPage2():void
		{
			
			this.gotoAndStop("p2");
			
			
			txt_page.text = "2/3";
			blittools_text.doSwapTxt(hdr_paytable, oMESSAGES.hdr_paytable, []);
			blittools_text.doSwapTxt(msg_scattersymbols, oMESSAGES.msg_scattersymbols, []);
			
			blittools_general.doInitButton(bPrev);
			bPrev.addEventListener(MouseEvent.CLICK, function(e:Event):void {
				blittools_sounds.playSound("snd_click", "INTERFACE");
				doGotoPage1();
			});
			
			blittools_general.doInitButton(bNext);
			bNext.addEventListener(MouseEvent.CLICK, function(e:Event):void {
				blittools_sounds.playSound("snd_click", "INTERFACE");
				doGotoPage3();
			});

			
		}
		
		private function doGotoPage3():void
		{
			
			this.gotoAndStop("p3");
			
			txt_page.text = "3/3";
			
			blittools_text.doSwapTxt(hdr_features, oMESSAGES.hdr_features, []);
			blittools_text.doSwapTxt(hdr_ways, oMESSAGES.hdr_ways, []);
			blittools_text.doSwapTxt(msg_ways, oMESSAGES.msg_ways, []);
			blittools_text.doSwapTxt(hdr_freespinmode, oMESSAGES.hdr_freespinmode, []);
			blittools_text.doSwapTxt(msg_freespinmode1, oMESSAGES.msg_freespinmode1,[]);
			blittools_text.doSwapTxt(msg_freespinmode2, oMESSAGES.msg_freespinmode2,[]);
			
			blittools_text.doSwapTxt(hdr_wilds, oMESSAGES.hdr_wilds, []);
			blittools_text.doSwapTxt(msg_wilds1, oMESSAGES.msg_wilds1,[]);
			blittools_text.doSwapTxt(msg_wilds2, oMESSAGES.msg_wilds2,[]);

		
			
			blittools_general.doInitButton(bPrev);
			bPrev.addEventListener(MouseEvent.CLICK, function(e:Event):void {
				blittools_sounds.playSound("snd_click", "INTERFACE");
				doGotoPage2();
			});
			

			bNext.alpha = .5;

			
		}

		private function doDestroy(){
			MovieClip(this.parent).removeChild(this);	
		}


	}
}