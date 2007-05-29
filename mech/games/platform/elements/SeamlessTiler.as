
////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 Mecheye Independent Studios
//  Some Rights Reserved.
//  Source Code written by JP St. Pierre
//
////////////////////////////////////////////////////////////////////////////////


package mech.games.platform.elements {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.geom.*;
	import flash.events.Event;
	
	import mech.games.platform.Renderable;
	
	import mech.games.platform.Element;
	import mech.games.platform.elements.SeamlessTilerMode;
	
	import mech.utilities.Loadable;
	
	public class SeamlessTiler extends Bitmap implements Loadable, Renderable {
		
		protected var backgroundData:BitmapData;
		protected var backgroundDimensions:Rectangle;
		
		private var backgroundLoader:Element;
		
		protected var tileMode:SeamlessTilerMode;
		protected var elementWidth:Number;
		protected var elementHeight:Number;
		protected var tileOffsets:Point;
		
		public function SeamlessTiler ( source:String, baseWidth:Number, baseHeight:Number, tileMode:SeamlessTilerMode, offsets:Point, autoLoad:Boolean = false ):void {
			
			backgroundLoader = new Element ( source, autoLoad );
			backgroundLoader.addEventListener ( Event.COMPLETE, elementImageLoaded );
			
			this.tileMode = tileMode;
			this.tileOffsets = offsets;
			this.elementWidth = baseWidth;
			this.elementHeight = baseHeight;
			
		}
		
		public function load ( ):void {
			backgroundLoader.load ( );
		}
		
		public function render ( ):BitmapData {
			return this.bitmapData;
		}
		
		public function getOffsets ( ):Point {
			return 
		}
		
		private function elementImageLoaded ( event:Event ):void {
			
			backgroundData = backgroundLoader.bitmapData;
			backgroundDimensions = new Rectangle ( 0, 0, backgroundData.width, backgroundData.height )
			manipulateImage ( );
			this.dispatchEvent ( event );
			
		}
		
		protected function manipulateImage ( ):void {
			
			var finalBitmapData:BitmapData = new BitmapData ( elementWidth, elementHeight );
			
			var xRepeat:Number = 1;
			var yRepeat:Number = 1;
			
			if ( tileMode == SeamlessTilerMode.REPEAT || tileMode == SeamlessTilerMode.REPEAT_X ) {
				xRepeat = Math.ceil ( backgroundData.width / elementWidth );
			}
			if ( tileMode == SeamlessTilerMode.REPEAT || tileMode == SeamlessTilerMode.REPEAT_Y ) {
				yRepeat = Math.ceil ( backgroundData.height / elementHeight );
			}
			
			var sourceRect:Rectangle = new Rectangle ( 0, 0, backgroundData.width, backgroundData.height );
			
			var destPoint:Point = new Point ( );
			
			for ( var i:Number = 0; i < xRepeat; i++ ) {
				
				destPoint.x = i * ( backgroundData.width - tileOffsets.x );
				
				for ( var j:Number = 0; j < yRepeat; j++ ) {
					
					destPoint.y = j * ( backgroundData.height - tileOffsets.y );
					finalBitmapData.copyPixels ( backgroundData, sourceRect, destPoint );
					
				}
			}
			
			this.bitmapData = finalBitmapData;
			
		}
		
		protected function scrollBy ( point:Point ):void {
			
			
			
		}
		
		
		public function getPosition ( ):Point {
			return new Point ( this.x, this.y );
		}
		
		public function getDimensions ( ):Point {
			return new Point ( this.width, this.height );
		}
		
	}
	
}