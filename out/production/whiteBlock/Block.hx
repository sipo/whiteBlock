package ;
import js.html.History;
import common.RequestParams;
import common.Page;
import storage.LocalStorageFactory;
import storage.LocalStorageDetail;
import haxe.ds.StringMap;
import haxe.web.Request;
import js.html.Location;
import js.JQuery;
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
	/* dom準備完了 */
	private var isReady:Bool = false;
	/* ブロックされたURL */
	private var targetPage:Page;
	/* view */
	private var view:BlockView;
	
	/** 解除後に遷移する数。href="#"なら-2、それ以外なら-1でいいはず */
	private static inline var HISTORY_BACK_NUM:Int = -2;
	
	/* ================================================================
	 * 基本処理
	 */
	
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
		localStorageDetail = factory.create(storage_changeHandler, false);
		// 初期データの取得
//		lastBlockPage = localStorageDetail.getLastBlockPage();
		var params:StringMap<String> = Request.getParams();
		targetPage = new Page(StringTools.urlDecode(params.get(RequestParams.TITLE)), StringTools.urlDecode(params.get(RequestParams.URL)));
		// viewの用意
		view = new BlockView(this, localStorageDetail);
		// 準備完了タイミングで初期描画
		new JQuery("document").ready(document_readyHandler);
	}
	
	/*
	 * DOM準備完了
	 */
	private function document_readyHandler(event:JqEvent):Void
	{
		var factory:LocalStorageFactory = new LocalStorageFactory();
		localStorageDetail = factory.create(storage_changeHandler, false);
		isReady = true;
		// 描画呼び出し
		view.initialize();
		view.draw(targetPage);
	}
	
	/*
	 * ストレージデータの変更時
	 */
	private function storage_changeHandler(key:String):Void
	{
		if (!isReady) return;
		Note.log("storage_change" + key);
	}
	
	/* ================================================================
	 * Viewからの挙動（必要ならController化する
	 */
	
	/**
	 * あとで見るリストに追加
	 */
	public function addLaterList():Void
	{
		localStorageDetail.addLaterList(targetPage.clone());
	}
	
	/**
	 * ブロック解除開始
	 */
	public function startUnblock(unblockTime:Float):Void
	{
		localStorageDetail.startUnblock(unblockTime);
		Browser.window.history.go(HISTORY_BACK_NUM);
	}
	
	/*
	 * ホワイトリストに追加し、画面遷移
	 */
	public function addWhiteList(url:String):Void
	{
		localStorageDetail.addWhitelist(url);
		Browser.window.history.go(HISTORY_BACK_NUM);
	}
}
