package ;
import chrome.MessageSender;
import chrome.Extension;
class Block
{
	/**
	 * 起点
	 */
	public static function main():Void
	{
	}
	
	/**
	 * コンストラクタ
	 */
	public function new()
	{
		trace("constractor block.js");
		Extension.onRequest.addListener(extension_request);
	}
	
	/*
	 * comment
	 */
	private function extension_request(request:Dynamic, sender:MessageSender, sendResponse:Dynamic->Void):Void
	{
		trace("extension_request");
		sendResponse({});
	}
}


// maxlength="20"
