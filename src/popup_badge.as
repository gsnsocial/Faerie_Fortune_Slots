package src
{

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
    import flash.utils.*;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.system.SecurityDomain;	
	import flash.display.*;
	import flash.net.*;
	
	
	
	import src.gsnSlotsApi;
	import src.blit.*;
	import flash.display.Bitmap;
	
	public class popup_badge extends MovieClip
	{

		public var badge_obj:Object;
		public var callback:Function;
		private var __this:MovieClip;
		private var __timeline:MovieClip;
		private var __controller:*;
		private var __game:*;
		private var game_id:int;
		private var oMESSAGES:Object;
		private var oPREFS:Object;
		private var gsnTools:gsnSlotsApi;
		
		/*
		"id": 878,
		"localizedName": "Wolf Pack",
		"imageUrl130": "https://cdn.mesmo.tv/uploads/badges/s130/b7204497561070177232.png",
		"imageUrl200": "https://cdn.mesmo.tv/uploads/badges/s200/b7204497561070177232.png",
		"imageUrl": "https://cdn.mesmo.tv/uploads/badges/s75/b7204497561070177232.jpg",
		"tokenAward": 1000,
		"localizedDescription": "Match 3 wolf symbols."
		*/

		public function popup_badge(controller:Object, game:Object, o:Object, c:Function){
	
			__controller = controller;
			__timeline = MovieClip(controller);
			__game = game;
			__this = MovieClip(this);
			
			oMESSAGES = __controller.oMESSAGES;
			oPREFS = __controller.oPREFS;
			gsnTools = __controller.gsnTools;
			
			badge_obj = o;
			callback = c;
			
			this.addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void
			{
				doInit(); 
			});
		}
		
		
		
		private function doInit():void
		{


			blittools_text.doSwapTxt(bShare.txt, oMESSAGES.button_share, []);
			blittools_text.doSwapTxt(txtHeader, oMESSAGES.title_badge, []);


			blittools_general.doInitButton(bShare);
			bShare.buttonMode=true;
			bShare.mouseChildren=false;
			bShare.addEventListener(MouseEvent.MOUSE_UP, function(e:Event):void {
				doShare();
			});
			
			
			bClose.buttonMode=true;
			bClose.mouseChildren=false;
			bClose.addEventListener(MouseEvent.MOUSE_UP, function(e:Event):void {
				doDestroy();
			});


			txtTitle.text = badge_obj.localizedName;
			txtDesc.text = badge_obj.localizedDescription;
			txtWin.text = blittools_general.doFormatNumber(badge_obj.tokenAward);
			

			var oLoader:Loader = new Loader();
			oLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void  { 
				var bitmap:Bitmap = Bitmap(e.currentTarget.content);
				mcBadge.addChild(bitmap);
				bitmap.x = -(bitmap.width * .5);
				bitmap.y = -(bitmap.height * .5);
			});
			
			//var url:String = String(__controller.mesmoResourceDir + __controller.pathSlash + "files/badge_" + badge_obj.imageUrl200 + ".png");

			var url:String = String(badge_obj.imageUrl200);

			oLoader.load(new URLRequest(url));

			
			
		}


		private function doDestroy():void{
			__timeline.removeChild(this);
			callback();
		}

		private function doShare():void{
			__this.gotoAndStop("sending");
			__controller.doFullscreenOff();
			gsnTools.doPublishBadgeFeed(badge_obj.id, doShareComplete); 
		}
		
		public function doShareComplete():void
		{
			doDestroy();
			
		}


	}
}




