package mech.themes {
	
	import mech.themes.Image;
	import mech.themes.Playlist;
	import mech.sound.utilities.SoundEvent;
	
	import flash.utils.*;
	
	import flash.display.Sprite;
	import flash.net.URLRequest;
	
	import flash.events.*;
	
	public class Button extends Sprite {
		
		private var toggleTo:String;
		private var doesToggle:Boolean;
		private var onClickFunctionName:String;
		
		public var xmlId:String;
		public var buttonImage:Image;
		
		public var buttonXml:XMLList;
		
		public static var shufButton:Button;
		public static var repButton:Button;
		public static var rep1Button:Button;
		public static var playButton:Button;
		public static var pauseButton:Button;
		public static var hidePlaylistButton:Button;
		
		public var onImageLoaded:Function = function (e:Event):void {};
		
		public function Button (buttonXml:XMLList):void {
			
			this.buttonXml = buttonXml;
			xmlId = buttonXml.@name;
			if (!buttonXml.hasOwnProperty ("ToggleTo")) {
				doesToggle = false;
			} else {
				doesToggle = true;
				toggleTo = buttonXml.ToggleTo.text ();
			}
			onClickFunctionName = buttonXml.@onClick;
			
			var imageXml:XMLList = buttonXml.Image;
			buttonImage = new Image (imageXml);
			
			this.x = buttonXml.Position.@x;
			this.y = buttonXml.Position.@y;
			
			buttonImage.addEventListener (MouseEvent.CLICK, onClick);
			buttonImage.onImageLoaded = _onImageLoaded;
			
			xmlId = buttonXml.@name;
			
			addChild (buttonImage);
		}
		
		public function initB ():void {
			if (!this.doesToggle) {
				return;
			}
			
			if (buttonXml.hasOwnProperty ("@visibility")) {
				if (buttonXml.@visibility.toString ().toLowerCase () == "autostart") {
					toggle ();
				} else {
					setVisibility ((buttonXml.@visibility == "true"));
				}
			}
			
			if (this.onClickFunctionName == "setShuffleFalse") {
				shufButton = this;
			}
			if (this.onClickFunctionName == "setRepeat1False") {
				rep1Button = this;
			}
			if (this.onClickFunctionName == "setRepeatFalse") {
				repButton = this;
			}
			if (this.onClickFunctionName == "pauseSound") {
				pauseButton = this;
			}
			if (this.onClickFunctionName == "playSound") {
				playButton = this;
			}
			if (this.onClickFunctionName == "hidePlaylist" && this.doesToggle) {
				hidePlaylistButton = this;
			}
			
			
			if (this.onClickFunctionName == "setAutoStartFalse" && !VinomPlayer.autoStart) this.toggle ();
			if (this.onClickFunctionName == "setAutoStartTrue" && VinomPlayer.autoStart) this.toggle ();
			if (this.onClickFunctionName == "setRepeatFalse" && !VinomPlayer.doesRepeat) this.toggle ();
			if (this.onClickFunctionName == "setRepeatTrue" && VinomPlayer.doesRepeat) this.toggle ();
			if (this.onClickFunctionName == "setRepeat1False" && !VinomPlayer.doesRepeat1) this.toggle ();
			if (this.onClickFunctionName == "setRepeat1True" && VinomPlayer.doesRepeat1) this.toggle ();
			if (this.onClickFunctionName == "setShuffleFalse" && !VinomPlayer.doesShuffle) this.toggle ();
			if (this.onClickFunctionName == "setShuffleTrue" && VinomPlayer.doesShuffle) this.toggle ();
		}
		
		private function _onImageLoaded (e:Event):void {
			onImageLoaded (e);
		}
		
		public function setVisibility (v:Boolean):void {
			this.visible = v;
		}
		
		public function getName ():String {
			return xmlId;
		}
		
		public function toggle ():void {
			if (this.doesToggle) {
				setVisibility (false);
				var button:Button = Button.getButton(this.toggleTo);
				button.setVisibility (true);
			}
		}
		
		public static function getButton (buttonName:String):Button {
			for (var i:String in VinomPlayer.currentTheme.buttons) {
				if (i == buttonName) {
					return VinomPlayer.currentTheme.buttons[i];
				}
			}
			return null;
		}
		
		public function onClick (e:MouseEvent):void {
			toggle ();
			var i:Playlist;
			switch (this.onClickFunctionName) {
				case "playSound":
					SoundEvent.playSound ();
				break;
				case "stopSound":
					SoundEvent.stopSound ();
					Button.pauseButton.toggle ();
				break;
				case "pauseSound":
					SoundEvent.pauseSound ();
				break;
				case "nextSong":
					SoundEvent.nextSong ();
				break;
				case "previousSong":
					SoundEvent.previousSong ();
				break;
				case "setAutoStartFalse":
					VinomPlayer.autoStart = false;
					VinomPlayer.setOptions ();
				break;
				case "setAutoStartTrue":
					VinomPlayer.autoStart = true;
					VinomPlayer.setOptions ();
				break;
				case "setShuffleFalse":
					SoundEvent.setShuffle (false);
				break;
				case "setShuffleTrue":
					SoundEvent.setShuffle (true);
					// Button.repButton.toggle ();
				break;
				case "setRepeatFalse":
					SoundEvent.setRepeat (false);
					SoundEvent.setRepeat1 (false);
				break;
				case "setRepeatTrue":
					SoundEvent.setRepeat (true);
					//Button.rep1Button.toggle ();
				break;
				case "setRepeat1False":
					SoundEvent.setRepeat1 (false);
				break;
				case "setRepeat1True":
					SoundEvent.setRepeat1 (true);
					//Button.repButton.toggle ();
					//Button.shufButton.toggle ();
				break;
				case "showPlaylist":
					for each(i in VinomPlayer.currentTheme.lists) {
						i.visible = true;
					}
				break;
				case "hidePlaylist":
					for each(i in VinomPlayer.currentTheme.lists) {
						i.visible = false;
					}
					if (Button.hidePlaylistButton is Button) {
						Button.hidePlaylistButton.toggle ();
					}
				break;
			}
		}
	}
}