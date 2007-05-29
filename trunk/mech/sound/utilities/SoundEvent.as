package mech.sound.utilities {
	
	public class SoundEvent {
		
		public static function playSound ():void {
			VinomPlayer.soundQueue.play ();
		}
		
		public static function pauseSound ():void {
			VinomPlayer.soundQueue.pause ();
		}
		
		public static function stopSound ():void {
			VinomPlayer.soundQueue.stop ();
		}
		
		public static function nextSong ():void {
			VinomPlayer.soundQueue.nextSong ();
		}
		
		public static function previousSong ():void {
			VinomPlayer.soundQueue.previousSong ();
		}
		
		public static function getVolume ():Number {
			return VinomPlayer.soundQueue.soundPlayer.getVolume ();
		}
		
		public static function setVolume (volume:Number):void {
			VinomPlayer.currentVolume = volume;
			VinomPlayer.soundQueue.soundPlayer.setVolume (volume);
		}
		
		public static function getPosition ():Number {
			return VinomPlayer.soundQueue.soundPlayer.getPosition ();
		}
		
		public static function setPosition (position:Number):void {
			VinomPlayer.soundQueue.soundPlayer.setPosition (position);
		}
		
		public static function getDuration ():Number {
			return VinomPlayer.soundQueue.soundPlayer.getDuration ();
		}
		
		public static function get isPlaying ():Boolean {
			return VinomPlayer.soundQueue.soundPlayer.isPlaying;
		}
		
		public static function setShuffle ( shuffle:Boolean ):void {
			VinomPlayer.soundQueue.setShuffle ( shuffle );
		}
		
		public static function setRepeat ( repeat:Boolean ):void {
			VinomPlayer.soundQueue.setRepeat ( repeat );
		}
		
		public static function setRepeat1 ( repeat:Boolean ):void {
			VinomPlayer.soundQueue.setRepeat1 ( repeat );
		}
		
	}

}