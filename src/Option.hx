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
		var factory:LocalStorageFactory = new LocalStorageFactory();
		localStorageDetail = factory.create(storage_changeHandler, false);
		view = new OptionView();
		// 準備完了タイミングで初期描画
		new JQuery("document").ready(document_readyHandler);
		Browser.window.setTimeout(window_timeoutHandler, 1000);
	}
	
	/*
	 * 描画準備終了
	 */
	private function document_readyHandler(event:JqEvent):Void
	{
		view.initialize();
	}
	
	/*
	 * ストレージデータの変更時
	 */
	private function storage_changeHandler(key:String):Void
	{
		// 特になし
	}
	
	/*
	 * １秒毎の処理
	 */
	private function window_timeoutHandler():Void
	{
	}
}
