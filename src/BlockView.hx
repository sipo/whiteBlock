package ;
import storage.UnblockState;
import common.Page;
import storage.LocalStorageDetail;
import common.StringUtil;
import haxe.web.Dispatch;
import haxe.Template;
import common.UnblockTimeDownList;
import js.JQuery;
private typedef BlockTimeContext = {
	time:String
}
private typedef TargetPageContext = {
	urlFull:String,
	urlShort:String,
	title:String
}
private typedef TodayUnblockTotalContext = {
	time:String
}
class BlockView {
	
	/* Block */
	private var block:Block;
	
	/* データ本体。ここで操作したらダメ（本来は依存を消すべきだけど、とりあえず規約で止める） */
	private var localStorageDetail:LocalStorageDetail;
	
	/* --------------------------------
	 * パーツ（JQueryは対象の種類情報が消失するため、変数に種類情報を付与）
	 */
	
//  <p id="blockTime"><small>::time::経過</small></p>
	private var blockTime_container:JQuery;	// ブロック情報表示
	private var blockTimeBase:Template;
//  <p id="targetPage"><a href="::urlFull::">::title::(::urlShort::)</a></p>
	private var targetPage_container:JQuery;	// ブロック情報表示
	private var targetPageBase:Template;
	
	private var addLaterList_clickable:JQuery;	// あとで見る追加ボタン
	
	private var unblock_clickable:JQuery;         // ブロック解除開始リンク
	private var unblockTime:UnblockTimeDownList;     // ブロック解除する時間
//  <p id="todayUnblockTotal"><small>今日は合計::time::解除しています</small></p>
	private var todayUnblockTotal_container:JQuery;     // ブロック解除する時間
	private var todayUnblockTotalBase:Template;
	
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
		blockTime_container = new JQuery("#blockTime");
		targetPage_container = new JQuery("#targetPage");
		
		addLaterList_clickable = new JQuery("#addLaterList");
		
		unblock_clickable = new JQuery("#unblock");
		unblockTime = new UnblockTimeDownList(new JQuery("#unblockTime"));
		todayUnblockTotal_container = new JQuery("#todayUnblockTotal");
		
		addWhiteList_clickable = new JQuery("#addWhiteList");
		addWhitelistText_input = new JQuery("#addWhitelistText");
		
		// テンプレート情報を取得し、中身のHTMLを削除
		blockTimeBase = new Template(blockTime_container.html());
		blockTime_container.html("");
		targetPageBase = new Template(targetPage_container.html());
		targetPage_container.html("");
		todayUnblockTotalBase = new Template(todayUnblockTotal_container.html());
		todayUnblockTotal_container.html("");
		
		// イベントの登録
		addLaterList_clickable.click(addLaterList_clickHandler);
		unblock_clickable.click(unblock_clickHandler);
		addWhiteList_clickable.click(addWhiteList_clickHandler);
	}
	
	/**
	 * 描画
	 */
	public function draw(targetPage:Page):Void
	{
		Note.log("draw");
		var date:Date = Date.now();
		var unblockState:UnblockState = localStorageDetail.getUnblockState();
		// 基本情報表示
		var blockTime:Float = date.getTime() - unblockState.switchTime;
		var blockTimeContext:BlockTimeContext = {time:StringUtil.timeDisplay(blockTime, false)};
		blockTime_container.html(blockTimeBase.execute(blockTimeContext));
		var targetPageContext:TargetPageContext = {urlFull:targetPage.url, urlShort:StringUtil.limit(targetPage.url, URL_LIMIT), title:StringUtil.limit(targetPage.title, URL_LIMIT)};
		targetPage_container.html(targetPageBase.execute(targetPageContext));
		
		// ブロック解除
		unblockTime.draw(localStorageDetail.getUnblockTimeList(), localStorageDetail.unblockTimeDefaultIndex);
		var todayUnblockTotalContext:TodayUnblockTotalContext = {time:StringUtil.timeDisplay(unblockState.todayUnblockTotal, false)};
		todayUnblockTotal_container.html(todayUnblockTotalBase.execute(todayUnblockTotalContext));
	
		// ホワイトリスト
		// 最後にアクセスしたURLを候補に
		var url:String = targetPage.url;
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
