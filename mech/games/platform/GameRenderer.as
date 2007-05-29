
////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 Mecheye Independent Studios
//  Some Rights Reserved.
//  Source Code written by JP St. Pierre
//
////////////////////////////////////////////////////////////////////////////////


package mech.games.platform {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.*;
	import flash.geom.*;
	
	import flash.utils.describeType;
	
	import mech.games.platform.*;
	import mech.games.platform.hero.Hero;
	
	import mech.utilities.FlashOut;
	import mech.utilities.Loadable;
	
	/**
	* A class that renderers all objects onto the screen.
	*/	
	public class GameRenderer extends Bitmap implements Renderable {
		
		protected var renderQueue:Array;
		protected var renderedBitmap:BitmapData;
		protected var baseBitmap:BitmapData;
		
		protected var doesDispose:Boolean;
		
		public function GameRenderer ( width:Number, height:Number, transparent:Boolean = true, fillColor:uint = 0, ...children ):void {
			
			renderQueue = new Array ( );
			
			baseBitmap = renderedBitmap = new BitmapData ( width, height, transparent, fillColor );
			
			super ( );
			
		}
		
		
		public function render ( ):BitmapData {
			return renderFrame ( );
		}
		
		public function getPosition ( ):Point {
			return new Point ( this.x, this.y );
		}
		
		public function getDimensions ( ):Point {
			return new Point ( this.width, this.height );
		}
		
		
		
		public function start ( ):void {
			this.addEventListener ( Event.ENTER_FRAME, renderFrame );
		}
		
		public function stop ( ):void {
			this.removeEventListener ( Event.ENTER_FRAME, renderFrame );
		}
		
		public function set clear ( value:Boolean ):void {
			doesDispose = value;
		}
		
		public function get clear ( ):Boolean {
			return doesDispose;
		}
		
		
		protected function renderFrame ( event:Event = null ):BitmapData {
			
			
			if ( doesDispose ) {
				renderedBitmap.dispose ( );
				renderedBitmap = baseBitmap.clone ( );
			}
			
			for each ( var item:Renderable in renderQueue ) {
				
				FlashOut.trace ( item );
				
				var itemBitmap:BitmapData = item.render ( );
				
				var itemRect:Rectangle = new Rectangle ( 0, 0, item.getDimensions ( ).x , item.getDimensions ( ).y );
				var itemPoint:Point = new Point ( item.getPosition ( ).x , item.getPosition ( ).y );
				
				renderedBitmap.copyPixels ( itemBitmap, itemRect, itemPoint, null, null, true );
				
			}
			
			this.dispatchEvent ( new Event ( Event.RENDER ) );
			
			this.bitmapData = renderedBitmap;
			
			return renderedBitmap;
			
		}
		
		public function addAtTop ( value:Renderable ):void {
			renderQueue.push ( value );
		}
		
		public function addAtBottom ( value:Renderable ):void {
			renderQueue.unshift ( value );
		}
		
		public function addAtIndex ( index:int, value:Renderable ):void {
			renderQueue.splice ( index, 0, value );
		}
		
		public function remove ( value:Renderable ):void {
			renderQueue.splice ( renderQueue.indexOf ( value ), 1 );
		}
		
		public function removeByIndex ( index:int ):void {
			renderQueue.splice ( index, 1 );
		}
		
		public function swapIndexes ( index1:int, index2:int ):void {
			arraySwap ( renderQueue, index1, index2 );
		}
		
		public function swapChildren ( value1:Renderable, value2:Renderable ):void {
			
			if ( ( value1 in renderQueue ) && ( value2 in renderQueue ) ) {
				
				var index1:int = renderQueue.indexOf ( value1 );
				var index2:int = renderQueue.indexOf ( value2 );
				
				arraySwap ( renderQueue, index1, index2 );
				
			}
		}
		
		private static function arraySwap ( array:Array, index1:*, index2:* ):Array {
			
			var temporary:Renderable = array [ index1 ];
			
			array [ index1 ] = array [ index2 ];
			array [ index2 ] = temporary;
			
			return array;
			
		}
		
	}
	
}