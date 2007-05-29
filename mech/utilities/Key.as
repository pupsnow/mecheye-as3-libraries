
////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 Senocular
//  All Rights Reserved.
//  Source Code written by Trevor McCauley
//
////////////////////////////////////////////////////////////////////////////////


package mech.utilities {
	
	import flash.display.Stage;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	import flash.ui.Keyboard;
	
	/**
	* A class meant to replicate the functions of the ActionScript 1 and ActionScript 2 Key class.
	*/
	public class Key {
		
		private static var theStage:Stage;
		private static var initialized:Boolean = false;
		
		private static var keysDown:Array = new Array ();
		
		public static function initialize ( stage:Stage ):void {
			
			if ( Key.initialized || Key.theStage == stage ) {
				return;
			}
			
			Key.theStage = stage;
			Key.theStage.addEventListener ( KeyboardEvent.KEY_DOWN, keyDownHandler );
			Key.theStage.addEventListener ( KeyboardEvent.KEY_UP, keyUpHandler );
			
			Key.theStage.addEventListener ( Event.DEACTIVATE, clearAllKeys );
			
			Key.initialized = true;
			
		}
		
		public static function isDown ( keyCode:uint ):Boolean {
			
			if ( !initialized ) {
				return false;
			}
			
			return Boolean (keyCode in keysDown);
			
		}
		
		private static function keyDownHandler ( event:KeyboardEvent ):void {
			
			keysDown [ event.keyCode ] = true;
		}
		
		private static function keyUpHandler ( event:KeyboardEvent ):void {
			if ( event.keyCode in keysDown ) {
				delete keysDown[event.keyCode];
			}
		}
		
		private static function clearAllKeys ( event:Event ):void {
			keysDown = new Array ();
		}
		
	}
	
}