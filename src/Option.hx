package ;
import js.Browser;
import js.JQuery;
class Option {
	
	public static var option:Option;
	
	/* データの扱い */
	private var localStorageDetail:LocalStorageDetail;
	
	/* view */
	private var view:OptionView;
	
	/* ================================================================
	 * 処理
	 */
	
	/**
	 * 起点
	 */
	public static function main():Void
	{
		option = new Option();
	}
	
	/**
	 * コンストラクタ
	 */
	public function new()
	{
		// データの用意
		var factory:LocalStorageFactory = new LocalStorageFactory();
		localStorageDetail = factory.create(storage_changeHandler, false);
		// viewの用意
		view = new OptionView(this, localStorageDetail);
		// DOMの準備完了イベント登録
		new JQuery("document").ready(document_readyHandler);
		// 繰り返し処理イベント登録
		Browser.window.setInterval(window_timeoutHandler, 1000);
		// 
	}
	
	/*
	 * 描画準備終了
	 */
	private function document_readyHandler(event:JqEvent):Void
	{
		view.initialize(this);
		view.drawUnblockState(true);
	}
	
	/*
	 * ストレージデータの変更時
	 */
	private function storage_changeHandler(key:String):Void
	{
		Note.log("storage_changeHandler " + key);
		switch(key){
			case LocalStorageKey.VERSION:
				// 特殊なので値なし
			case LocalStorageKey.LAST_BLOCK_URL:
			case LocalStorageKey.UNBLOCK_TIME_LIST:
			case LocalStorageKey.UNBLOCK_TIME_DEFAULT_INDEX:
			case LocalStorageKey.UNBLOCK_STATE:
				view.drawUnblockState(false);
			case LocalStorageKey.WHITELIST:
			case LocalStorageKey.WHITELIST_USE_REGEXP:
			case LocalStorageKey.BLACKLIST:
			case LocalStorageKey.BLACKLIST_USE_REGEXP:
			case LocalStorageKey.LATER_LIST:
				view.drawLaterList();
			default :
				throw "対応していない値です key=" + key;
		}
	}
	
	/*
	 * １秒毎の処理
	 */
	private function window_timeoutHandler():Void
	{
		view.drawUnblockState(false);
	}
	
	/* ================================================================
	 * Viewからの挙動（必要ならController化する
	 */
	
	/**
	 * ブロック解除開始
	 */
	public function unblock_clickHandler(unblockTime:Float):Void
	{
		localStorageDetail.startUnblock(unblockTime);
	}
}
