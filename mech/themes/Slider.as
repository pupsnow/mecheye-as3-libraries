package mech.themes {
	
	import mech.themes.Image;
	import mech.sound.utilities.*;
	
	import flash.display.Loader;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.net.URLRequest;
	import flash.geom.Rectangle;
	import flash.events.*;
	
	public class Slider extends Sprite {
		
		public var sliderImage:Image;
		public var background:Image;
		
		public var onImageLoaded:Function = function (e:Event):void {};
		
		public var xmlId:String;
		
		private var triggerSlide:Boolean = false;
		private var triggerBackgroundClick:Boolean = false;
		private var triggerMouseWheel:Boolean = false;
		
		private var isDragging:Boolean = false;
		
		private var action:String;
		
		private var slideBounds:Rectangle;
		
		private var maskLoader:Loader;
		private var maskImg:Bitmap;
		
		private var totalWidth:Number;
		private var totalHeight:Number;
		private var totalDimension:Number;
		
		private var slideAlign:Number;
		private var negative:Boolean;
		
		private var lastPosition:Number;
		
		private var moveAxis:Boolean;
		
		private static const AXIS_HORIZONTAL:Boolean = false;
		private static const AXIS_VERTICAL:Boolean = true;
		
		private var MARGIN:Number = 0;
		private var VOLUME_SCALE:Number = 1;
		private var WHEEL_DELTA:Number = 6;
		
		public function Slider (sliderXml:XMLList):void {
			
			var baseDir:String = VinomPlayer.currentTheme.baseDir + "/";
			
			this.x = sliderXml.Position.@x;
			this.y = sliderXml.Position.@y;
			
			totalWidth = sliderXml.Size.@width;
			totalHeight = sliderXml.Size.@height;
			
			if (sliderXml.hasOwnProperty ("@moveAxis")) {
				moveAxis = (String (sliderXml.@moveAxis).toLowerCase () == "y");
			} else {
				moveAxis = false;
			}
			
			if (sliderXml.hasOwnProperty ("@negative")) {
				negative = (String (sliderXml.@negative).toLowerCase () == "true");
			} else {
				negative = false;
			}
			
			slideAlign = totalWidth / 2;
			
			if (sliderXml.hasOwnProperty ("@align")) {
				var alignStr:String = sliderXml.@align;
				if (alignStr == "left") {
					slideAlign = totalWidth;
				} else if (alignStr == "right") {
					slideAlign = 0;
				}
			}
			
			if (moveAxis) {
				totalDimension = totalHeight;
			} else {
				totalDimension = totalWidth;
			}
			
			action = sliderXml.@action;
			xmlId = sliderXml.@name;
			
			sliderImage = new Image (sliderXml.SliderImage);
			sliderImage.onImageLoaded = _onImageLoaded;
			
			addChild (sliderImage);
			
			var triggers:String = String (sliderXml.@triggers);
			if (triggers.search ("S") != -1) {
				triggerSlide = true;
			}
			if (triggers.search ("B") != -1) {
				triggerBackgroundClick = true;
			}
			if (triggers.search ("W") != -1) {
				triggerMouseWheel = true;
			}
			
			
			if (sliderXml.SliderImage.hasOwnProperty ("@mask")) {
				maskLoader = new Loader ();
				maskLoader.contentLoaderInfo.addEventListener ( Event.COMPLETE, maskImgLoadComplete );
				maskLoader.load ( new URLRequest (baseDir + sliderXml.SliderImage.@mask) );
			}
			
			// this.addEventListener (MouseEvent.MOUSE_DOWN, startSlide);
			this.addEventListener (Event.ENTER_FRAME, onEnterFrame);
			VinomPlayer.instance.addEventListener (MouseEvent.MOUSE_WHEEL, onMouseWheel);
			VinomPlayer.instance.addEventListener (MouseEvent.MOUSE_DOWN, onClick);
			
			if (moveAxis) {
				slideBounds = new Rectangle (0, MARGIN, totalWidth, totalHeight - 2 * MARGIN);
			} else {
				slideBounds = new Rectangle (MARGIN, 0, totalWidth - 2 * MARGIN, totalHeight);
			}
			
		}
		
		private function maskImgLoadComplete (e:Event):void {
			e.target.removeEventListener (Event.COMPLETE, maskImgLoadComplete);
			maskImg = Bitmap ( e.target.content );
			var maskImg2:Bitmap = new Bitmap (maskImg.bitmapData);
			maskImg.cacheAsBitmap = true;
			maskImg2.cacheAsBitmap = true;
			
			addChild (maskImg);
			addChild (maskImg2);
			this.mask = maskImg2;
		}
		
		private function _onImageLoaded (e:Event):void {
			Output.trace ("Slider loaded");
			onImageLoaded (e);
		}
		
		private function onEnterFrame ( event:Event ):void {
			
			lastPosition = getSliderPosition ();
			
			if (isDragging) {
				return;
			}
			
			if (moveAxis) {
				sliderImage.y = getSliderPosition ();
			} else {
				sliderImage.x = getSliderPosition ();
			}
			
		}
		
		private function onClick ( event:MouseEvent ):void {
			if (!triggerBackgroundClick) {
				return;
			}
			
			var slideValue:Number;
			
			if (moveAxis) {
				slideValue = this.mouseY;
			} else {
				slideValue = this.mouseX;
			}
			
			if (! slideBounds.contains (this.mouseX, this.mouseY)) {
				return;
			}
			
			/*if (slideX > totalWidth - MARGIN) {
				return;
			}
			if (this.mouseY > totalHeight) {
				return;
			}
			if (slideX < MARGIN) {
				return;
			}
			if (this.mouseY < 0) {
				return;
			}*/
			
			startSlide ();
			setSlider (slideValue - slideAlign);
		}
		
		private function startSlide ():void {
			isDragging = true;
			VinomPlayer.instance.addEventListener ( MouseEvent.MOUSE_MOVE, updateSlider );
			VinomPlayer.instance.addEventListener ( MouseEvent.MOUSE_UP, stopSlide );
		}
		
		private function stopSlide ( event:MouseEvent ):void {
			isDragging = false;
			VinomPlayer.instance.removeEventListener ( MouseEvent.MOUSE_MOVE, updateSlider );
			VinomPlayer.instance.removeEventListener ( MouseEvent.MOUSE_UP, stopSlide );
		}
		
		private function onMouseWheel ( event:MouseEvent ):void {
			if (!triggerMouseWheel) {
				return;
			}
			if (!SoundEvent.isPlaying) {
				return;
			}
			if (! slideBounds.contains (this.mouseX, this.mouseY)) {
				return;
			}
			
			if (event.delta < 0) {
				setSlider ( getSlider () + ( (moveAxis) ? WHEEL_DELTA : -WHEEL_DELTA ) );
			}
			
			if (event.delta > 0) {
				setSlider ( getSlider () - ( (moveAxis) ? WHEEL_DELTA : -WHEEL_DELTA ) );
			}
		}
		
		private function updateSlider ( event:MouseEvent ):void {			
			if (! slideBounds.contains (this.mouseX, this.mouseY)) {
				return;
			}
			var mouseValue:Number = (moveAxis) ? this.mouseY : this.mouseX;
			setSlider (mouseValue - slideAlign);
		}
		
		private function setSlider ( slideValue:Number ):void {
			if (slideValue < 0 && !negative) {
				slideValue = 0;
			}
			if (slideValue > totalDimension - 2*MARGIN - slideAlign) {
				slideValue = totalDimension - 2*MARGIN - slideAlign;
			}
			
			if (moveAxis) {
				sliderImage.y = slideValue;
			} else {
				sliderImage.x = slideValue;
			}
			
			setValue ( slideValue );
		}
		
		private function getSlider ():Number {
			return (moveAxis) ? sliderImage.y : sliderImage.x;
		}
		
		private function setValue ( value:Number ):void {
			lastPosition = value;
			var correctedValue:Number;
			switch (action) {
				case "setVolume":
					if (moveAxis) {
						value = slideBounds.height - value - 1;
					}
					correctedValue = convertPosition (value, VOLUME_SCALE);
					if (correctedValue < 0 && !negative) {
						correctedValue = 0;
					}
					if (SoundEvent.isPlaying) {
						SoundEvent.setVolume (correctedValue);
					} else {
						VinomPlayer.currentVolume = correctedValue;
					}
					VinomPlayer.setOptions ();
				break;
				case "setPosition":
					var duration:Number = SoundEvent.getDuration ();
					correctedValue = convertPosition (value, duration);
					Output.trace (correctedValue);
					SoundEvent.setPosition (correctedValue);
				break;
			}
		}
		
		private function getSliderPosition ():Number {
			var correctedValue:Number = 0;
			var value:Number;
			switch (action) {
				case "setVolume":
					if (SoundEvent.isPlaying) {
						value = SoundEvent.getVolume ();
					} else {
						value = VinomPlayer.currentVolume;
					}
					correctedValue = convertToPosition (value, VOLUME_SCALE);
					if (moveAxis) {
						correctedValue = slideBounds.height - correctedValue;
					}
				break;
				case "setPosition":
					if (SoundEvent.isPlaying) {
						value = SoundEvent.getPosition ();
						var duration:Number = SoundEvent.getDuration ();
						correctedValue = convertToPosition (value, duration);
					} else {
						return lastPosition;
					}
				break;
			}
			return correctedValue;
		}
		
		private function convertToPosition (value:Number, max:Number):Number {
			return (value * (totalDimension - 2 * MARGIN) / max) + MARGIN - ((negative) ? ((moveAxis) ? totalHeight : totalWidth) : 0);
		}
		
		private function convertPosition (value:Number, max:Number):Number {
			return (((value + ((negative) ? ((moveAxis) ? totalHeight : totalWidth) : 0)) / (totalDimension - 2 * MARGIN)) * max);
		}
		
	}
}