package ;
import js.html.DOMWindow;
import js.html.Storage;
import js.Browser;
import chrome.MessageSender;
import chrome.Extension;
class Block
{
	private static var mainInstance:Block;

	/* データの扱い */
	private var localStorageDetail:LocalStorageDetail;
	
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
		var factory:LocalStorageFactory = new LocalStorageFactory();
		localStorageDetail = factory.create(storage_change);
	}
	
	/*
	 * ストレージデータの変更時
	 */
	private function storage_change(key:String):Void
	{
		// 特になし
	}
}


// maxlength="20"
