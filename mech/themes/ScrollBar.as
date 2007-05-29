package mech.themes {
	
	import flash.display.Sprite;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.geom.*;
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	import mech.themes.Image;
	import mech.themes.Playlist;
	
	import mech.utilities.*;
	
	public class ScrollBar extends Sprite {
		
		public var onScroll:Function = function (i:Number):void {};
		
		public static const TIMER_INTERVAL:Number = 100;
		public static const SCROLL_UP:Number = -1;
		public static const SCROLL_DOWN:Number = 1;
		
		private var upArrow:Image;
		private var downArrow:Image;
		
		private var topCap:BitmapData;
		private var bottomCap:BitmapData;
		
		private var maskLoader:Loader;
		private var maskImg:Bitmap;
		
		private var track:Sprite;
		private var trackBitmap:BitmapData;
		private var barBitmap:BitmapData;
		
		private var barHeight:Number;
		private var numOfBars:Number;
		
		private var numberOfScrollBars:Number;
		private var targetList:Playlist;
		private var scrollTimer:Timer;

		private var scrollBarXml:XMLList;
		private var barUrl:String;
		private var trackY:Number = 10;
		
		private var loadQueue:LoadQueue;
		
		private var baseDir:String;
		
		public function ScrollBar (target:Playlist, scrollBarXml:XMLList):void {
			
			baseDir = VinomPlayer.currentTheme.baseDir + "/";
			
			this.scrollBarXml = scrollBarXml;
			targetList = target;
			
			loadQueue = new LoadQueue ( false )
			
			if (scrollBarXml.hasOwnProperty ("UpArrow")) {
				upArrow = new Image ( scrollBarXml.UpArrow, false );
				upArrow.addEventListener (MouseEvent.MOUSE_DOWN, upArrowStart);
				addChild (upArrow);
			}
			
			if (scrollBarXml.hasOwnProperty ("DownArrow")) {
				downArrow = new Image ( scrollBarXml.DownArrow, false );
				downArrow.addEventListener (MouseEvent.MOUSE_DOWN, downArrowStart);
				addChild (downArrow);
			}
			
			barHeight = scrollBarXml.Scroller.@barHeight;
			numOfBars = scrollBarXml.Scroller.@numberOfBars;
			
			var baseDir:String = VinomPlayer.currentTheme.baseDir + "/";
			barUrl = baseDir + scrollBarXml.Scroller.@bar;
			
			var trackLoader:Loader = new Loader ();
			trackLoader.load ( new URLRequest (baseDir + scrollBarXml.Scroller.@track) );
			trackLoader.contentLoaderInfo.addEventListener ( Event.COMPLETE, trackImageLoaded );
			
			track = new Sprite ();
			track.addEventListener ( MouseEvent.MOUSE_DOWN, onTrackClick);
			track.addEventListener ( Event.ENTER_FRAME, onEnterFrame );
			
			if (scrollBarXml.Scroller.hasOwnProperty ("@x")) {
				track.x = scrollBarXml.Scroller.@x;
			}
			if (scrollBarXml.Scroller.hasOwnProperty ("@y")) {
				track.y = scrollBarXml.Scroller.@y;
			}
			
			if (scrollBarXml.Scroller.hasOwnProperty ("@mask")) {
				maskLoader = new Loader ();
				maskLoader.contentLoaderInfo.addEventListener ( Event.COMPLETE, maskImgLoadComplete );
				maskLoader.load ( new URLRequest (baseDir + scrollBarXml.Scroller.@mask) );
			}
			
			addChild (track);
			
			if (scrollBarXml.hasOwnProperty ("@x")) {
				this.x = Number (scrollBarXml.@x);
			}
			if (scrollBarXml.hasOwnProperty ("@y")) {
				this.y = Number (scrollBarXml.@y);
			}
			
		}
		
		private function maskImgLoadComplete (e:Event):void {
			e.target.removeEventListener (Event.COMPLETE, maskImgLoadComplete);
			maskImg = Bitmap ( e.target.content );
			var maskImg2:Bitmap = new Bitmap (maskImg.bitmapData);
			maskImg.cacheAsBitmap = true;
			maskImg2.cacheAsBitmap = true;
			
			addChild (maskImg);
			addChild (maskImg2);
			this.mask = maskImg2;
		}
		
		public function updateTrack ( event:MouseEvent ):void {
			var firstIndex:Number = (((event.localY) / numOfBars) * targetList.maxRows) - targetList.maxRows / 2;
			Output.trace (firstIndex);
			if (firstIndex < -1) {
				firstIndex = -1;
			}
			if (firstIndex + numberOfScrollBars > numOfBars) {
				firstIndex = numOfBars - numberOfScrollBars;
			}
			targetList.onScroll (firstIndex);
		}
		
		public function onTrackClick ( event:MouseEvent ):void {
			VinomPlayer.instance.addEventListener ( MouseEvent.MOUSE_MOVE, updateTrack );
			VinomPlayer.instance.addEventListener ( MouseEvent.MOUSE_UP, stopTrackDrag );
			track.addEventListener ( MouseEvent.MOUSE_UP, stopTrackDrag );
			track.addEventListener ( MouseEvent.MOUSE_MOVE, updateTrack );
			updateTrack ( event );
		}
		
		public function stopTrackDrag ( event:MouseEvent ):void {
			VinomPlayer.instance.removeEventListener ( MouseEvent.MOUSE_MOVE, updateTrack );
			VinomPlayer.instance.removeEventListener ( MouseEvent.MOUSE_UP, stopTrackDrag );
			track.removeEventListener ( MouseEvent.MOUSE_UP, stopTrackDrag );
			track.removeEventListener ( MouseEvent.MOUSE_MOVE, updateTrack );
		}
		
		public function onEnterFrame ( event:Event ):void {
			// Output.trace (isLoaded);
			if (isLoaded < isLoadedMax) {
				return;
			}
			
			// Output.trace ("AA!");
			if (targetList.getNumberOfRows () < targetList.maxRows) {
				numberOfScrollBars = numOfBars;
			} else {
				numberOfScrollBars = Math.round (targetList.maxRows / targetList.getNumberOfRows () * numOfBars);
			}
			var barYPosition:Number = (targetList.firstIndex+1) * barHeight * (numOfBars / targetList.maxRows - 2);
			
			track.graphics.clear ();
			track.graphics.beginBitmapFill (trackBitmap);
			track.graphics.drawRect (0, 0, trackBitmap.width, barHeight * numOfBars);
			track.graphics.endFill ();
			
			track.graphics.beginBitmapFill (barBitmap);
			track.graphics.drawRect (0, barYPosition, barBitmap.width, barHeight * numberOfScrollBars);
			track.graphics.endFill ();
			
			if (topCap != null) {
				var topCapHeight:Number = Math.floor (topCap.height / barHeight) * barHeight;
				track.graphics.beginBitmapFill (topCap);
				track.graphics.drawRect (0, barYPosition, topCap.width, topCapHeight);
				track.graphics.endFill ();
			}
			if (bottomCap != null) {
				var bottomCapHeight:Number = Math.floor (bottomCap.height / barHeight) * barHeight;
				track.graphics.beginBitmapFill (bottomCap);
				track.graphics.drawRect (0, barYPosition + barHeight * (numberOfScrollBars - 1), bottomCap.width, bottomCapHeight);
				track.graphics.endFill ();
			}
			
		}
		
		public function trackImageLoaded ( event:Event ):void {
			trackBitmap = Bitmap (event.target.content).bitmapData;
			isLoaded ++;
			
			var barLoader:Loader = new Loader ();
			barLoader.load ( new URLRequest (barUrl) );
			barLoader.contentLoaderInfo.addEventListener ( Event.COMPLETE, barImageLoaded );
		}
		
		public function barImageLoaded ( event:Event ):void {
			barBitmap = Bitmap (event.target.content).bitmapData;
			isLoaded ++;
			
			Output.trace (scrollBarXml.toXMLString ());
			
			if (scrollBarXml.Scroller.hasOwnProperty ("@topCap")) {
				Output.trace ("Testing");
				var topCapLoader:Loader = new Loader ();
				topCapLoader.load ( new URLRequest (baseDir + scrollBarXml.Scroller.@topCap) );
				topCapLoader.contentLoaderInfo.addEventListener ( Event.COMPLETE, topCapLoaded );
				isLoadedMax ++;
			}
			
			if (scrollBarXml.hasOwnProperty ("Scroller.@bottomCap")) {
				var bottomCapLoader:Loader = new Loader ();
				bottomCapLoader.load ( new URLRequest (baseDir + scrollBarXml.Scroller.@bottomCap) );
				bottomCapLoader.contentLoaderInfo.addEventListener ( Event.COMPLETE, bottomCapLoaded );
				isLoadedMax ++;
			}
		}
		
		public function topCapLoaded ( event:Event ):void {
			topCap = Bitmap (event.target.content).bitmapData;
			isLoaded ++;
		}
		
		public function bottomCapLoaded ( event:Event ):void {
			bottomCap = Bitmap (event.target.content).bitmapData;
			isLoaded ++;
		}
		
		public function upArrowStart ( event:MouseEvent ):void {
			scrollTimer = new Timer (ScrollBar.TIMER_INTERVAL);
			scrollTimer.addEventListener (TimerEvent.TIMER, upArrowScroll);
			scrollTimer.start ();
			upArrow.addEventListener (MouseEvent.MOUSE_UP, upArrowStop);
			upArrow.addEventListener (MouseEvent.MOUSE_OUT, upArrowStop);
			upArrowScroll ( null );
		}
		
		public function downArrowStart ( event:MouseEvent ):void {
			scrollTimer = new Timer (ScrollBar.TIMER_INTERVAL);
			scrollTimer.addEventListener (TimerEvent.TIMER, downArrowScroll);
			scrollTimer.start ();
			downArrow.addEventListener (MouseEvent.MOUSE_UP, downArrowStop);
			downArrow.addEventListener (MouseEvent.MOUSE_OUT, downArrowStop);
			downArrowScroll ( null );
		}
		
		public function upArrowScroll ( event:TimerEvent ):void {
			onScroll (ScrollBar.SCROLL_UP + targetList.firstIndex);
		}
		
		public function downArrowScroll ( event:TimerEvent ):void {
			onScroll (ScrollBar.SCROLL_DOWN + targetList.firstIndex);
		}
		
		public function upArrowStop ( event:MouseEvent ):void {
			scrollTimer.removeEventListener (TimerEvent.TIMER, upArrowScroll);
			scrollTimer.stop ();
			upArrow.removeEventListener (MouseEvent.MOUSE_UP, upArrowStop);
			upArrow.removeEventListener (MouseEvent.MOUSE_OUT, upArrowStop);
		}
		
		public function downArrowStop ( event:MouseEvent ):void {
			scrollTimer.removeEventListener (TimerEvent.TIMER, downArrowScroll);
			scrollTimer.stop ();
			downArrow.removeEventListener (MouseEvent.MOUSE_UP, downArrowStop);
			downArrow.removeEventListener (MouseEvent.MOUSE_OUT, downArrowStop);
		}
		
	}
}