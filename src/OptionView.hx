package ;
import js.JQuery.JqEvent;
import js.JQuery;
class OptionView {

	
	
	/* --------------------------------
	 * DOMパーツ（JQueryは対象の種類情報が消失するため、変数に種類情報を付与）
	 */
	
	private var blockDisplay_switch:JQuery;    // ブロック時に表示するエリア
	private var blockTime_text:JQuery;       // ブロックしている時間の表示
	private var unblockTime_text:JQuery;     // ブロック解除する時間
	private var unblock_clickable:JQuery;         // ブロック解除開始リンク
	
	private var unblockDisplay_switch:JQuery;  // ブロック解除時に表示するエリア
	private var unblockTimeLeft_text:JQuery; // ブロック解除の残り時間
	
	private var laterList_container:JQuery; // あとで見るリスト
	private var laterKits:Array<LaterKit>; // 追加されたあとで見るリストの１つずつの情報
	private var laterKitBase:String;
	
	private var unblockTimeList_textArea:JQuery; // ブロック解除時間の入力フィールド
	private var unblockTimeDefaultIndex_select:JQuery; // ブロック解除時間のデフォルト選択プルダウン
	private var unblockTimeDefaultIndexes_option:Array<JQuery>;
	// <option value="::index::">::time::</option>
	private var unblockTimeDefaultIndexOptionBase:String;
	private var whitelist_textArea:JQuery; // 
	private var whitelistUseRegexp_checkbox:JQuery; // 
	private var blacklist_textArea:JQuery; // 
	private var blacklistUseRegexp_checkbox:JQuery; // 
	
	private var save_clickable:JQuery; // セーブボタン
	
	/* --------------------------------
	 * テンプレート置き換え文字
	 */
	
	/** リンク先URL */
	private static inline var LATER_KIT_HREF:String = "url";
	/** 表示されるタイトルとURLのセット */
	private static inline var LATER_KIT_TEXT:String = "titleAndUrl";
	/** 表示されるタイトルとURLのセット */
	private static inline var UNBLOCK_TIME_DEFAULT_INDEX_VALUE:String = "index";
	/** 表示されるタイトルとURLのセット */
	private static inline var UNBLOCK_TIME_DEFAULT_INDEX_TEXT:String = "time";
	
	
	/* ================================================================
	 * 初期化
	 */
		
	/**
	 * コンストラクタ
	 */
	public function new()
	{
	}
	
	/**
	 * 初期化指示
	 */
	public function initialize()
	{
		blockDisplay_switch = new JQuery("#blockDisplay");
		blockTime_text = new JQuery("#blockTime");
		
		unblockTime_text = new JQuery("#unblockTime");
		unblock_clickable = new JQuery("#unblock");
		
		unblockDisplay_switch = new JQuery("#unblockDisplay");
		unblockTimeLeft_text = new JQuery("#unblockTimeLeft");
		
		laterList_container = new JQuery("#unblockTimeLeft");
		laterKits = [];
		laterKitBase = laterList_container.html();
		
		unblockTimeList_textArea = new JQuery("#unblockTimeList");
		unblockTimeDefaultIndex_select = new JQuery("#unblockTimeDefaultIndex");
		unblockTimeDefaultIndexes_option = [];
		unblockTimeDefaultIndexOptionBase = unblockTimeDefaultIndex_select.html();
		whitelist_textArea = new JQuery("#whitelist");
		whitelistUseRegexp_checkbox = new JQuery("#whitelistUseRegexp");
		blacklist_textArea = new JQuery("#blacklist");
		blacklistUseRegexp_checkbox = new JQuery("#blacklistUseRegexp");
		save_clickable = new JQuery("#save");
		
		// イベントの登録
		unblock_clickable.click(unblock_clickHandler);
	}
	
	
	/* ================================================================
	 * 描画指示
	 */
	
	/**
	 * blockStateの描画
	 */
	public function drawBlockState():Void
	{
		
	}
	
	/**
	 * blockStateの時間表示の更新
	 */
	public function updateBlockStateTime():Void
	{
		
	}
	
	/**
	 * あとで見るリストの描画
	 */
	public function drawLaterList():Void
	{
		
	}
	
	/**
	 * コンフィグの描画
	 */
	public function drawConfig():Void
	{
		
	}
	
	/* ================================================================
	 * イベント
	 */
	
	/*
	 * ブロック解除をクリック
	 */
	private function unblock_clickHandler(event:JqEvent):Void
	{
		
	}
	
	/*
	 * あとで見るリンクのクリック
	 */
	private function laterUrlLink_clickHandler(event:JqEvent, index:Int):Void
	{
		
	}
	
	/*
	 * あとで見る削除のクリック
	 */
	private function laterUrlDelete_clickHandler(event:JqEvent, index:Int):Void
	{
		
	}
	
	/*
	 * ブロック解除時間の変更
	 */
	private function unblockTimeList_changeHandler(event:JqEvent):Void
	{
		
	}
	
	/*
	 * 保存ボタンのクリック
	 */
	private function save_clickHandler(event:JqEvent):Void
	{
		
	}
	
	/*
	 * 画面のアンロード時の処理
	 * 設定を比較して、変更があったら注意する
	 */
	private function body_unloadHandler(event:JqEvent):Void
	{
		
	}
}
typedef LaterKit = {
	laterUrlLink_clickable:js.JQuery,
	deleteLaterUrl_clickable:js.JQuery
}
