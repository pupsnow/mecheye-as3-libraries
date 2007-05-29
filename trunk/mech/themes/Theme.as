package mech.themes {
	
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.*;
	import flash.errors.*;
	
	import flash.display.Stage;
	
	import mech.themes.*;
	
	import com.anttikupila.revolt.Revolt;
	import com.anttikupila.revolt.presets.AlbumArt;
	
	public class Theme {
		
		private var _baseDir:String;
		
		public var xmlData:XML;
		public var urlLoader:URLLoader;
		
		public var buttons:Array;
		public var sliders:Array;
		public var lists:Array;
		public var songInfos:Array;
		public var visualizers:Array;
		
		public var backgroundImage:Image;
		private var xmlToParse:XML;
		
		public function Theme ( file:String ):void {
			
			buttons = new Array ( );
			sliders = new Array ( );
			lists = new Array ( );
			songInfos = new Array ( );
			visualizers = new Array ( );
			
			var urlRequest:URLRequest = new URLRequest ( file );
			urlLoader = new URLLoader ( );
			urlLoader.addEventListener ( Event.COMPLETE, dataLoadComplete );
			urlLoader.load ( urlRequest );
			
			VinomPlayer.trace ("Loading theme XML.");
			
		}
		
		public function get baseDir ( ):String {
			return _baseDir;
		}
		
		public function dataLoadComplete ( event:Event ):void {
			
			try {
				xmlData = new XML ( urlLoader.data );
				VinomPlayer.trace ("Parsing theme XML.");
				parseXml ( xmlData );
			} catch(e:Error) {
				VinomPlayer.stopAll = true;
				VinomPlayer.trace ( "Theme XML Parsing Error: " + e.message + "\n Please notify a vinom administrator." );
			}
			
		}
		
		public function parseXml ( argXmlToParse:XML ):void {
			
			if ( VinomPlayer.stopAll ) {
				return;
			}
			
			xmlToParse = argXmlToParse;
			_baseDir = xmlToParse.Theme.BaseDir.text ();
			
			backgroundImage = new Image ( XMLList (xmlToParse.Theme.Image) );
			backgroundImage.onImageLoaded = nextButton;
			VinomPlayer.trace ("Loading Background Image.");
			
		}
		
		public function nextButton (e:Event):void {
			
			if (VinomPlayer.stopAll) {
				return;
			}
			
			var buttonXmlArray:XMLList = xmlToParse.Theme.Button;
			if (buttonXmlArray.length () < 1) {
				nextSlider (e);
				return;
			}
			var temporaryButton:Button = new Button (XMLList (buttonXmlArray[buttonIndex ++]));
			buttons[temporaryButton.xmlId] = temporaryButton;
			if (buttonIndex - 1 < buttonXmlArray.length ()) {
				temporaryButton.onImageLoaded = nextButton;
			} else {
				VinomPlayer.trace ("Buttons Loaded.");
				nextSlider (e);
			}
		}
		
		public function nextSlider (e:Event):void {
			
			if (VinomPlayer.stopAll) {
				return;
			}
			
			var sliderXmlArray:XMLList = xmlToParse.Theme..Slider;
			if (sliderXmlArray.length () < 1) {
				nextPlaylist (e);
				return;
			}
			var temporarySlider:Slider = new Slider (XMLList (sliderXmlArray[sliderIndex ++]));
			sliders [temporarySlider.xmlId] = temporarySlider;
			if (sliderIndex - 1 < sliderXmlArray.length ()) {
				temporarySlider.onImageLoaded = nextSlider;
			} else {
				VinomPlayer.trace ("Sliders Loaded.");
				nextPlaylist (e);
			}
		}
		
		public function nextPlaylist (e:Event):void {
			
			if (VinomPlayer.stopAll) {
				return;
			}
			
			var playlistXmlArray:XMLList = xmlToParse.Theme..Playlist;
			if (playlistXmlArray.length () < 1) {
				nextSongInfo (e);
				return;
			}
			var xmlNode:XML = playlistXmlArray[listIndex ++];
			var temporaryPlaylist:Playlist = new Playlist (xmlNode);
			lists [temporaryPlaylist.xmlId] = temporaryPlaylist;
			if (listIndex < playlistXmlArray.length ()) {
				temporaryPlaylist.onLoaded = nextPlaylist;
			} else {
				VinomPlayer.trace ("Playlist Displays loaded.");
				nextSongInfo (e);
			}
		}
		
		public function nextSongInfo (e:Event):void {
			
			if (VinomPlayer.stopAll) {
				return;
			}
			
			var songInfoXmlArray:XMLList = xmlToParse.Theme..SongInfo;
			if (songInfoXmlArray.length () < 1) {
				nextVisualizer (e);
				return;
			}
			var xmlNode:XML = songInfoXmlArray[songInfoIndex ++];
			var temporarySongInfo:SongInfo = new SongInfo (xmlNode);
			songInfos [temporarySongInfo.xmlId] = temporarySongInfo;
			if (songInfoIndex < songInfoXmlArray.length ()) {
				temporarySongInfo.onLoaded = nextSongInfo;
			} else {
				VinomPlayer.trace ("Song Info Displays loaded.");
				nextVisualizer (e);
			}
		}
		
		public function nextVisualizer (e:Event):void {
			
			if (VinomPlayer.stopAll) {
				return;
			}
			
			var visualizerXmlArray:XMLList = xmlToParse.Theme..Visualizer;
			if (visualizerXmlArray.length () < 1) {
				displayEverything ();
				return;
			}
			var xmlNode:XML = visualizerXmlArray[visualizerIndex ++];
			var width:Number = xmlNode.Size.@width;
			var height:Number = xmlNode.Size.@height;
			var x:Number = xmlNode.Position.@x;
			var y:Number = xmlNode.Position.@y;
			var albumArt:String = xmlNode.@albumArt;
			var temporaryRevolt:Revolt = new Revolt (x, y, width, height, albumArt);
			visualizers [xmlNode.@name] = temporaryRevolt;
			if (visualizerIndex < visualizerXmlArray.length ()) {
				VinomPlayer.trace ("Visualizers loaded.");
				nextVisualizer (e);
			} else {
				displayEverything ();
			}
		}
		
		public function displayEverything ():void {
			
			if (VinomPlayer.stopAll) {
				return;
			}
			
			VinomPlayer.instance.removeChild (VinomPlayer.loadingOutput);
			
			VinomPlayer.instance.addChild (backgroundImage);
			var i:String;
			for (i in buttons) {
				VinomPlayer.instance.addChild (buttons[i]);
				buttons[i].initB ();
				Output.trace (buttons[i]);
			}
			for (i in sliders) {
				VinomPlayer.instance.addChild (sliders[i]);
			}
			for (i in songInfos) {
				VinomPlayer.instance.addChild (songInfos[i]);
			}
			for (i in visualizers) {
				VinomPlayer.instance.addChild (visualizers[i]);
			}
			for (i in lists) {
				VinomPlayer.instance.addChild (lists[i]);
			}
			if (AlbumArt.instance is AlbumArt) {
				AlbumArt.instance.loadImage ();
			}
			VinomPlayer.soundQueue.init ();
		}
		
		public function toString ():String {
			return "Theme";
		}
		
		public static function returnFontLoader ( autoLoad:Boolean = false, argBaseDir:String, fontXml:XMLList ):FontLoader {
			var bold:Object = false;
			var italic:Object = false;
			var underline:Object = false;
			var align:String = "left";
			var size:Object = 12;
			var color:Object = 0;
			var leftMargin:Object = 0;
			var rightMargin:Object = 0;
			var indent:Object = 0;
			var leading:Object = 0;
			var kerning:Number = 0;
			
			if (fontXml.hasOwnProperty ("@bold")) {
				bold = (fontXml.@bold == "true");
			}
			if (fontXml.hasOwnProperty ("@italic")) {
				italic = (fontXml.@italic == "true");
			}
			if (fontXml.hasOwnProperty ("@underline")) {
				italic = (fontXml.@underline == "true");
			}
			if (fontXml.hasOwnProperty ("@size")) {
				size = Number (fontXml.@size);
			}
			if (fontXml.hasOwnProperty ("@align")) {
				align = String (fontXml.@align);
			}
			if (fontXml.hasOwnProperty ("@color")) {
				color = Theme.getColor (fontXml.@color);
			}
			if (fontXml.hasOwnProperty ("@leftMargin")) {
				leftMargin = Number (fontXml.@leftMargin);
			}
			if (fontXml.hasOwnProperty ("@rightMargin")) {
				rightMargin = Number (fontXml.@rightMargin);
			}
			if (fontXml.hasOwnProperty ("@indent")) {
				indent = Number (fontXml.@indent);
			}
			if (fontXml.hasOwnProperty ("@leading")) {
				leading = Number (fontXml.@leading);
			}
			if (fontXml.hasOwnProperty ("@letterSpacing")) {
				kerning = Number (fontXml.@letterSpacing);
			}
			
			var fontStyleLoader:FontLoader = new FontLoader ( autoLoad, argBaseDir + fontXml.@swf, size, color, bold, italic, underline, align, leftMargin, rightMargin, indent, leading, kerning );
			return fontStyleLoader;
		}
		
		private static function getColor ( value:String ):Number {
			if (value.charAt (0) == "#") {
				return hexStringToColor ( value, 1 );
			}
			if (value.search (",") != -1) {
				return rgbStringToColor ( value );
			}
			return hexStringToColor ( value, 0 );
		}
		
		private static function hexStringToColor ( value:String, startIndex:Number ):Number {
			return parseInt (value.substring (startIndex, value.length), 16);
		}
		
		private static function rgbStringToColor ( value:String ):Number {
			var colors:Array = value.split (",");
			var red:Number = parseInt (String (colors[0]), 10);
			var green:Number = parseInt (String (colors[1]), 10);
			var blue:Number = parseInt (String (colors[2]), 10);
			
			return (red << 16) | (green << 8) | blue;
		}
		
		
	}
	
}