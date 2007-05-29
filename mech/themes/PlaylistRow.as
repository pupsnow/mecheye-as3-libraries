package mech.themes {
	
	import flash.text.TextField;
	import flash.text.AntiAliasType;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.display.Sprite;
	import flash.events.*;
	
	import mech.sound.utilities.Song;
	import mech.themes.FontLoader;
	import mech.themes.Theme;
	
	import mech.utilities.*;
	
	public class PlaylistRow extends Sprite implements Loadable {
		
		public var song:Song;
		public var display:TextField;
		
		private var formatType:String;
		private var fontStyle:TextFormat;
		private var fontStyleLoader:FontLoader;
		private var listNode:XMLList;
		
		private var rowHeight:Number;
		private var rowWidth:Number;
		
		public function PlaylistRow ( listXml:XML, songInfo:Song, autoLoad:Boolean = false ):void {
			
			song = songInfo;
			formatType = listXml.FormatType.text ( );
			listNode = listXml.List;
			
			rowHeight = listNode.@rowHeight || 0;
			rowWidth = listNode.@rowWidth || 0;
			
			var baseDir:String = VinomPlayer.currentTheme.baseDir + "/";
			
			display = new TextField ();
			addChild ( display );
			
			this.addEventListener ( MouseEvent.CLICK, onClick );
			this.buttonMode = true;
			this.useHandCursor = true;
			
			fontStyleLoader = Theme.returnFontLoader ( false, baseDir, listXml.Font );
			fontStyleLoader.addEventListener ( Event.COMPLETE, onFontLoaded );
			
			if ( autoLoad ) {
				fontStyleLoader.load ( );
			}
			
		}
		
		public function load ( ):void {
			fontStyleLoader.load ( );
		}
		
		public function onFontLoaded ( event:Event ):void {
			
			fontStyle = fontStyleLoader as TextFormat;
			
			display.text = getDisplayText ( );
			display.height = rowHeight;
			display.width = rowWidth;
			display.selectable = false;
			display.setTextFormat ( fontStyle );
			
			Output.trace ("Playlist Font Loaded!");
			
			this.dispatchEvent ( event );
			
		}
		
		public function onClick ( event:MouseEvent ):void {
			VinomPlayer.soundQueue.playFromIndex ( song.index );
		}
		
		public function getDisplayText ():String {
			
			var replacedText:String = formatType;
			var trackNumberWithSpace:String = song.trackNumber.toString ();
			var trackNumberWith0:String = song.trackNumber.toString ();
			
			var maxChars:Number = Number (listNode.@maxChars || 0);
			
			if (trackNumberWith0.length < 2) {
				trackNumberWith0 = "0" + trackNumberWith0;
			}
			
			if (trackNumberWithSpace.length < 2) {
				trackNumberWithSpace += " ";
			}
			
			replacedText = replacedText.replace ( "%TRACKNUMBER%", song.trackNumber.toString () );
			replacedText = replacedText.replace ( "%TRACKNUMBER %", trackNumberWithSpace );
			replacedText = replacedText.replace ( "%0TRACKNUMBER%", trackNumberWith0 );
			replacedText = replacedText.replace ( "%ARTIST%", song.artist );
			replacedText = replacedText.replace ( "%ALBUM%", song.album );
			replacedText = replacedText.replace ( "%SONGTITLE%", song.title );
			
			if (maxChars > 0) {
				replacedText = replacedText.substring (0, maxChars);
			}
			
			return replacedText;
			
		}
		
	}
	
}