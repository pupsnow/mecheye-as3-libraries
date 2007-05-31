
////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 Mecheye Independent Studios
//  Some Rights Reserved.
//  Source Code written by JP St. Pierre
//
////////////////////////////////////////////////////////////////////////////////


package mech.sound {
	
	import mech.sound.utilities.*;
	import mech.themes.Button;
	import mech.themes.Playlist;
	import mech.themes.Theme;
	
	
	import flash.events.*;
	import flash.errors.*;
	import flash.media.SoundTransform;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.*;
	
	public class SoundQueue extends EventDispatcher {
		
		private static var REPEAT_THRESHOLD:Number = 1000;
		
		private var _queue:Array;
		private var _autoStart:Boolean;
		private var currentIndex:Number;
		private var transformer:SoundTransform;
		private var urlLoader:URLLoader;
		
		public var soundPlayer:SoundPlayer;
		public var isResuming:Boolean;
		
		public var shuffle:Boolean;
		
		public var shufflePrevSong:Song;
		public var shuffleArray:Array;
		
		public var repeat:Boolean;
		public var repeatOne:Boolean;
		
		public var loops:Number;
		public var songsPlayed:Number;
		
		public function SoundQueue ( queue:Array = null, autoStart:Boolean = false ):void {
			
			loops = 0;
			songsPlayed = 0;
			
			shuffle = false;
			shufflePrevSong = undefined;
			shuffleArray = new Array ();
			
			repeat = false;
			repeatOne = false;
			
			soundPlayer = new SoundPlayer ( null, autoStart );
			
			currentIndex = 0;
			isResuming = false;
			
			if ( _queue != null ) {
				_queue = queue;
			} else {
				_queue = new Array ();
			}
			
			_autoStart = autoStart;
		}
		
		public function init ():void {
			
			if ( _autoStart ) {
				playFromIndex ( currentIndex );
			}
			
		}
		
		public function addSong ( song:Song ):void {
			_queue.push ( song );
		}
		
		public function removeSong ( song:Song ):void {
			_queue.splice ( _queue.indexOf ( value ), 1 );
		}
		
		public function set shuffle ( value:Boolean ):void {
			shuffle = value;
		}
		
		public function setRepeat ( value:Boolean ):void {
			repeat = value;
		}
		
		public function setRepeatOne ( value:Boolean ):void {
			
			repeatOne = value;
			repeat = value ? false : repeat;
			shuffle = value ? false : shuffle;
			
		}
		
		public function getCurrentSong ( ):Song {
			
			if (shuffle) {
				return shuffleArray [ currentIndex ];
			}
			
			return _queue [ currentIndex ];
			
		}
		
		public function getSong ( index:Number ):Song {
			return _queue [ index ];
		}
		
		public function load ( file:String, autoStart:Boolean = false ):void {
			
			_autoStart = autoStart;
			
			var urlRequest:URLRequest = new URLRequest (file);
			var urlVariables:URLVariables = new URLVariables ();
			
			urlVariables.passThrough = "vinom.net";
			
			urlRequest.data = urlVariables;
			urlRequest.method = URLRequestMethod.POST;
			
			urlLoader = new URLLoader ( );
			urlLoader.addEventListener ( Event.COMPLETE, dataLoadComplete );
			urlLoader.addEventListener ( IOErrorEvent.IO_ERROR, ioError );
			urlLoader.addEventListener ( SecurityErrorEvent.SECURITY_ERROR, securityError );
			
			urlLoader.load ( urlRequest );
			
		}
		
		public function ioError ( event:IOErrorEvent ):void {
		}
		
		public function securityError ( event:SecurityErrorEvent ):void {
		}
		
		public function dataLoadComplete ( event:Event ):void {
			var xmlData:XML = new XML (urlLoader.data);
			parseXml (xmlData);
		}
		
		public function parseXml ( xmlToParse:XML ):void {
			
			for ( var i:Number = 0; i < xmlToParse..song.length( ); i++ ) {
				
				var songXml:XML = xmlToParse..song[i];
				var song:Song = new Song (songXml.@url, songXml.@id, i, songXml.@artist, songXml.@title, songXml.@album, songXml.@imageUrl);
				_queue.push (song);
				shuffleArray.push (song);
				
			}
			
		}
		
		public function getQueue ( ):Array {
			return _queue;
		}
		
		public function nextSong ( event:Event = null ):void {
			
			isResuming = false;
			
			if ( repeatOne ) {
				playFromIndex ( currentIndex );
				return;
			}
			
			if ( shuffle ) {
				removeFromShuffleArray ( currentIndex );
				shufflePrevSong = getCurrentSong ( );
			}
			
			currentIndex ++;
			
			if ( currentIndex >= _queue.length ) {
				
				if ( repeat ) {
					currentIndex = 0;
				} else {
					currentIndex --;
					return;
				}
				
			}
			
			if ( soundPlayer.isPlaying ) {
				this.play ( );
			}
			
		}
		
		private function getRandomIndexMath ( ):Number {
			return Math.floor ( Math.random ( ) * ( _queue.length ) ) + ( _queue.length * loops );
		}
		
		private function getRandomIndex ( ):Number {
			
			var index:Number = getRandomIndexMath ( );
			while (shuffleArray [ index ].hasBeenPlayed) {
				index = getRandomIndexMath ( );
			}
			return index;
			
		}
		
		public function previousSong ( ):void {
			
			isResuming = false;
			
			if ( repeatOne ) {
				
				playFromIndex ( currentIndex );
				return;
				
			}
			
			if ( soundPlayer.getPosition () > REPEAT_THRESHOLD ) {
				
				soundPlayer.stop ( );
				soundPlayer.play ( );
				return;
				
			}
			
			if ( shuffle ) {
				
				if ( getCurrentSong ().previousShuffleSong is Song ) {
					
					if ( soundPlayer.isPlaying ) {
						currentIndex = getCurrentSong ( ).previousShuffleSong.index;
					}
					
				}
				
			} else {
				
				currentIndex --;
				
			}
			
			
			if ( currentIndex < 0 ) {
				
				if ( repeat ) {
					currentIndex = _queue.length;
				} else {
					currentIndex ++;
					return;
				}
				
			}
			if ( soundPlayer.isPlaying ) {
				
				if ( shuffle ) {
					playFromShuffleIndex ( currentIndex );
					return;
				}
				
				playFromIndex ( currentIndex );
				
			}
		}
		
		public function resume ( ):void {
			soundPlayer.play ( );
		}
		
		public function get index ( ):Number {
			return currentIndex;
		}
		
		public function play ( ):void {
			
			if ( isResuming ) {
				resume ( );
				return;
			}
			
			if ( shuffle ) {
				
				checkShuffleReset ( );
				playFromShuffleIndex ( getRandomIndex () );
				shuffleArray [ currentIndex ].previousShuffleSong = shufflePrevSong;
				
			} else {
				
				playFromIndex ( currentIndex );
				
			}
			
			setPlaylistIndex ( );
			
		}
		
		private function checkShuffleReset ( ):void {
			
			if ( songsPlayed >= _queue.length ) {
				
				if ( !repeat ) {
					
					isResuming = false;
					soundPlayer.stop ( );
					return;
					
				}
				
				songsPlayed = 0;
				
				for ( var i:String in _queue ) {
					
					var song:Song = _queue [ i ].clone ( );
					song.index = int ( i ) + _queue.length * loops;
					shuffleArray.push ( song );
					
				}
				
				loops ++;
			}
			
		}
		
		/*public function setPlaylistIndex ():void {
			
			for ( var i:String in VinomPlayer.currentTheme.lists ) {
				
				var list:Playlist = VinomPlayer.currentTheme.lists [ i ];
				
				var index:Number = getCurrentSong ( ).trackNumber;
				
				if ( index > list.firstIndex + list.maxRows + 1 ) {
					list.onScroll ( list.clipIndex (index) );
				}
				if ( index < list.firstIndex + 1 ) {
					list.onScroll ( list.clipIndex (index) );
				}
				
			}
		}*/
		
		public function pause ():void {
			soundPlayer.pause ();
			
		}
		
		public function stop ():void {
			isResuming = false;
			soundPlayer.stop ();
			shuffleArray = _queue;
		}
		
		public function loadComplete ( event:Event ):void {
			isResuming = true;
			this.
		}
		
		public function soundComplete ( event:Event ):void {
			
			nextSong ( event );
			
		}
		
		public function removeFromShuffleArray ( index:Number ):void {
			shuffleArray [ index ].hasBeenPlayed = true;
		}
		
		public function playFromShuffleIndex ( index:Number ):void {
			
			isResuming = true;
			currentIndex = index;
			
			songsPlayed ++;
			soundPlayer.load  ( shuffleArray [ currentIndex ].src, true );
			
			soundPlayer.addEventListener ( Event.COMPLETE, loadComplete );
			soundPlayer.addEventListener ( Event.SOUND_COMPLETE, soundComplete );
			
		}
		
		public function playFromIndex ( index:Number ):void {
			
			// Output.trace (_queue[index].src);
			isResuming = true;
			currentIndex = index;
			soundPlayer.load  ( _queue [ index ].src, true );
			
			soundPlayer.addEventListener ( Event.COMPLETE, loadComplete );
			soundPlayer.addEventListener ( Event.SOUND_COMPLETE, soundComplete );
			
		}
		
	}
}