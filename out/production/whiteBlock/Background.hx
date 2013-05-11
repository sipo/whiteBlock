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
	
	/** 必ずデータをクリアするデバッグ挙動 */
	public static inline var DEBUG_CLEAR_DATA:Bool = true;
	
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
		localStorageDetail = factory.create(storage_changeHandler, DEBUG_CLEAR_DATA);
		Tabs.onUpdated.addListener(tab_updatedHandler);
	}
	
	/*
	 * ストレージデータの変更時
	 */
	private function storage_changeHandler(key:String):Void
	{
		// 特になし
	}
	
	/*
	 * タブの更新時
	 */
	private function tab_updatedHandler(tabId:Int, changedInfo:UpdateInfo, tab:Tab):Void
	{
		trace("tab_updated");
		var targetUrl:String = tab.url;
		// ブロックページのURlを取得
		var blockUrl:String = Extension.getURL("block.html");
		
		// 除外処理
		if (targetUrl == blockUrl){
			trace("ブロックページなので循環を防ぐために除外");
			return;
		}
		var isWeb:EReg = ~/^(http:)|(https:)/;
		if (!isWeb.match(targetUrl)){
			trace("webページじゃない場合除外");	// あとで、httpsはオプション設定にするべきかも
			return;
		}
//		if (targetUrl != "http://b.hatena.ne.jp/tail_y/"){
//			trace("テストページじゃない場合除外");	// 開発用にテストページに限定する
//			return;
//		}
		// リストをチェック
		if (checkList(targetUrl, localStorageDetail.getWhitelist(), localStorageDetail.whitelistUseRegexp)){
			if (!checkList(targetUrl, localStorageDetail.getBlacklist(), localStorageDetail.blacklistUseRegexp)) return;
		}
		// ページをブロックする
		// ブロックするにはコンテンツスクリプトを利用する方法があるが、HTMLに既にあるスクリプトの競合がどうなるか分からなくて、こちらを利用
		localStorageDetail.lastBlockUrl = targetUrl;
		Tabs.update(tabId, {url:blockUrl}, afterBlock);
	}
	/*
	 * 対象URLがリストに含まれているかチェックする
	 */
	private function checkList(targetUrl:String, list:Array<String>, useRegexp:Bool):Bool
	{
		trace("checkList " + list);
		for (url in list) {
			if (useRegexp){
				if (new EReg(url, "").match(targetUrl)){	// オプション無しで正規表現チェック
					trace("match" + url);
					return true;
				}
			}else{
				if (targetUrl.indexOf(url) != -1){	// 部分一致でチェック
					trace("indexOf" + url);
					return true;
				}
			}
		}
		return false;
	}
	
	/*
	 * ブロック後動作
	 */
	private function afterBlock(tab:Tab):Void
	{
		trace("afterBlock");
//		Tabs.sendMessage(tab.id, {}, blockCallback);
	}
	
}
