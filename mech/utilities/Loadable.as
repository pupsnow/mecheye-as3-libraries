
////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2007 Mecheye Independent Studios
//  Some Rights Reserved.
//  Source Code written by JP St. Pierre
//
////////////////////////////////////////////////////////////////////////////////


package mech.utilities {
	
	import flash.events.IEventDispatcher;
	
	public interface Loadable extends IEventDispatcher {
		
		function load ( ):void;
		
	}
	
}