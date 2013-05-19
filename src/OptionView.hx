package ;
import js.html.Element;
import js.html.BodyElement;
import js.html.DOMWindow;
import js.html.Event;
import js.Browser;
import Option.StorageSaveData;
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
	/* 何らかの変更があった場合 */
	private var anyChange:Bool;
	
	/* 最後に選択されたデフォルト値が示すアンブロック時間。一致するものがあれば、プルダウン選択は優先的にそこへ移動する */
	private var lastUnblockTimeDefaultValue:Float;
	
	private static inline var MINUTE_TIME:Float = 1000 * 60;
	private static inline var CHECKBOX_ATTR:String = "checked";
	private static inline var TEXTAREA_ROWS_ATTR:String = "rows";
	private static inline var TEXTAREA_ROWS_MIN:Int = 5;
	private static inline var TEXTAREA_ROWS_MAX:Int = 20;
	private static inline var SAVE_DISABLED_ATTR:String = "disabled";
	
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
	
	private var delete_clickable:JQuery; // 削除ボタン
	
	
	
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
		delete_clickable = new JQuery("#delete");
		
		// イベント
		unblockTimeList_textArea.keyup(unblockTimeList_changeHandler);	// inputイベントとか無いのー？
		unblockTimeList_textArea.change(unblockTimeList_changeHandler);
		unblockTimeDefaultIndex.change(unblockTimeDefaultIndex_changeHandler);
		whitelist_textArea.keyup(any_changeHandler);
		whitelist_textArea.change(any_changeHandler);
		whitelistUseRegexp_checkbox.change(any_changeHandler);
		blacklist_textArea.keyup(any_changeHandler);
		blacklist_textArea.change(any_changeHandler);
		blacklistUseRegexp_checkbox.change(any_changeHandler);
		save_clickable.click(save_clickHandler);
		delete_clickable.click(delete_clickHandler);
		
//		var body:BodyElement = cast(new JQuery("body").get()[0], BodyElement);
//		body.onbeforeunload = window_unloadHandler; // うーん、動かない・・・まあいいか
		
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
		
		switchChange(false);
	}
	/*
	 * リスト表示の描画
	 */
	private function drawListTextArea(textArea:JQuery, list:Array<String>):Void
	{
		textArea.val(list.join("\n"));
		var rows:Int = list.length + 1;
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
		unblockTimeList_textAreaValue = cleanBreak(unblockTimeList_textAreaValue);
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
		any_changeHandler(null);
	}
	
	/*
	 * ブロック解除時間デフォルト選択の変更
	 */
	private function unblockTimeDefaultIndex_changeHandler(event:JqEvent):Void
	{
		Note.log("unblockTimeList_changeHandler");
		lastUnblockTimeDefaultValue = unblockTimeDefaultIndex.getValue();
		any_changeHandler(null);
	}
	
	
	/*
	 * 何らかデータの変更
	 */
	private function any_changeHandler(event:JqEvent):Void
	{
		Note.log("any_changeHandler");
		switchChange(true);
	}
	
	/*
	 * 保存ボタンのクリック
	 */
	private function save_clickHandler(event:JqEvent):Void
	{
		Note.log("save_clickHandler");
		switchChange(false);
		
		var unblockTimeList:Array<Float> = [];
		var unblockTimeListString:Array<String> = cleanBreak(unblockTimeList_textArea.val()).split("\n");
		for(i in 0...unblockTimeListString.length) unblockTimeList.push(Std.parseFloat(unblockTimeListString[i]) * MINUTE_TIME);	// 本当はここで、変換できなかったら警告を出すのがいいのだろうけど・・・
		
		var unblockTimeDefaultValue:Float = unblockTimeDefaultIndex.getValue();
		
		var whitelist:Array<String> = textAreaToArray(whitelist_textArea);
		var whitelistUseRegexp:Bool = checkboxToBool(whitelistUseRegexp_checkbox);
		var blacklist:Array<String> = textAreaToArray(blacklist_textArea);
		var blacklistUseRegexp:Bool = checkboxToBool(blacklistUseRegexp_checkbox);
		
		var data:StorageSaveData = {
			unblockTimeList:unblockTimeList,
			unblockTimeDefaultValue:unblockTimeDefaultValue,
			whitelist:whitelist,
			whitelistUseRegexp:whitelistUseRegexp,
			blacklist:blacklist,
			blacklistUseRegexp:blacklistUseRegexp
		}
		Note.log("save " + data);
		option.save(data);
	}
	private function textAreaToArray(textArea:JQuery):Array<String>
	{
		var tmpList:Array<String> = cleanBreak(textArea.val()).split("\n");
		var ans:Array<String> = [];
		for (i in 0...tmpList.length) {
			var text:String = tmpList[i];
			if (text == "") continue;
			ans.push(text);
		}
		return ans;
	}
	private function checkboxToBool(checkbox:JQuery):Bool
	{
		return checkbox.is(":" + CHECKBOX_ATTR);	// JQueryのクソキモいところ。
	}
	
	/*
	 * 削除ボタンのクリック
	 */
	private function delete_clickHandler(event:JqEvent):Void
	{
		if (Browser.window.confirm("設定やブロック時間の記録などを全て消し、デフォルトに戻します")){
			option.delete();
		}else{
			
		}
	}


	/*
	 * 画面のアンロード時の処理
	 * 変更があったら注意する　※なんか動かん！
	 */
	private function window_unloadHandler(event:Event):Void
	{
		if (!anyChange) return;
		untyped __js__("event.returnValue = 'ページから移動しますか？'");
		untyped __js__("return event");
	}
	
	/* ================================================================
	 * 内部処理
	 */
	
	/*
	 * 何らかの変更があった常態かどうかを切り替える
	 */
	private function switchChange(isChange:Bool):Void
	{
		anyChange = isChange;
		if (isChange) save_clickable.removeAttr(SAVE_DISABLED_ATTR);
		else save_clickable.attr(SAVE_DISABLED_ATTR, SAVE_DISABLED_ATTR);
	}
	
	/*
	 * 改行コードを揃える
	 */
	private function cleanBreak(original:String):String
	{
		return new EReg("(\r\n)|(\r)", "g").replace(original, "\n");
	}
}
