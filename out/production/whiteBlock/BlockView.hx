package ;
import common.Page;
import storage.LocalStorageDetail;
import common.StringUtil;
import haxe.web.Dispatch;
import haxe.Template;
import common.UnblockTimeDownList;
import js.JQuery;
private typedef LastPageContext = {
	urlFull:String,
	urlShort:String,
	title:String
}

class BlockView {
	
	/* Block */
	private var block:Block;
	
	/* データ本体。ここで操作したらダメ（本来は依存を消すべきだけど、とりあえず規約で止める） */
	private var localStorageDetail:LocalStorageDetail;
	
	/* --------------------------------
	 * パーツ（JQueryは対象の種類情報が消失するため、変数に種類情報を付与）
	 */
	
	private var lastPage_container:JQuery;	// ブロック情報表示
//  <p id="targetPage"><a href="::urlFull::">::title::(::urlShort::)</a></p>
	private var lastPageBase:Template;
	
	private var addLaterList_clickable:JQuery;	// あとで見る追加ボタン
	
	private var unblock_clickable:JQuery;         // ブロック解除開始リンク
	private var unblockTime:UnblockTimeDownList;     // ブロック解除する時間
	private var blockTime_text:JQuery;     // ブロック解除する時間
	
	private var addWhiteList_clickable:JQuery;	// ホワイトリスト追加ボタン
	private var addWhitelistText_input:JQuery;	// ホワイトリスト追加文字フィールド
	
	/* --------------------------------
	 * DOMパラメータ
	 */
	
	private static inline var ADD_WHITELIST_TEXT_MAX_SIZE:Int = 100;
	
	private static inline var URL_LIMIT:Int = 100;
	private static inline var TITLE_LIMIT:Int = 100;
	
	public function new(block:Block, localStorageDetail:LocalStorageDetail)
	{
		this.block = block;
		this.localStorageDetail = localStorageDetail;
	}
	
	/**
	 * 初期化指示
	 */
	public function initialize()
	{
		// ページ情報の取得
		
		
		// DOMの初期化
		lastPage_container = new JQuery("#targetPage");
		// テンプレート情報を取得し、中身のHTMLを削除
		lastPageBase = new Template(lastPage_container.html());
		lastPage_container.html("");
		
		addLaterList_clickable = new JQuery("#addLaterList");
		
		blockTime_text = new JQuery("#blockTime");
		unblockTime = new UnblockTimeDownList(new JQuery("#unblockTime"));
		unblock_clickable = new JQuery("#unblock");
		
		addWhiteList_clickable = new JQuery("#addWhiteList");
		addWhitelistText_input = new JQuery("#addWhitelistText");
		
		// イベントの登録
		addLaterList_clickable.click(addLaterList_clickHandler);
		unblock_clickable.click(unblock_clickHandler);
		addWhiteList_clickable.click(addWhiteList_clickHandler);
	}
	
	/**
	 * 描画
	 */
	public function draw(lastBlockPage:Page):Void
	{
		Note.log("draw");
		// 基本情報表示
		var context:LastPageContext = {urlFull:lastBlockPage.url, urlShort:StringUtil.limit(lastBlockPage.url, URL_LIMIT), title:StringUtil.limit(lastBlockPage.title, URL_LIMIT)};
		lastPage_container.html(lastPageBase.execute(context));
		
		// ブロック解除
		unblockTime.draw(localStorageDetail.getUnblockTimeList(), localStorageDetail.unblockTimeDefaultIndex);
		
	
		// ホワイトリスト
		// 最後にアクセスしたURLを候補に
		var url:String = lastBlockPage.url;
		addWhitelistText_input.val(url);
		// フィールドの長さをURLに合わせる。ただし、大きくなり過ぎないように
		var fieldSize:Int = url.length;
		if (ADD_WHITELIST_TEXT_MAX_SIZE < fieldSize) fieldSize = ADD_WHITELIST_TEXT_MAX_SIZE;
		addWhitelistText_input.attr("size", cast(fieldSize));
	}
	
	/* ================================================================
	 * イベント
	 */
	
	/**
	 * あとでリスト追加をクリック
	 */
	private function addLaterList_clickHandler(event:JqEvent):Void
	{
		
	}
	
	/*
	 * ブロック解除をクリック
	 */
	private function unblock_clickHandler(event:JqEvent):Void
	{
		Note.log("unblock_clickHandler");
		block.startUnblock(unblockTime.getValue());
	}
	
	/*
	 * ホワイトリストに追加し、画面遷移
	 */
	private function addWhiteList_clickHandler(event:JqEvent):Void
	{
		Note.log("addWhiteList_clickHandler");
		block.addWhiteList(addWhitelistText_input.val());
	}
}
//OptionViewを真似するところから
