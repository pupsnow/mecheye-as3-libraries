
////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 Mecheye Independent Studios
//  Some Rights Reserved.
//  Source Code written by JP St. Pierre
//
////////////////////////////////////////////////////////////////////////////////


package mech.utilities {
	
	import flash.display.Loader;
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	
	import mech.utilities.Loadable;
	
	public class LoaderWrapper extends Loader implements Loadable {
		
		private var _request:URLRequest;
		private var _context:LoaderContext;
		
		public function LoaderWrapper ( request:URLRequest = null, context:LoaderContext = null, autoLoad:Boolean = false ):void {
			
			super ( );
			
			_request = request;
			_context = context;
			
			if ( autoLoad ) {
				load ( );
			}
			
		}
		
		public function set request ( value:URLRequest ):void {
			_request = value;
		}
		
		public function get request ( ):URLRequest {
			return _request;
		}
		
		public function set context ( value:LoaderContext ):void {
			_context = value;
		}
		
		public function get context ( ):LoaderContext {
			return _context;
		}
		
		public function load ( ):void {
			super.load ( _request, _context );
		}
		
	}
	
}