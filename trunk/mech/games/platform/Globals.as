
////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 Mecheye Independent Studios
//  Some Rights Reserved.
//  Source Code written by JP St. Pierre
//
////////////////////////////////////////////////////////////////////////////////


package mech.games.platform {
	
	import flash.display.DisplayObject;
	
	/**
	* A class meant to declare global variables, functions, and constants used in the Platform Game.
	*/	
	public class Globals {
		
		public static var STAGE:DisplayObject;
		
		public static const IMAGE_DIR:String = "sprites/";
		public static const XML_DIR:String = "xmldata/";
		
		public static const GAME_XML_FILENAME:String = "base.xml";
		
		public static const STAGE_WIDTH:Number = 550;
		public static const STAGE_HEIGHT:Number = 400;
		
		
		public static const GRAVITY:Number = 0.5;
		public static const ACCELERATION:Number = 1.04;
		public static const FRICTION:Number = 0.75;
		public static const SPEED:Number = 0.2;
		public static const MAX_SPEED:Number = 12;
		
		public static const TRANSPARENT_COLOR:uint = 0xFFFF00FF;
		
		public static var filesLoaded:Array = new Array ( );
		
	}
	
}