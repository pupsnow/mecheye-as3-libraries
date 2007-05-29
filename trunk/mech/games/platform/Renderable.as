
////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 Mecheye Independent Studios
//  Some Rights Reserved.
//  Source Code written by JP St. Pierre
//
////////////////////////////////////////////////////////////////////////////////


package mech.games.platform {
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	
	public interface Renderable {
		
		function render ():BitmapData;
		
		function getPosition ():Point;
		function getDimensions ():Point;
		function getOffsets ():Point;
		
	}
	
}