
////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 Mecheye Independent Studios
//  Some Rights Reserved.
//  Source Code written by JP St. Pierre
//
////////////////////////////////////////////////////////////////////////////////


package mech.utilities {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mech.utilities.Loadable;
	
	public class LoadQueue extends EventDispatcher implements Loadable {
		
		private var _queue:Array;
		private var _queueLength:Number;
		private var _itemsLoaded:Number;
		private var _currentItem:Loadable;
		
		public function LoadQueue ( autoLoad:Boolean = false, ...queue ):void {
			
			_queue = queue;
			_queueLength = _queue.length;
			_itemsLoaded = 0;
			
			if ( autoLoad ) {
				load ( );
			}
			
		}
		
		public function load ():void {
			_load ( );
		}
		
		public function get queue ():Array {
			return _queue;
		}
		
		public function get length ():Number {
			return _queueLength;
		}
		
		public function get itemsLoaded ():Number {
			return _itemsLoaded;
		}
		
		private function _load ( index:Number = 0 ):void {
			
			_currentItem = _queue [ index ];
			_currentItem.addEventListener ( Event.COMPLETE, itemLoaded );
			_currentItem.load ();
			
		}
		
		private function itemLoaded ( event:Event ):void {
			
			_currentItem.removeEventListener ( Event.COMPLETE, itemLoaded );
			
			_itemsLoaded ++;
			
			if ( _itemsLoaded >= _queueLength ) {
				
				this.dispatchEvent ( event );
				return;
				
			}
			
			_load ( _itemsLoaded );
			
		}
		
	}
	
}