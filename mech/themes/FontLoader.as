package mech.themes {
	
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.text.TextFormat;
	import flash.utils.*;
	
	import mech.themes.IFont;
	import mech.utilities.*;
	
	public class FontLoader extends TextFormat implements IEventDispatcher, Loadable {
		
		private static var fontCache:Array = new Array ();
		private var eventDispatcher:EventDispatcher;
		private var url:String;
		
		public function FontLoader ( autoLoad:Boolean = false, url:String, size:Object = 12, color:Object = 0x000000, bold:Object = false, italic:Object = false, underline:Object = null, align:String = null, leftMargin:Object = null, rightMargin:Object = null, indent:Object = null, leading:Object = null, kerning:Number = 0 ) {
			
			super ( null, size, color, bold, italic, underline, null, null, align, leftMargin, rightMargin, indent, leading );
			
			this.letterSpacing = kerning;
			this.url = url;
			
			if ( fontCache [ url ] != null ) {
				setFontStyle ( fontCache [ url ] );
			} else {
				
				if ( autoLoad ) {
					load ( );
				}
				
			}
			
		}
		
		public function load ( ):void {
			
			var loader:Loader = new Loader ( );
			var context:LoaderContext = new LoaderContext ( );
			context.applicationDomain = new ApplicationDomain ( ApplicationDomain.currentDomain );
			loader.contentLoaderInfo.addEventListener ( Event.COMPLETE, onFontLoaded );
			loader.load ( new URLRequest ( url ), context );
			
		}
		
		private function onFontLoaded ( event:Event ):void {
			
			var info:LoaderInfo = event.target as LoaderInfo;
			var loadedFont:* = info.content;
			
			fontCache [ event.target.url ] = loadedFont;
			setFontStyle ( loadedFont  );
			
			this.dispatchEvent ( event );
			
		}
		
		private function setFontStyle ( loadedFont:* ):void {
			
			if ( this.bold ) {
				if ( this.italic ) {
					this.font = loadedFont.fontNameBoldItalic;
					return;
				} else {
					this.font = loadedFont.fontNameBold;
					return;
				}
			}
			
			if ( this.italic ) {
				this.font = loadedFont.fontNameItalic;
				return;
			}
			
			this.font = loadedFont.fontNameNormal;
			
		}
		
		
		
		public function addEventListener ( type:String, listener:Function, useCapture:Boolean = false, priority:int = 0 ):void {
			eventDispatcher.addEventListener ( type, listener, useCapture, priority );
		}

		public function dispatchEvent ( event:Event ):Boolean {
			return eventDispatcher.dispatchEvent ( event );
		}

		public function hasEventListener ( type:String ):Boolean {
			return eventDispatcher.hasEventListener ( type );
		}

		public function removeEventListener ( type:String, listener:Function, useCapture:Boolean = false ):void {
			eventDispatcher.removeEventListener ( type, listener, useCapture );
		}

		public function willTrigger ( type:String ):Boolean {
			return eventDispatcher.willTrigger ( type );
		}
		
	}
	
}