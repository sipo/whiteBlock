package ;
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
	private var lastBlockUrl:String;
	
	/* --------------------------------
	 * DOMパーツ
	 */
	
	private var addWhiteList:JQuery;
	private var addWhitelistText:JQuery;
	
	/* --------------------------------
	 * DOMパラメータ
	 */
	
	private static inline var ADD_WHITELIST_TEXT_MAX_SIZE:Int = 100;
	
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
		localStorageDetail = factory.create(storageHandler_change, false);
		// 初期データの取得
		lastBlockUrl = localStorageDetail.lastBlockUrl;
		// 準備完了タイミングで初期描画
		new JQuery("document").ready(documentHandler_ready);
	}
	
	/*
	 * DOM準備完了
	 */
	private function documentHandler_ready(event:JqEvent):Void
	{
		isReady = true;
		// パーツ取得
		addWhiteList = new JQuery("#addWhiteList");
		addWhitelistText = new JQuery("#addWhitelistText");
		// 描画呼び出し
		drawAddWhitelistText();
		// イベント登録
		addWhiteList.click(addWhiteListHandler_click);
	}
	
	/*
	 * ストレージデータの変更時
	 */
	private function storageHandler_change(key:String):Void
	{
		if (!isReady) return;
		trace("storage_change" + key);
	}
	
	/* ================================================================
	 * 描画処理
	 */
	
	/*
	 * ブロックしたURLを描画
	 */
	private function drawAddWhitelistText():Void
	{
		trace("drawLastBlockUrl");
		// 最後にアクセスしたURLを候補に
		addWhitelistText.val(lastBlockUrl);
		// フィールドの長さをURLに合わせる。ただし、大きくなり過ぎないように
		var fieldSize:Int = lastBlockUrl.length;
		if (ADD_WHITELIST_TEXT_MAX_SIZE < fieldSize) fieldSize = ADD_WHITELIST_TEXT_MAX_SIZE;
		addWhitelistText.attr("size", cast(fieldSize));
	}
	
	/* ================================================================
	 * UI処理
	 */
	
	/*
	 * ホワイトリストに追加し、画面遷移
	 */
	private function addWhiteListHandler_click(event:JqEvent):Void
	{
		localStorageDetail.addWhitelist(addWhitelistText.val());
		Browser.window.location.assign(lastBlockUrl);
	}
}


// maxlength="20"
