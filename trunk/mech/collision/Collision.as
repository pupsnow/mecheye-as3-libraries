
////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 Mecheye Independent Studios
//  Some Rights Reserved.
//  Source Code written by JP St. Pierre
//
////////////////////////////////////////////////////////////////////////////////


package mech.games.platform.collision {
	
	import flash.geom.Rectangle;
	import mech.games.platform.collision.*;
	
	public class Collision {
		
		public var object:Collidable;
		public var intersection:Rectangle;
		public var side:CollisionType;
		public var isCollided:Boolean = false;
		
		public static const EMPTY_COLLISION:Collision = new Collision ( null, null, CollisionType.NONE );
		
		public function Collision ( object:Collidable, intersection:Rectangle, side:CollisionType ):void {
			
			this.object = object;
			this.intersection = intersection;
			this.side = side;
			
		}
		
		public function isEmpty ( ):Boolean {
			return ( this === EMPTY_COLLISION );
		}
		
	}
	
}
