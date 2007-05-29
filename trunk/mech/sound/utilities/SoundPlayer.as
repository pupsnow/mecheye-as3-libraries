package mech.sound.utilities {
	
	import flash.net.URLRequest;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	import flash.events.*;
	
	public class SoundPlayer {
		
		private var sound:Sound;
		private var soundChannel:SoundChannel;
		
		private var _autoStart:Boolean;
		private var _position:Number;
		private var _volume:Number;
		
		public var isPlaying:Boolean;
		public var isPaused:Boolean;
		public var isStopped:Boolean;
		public var isLoading:Boolean;
		public var isInit:Boolean;
		
		public function SoundPlayer ( file:String = undefined, autoStart:Boolean = false ):void {
			
			if ( file ) {
				load ( file, autoStart || false );
			}
			
			isInit = true;
			isPlaying = false;
			isPaused = false;
			isStopped = false;
			isLoading = false;
			
		}
		
		public function load ( file:String, autoStart:Boolean ):void {
			
			if ( isPlaying ) {
				soundChannel.stop ( );
			}
			
			isInit = false;
			sound = new Sound ( );
			sound.load ( new URLRequest ( file ) );
			sound.addEventListener ( Event.OPEN, loadOpen );
			
			if ( SoundPlayer.BUFFER_PERCENT == 1 ) {
				sound.addEventListener ( Event.COMPLETE, loadComplete );
			}
			sound.addEventListener ( ProgressEvent.PROGRESS, loadProgress );
			
			_autoStart = autoStart;
			
		}
		
		public function get leftPeak ( ):Number {
			return soundChannel.leftPeak;
		}
		
		public function get rightPeak ( ):Number {
			return soundChannel.rightPeak;
		}
		
		public function get position ( ):Number {
			return soundChannel.position;
		}
		
		public function set position ( value:Number ):void {
			
			var playing:Boolean = isPlaying;
			pause ( );
			_position = position;
			
			if ( playing ) {
				play ( );
			}
			
		}
		
		public function get duration ( ):Number {
			return sound.length;
		}
		
		public function get volume ( ):Number {
			return soundChannel.soundTransform.volume;
		}
		
		public function set volume ( value:Number ):void {
		
			var transform:SoundTransform = soundChannel.soundTransform;
			transform.volume = v;
			soundChannel.soundTransform = transform;
		
		}
		
		public function set autoStart ( value:Boolean ):void {
			_autoStart = a;
		}
		
		public function get autoStart ():Boolean {
			return _autoStart;
		}
		
		public function play ():void {
			
			if ( isPlaying ) {
				return;
			}
			
			soundChannel.stop ( );
			soundChannel = sound.play ( _position );
			
			volume = SoundPlayer._volume;
			soundChannel.addEventListener ( Event.SOUND_COMPLETE, soundComplete );
			
			isPlaying = true;
			isLoading = false;
			isPaused = false;
			isStopped = false;
		}
		
		public function pause ():void {
			
			_position = soundChannel.position;
			
			soundChannel.stop ( );
			soundChannel.removeEventListener ( Event.SOUND_COMPLETE, soundComplete );
			
			isPaused = true;
			isPlaying = false;
			isLoading = false;
			isStopped = false;
			
		}
		
		public function stop ():void {
			
			_position = 0;
			
			soundChannel.stop ();
			soundChannel.removeEventListener (Event.SOUND_COMPLETE, soundComplete);
			
			isStopped = true;
			isPlaying = false;
			isLoading = false;
			isPaused = false;
			
		}
		
		private function loadProgress ( event : ProgressEvent ):void {
			
			if ( event.bytesLoaded >= event.bytesTotal * VinomPlayer.BUFFER_PERCENT ) {
				sound.removeEventListener (ProgressEvent.PROGRESS, loadProgress);
				loadComplete (event);
			}
			
			onLoadProgress (event);
		}
		
		private function loadComplete ( event:Event ):void {
			
			sound.removeEventListener (Event.COMPLETE, loadComplete);
			isLoading = false;
			isPaused = false;
			isStopped = true;
			isPlaying = false;
			if (_autoStart) {
				soundChannel = sound.play (0);
				setVolume (VinomPlayer.currentVolume);
				soundChannel.addEventListener (Event.SOUND_COMPLETE, soundComplete);
				isPlaying = true;
				isStopped = false;
			}
			this.dispatchEvent ( event );
		}
		
		private function loadOpen ( event:Event ):void {
			isLoading = true;
			this.dispatchEvent ( event );
		}
				
		private function soundComplete ( event:Event ):void {
			this.dispatchEvent ( event );
		}
		
	}
	
}