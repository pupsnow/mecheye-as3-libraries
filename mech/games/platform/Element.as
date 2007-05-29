
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
	import flash.display.Loader;
	import flash.events.Event;
	import flash.geom.*;
	import flash.net.URLRequest;
	
	import mech.games.platform.Globals;
	import mech.utilities.Loadable;
	
	/**
	* The Element class is a base class for every object on the screen.
	*/
	public class Element extends Bitmap implements Loadable, Renderable {
		
		private var url:String;
		
		/**
		* Creates a new GameElement.
		* @param	source	The path to the image file of the GameElement.
		*/
		public function Element ( source:String, autoLoad:Boolean = false ):void {
			
			url = Globals.IMAGE_DIR + source;
			
			if ( autoLoad ) {
				load ();
			}
			
		}
		
		/**
		* The function called when the source image has loaded.
		* @param	event The event object from when the event is dispatched.
		*/
		protected function elementImageLoaded ( event:Event ):void {
			
			this.bitmapData = makeTransparent ( event.target.content.bitmapData );
			Globals.filesLoaded [ url ] = event.target.content.bitmapData;
			
			manipulateImage ( this.bitmapData );
			
			this.dispatchEvent ( event );
			this.addEventListener ( Event.ENTER_FRAME, update );
			
		}
		
		protected function manipulateImage ( sourceBmp:BitmapData ):void {
		}
		
		public function load ( ):void {
			
			var cachedFile:BitmapData = Globals.filesLoaded [ url ];
			
			if ( cachedFile != null ) {
				this.bitmapData = makeTransparent ( cachedFile.clone ( ) );
				manipulateImage ( this.bitmapData );
				this.dispatchEvent ( new Event ( Event.COMPLETE ) );
				return;
			}
			
			var spriteLoader:Loader = new Loader ( );
			spriteLoader.load ( new URLRequest ( url ) );
			spriteLoader.contentLoaderInfo.addEventListener ( Event.COMPLETE, elementImageLoaded );
			
		}
		
		/**
		* Protected function that removes a certain color designated as transparent.
		* @param	data
		*/
		protected function makeTransparent ( source:BitmapData ):BitmapData {
			
			var resultBitmapData:BitmapData = new BitmapData ( source.width, source.height, true );
			resultBitmapData.threshold ( source, source.rect, new Point (0, 0), "==", Globals.TRANSPARENT_COLOR, 0, 0xFFFFFFFF, true );
			
			return resultBitmapData;
			
		}
		
		protected function update ( event:Event ):void {
			
		}
		
		public function render ( ):BitmapData {
			return this.bitmapData;
		}
		
		public function getPosition ( ):Point {
			return new Point ( this.x, this.y );
		}
		
		public function getDimensions ( ):Point {
			return new Point ( this.width, this.height );
		}
		
	}
	
}
