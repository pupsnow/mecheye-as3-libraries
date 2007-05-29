package mech.sound.utilities {
	
	public class Song {
		
		public var trackNumber:Number;
		public var index:Number;
		public var songId:Number;
		public var artist:String;
		public var album:String;
		public var albumArt:String;
		public var title:String;
		public var src:String;
		public var previousShuffleSong:Song;
		public var hasBeenPlayed:Boolean;
		
		public function Song (argSrc:String, argId:Number, argIndex:Number = 0, argArtist:String = "Various", argTitle:String = "Untitled", argAlbum:String = "Unknown", argAlbumArt:String = "unknown.jpg") {
			this.hasBeenPlayed = false;
			this.trackNumber = argIndex + 1;
			this.index = argIndex;
			this.artist = argArtist;
			this.album = argAlbum;
			this.albumArt = argAlbumArt;
			this.title = argTitle;
			this.src = argSrc;
			this.songId = argId;
		}
		
		public function clone ():Song {
			var song:Song = new Song (this.src, this.songId, this.index, this.artist, this.title, this.album, this.albumArt);
			return song;
		}
	}
}
