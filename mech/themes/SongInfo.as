package mech.themes {
	
	import flash.text.TextField;
	import flash.text.AntiAliasType;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.text.TextFormat;
	import flash.display.Sprite;
	import flash.events.*;
	
	import mech.themes.Image;
	import mech.themes.FontLoader;
	import mech.sound.utilities.Song;
	
	public class SongInfo extends Sprite {
		
		public var display:TextField;
		public var formatType:String;
		public var fontStyle:TextFormat;
		public var xmlId:String;
		public var loadText:String;
		public var loadTextFinal:String;
		
		private var fontStyleLoader:FontLoader;
		
		public var onLoaded:Function = function (e:Event):void {};
		
		public function SongInfo (songInfoXml:XML):void {
			
			var baseDir:String = VinomPlayer.currentTheme.baseDir + "/";
			
			xmlId = songInfoXml.@name;
			loadText = songInfoXml.LoadText.text ();
			formatType = songInfoXml.FormatType.text ();
			
			fontStyleLoader = Theme.returnFontLoader (baseDir, songInfoXml.Font);
			fontStyleLoader.onComplete = _onLoaded;
			
			display = new TextField ();
			display.selectable = false;
			
			addChild (display);
			
			this.x = songInfoXml.Position.@x;
			this.y = songInfoXml.Position.@y;
			
			this.addEventListener (Event.ENTER_FRAME, onEnterFrame);
			VinomPlayer.soundQueue.soundPlayer.onLoadProgress = onLoadProgress;
			onEnterFrame ();
		}
		
		private function _onLoaded (e:Event):void {
			Output.trace ("Font Loaded!");
			if (fontStyleLoader.align == TextFormatAlign.CENTER) {
				display.x -= display.width / 2;
			}
			if (fontStyleLoader.align == TextFormatAlign.RIGHT) {
				display.x -= display.width;
			}
			onLoaded (e);
		}
		
		private function onLoadProgress ( event:ProgressEvent ):void {
			var percent:Number = (event.bytesLoaded / (event.bytesTotal * VinomPlayer.BUFFER_PERCENT));
			if (loadText == "%PERCENT%") {
				loadTextFinal = String ( Math.floor (percent * 100) );
				return;
			}
			var loadTextLength:Number = percent * loadText.length;
			loadTextFinal = loadText.substr (0, loadTextLength);
		}
		
		private function onEnterFrame ( event:Event = undefined ):void {
			if (!VinomPlayer.soundQueue.soundPlayer.isPlaying) {
				return;
			}
			fontStyle = fontStyleLoader as TextFormat;
			display.text = getDisplayText ();
			display.autoSize = fontStyleLoader.align;
			display.antiAliasType = AntiAliasType.ADVANCED;
			display.setTextFormat (fontStyle);
			
		}
		
		private function getDisplayText ():String {
			
			if (VinomPlayer.soundQueue.soundPlayer.isLoading && loadText) {
				return loadTextFinal;
			}
			
			var replacedText:String = formatType;
			
			var theSong:Song = VinomPlayer.soundQueue.getCurrentSong ();
			if (VinomPlayer.soundQueue.soundPlayer.isStopped) {
				theSong.artist = "Stopped";
			}
			var trackNumberWithSpace:String = theSong.trackNumber.toString ();
			var trackNumberWith0:String = theSong.trackNumber.toString ();
			
			// Output.trace (trackNumberWithSpace);
			
			if (trackNumberWith0.length < 2) {
				trackNumberWith0 = "0" + trackNumberWith0;
			}
			
			if (trackNumberWithSpace.length < 2) {
				trackNumberWithSpace += " ";
			}
			
			
			var position:int = int (VinomPlayer.soundQueue.soundPlayer.getPosition () / 1000);
			var duration:int = int (VinomPlayer.soundQueue.soundPlayer.getDuration () / 1000);
			
			var positionMinutes:String = String (int (position/60));
			var positionSeconds:String = String (int (position%60));
			
			var durationMinutes:String = String (int (duration/60));
			var durationSeconds:String = String (int (duration%60));
			
			if (positionMinutes.toString ().length < 2) {
				positionMinutes = "0" + positionMinutes;
			}
			if (positionSeconds.toString ().length < 2) {
				positionSeconds = "0" + positionSeconds;
			}
			if (durationMinutes.toString ().length < 2) {
				durationMinutes = "0" + durationMinutes;
			}
			if (durationSeconds.toString ().length < 2) {
				durationSeconds = "0" + durationSeconds;
			}
			
			if (VinomPlayer.soundQueue.soundPlayer.isStopped) {
				positionMinutes = positionSeconds = durationMinutes = durationSeconds = "00";
			}
			
			replacedText = replacedText.replace ( "%TRACKNUMBER%", theSong.trackNumber.toString () );
			replacedText = replacedText.replace ( "%TRACKNUMBER %", trackNumberWithSpace );
			replacedText = replacedText.replace ( "%0TRACKNUMBER%", trackNumberWith0 );
			replacedText = replacedText.replace ( "%ARTIST%", theSong.artist );
			replacedText = replacedText.replace ( "%ALBUM%", theSong.album );
			replacedText = replacedText.replace ( "%SONGTITLE%", theSong.title );
			replacedText = replacedText.replace ( "%CURRENTMINUTES%", positionMinutes );
			replacedText = replacedText.replace ( "%CURRENTSECONDS%", positionSeconds );
			replacedText = replacedText.replace ( "%DURATIONMINUTES%", durationMinutes );
			replacedText = replacedText.replace ( "%DURATIONSECONDS%", durationSeconds );
			
			return replacedText;
		}
	}
	
}