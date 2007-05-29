package mech.themes {
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	
	import mech.sound.utilities.Song;
	import mech.sound.utilities.SoundQueue;
	import mech.themes.Image;
	import mech.themes.PlaylistRow;
	import mech.themes.ScrollBar;
	import mech.utilities.*;
	
	public class Playlist extends Sprite implements Loadable {
		
		private var listRows:Array;
		private var scrollBar:ScrollBar;
		private var buttons:Array;
		
		private var loadQueue:LoadQueue;
		
		private var rowSpacer:Number;
		private var maxRows:Number;
		
		private var xmlId:String;
		private var firstIndex:Number;
		private var background:Image;
		
		private var visibility:Boolean;
		
		private var listX:Number = 0;
		private var listY:Number = 0;
		
		private var playlistXml:XML;
		private var isScrollBarActive:Boolean = false;
		
		public static const DEFAULT_MAX_ROWS:Number = 8;
		public static const DEFAULT_ROW_SPACER:Number = 15;
		
		public function Playlist ( argPlaylistXml:XML, autoLoad:Boolean = false ):void {
			
			playlistXml = argPlaylistXml;
			xmlId = playlistXml.@name;
			
			buttons = new Array ();
			
			rowIndex = 0;
			buttonIndex = 0;
			
			maxRows = playlistXml.List.@maxRows || DEFAULT_MAX_ROWS;
			rowSpacer = playlistXml.List.@rowSpacer || DEFAULT_ROW_SPACER;
			
			visibility = ( playlistXml.@visibility == "hidden" ) || false;
			firstIndex = -1;
			
			listRows = generateRowData ( );
			
			loadQueue = new LoadQueue ( false );
			loadQueue.addToQueue ( listRows );
			loadQueue.addEventListener ( Event.COMPLETE,
			
			if (playlistXml.hasOwnProperty ("Background")) {
				loadBackground ( null );
			}
			
			scrollBar = new ScrollBar (this, playlistXml.ScrollBar);
			scrollBar.onScroll = onScroll;
			
			if ( getNumberOfRows ( ) > maxRows ) {
				addChild (scrollBar);
				isScrollBarActive = true;
			}
			
			this.addEventListener (MouseEvent.MOUSE_WHEEL, onMouseWheel);
			
			this.visible = !visibility;
			
			if (playlistXml.List.hasOwnProperty ("@x")) {
				listX = playlistXml.List.@x;
			}
			if (playlistXml.List.hasOwnProperty ("@y")) {
				listY = playlistXml.List.@y;
			}
			
			this.x = playlistXml.Position.@x;
			this.y = playlistXml.Position.@y;
		}
		
		/*public function loadNextRow ( e:Event ):void {
			
			
			Output.trace ( "Loading Row!" );
			var queue:SoundQueue = VinomPlayer.soundQueue;
			var song:Song = queue.getSong ( rowIndex ++ );
			var row:PlaylistRow = new PlaylistRow ( playlistXml, song );
			row.y = ( rowIndex - 1 ) * rowSpacer + listY;
			row.x = listX;
			
			if ( !isScrollBarActive ) {
				row.width += scrollBar.width;
			}
			
			if ( rowIndex > maxRows ) {
				row.visible = false;
			}
			
			listRows.push ( row );
			addChild ( row );
			
			if ( rowIndex < getNumberOfRows ( ) ) {
				row.onLoaded = loadNextRow;
			} else {
				loadNextButton ( e );
			}
			
			
		}*/
		
		public function load ( ):void {
			loadQueue.load ( );
		}
		
		private function generateRowData ( ):void {
			
			for ( var i:Number in VinomPlayer.soundQueue.getQueue ( ) ) {
				
				var rowSong:Song = VinomPlayer.soundQueue.getSong ( i );
				
				var row:PlaylistRow = new PlaylistRow ( playlistXml, rowSong, false );
				row.y = ( i - 1 ) * rowSpacer + listY;
				row.x = listX;
				
				if ( !isScrollBarActive ) {
					row.width += scrollBar.width;
				}
				
				if ( rowindex > maxRows ) {
					row.visible = false;
				}
				
				listRows.push ( row );
				addChild ( row );
				
			}
			
		}
		
		private function loadNextButton ( e:Event ):void {
			
			if (VinomPlayer.stopAll) {
				return;
			}
			
			var buttonXmlArray:XMLList = playlistXml.Button;
			
			if (buttonXmlArray.length () < 1) {
				onLoaded (e);
				return;
			}
			
			var temporaryButton:Button = new Button (XMLList (buttonXmlArray[buttonIndex ++]));
			
			buttons [temporaryButton.xmlId] = temporaryButton;
			
			if (buttonIndex < buttonXmlArray.length ()) {
				temporaryButton.onImageLoaded = loadNextButton;
			} else {
				for each(var i:Button in buttons) {
					addChild (i);
				}
				onLoaded (e);
			}
			
		}
		
		public function loadBackground ( e:Event ):void {
			background = new Image ( playlistXml.Background );
			background.addEventListener ( Event.COMPLETE, loadRows );
			addChild ( background );
		}
		
		public function onMouseWheel ( event:MouseEvent ):void {
			firstIndex += (event.delta < 0) ? ScrollBar.SCROLL_DOWN : ScrollBar.SCROLL_UP;
			if (firstIndex < -1) {
				firstIndex = -1;
			}
			/*if (firstIndex + scrollBar.numberOfScrollBars > scrollBar.numOfBars) {
				firstIndex = scrollBar.numOfBars - scrollBar.numberOfScrollBars;
			}*/
			onScroll ( firstIndex );
		}
		
		public function getNumberOfRows ( ):Number {
			
			return VinomPlayer.soundQueue.getQueue ( ).length;
			
		}
		
		public function clipIndex ( index:Number ):Number {
			
			if ( index >= listRows.length - maxRows - 1 ) {
				index = listRows.length - maxRows - 1;
			}
			if ( index < -1 ) {
				index = -1;
			}
			return index;
			
		}
		
		public function onScroll ( index:Number ):void {
			
			firstIndex = clipIndex ( index );
			
			for ( var strIndex:String in listRows ) {
				
				var i:Number = Number ( strIndex );
				var row:PlaylistRow = listRows [ i ];
				
				row.y = ( i - firstIndex - 1 ) * rowSpacer + listY;
				row.visible = true;
				
				if ( i < firstIndex + 1 ) {
					row.visible = false;
				}
				if ( i >= Math.floor ( firstIndex + maxRows + 1 ) ) {
					row.visible = false;
				}
				
			}
			
		}
		
	}
	
}