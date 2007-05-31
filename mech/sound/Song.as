
////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 Mecheye Independent Studios
//  Some Rights Reserved.
//  Source Code written by JP St. Pierre
//
////////////////////////////////////////////////////////////////////////////////


package mech.sound {
	
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
		
		public function Song ( src:String, id:Number, index:Number = 0, artist:String = "Various", title:String = "Untitled", album:String = "Unknown", albumArt:String = "unknown.jpg") {
			
			this.hasBeenPlayed = false;
			this.trackNumber = index + 1;
			this.index = index;
			this.artist = artist;
			this.album = album;
			this.albumArt = albumArt;
			this.title = title;
			this.src = src;
			this.songId = id;
			
		}
		
		public function clone ( ):Song {
			
			var song:Song = new Song (this.src, this.songId, this.index, this.artist, this.title, this.album, this.albumArt);
			return song;
			
		}
	}
}
