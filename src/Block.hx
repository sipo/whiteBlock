package ;
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
	/* 最後にブロックされたURL（おそらくこのページのもとのURLであることを期待するが、完全ではない気がする） */
	private var lastBlockPage:Page;
	/* view */
	private var view:BlockView;
	
	
	
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
		lastBlockPage = new Page(StringTools.urlDecode(params.get("title")), StringTools.urlDecode(params.get("url")));	// TODO:定数化
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
		view.draw(lastBlockPage);
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
		localStorageDetail.addLaterList(lastBlockPage.clone());
	}
	
	/**
	 * ブロック解除開始
	 */
	public function startUnblock(unblockTime:Float):Void
	{
		localStorageDetail.startUnblock(unblockTime);
	}
	
	/*
	 * ホワイトリストに追加し、画面遷移
	 */
	public function addWhiteList(url:String):Void
	{
		localStorageDetail.addWhitelist(url);
		Browser.window.location.assign(lastBlockPage.url);
	}
}
