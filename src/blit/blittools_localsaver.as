package  src.blit {

	public class blittools_localsaver{
		
			import flash.net.SharedObject;
			
			//doSaveLocal()
			public static function doSaveLocal(myGameName:String, myItem:String, myData:Object):Boolean{
				var d:SharedObject = SharedObject.getLocal(myGameName);
				d.data[myItem] = myData;
				d.flush();
				return true;
			}
			
			//doGetLocal()
			public static function doGetLocal(myGameName:String, myItem:String):*{
				var d:SharedObject = SharedObject.getLocal(myGameName);
				if (d.data[myItem]){
					return(d.data[myItem]);
				}else{
					return null;
				}
			}


	}
}