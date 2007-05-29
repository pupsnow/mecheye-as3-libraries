package mech.themes {
	public interface IFont {
		static var fontRegular:Class;
		static var fontBold:Class;
		static var fontItalic:Class;
		static var font
		
		function get fontNameNormal ():String;
		function get fontNameBold ():String;
		function get fontNameItalic ():String;
		function get fontNameBoldItalic ():String;
	}
}