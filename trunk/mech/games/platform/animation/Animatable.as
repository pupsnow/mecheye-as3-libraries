
////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 Mecheye Independent Studios
//  Some Rights Reserved.
//  Source Code written by JP St. Pierre
//
////////////////////////////////////////////////////////////////////////////////


package mech.games.platform.animation {
	
	/**
	* An interfaced used to describe an object that can be animated.
	*/	
	public interface Animatable {
		
		function animate ():void;
		function setFrame ( frame:uint ):void;
		function nextFrame ():void;
		function previousFrame ():void;
		
	}
	
}