package ;
import js.Lib;
import js.html.Storage;
import js.html.DOMWindow;
import js.JQuery;
import js.Browser;
import chrome.Tab;
import String;
import chrome.Extension;
import chrome.Tabs;
class Background 
{
	public static var background:Background;
	
	/* データの扱い */
	private var localStorageDetail:LocalStorageDetail;
	
	/**
	 * 起点
	 */
	public static function main():Void
	{
		background = new Background();
	}
	
	/**
	 * コンストラクタ
	 */
	public function new()
	{
		var factory:LocalStorageFactory = new LocalStorageFactory();
		localStorageDetail = factory.create(storage_change);
		Tabs.onUpdated.addListener(tab_updated);
	}
	
	/*
	 * ストレージデータの変更時
	 */
	private function storage_change(key:String):Void
	{
		// 特になし
	}
	
	/*
	 * タブの更新時
	 */
	private function tab_updated(tabId:Int, changedInfo:UpdateInfo, tab:Tab):Void
	{
		trace("tab_updated");
		trace(tab.url);
		// ブロックページのURlを取得
		var blockUrl:String = Extension.getURL("block.html");
		// 除外処理
		if (tab.url == blockUrl){
			trace("ブロックページなので循環を防ぐために除外");
			return;
		}
		var isWeb:EReg = ~/^(http:)|(https:)/;
		if (!isWeb.match(tab.url)){
			trace("webページじゃない場合除外");	// あとで、httpsはオプション設定にするべきかも
			return;
		}
		if (tab.url != "http://b.hatena.ne.jp/tail_y/"){
			trace("テストページじゃない場合除外");	// とりあえずテストページに限定する
			return;
		}
		// 
		
		var window:DOMWindow = Browser.window;
		var storage:Storage = window.localStorage;
		storage.setItem("checkData", "sadbgf");
		// ページをブロックする
		// ブロックするにはコンテンツスクリプトを利用する方法があるが、
		Tabs.update(tabId, {url:blockUrl}, afterBlock);
	}
	
	/*
	 * ブロック後動作
	 */
	private function afterBlock(tab:Tab):Void
	{
		trace("afterBlock");
//		Tabs.sendMessage(tab.id, {}, blockCallback);
	}
	
	/*
	 * ブロックからのコールバック
	 */
	private function blockCallback(message:Dynamic):Void
	{
		trace("blockCallback");
	}
}
