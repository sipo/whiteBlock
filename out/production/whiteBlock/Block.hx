package ;
import js.html.DOMWindow;
import js.html.Storage;
import js.Browser;
import chrome.MessageSender;
import chrome.Extension;
class Block
{
	private static var mainInstance:Block;

	/**
	 * 起点
	 */
	public static function main():Void
	{
		mainInstance = new Block();
	}
	
	/**
	 * コンストラクタ
	 */
	public function new()
	{
		trace("constractor block.js");
		var window:DOMWindow = Browser.window;
		var storage:Storage = window.sessionStorage;
		trace(storage.getItem("checkData"));
//		Extension.onRequest.addListener(extension_request);
	}
	
	/*
	 * comment
	 */
	private function extension_request(request:Dynamic, sender:MessageSender, sendResponse:Dynamic->Void):Void
	{
//		trace("extension_request");
//		sendResponse({});
	}
}


// maxlength="20"
