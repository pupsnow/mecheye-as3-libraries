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
		public var _position:Number;
		
		public var isPlaying:Boolean;
		public var isPaused:Boolean;
		public var isStopped:Boolean;
		public var isLoading:Boolean;
		public var isInit:Boolean;
		
		public var onLoadComplete:Function = function (e:Event):void {};
		public var onLoadStart:Function = function (e:Event):void {};
		public var onLoadProgress:Function = function (e:Event):void {};
		public var onSoundComplete:Function = function (e:Event):void {};
		
		public function SoundPlayer (file:String = undefined, autoStart:Boolean = false):void {
			if (file) {
				load (file, autoStart || false);
			}
			isInit = true;
			isPlaying = false;
			isPaused = false;
			isStopped = false;
			isLoading = false;
		}
		
		public function load (file:String, autoStart:Boolean):void {
			if (isPlaying) {
				soundChannel.stop ();
			}
			isInit = false;
			sound = new Sound ();
			sound.load ( new URLRequest (file) );
			sound.addEventListener (Event.OPEN, loadOpen);
			if (VinomPlayer.BUFFER_PERCENT == 1) {
				sound.addEventListener (Event.COMPLETE, loadComplete);
			}
			sound.addEventListener (ProgressEvent.PROGRESS, loadProgress);
			
			_autoStart = autoStart;
		}
		
		public function getLeftPeak ():Number {
			return soundChannel.leftPeak;
		}
		
		public function getRightPeak ():Number {
			return soundChannel.rightPeak;
		}
		
		public function getPosition ():Number {
			return soundChannel.position;
		}
		
		public function setPosition (position:Number):void {
			var playing:Boolean = isPlaying;
			pause ();
			_position = position;
			if (playing) {
				play ();
			}
		}
		
		public function getDuration ():Number {
			return sound.length;
		}
		
		public function getVolume ():Number {
			return soundChannel.soundTransform.volume;
		}
		
		public function setVolume (v:Number):void {
			var transform:SoundTransform = soundChannel.soundTransform;
			transform.volume = v;
			soundChannel.soundTransform = transform;
		}
		
		public function setAutoStart (a:Boolean):void {
			_autoStart = a;
		}
		
		public function getAutoStart ():Boolean {
			return _autoStart;
		}
		
		public function play ():void {
			if (isPlaying) {
				return;
			}
			soundChannel.stop ();
			soundChannel = sound.play (_position);
			setVolume (VinomPlayer.currentVolume);
			soundChannel.addEventListener (Event.SOUND_COMPLETE, soundComplete);
			isPlaying = true;
			isLoading = false;
			isPaused = false;
			isStopped = false;
		}
		
		public function pause ():void {
			_position = soundChannel.position;
			soundChannel.stop ();
			soundChannel.removeEventListener (Event.SOUND_COMPLETE, soundComplete);
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
		
		private function loadComplete ( event : Event ):void {
			
			// Output.trace ("Load Complete");
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
			onLoadComplete (event);
		}
		
		private function loadOpen ( event : Event ):void {
			isLoading = true;
			onLoadStart (event);
		}
				
		private function soundComplete ( event : Event ):void {
			onSoundComplete (event);
		}
		
	}
	
}