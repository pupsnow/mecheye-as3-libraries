
////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 Mecheye Independent Studios
//  Some Rights Reserved.
//  Source Code written by JP St. Pierre
//
////////////////////////////////////////////////////////////////////////////////


package mech.games.platform.moving {
	
	import flash.display.Sprite;
	import flash.geom.Point;
	
	import mech.games.platform.moving.Movable;
	import mech.games.platform.Element;
	
	public class MovingElement extends Element implements Movable {
		
		public var velocity:Point;
		public var position:Point;
		
		/**
		* Constructs a MovingObject.
		*/
		public function MovingElement ( file:String, autoLoad:Boolean ):void {
			
			this.velocity = new Point ();
			this.position = new Point ();
			
			super ( file, autoLoad );
			
		}
		
		/**
		* Moves a MovingObject.
		* Called by the update function.
		*/
		public function move ( ):void {
			
			this.position = this.position.add (this.velocity);
			
			this.x = this.position.x;
			this.y = this.position.y;
			
		}
		
		/**
		* MovingObject update function.
		* Called every frame.
		*/
		override public function update ( ):void {
			super.update ();
			move ();
		}
		
		
		
	}
	
}
