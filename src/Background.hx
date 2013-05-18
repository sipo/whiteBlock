package ;
import common.StringUtil;
import storage.UnblockState;
import chrome.BrowserAction;
import common.RequestParams;
import storage.LocalStorageFactory;
import storage.LocalStorageDetail;
import StringTools;
import Std;
import haxe.ds.StringMap;
import haxe.web.Dispatch;
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
		// タブの変更イベント
		Tabs.onUpdated.addListener(tab_updatedHandler);
		// 繰り返し処理イベント登録
		Browser.window.setInterval(window_timeoutHandler, 1000);
	}
	
	/*
	 * ストレージデータの変更時
	 */
	private function storage_changeHandler(key:String):Void
	{
		// 特になし
	}
	
	/*
	 * 毎フレーム
	 */
	private function window_timeoutHandler():Void
	{
		if (localStorageDetail.checkUnblock()){
			batchDraw();
			return;
		}
		batchClear();
	}
	
	/*
	 * タブの更新時
	 */
	private function tab_updatedHandler(tabId:Int, changedInfo:UpdateInfo, tab:Tab):Void
	{
		if (changedInfo.status != "complete") return;
		Note.log("tab_updated");
		
		var targetUrl:String = tab.url;
		var targetUrlNoGet:String = targetUrl.split("?")[0];
		// ブロックページのURlを取得
		var blockUrl:String = Extension.getURL("block.html");
		
		// 除外処理
		if (targetUrl == null || targetUrl == "null"){
			Note.log("null除外");
			return;
		}
		if (targetUrlNoGet == blockUrl){
			Note.log("ブロックページなので循環を防ぐために除外");
			return;
		}
		var isWeb:EReg = ~/^(http:)|(https:)/;
		if (!isWeb.match(targetUrl)){
			Note.log("webページじゃない場合除外");	// あとで、httpsはオプション設定にするべきかも
			return;
		}
		
		// 裏で変更があった場合、タブイベントとstorageイベントは前後する可能性があるので、ロードを挟む
		localStorageDetail.loadAllValue();
		
		// リストをチェック
		if (checkList(targetUrl, localStorageDetail.getWhitelist(), localStorageDetail.whitelistUseRegexp)){
			if (!checkList(targetUrl, localStorageDetail.getBlacklist(), localStorageDetail.blacklistUseRegexp)) return;
		}
		// ブロック解除中ならブロックしない
		if (localStorageDetail.checkUnblock()){
			batchDraw();
			return;
		}
		batchClear();
		// ページをブロックする（ブロックするにはコンテンツスクリプトを利用する方法があるが、HTMLに既にあるスクリプトの競合がどうなるか分からなくて、こちらを利用）
		
		// ブロックページの準備
		var params:StringMap<String> = new StringMap<String>();
		params.set(RequestParams.TITLE, tab.title);
		params.set(RequestParams.URL, targetUrl);
		var paramsStrings:Array<String> = [];
		for(key in params.keys()){
			paramsStrings.push(key + "=" + StringTools.urlEncode(params.get(key)));
		}
		blockUrl += "?" + paramsStrings.join("&");
		// タブを遷移させることでブロック
		Note.log("ブロック " + targetUrl);
		Tabs.update(tabId, {url:blockUrl}, afterBlock);
	}
	/*
	 * 対象URLがリストに含まれているかチェックする
	 */
	private function checkList(targetUrl:String, list:Array<String>, useRegexp:Bool):Bool
	{
		Note.log("checkList " + list);
		for (url in list) {
			if (useRegexp){
				if (new EReg(url, "").match(targetUrl)){	// オプション無しで正規表現チェック
					Note.log("match" + url);
					return true;
				}
			}else{
				if (targetUrl.indexOf(url) != -1){	// 部分一致でチェック
					Note.log("indexOf" + url);
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
	
	/**
	 * バッチの描画
	 */
	public function batchDraw():Void
	{
		var date:Date = Date.now();
		var unblockState:UnblockState = localStorageDetail.getUnblockState();
		var time:Float = unblockState.unblockTime + unblockState.switchTime - date.getTime();
		BrowserAction.setBadgeText({text:StringUtil.timeDisplayMinutes(time)});
	}
	public function batchClear():Void
	{
		BrowserAction.setBadgeText({text:""});
	}
}
