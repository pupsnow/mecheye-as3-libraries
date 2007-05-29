
////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 Mecheye Independent Studios
//  Some Rights Reserved.
//  Source Code written by JP St. Pierre
//
////////////////////////////////////////////////////////////////////////////////


package mech.games.platform.animation {
	
	import flash.geom.Point;
	
	/**
	* @private
	*/
	public class AnimationCycle {
		
		public var cycleName:String;
		public var cycleStart:Point;
		public var frameWidth:Number;
		public var frameHeight:Number;
		public var totalFrames:Number;
		public var align:String;
		
		public static const ALIGN_HORIZONTAL:String = "h";
		public static const ALIGN_VERTICAL:String = "v";
		
		public function AnimationCycle ( cycleName:String, cycleStart:Point, frameWidth:Number, frameHeight:Number, totalFrames:Number, align:String ):void {
			
			this.cycleName = cycleName;
			this.cycleStart = cycleStart;
			this.frameWidth = frameWidth;
			this.frameHeight = frameHeight;
			this.totalFrames = totalFrames;
			this.align = align;
			
		}
		
	}
	
}