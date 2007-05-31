
////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 Mecheye Independent Studios
//  Some Rights Reserved.
//  Source Code written by JP St. Pierre
//
////////////////////////////////////////////////////////////////////////////////


package mech.sound {
	
	import flash.events.*;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	
	import mech.sound.SoundPlayerState;
	import mech.utilities.Loadable;
	
	public class SoundPlayer extends EventDispatcher implements Loadable {
		
		private var sound:Sound;
		private var soundChannel:SoundChannel;
		
		private var _autoStart:Boolean;
		private var _position:Number;
		
		private var soundState:SoundPlayerState;
		
		public function SoundPlayer ( autoStart:Boolean = false, file:String = undefined ):void {
			
			if ( file != undefined ) {
				load ( file, autoStart );
			}
			
			soundState = SoundPlayerState.INITIALIZED;
			
		}
		
		public function load ( file:String, autoStart:Boolean ):void {
			
			if ( isPlaying ) {
				soundChannel.stop ( );
			}
			
			sound = new Sound ( );
			sound.load ( new URLRequest ( file ) );
			sound.addEventListener ( Event.OPEN, loadOpen );
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
			
			var wasPlaying:Boolean = ( soundState == SoundPlayerState.PLAYING );
			
			pause ( );
			_position = value;
			
			if ( wasPlaying ) {
				play ();
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
			transform.volume = value;
			soundChannel.soundTransform = transform;
			
		}
		
		public function set autoStart ( value:Boolean ):void {
			_autoStart = value;
		}
		
		public function get autoStart ( ):Boolean {
			return _autoStart;
		}
		
		public function play ():void {
			
			if ( soundState == SoundPlayerState.PLAYING ) {
				return;
			}
			
			soundChannel.stop ();
			soundChannel = sound.play ( _position );
			soundChannel.addEventListener ( Event.SOUND_COMPLETE, soundComplete );
			
			soundState = SoundPlayerState.PLAYING;
			
		}
		
		public function pause ():void {
			
			if ( soundState == SoundPlayerState.INITIALIZED ) {
				return;
			}
			
			_position = soundChannel.position;
			
			soundChannel.stop ();
			soundChannel.removeEventListener ( Event.SOUND_COMPLETE, soundComplete );
			
			soundState = SoundPlayerState.PAUSED;
			
		}
		
		public function stop ():void {
			
			_position = 0;
			soundChannel.stop ();
			soundChannel.removeEventListener ( Event.SOUND_COMPLETE, soundComplete );
			
			soundState = SoundPlayerState.STOPPED;
			
		}
		
		private function loadProgress ( event:ProgressEvent ):void {
			
			this.dispatchEvent ( event );
			
		}
		
		private function loadComplete ( event:Event ):void {
			
			sound.removeEventListener ( ProgressEvent.PROGRESS, loadProgress );
			sound.removeEventListener ( Event.COMPLETE, loadComplete );
			soundState = SoundPlayerState.STOPPED;
			
			if ( _autoStart ) {
				
				soundState = SoundPlayerState.PLAYING;
				
				soundChannel = sound.play (0);
				soundChannel.addEventListener (Event.SOUND_COMPLETE, soundComplete);
				
			}
			
			this.dispatchEvent ( event );
			
		}
		
		private function loadOpen ( event:Event ):void {
			
			soundState = SoundPlayerState.LOADING;
			this.dispatchEvent ( event );
			
		}
				
		private function soundComplete ( event:Event ):void {
			
			this.dispatchEvent ( event );
			
		}
		
	}
	
}