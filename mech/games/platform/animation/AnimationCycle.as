
////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 Mecheye Independent Studios
//  Some Rights Reserved.
//  Source Code written by JP St. Pierre
//
////////////////////////////////////////////////////////////////////////////////


package mech.games.platform.animation {
	
	import flash.geom.Point;
	
	public class AnimationCycle {
		
		public var cycleStart:Point;
		public var frameWidth:Number;
		public var frameHeight:Number;
		public var totalFrames:Number;
		
		public var align:AnimationCycleAlignMode;
		
		public function AnimationCycle ( cycleStart:Point, frameWidth:Number, frameHeight:Number, totalFrames:Number, align:AnimationCycleAlignMode ):void {
			
			this.cycleStart = cycleStart;
			this.frameWidth = frameWidth;
			this.frameHeight = frameHeight;
			this.totalFrames = totalFrames;
			this.align = align;
			
		}
		
	}
	
}