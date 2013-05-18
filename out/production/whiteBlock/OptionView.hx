package ;
import storage.UnblockState;
import storage.LocalStorageDetail;
import common.UnblockTimeDownList;
import common.StringUtil;import common.StringUtil;
import haxe.Template;
import haxe.Template;
import js.JQuery.JqEvent;
import js.JQuery;
class OptionView {

	/* オプション本体。依存を消す場合はexternなどを使う */
	private var option:Option;
	/* データ本体。ここで操作したらダメ（本来は依存を消すべきだけど、とりあえず規約で止める） */
	private var localStorageDetail:LocalStorageDetail;
	
	/* 最後に選択されたデフォルト値が示すアンブロック時間。一致するものがあれば、プルダウン選択は優先的にそこへ移動する */
	private var lastUnblockTimeDefaultValue:Float;
	
	private static inline var MINUTE_TIME:Float = 1000 * 60;
	private static inline var CHECKBOX_ATTR:String = "checked";
	private static inline var TEXTAREA_ROWS_ATTR:String = "rows";
	private static inline var TEXTAREA_ROWS_MIN:Int = 5;
	private static inline var TEXTAREA_ROWS_MAX:Int = 20;
	
	/* --------------------------------
	 * パーツ（JQueryは対象の種類情報が消失するため、変数に種類情報を付与）
	 */
	
	private var unblockTimeList_textArea:JQuery; // ブロック解除時間の入力フィールド
	private var unblockTimeDefaultIndex:UnblockTimeDownList; // ブロック解除時間のデフォルト選択プルダウン
	private var whitelist_textArea:JQuery; // 
	private var whitelistUseRegexp_checkbox:JQuery; // 
	private var blacklist_textArea:JQuery; // 
	private var blacklistUseRegexp_checkbox:JQuery; // 
	
	private var save_clickable:JQuery; // セーブボタン
	
	
	
	/* ================================================================
	 * 初期化
	 */
		
	/**
	 * コンストラクタ
	 */
	public function new(option:Option, localStorageDetail:LocalStorageDetail)
	{
		this.option = option;
		this.localStorageDetail = localStorageDetail;
	}
	
	/**
	 * 初期化指示
	 */
	public function initialize()
	{
		Note.log("optionView initialize");
		// 必要変数
		
		unblockTimeList_textArea = new JQuery("#unblockTimeList");
		unblockTimeDefaultIndex = new UnblockTimeDownList(new JQuery("#unblockTimeDefaultIndex"));
		whitelist_textArea = new JQuery("#whitelist");
		whitelistUseRegexp_checkbox = new JQuery("#whitelistUseRegexp");
		blacklist_textArea = new JQuery("#blacklist");
		blacklistUseRegexp_checkbox = new JQuery("#blacklistUseRegexp");
		save_clickable = new JQuery("#save");
		
		unblockTimeDefaultIndex.change(unblockTimeDefaultIndex_changeHandler);
		
		drawConfig();
	}
	
	
	/* ================================================================
	 * 描画指示
	 */
	
	
	/**
	 * コンフィグの描画
	 */
	public function drawConfig():Void
	{
		var unblockTimeList = localStorageDetail.getUnblockTimeList();
		var unblockTimeMinuteList:Array<Float> = [];
		for (i in 0...unblockTimeList.length) {
			var minute:Float = unblockTimeList[i] / MINUTE_TIME;
			unblockTimeMinuteList.push(minute);
		}
		unblockTimeList_textArea.val(unblockTimeMinuteList.join("\n"));
		
		lastUnblockTimeDefaultValue = localStorageDetail.unblockTimeDefaultValue;
		drawUnblockTimeDefault();
		
		drawListTextArea(whitelist_textArea, localStorageDetail.getWhitelist());
		
		drawCheckbox(whitelistUseRegexp_checkbox, localStorageDetail.whitelistUseRegexp);
		
		drawListTextArea(blacklist_textArea, localStorageDetail.getBlacklist());
		
		drawCheckbox(blacklistUseRegexp_checkbox, localStorageDetail.blacklistUseRegexp);
	}
	/*
	 * リスト表示の描画
	 */
	private function drawListTextArea(textArea:JQuery, list:Array<String>):Void
	{
		textArea.val(list.join("\n"));
		var rows:Int = list.length;
		rows = if (rows < TEXTAREA_ROWS_MIN) TEXTAREA_ROWS_MIN else if (TEXTAREA_ROWS_MAX < rows) TEXTAREA_ROWS_MAX else rows;
		textArea.attr(TEXTAREA_ROWS_ATTR, Std.string(rows));
	}
	/*
	 * チェックボックスの描画
	 */
	private function drawCheckbox(checkbox:JQuery, value:Bool):Void
	{
		if (value) checkbox.attr(CHECKBOX_ATTR, CHECKBOX_ATTR);
		else checkbox.removeAttr(CHECKBOX_ATTR);
	}
	
	/**
	 * アンブロックデフォルト時間のプルダウンの再描画
	 */
	public function drawUnblockTimeDefault():Void
	{
		var unblockTimeList_textAreaValue:String = unblockTimeList_textArea.val();
		unblockTimeList_textAreaValue = new EReg("(\r\n)|(\r)", "g").replace(unblockTimeList_textAreaValue, "\n");
		var unblockMinutesString:Array<String> = unblockTimeList_textArea.val().split("\n");
		// 時間リストの生成
		var timeList:Array<Float> = [];
		for (i in 0...unblockMinutesString.length) {
			var minute:Float = Std.parseFloat(unblockMinutesString[i]);
			if (Math.isNaN(minute)){
				timeList.push(0);
				continue;
			}			
			timeList.push(minute * MINUTE_TIME);
		}
		// 描画
		unblockTimeDefaultIndex.draw(timeList, lastUnblockTimeDefaultValue);
	}
	
	/* ================================================================
	 * イベント
	 */
	
	/*
	 * ブロック解除時間の変更
	 */
	private function unblockTimeList_changeHandler(event:JqEvent):Void
	{
		Note.log("unblockTimeList_changeHandler");
		drawUnblockTimeDefault();
	}
	
	/*
	 * ブロック解除時間デフォルト選択の変更
	 */
	private function unblockTimeDefaultIndex_changeHandler(event:JqEvent):Void
	{
		Note.log("unblockTimeList_changeHandler");
		lastUnblockTimeDefaultValue = unblockTimeDefaultIndex.getValue();
	}
	
	/*
	 * 保存ボタンのクリック
	 */
	private function save_clickHandler(event:JqEvent):Void
	{
		Note.log("save_clickHandler");
	}
	
	/*
	 * 画面のアンロード時の処理
	 * 設定を比較して、変更があったら注意する
	 */
	private function body_unloadHandler(event:JqEvent):Void
	{
		
	}
	
	/* ================================================================
	 * 内部処理
	 */
	
	
}
