package mech.themes {
	
	import flash.display.LoaderInfo;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.net.URLRequest;
	
	import flash.events.*;
	
	import mech.utilities.*;
	
	public class Image extends Sprite implements Loadable {
		
		public var outImg:BitmapData;
		public var overImg:BitmapData;
		public var downImg:BitmapData;
		
		public var loadQueue:LoadQueue;
		
		public var resultBmp:Bitmap;
		
		public function Image ( imageXml:XMLList, autoLoad:Boolean =- false ):void {	
			
			if ( !imageXml.hasOwnProperty ( "@out" ) ) {
				return;
			}
			
			resultBmp = new Bitmap ();
			resultBmp.cacheAsBitmap = true;
			addChild (resultBmp);
			
			var baseDir:String = VinomPlayer.currentTheme.baseDir + "/";
			
			var outImageLoader:LoaderWrapper = new LoaderWrapper ( new URLRequest ( imageXml.@out ) );
			outImageLoader.contentLoaderInfo.addEventListener ( Event.COMPLETE, outImgLoadComplete );
			
			loadQueue = new LoadQueue ( false, outImageLoader );
			
			var overImageLoader:LoaderWrapper = new LoaderWrapper ( );
			var downImageLoader:LoaderWrapper = new LoaderWrapper ( );
			
			if ( imageXml.hasOwnProperty ( "@over" ) ) {
				overImageLoader.request.url = imageXml.@over;
				overImageLoader.contentLoaderInfo.addEventListener ( Event.COMPLETE, overImgLoadComplete );
				loadQueue.addToQueue ( overImageLoader );
			}
			
			if ( imageXml.hasOwnProperty ( "@down" ) ) {
				downImageLoader.request.url = imageXml.@down;
				downImageLoader.contentLoaderInfo.addEventListener ( Event.COMPLETE, downImgLoadComplete );
				loadQueue.addToQueue ( downImageLoader );
			}
			
			
			if ( imageXml.hasOwnProperty ( "@x" ) ) {
				this.x = Number ( imageXml.@x );
			}
			if ( imageXml.hasOwnProperty ( "@y") ) {
				this.y = Number ( imageXml.@y );
			}
			if ( imageXml.hasOwnProperty ( "@rotation" ) ) {
				this.rotation = Number ( imageXml.@rotation );
			}
			
			if ( autoLoad ) {
				load ( );
			}
			
		}
		
		public function load ( ):void {
			loadQueue.load ( );
		}
		
		private function outImgLoadComplete ( event:Event ):void {
			
			outImg = Bitmap ( event.target.content ).bitmapData;
			resultBmp.bitmapData = outImg;
			
			this.dispatchEvent ( event );
			
		}
		
		private function overImgLoadComplete ( event:Event ):void {
			
			overImg = Bitmap ( event.target.content ).bitmapData;
			
			this.addEventListener ( MouseEvent.ROLL_OVER, onRollOver );
			this.addEventListener ( MouseEvent.ROLL_OUT, onRollOut );
			
		}
		
		private function downImgLoadComplete ( event:Event ):void {
			
			downImg = Bitmap ( event.target.content ).bitmapData;
			
			this.addEventListener ( MouseEvent.MOUSE_DOWN, onPress );
			this.addEventListener ( MouseEvent.MOUSE_UP, onRelease );
			
		}
		
		private function onRollOver ( e:MouseEvent ):void {
			
			if ( e.buttonDown ) {
				resultBmp.bitmapData = downImg;
				return;
			}
			
			resultBmp.bitmapData = overImg;
		}
		
		private function onRollOut ( e:MouseEvent ):void {
			resultBmp.bitmapData = outImg;
		}
		
		private function onPress ( e:MouseEvent ):void {
			resultBmp.bitmapData = downImg;
		}
		
		private function onRelease ( e:MouseEvent ):void {
			
			if ( overImg == null ) {
				resultBmp.bitmapData = outImg;
				return;
			}
			
			resultBmp.bitmapData = overImg;
		}
		
	}

}