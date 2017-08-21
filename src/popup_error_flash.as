package src
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
    import flash.utils.*;
	import flash.net.*;

	public class popup_error_flash extends MovieClip
	{

		public function popup_error_flash(){
			
			bgetFlash.addEventListener(MouseEvent.MOUSE_UP, function(e:Event) {
				var request:URLRequest = new URLRequest("http://get.adobe.com/flashplayer/");
				navigateToURL(request, "_blank");
			});
		}
		

	}
}