package ;
import storage.LocalStorageKey;
import storage.LocalStorageFactory;
import storage.LocalStorageDetail;
import js.Browser;
import js.JQuery;
class Popup {
	
	public static var popup:Popup;
	
	/* データの扱い */
	private var localStorageDetail:LocalStorageDetail;
	
	/* view */
	private var view:PopupView;
	
	private var isReady:Bool = false;
	
	/* ================================================================
	 * 処理
	 */
	
	/**
	 * 起点
	 */
	public static function main():Void
	{
		popup = new Popup();
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
		view = new PopupView(this, localStorageDetail);
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
		view.initialize();
		view.drawUnblockState(true);
		view.drawLaterList();
		view.drawTotal();
		isReady = true;
	}
	
	/*
	 * ストレージデータの変更時
	 */
	private function storage_changeHandler(key:String):Void
	{
		if (!isReady) return;
		Note.log("storage_changeHandler " + key);
		switch(key){
			case LocalStorageKey.VERSION:
				// 特殊なので値なし
			case LocalStorageKey.UNBLOCK_TIME_LIST:
			case LocalStorageKey.UNBLOCK_TIME_DEFAULT_VALUE:
			case LocalStorageKey.UNBLOCK_STATE:
				view.drawUnblockState(false);
				view.drawLaterList();
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
		if (!isReady) return;
		view.drawUnblockState(false);
	}
	
	/* ================================================================
	 * Viewからの挙動（必要ならController化する
	 */
	
	/**
	 * ブロック解除開始
	 */
	public function startUnblock(unblockTime:Float):Void
	{
		localStorageDetail.startUnblock(unblockTime);
	}
	
	/**
	 * ブロック解除終了
	 */
	public function endUnblock():Void
	{
		localStorageDetail.endUnblock();
	}
	
	/**
	 * あとでみるクリック
	 */
	public function openLater(index:Int):Void
	{
		localStorageDetail.removeLaterList(index);
	}
	
	/**
	 * ブロック解除開始
	 */
	public function deleteLater(index:Int):Void
	{
		localStorageDetail.removeLaterList(index);
	}
}
