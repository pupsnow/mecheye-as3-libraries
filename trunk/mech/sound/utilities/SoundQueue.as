package mech.sound.utilities {
	
	import mech.sound.utilities.*;
	import mech.themes.Button;
	import mech.themes.Playlist;
	import mech.themes.Theme;
	
	import com.anttikupila.revolt.presets.AlbumArt;
	
	import flash.events.*;
	import flash.errors.*;
	import flash.media.SoundTransform;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.*;
	
	public class SoundQueue {
		
		[ArrayElementType("Song")]
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
		
		public function SoundQueue (queue:Array = null, autoStart:Boolean = false):void {
			
			loops = 0;
			songsPlayed = 0;
			shuffle = false;
			shufflePrevSong = undefined;
			shuffleArray = new Array ();
			repeat = false;
			repeatOne = false;
			
			soundPlayer = new SoundPlayer (null, autoStart);
			
			currentIndex = 0;
			isResuming = false;
			if (_queue != null) {
				_queue = queue;
			} else {
				_queue = new Array ();
			}
			
			_autoStart = autoStart;
		}
		
		public function init ():void {
			if (_autoStart) {
				playFromIndex ( 0 );
			}
		}
		
		public function addSong ( song:Song ):void {
			_queue.push (song);
		}
		
		public function removeSong ( song:Song ):void {
			for (var i:String in _queue) {
				if (_queue[i] === song) {
					_queue.splice (int (i), 1);
				}
			}
		}
		
		public function setShuffle (s:Boolean):void {
			shuffle = s;
			repeatOne = s ? false : repeatOne;
			VinomPlayer.doesShuffle = s;
			VinomPlayer.doesRepeat1 = repeatOne;
			VinomPlayer.setOptions ();
		}
		
		public function setRepeat (r:Boolean):void {
			repeat = r;
			repeatOne = r ? false : repeatOne;
			VinomPlayer.doesRepeat = r;
			VinomPlayer.setOptions ();
		}
		
		public function setRepeat1 (r:Boolean):void {
			repeatOne = r;
			repeat = r ? false : repeat;
			shuffle = r ? false : shuffle;
			VinomPlayer.doesRepeat1 = r;
			VinomPlayer.doesShuffle = shuffle;
			VinomPlayer.doesRepeat = repeat;
			VinomPlayer.setOptions ();
		}
		
		public function getCurrentSong ():Song {
			if (shuffle) {
				return shuffleArray[currentIndex];
			}
			return _queue[currentIndex];
		}
		
		public function getSong ( index:Number ):Song {
			return _queue[index];
		}
		
		public function load ( file:String, autoStart:Boolean = false ):void {
			_autoStart = autoStart;
			var urlRequest:URLRequest = new URLRequest (file);
			var urlVariables:URLVariables = new URLVariables ();
			urlVariables.passThrough = "vinom.net";
			urlRequest.data = urlVariables;
			urlRequest.method = URLRequestMethod.POST;
			urlLoader = new URLLoader ();
			urlLoader.addEventListener (Event.COMPLETE, dataLoadComplete);
			urlLoader.addEventListener (IOErrorEvent.IO_ERROR, ioError);
			urlLoader.addEventListener (SecurityErrorEvent.SECURITY_ERROR, securityError);
			try {
				urlLoader.load (urlRequest);
				Output.trace ("Loading playlist XML.");
			} catch (e:Error) {
				Output.trace ("Error: "+e.message);
			}
		}
		
		public function ioError ( event:IOErrorEvent ):void {
			Output.trace ( "IOError: " + event.text );
		}
		
		public function securityError ( event:SecurityErrorEvent ):void {
			Output.trace ( "SecurityError: " + event.text );
		}
		
		public function dataLoadComplete ( event:Event ):void {
			try {
				var xmlData:XML = new XML (urlLoader.data);
				Output.trace ("Parsing playlist XML.");
				parseXml (xmlData);
			} catch(e:Error) {
				VinomPlayer.stopAll = true;
				Output.trace ("Playlist XML Parsing Error: " + e.message);
			}
		}
		
		public function parseXml ( xmlToParse:XML ):void {
			
			if (VinomPlayer.stopAll) {
				return;
			}
			
			for (var i:Number = 0; i < xmlToParse..song.length(); i++) {
				var songXml:XML = xmlToParse..song[i];
				var song:Song = new Song (songXml.@url, songXml.@id, i, songXml.@artist, songXml.@title, songXml.@album, songXml.@imageUrl);
				_queue.push (song);
				shuffleArray.push (song);
			}
			//if (_autoStart) {
				//playFromIndex (currentIndex);
			//}
			
			VinomPlayer.trace ("Playlist parsed.");
			
			VinomPlayer.currentTheme = new Theme (VinomPlayer.themeUrl);
			
		}
		
		public function getQueue ( ):Array {
			return _queue;
		}
		
		public function nextSong ( event:Event = null ):void {
			isResuming = false;
			if (repeatOne) {
				playFromIndex (currentIndex);
				return;
			}
			if (shuffle) {
				removeFromShuffleArray (currentIndex);
				shufflePrevSong = getCurrentSong ();
			}
			currentIndex ++;
			if (currentIndex >= _queue.length) {
				if (repeat) {
					currentIndex = 0;
				} else {
					currentIndex --;
					return;
				}
			}
			if (soundPlayer.isPlaying) {
				this.play ();
			}
		}
		
		public function getRandomIndexMath ():Number {
			return Math.floor (Math.random () * (_queue.length)) + _queue.length * loops;
		}
		
		public function getRandomIndex ():Number {
			var index:Number = getRandomIndexMath ();
			while (shuffleArray[index].hasBeenPlayed) {
				index = getRandomIndexMath ();
			}
			Output.trace (index);
			return index;
		}
		
		public function previousSong ():void {
			if (soundPlayer.isInit) {
				return;
			}
			
			isResuming = false;
			if (repeatOne) {
				playFromIndex (currentIndex);
				return;
			}
			if (soundPlayer.getPosition () > 1000) {
				soundPlayer.stop ();
				soundPlayer.play ();
				return;
			}
			if (shuffle) {
				if (getCurrentSong ().previousShuffleSong is Song) {
					if (soundPlayer.isPlaying) {
						currentIndex = getCurrentSong ().previousShuffleSong.index;
					}
				}
			} else {
				currentIndex --;
			}
			if (currentIndex < 0) {
				if (repeat) {
					currentIndex = _queue.length;
				} else {
					currentIndex ++;
					return;
				}
			}
			if (soundPlayer.isPlaying) {
				if (shuffle) {
					playFromShuffleIndex (currentIndex);
					return;
				}
				playFromIndex (currentIndex);
			}
		}
		
		public function resume ():void {
			soundPlayer.play ();
		}
		
		public function getIndex ():Number {
			return currentIndex;
		}
		
		public function play ():void {
			if (isResuming) {
				resume ();
				return;
			}
			if (shuffle) {
				checkShuffleReset ();
				playFromShuffleIndex ( getRandomIndex () );
				shuffleArray[currentIndex].previousShuffleSong = shufflePrevSong;
			} else {
				playFromIndex (currentIndex);
			}
			setPlaylistIndex ();
		}
		
		public function checkShuffleReset ():void {
			if (Button.pauseButton is Button) {
				Button.pauseButton.toggle ();
			}
			if (songsPlayed >= _queue.length) {
				if (!repeat) {
					isResuming = false;
					soundPlayer.stop ();
					return;
				}
				songsPlayed = 0;
				for (var i:String in _queue) {
					var song:Song = _queue[i].clone ();
					song.index = int (i) + _queue.length * loops;
					shuffleArray.push (song);
				}
				loops ++;
			}
		}
		
		public function setPlaylistIndex ():void {
			for (var i:String in VinomPlayer.currentTheme.lists) {
				var list:Playlist = VinomPlayer.currentTheme.lists[i];
				var index:Number = getCurrentSong ().trackNumber;
				if (index > list.firstIndex + list.maxRows + 1) {
					list.onScroll ( list.clipIndex (index) );
				}
				if (index < list.firstIndex + 1) {
					list.onScroll ( list.clipIndex (index) );
				}
			}
		}
		
		public function pause ():void {
			if (soundPlayer.isInit) {
				return;
			}
			soundPlayer.pause ();
		}
		
		public function stop ():void {
			isResuming = false;
			soundPlayer.stop ();
			shuffleArray = _queue;
		}
		
		public function onLoadComplete ( event:Event ):void {
			isResuming = true;
			if (AlbumArt.instance is AlbumArt) {
				AlbumArt.instance.loadImage ();
			}
		}
		
		public function onSoundComplete ( event:Event ):void {
			
			var completeRequest:URLRequest = new URLRequest ( VinomPlayer.completeUrl );
			var completeVariables:URLVariables = new URLVariables ();
			completeVariables.mode = "songCompleted";
			completeVariables.songId = getCurrentSong().songId;
			completeRequest.data = completeVariables;
			completeRequest.method = URLRequestMethod.POST;
			var completeLoader:URLLoader = new URLLoader ( );
			completeLoader.load ( completeRequest );
			
			nextSong ( event );
		}
		
		public function removeFromShuffleArray ( index:Number ):void {
			shuffleArray[index].hasBeenPlayed = true;
		}
		
		public function playFromShuffleIndex ( index:Number ):void {
			if (VinomPlayer.stopAll) {
				return;
			}
			
			isResuming = true;
			currentIndex = index;
			
			// Output.trace ("i: "+index+"  j:"+getCurrentSong ().index+"  tn:"+getCurrentSong ().trackNumber);
			songsPlayed ++;
			soundPlayer.load  ( shuffleArray[currentIndex].src, true );
			soundPlayer.onLoadComplete = onLoadComplete;
			soundPlayer.onSoundComplete = nextSong;
		}
		
		public function playFromIndex ( index:Number ):void {
			
			if (VinomPlayer.stopAll) {
				return;
			}
			
			if (soundPlayer.isLoading) {
				soundPlayer.stop ();
			}
			
			if (Button.playButton is Button) {
				Button.playButton.toggle ();
			}
			
			// Output.trace (_queue[index].src);
			isResuming = true;
			currentIndex = index;
			soundPlayer.load  ( _queue[index].src, true );
			
			soundPlayer.onLoadComplete = onLoadComplete;
			soundPlayer.onSoundComplete = onSoundComplete;
		}
		
	}
}