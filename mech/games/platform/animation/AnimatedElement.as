
////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 Mecheye Independent Studios
//  Some Rights Reserved.
//  Source Code written by JP St. Pierre
//
////////////////////////////////////////////////////////////////////////////////


package mech.games.platform.animation {
	
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PixelSnapping;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.geom.*;
	import flash.net.URLRequest;
	
	import mech.games.platform.animation.Animatable;
	import mech.games.platform.animation.AnimationCycle;
	import mech.games.platform.Element;
	
	/**
	* The AnimatedElement class is a class on screen that 
	*/
	public class AnimatedElement extends Element implements Animatable {
		
		private var frames:Array;
		private var currentFrame:Number;
		private var cycle:AnimationCycle;
		
		/**
		* Creates a new AnimatedElemnt.
		* @param	source	The path to the image file of the GameElement.
		* @param	cycle	The animated cycle used in generating cycle data.
		*/
		public function AnimatedElement ( file:String, cycle:AnimationCycle, autoLoad:Boolean ):void {
			
			super ( file, autoLoad );
			
			this.frames = new Array ( );
			this.cycle = cycle;
			
		}
		
		/**
		* The function called when the source image has loaded.
		* @param	sourceBmp The bitmap loaded.
		*/
		override protected function manipulateImage ( sourceBmp:BitmapData ):void {
			
			for ( var i:Number = 0; i < cycle.totalFrames; i++ ) {
				
				var frameData:BitmapData = new BitmapData ( cycle.frameWidth, cycle.frameHeight, true );
				var frameStartPoint:Point = cycle.cycleStart;
				
				if ( cycle.align == AnimationCycleAlignMode.HORIZONTAL ) {
					frameStartPoint.x += i * cycle.frameWidth;
				} else {
					frameStartPoint.y += i * cycle.frameHeight;
				}
				
				var frameBounds:Rectangle = new Rectangle ( frameStartPoint.x, frameStartPoint.y, cycle.frameWidth, cycle.frameHeight );
				frameData.copyPixels ( sourceBmp, frameBounds, new Point (0, 0) );
				
				frames.push ( frameData );
				
			}
			
			this.bitmapData = frames [0];
			this.currentFrame = 0;
			
		}
		
		/**
		* To be overridden.
		*/
		public function animate ( ):void {
			
		}
		
		/**
		* Goes to the next frame of the animation.
		*/
		public function nextFrame ( ):void {
			setFrame ( (this.currentFrame + 1) % (cycle.totalFrames) );
		}
		
		/**
		* Goes to the previous frame of the animation.
		*/	
		public function previousFrame ( ):void {
			setFrame ( (this.currentFrame - 1) < 0 ? (cycle.totalFrames - 1) : (this.currentFrame - 1) );
		}
		
		/**
		* Sets the frame of the animation to a specific frame.
		* @param	frame	The frame number to set the animation to.
		*/
		public function setFrame ( frameIndex:uint ):void {
			this.currentFrame = frameIndex;
			this.bitmapData = frames [ frameIndex ];
		}
		
		override protected function update ( event:Event ):void {
			super.update ( event );
			animate ( );
		}
		
	}
}
