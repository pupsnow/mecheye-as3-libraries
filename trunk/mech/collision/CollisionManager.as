
////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 Mecheye Independent Studios
//  Some Rights Reserved.
//  Source Code written by JP St. Pierre
//
////////////////////////////////////////////////////////////////////////////////


package mech.collision {
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	public class CollisionManager extends EventDispatcher {
		
		private static const SECTION_DIVISOR:Number = 4;
		private static var OBJECTS:Array = new Array ( );
		
		private var owner:CollisionManagerOwner;
		
		public function CollisionManager ( owner:CollisionManagerOwner ):void {
			
			this.owner = owner;
			
		}
		
		/**
		* 
		* Notes about the collision. The collision method is a homebrewed method.
		* 
		* 
		* @param	object	The object to test collisions with.
		* @return	The collision that happens between collidee and the collider.
		*/
		
		private function collisionTest ( object:Collidable ):Collision {
			
			var objectRectangle:Rectangle = object.collisionBounds;
			var ownerRectangle:Rectangle = owner.collisionBounds;
			
			if ( objectRectangle.containsRect ( ownerRectangle ) ) {
				return new Collision ( object, ownerRectangle, CollisionType.INSIDE );
			}
			
			debugDraw ( ownerRectangle, 0x0000ff, 0x0000aa );
			
			if ( objectRectangle.intersects ( ownerRectangle ) ) {
				
				var intersection:Rectangle = objectRectangle.intersection ( ownerRectangle );
				
				var intersectionLeft	:Rectangle = getLeftRect	( intersection );
				var intersectionRight	:Rectangle = getRightRect	( intersection );
				var intersectionTop		:Rectangle = getTopRect		( intersection );
				var intersectionBottom	:Rectangle = getBottomRect	( intersection );
				
				var collisions:Array = new Array ( );
				
				collisions.push 	(
					new Collision ( object, ownerRectangle.intersection ( intersectionLeft		) ,	CollisionType.LEFT 	),
					new Collision ( object, ownerRectangle.intersection ( intersectionRight		) ,	CollisionType.RIGHT	),
					new Collision ( object, ownerRectangle.intersection ( intersectionTop		) ,	CollisionType.TOP	),
					new Collision ( object, ownerRectangle.intersection ( intersectionBottom	) ,	CollisionType.BOTTOM	)
				);
				
				
				var bestGuessCollisionArea:Number = 0;
				var bestGuessCollision:Collision;
				
				for each ( var collision:Collision in collisions ) {
					
					var size:Point = collision.intersection.size;
					var area:Number = ( size.x ) * ( size.y );
					
					if ( area > bestGuessCollisionArea ) {
						bestGuessCollisionArea	= area;
						bestGuessCollision		= collision;
					}
					
				}
				
				bestGuessCollision.isCollided = true;
				return bestGuessCollision;
			
			}
			
			return Collision.EMPTY_COLLISION;
			
		}
		
		/**
		* 
		* Registers an object with the CollisionManager.
		* Effectively, it sets the object up for collision handlers and makes the object collidable.
		* 
		* @param	object	The object
		*/
		public static function register ( object:Collidable ):void {
			
			if ( object in CollisionManager.OBJECTS ) {
				return;
			}
			
			/*object.dispatchEvent (
									new CollisionEvent (
										CollisionEvent.REGISTERED,
										this.owner
									)
								 );*/
			
			CollisionManager.OBJECTS.push ( object );
			
		}
		
		/**
		* 
		* Releases an object out of the CollisionManager.
		* 
		* @param	object	The object
		*/
		public static function release ( object:Collidable ):void {
			
			if ( ! ( object in CollisionManager.OBJECTS ) ) {
				return;
			}
			
			/*object.dispatchEvent (
									new CollisionEvent (
										CollisionEvent.RELEASED,
										this.owner
									)
								 );*/
			
			CollisionManager.OBJECTS.splice ( CollisionManager.OBJECTS.indexOf ( object ), 1 );
			
		}
		
		/**
		* Does the owner have any collisions?
		* @return Returns true if the owner has one or more collisions.
		*/
		public function hasAnyCollisions ( ):Boolean {
			return ( objectsCollidedWith.length > 0 );
		}
		
		/** 
		* All objects that have been collided with.
		*/
		public function get objectsCollidedWith ( ):Array {
			
			var collisionArray:Array = new Array ( );
			
			for each ( var object:Collidable in OBJECTS ) {
				
				if ( collisionTest ( object ).isCollided ) {
					collisionArray.push ( object );
				}
				
			}
			
			return collisionArray;
			
		}
		
		
		
		private function getLeftRect ( rect:Rectangle ):Rectangle {
			return new Rectangle ( rect.x, rect.y, rect.width / SECTION_DIVISOR, rect.height - 1 );
		}
		
		private function getRightRect ( rect:Rectangle ):Rectangle {
			return new Rectangle ( rect.right - ( rect.width / SECTION_DIVISOR ), rect.y, rect.width / SECTION_DIVISOR, rect.height - 1 );
		}
		
		private function getTopRect ( rect:Rectangle ):Rectangle {
			return new Rectangle ( rect.x, rect.y, rect.width, rect.height / SECTION_DIVISOR );
		}
		
		private function getBottomRect ( rect:Rectangle ):Rectangle {
			return new Rectangle ( rect.x, rect.bottom - ( rect.height / SECTION_DIVISOR ), rect.width, rect.height / SECTION_DIVISOR );
		}
		
		
		private function debugDraw ( rect:Rectangle, fillColor:uint, lineColor:uint ):void {
			
			/*
			if ( !Globals.DEBUG_MODE ) {
				return;
			}
			
			Globals.STAGE.graphics.clear ( );
			Globals.STAGE.graphics.lineStyle ( 1, lineColor );
			Globals.STAGE.graphics.beginFill ( fillColor, .3 );
			Globals.STAGE.graphics.drawRect ( rect.x, rect.y, rect.width, rect.height );
			Globals.STAGE.graphics.endFill ( );
			
			*/
			
		}
		
	}
	
}
