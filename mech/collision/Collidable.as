
////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 Mecheye Independent Studios
//  Some Rights Reserved.
//  Source Code written by JP St. Pierre
//
////////////////////////////////////////////////////////////////////////////////


package mech.collision {
	
	import flash.geom.Rectangle;
	import flash.events.IEventDispatcher;
	
	public interface Collidable extends IEventDispatcher {
		
		function get collisionBounds ( ):Rectangle;
		
	}
	
}
