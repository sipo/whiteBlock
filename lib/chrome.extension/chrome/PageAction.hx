package chrome;

/**
	http://code.google.com/chrome/extensions/pageAction.html
*/
@:native("chrome.pageAction") extern class PageAction {
	
	static function getPopup( details : { tabId : Int }, cb : String->Void ) : Void;
	static function getTitle( details : { tabId : Int }, cb : String->Void ) : Void;
	static function show( tabId : Int ) : Void;
	static function hide( tabId : Int ) : Void;
	
	static function setIcon(
		details : {
			tabId : Int,
			?imageData : Dynamic, // TODO ImageData
			?path : String,
			?iconIndex : Int
		},
		?cb : Void->Void
	) : Void;
	
	static function setPopup(
		details : {
			tabId : Int,
			popup : String
		}
	) : Void;
	
	static function setTitle(
		details : {
			tabId : Int,
			title : String
		}
	) : Void;
	
	static var onClicked(default,null) : Event<Tab->Void>;
}
