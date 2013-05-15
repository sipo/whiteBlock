package ;
import haxe.Template;
import haxe.Template;
import js.JQuery.JqEvent;
import js.JQuery;
class OptionView {

	/* オプション本体。依存を消す場合はexternなどを使う */
	private var option:Option;
	
	/* データ本体。ここで操作したらダメ（本来は依存を消すべきだけど、とりあえず規約で止める） */
	private var localStorageDetail:LocalStorageDetail;
	
	/* 最終描画のブロック状態がどうなっているか */
	private var lastDisplayIsUnblock:Bool;
	
	/* --------------------------------
	 * DOMパーツ（JQueryは対象の種類情報が消失するため、変数に種類情報を付与）
	 */
	
	private var blockDisplay_switch:JQuery;    // ブロック時に表示するエリア
	private var blockTime_text:JQuery;       // ブロックしている時間の表示
	private var unblockTime_select:JQuery;     // ブロック解除する時間
	private var unblock_clickable:JQuery;         // ブロック解除開始リンク
	
	private var unblockDisplay_switch:JQuery;  // ブロック解除時に表示するエリア
	private var unblockTimeLeft_text:JQuery; // ブロック解除の残り時間
	private var endUnblock_clickable:JQuery; // ブロック解除を終了する
	
	private var laterList_container:JQuery; // あとで見るリスト
	private var laterKits:Array<LaterKit>; // 追加されたあとで見るリストの１つずつの情報
	
	private var unblockTimeList_textArea:JQuery; // ブロック解除時間の入力フィールド
	private var unblockTimeDefaultIndex_select:JQuery; // ブロック解除時間のデフォルト選択プルダウン
	private var unblockTimeDefaultIndexes_option:Array<JQuery>;
	private var whitelist_textArea:JQuery; // 
	private var whitelistUseRegexp_checkbox:JQuery; // 
	private var blacklist_textArea:JQuery; // 
	private var blacklistUseRegexp_checkbox:JQuery; // 
	
	// <option value="::time::">::text::</option>
	private var unblockTimeTemplate:Template;
	// <li class="laterUrl"><a href="::url::" class="laterUrlLink">::titleAndUrl::</a>(<a href="#" class="deleteLaterUrl">削除</a>)</li>
	private var laterKitBase:Template;
	// <option value="::index::">::time::</option>
	private var unblockTimeDefaultIndexOptionTemplate:Template;
	
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
	public function initialize(option:Option)
	{
		trace("optionView initialize");
		// 必要変数
		
		// DOMの初期化
		blockDisplay_switch = new JQuery("#blockDisplay");
		blockTime_text = new JQuery("#blockTime");
		unblockTime_select = new JQuery("#unblockTime");
		unblock_clickable = new JQuery("#unblock");
		
		unblockDisplay_switch = new JQuery("#unblockDisplay");
		unblockTimeLeft_text = new JQuery("#unblockTimeLeft");
		endUnblock_clickable = new JQuery("#endUnblock");
		
		laterList_container = new JQuery("#laterList");
		laterKits = [];
		
		unblockTimeList_textArea = new JQuery("#unblockTimeList");
		unblockTimeDefaultIndex_select = new JQuery("#unblockTimeDefaultIndex");
		unblockTimeDefaultIndexes_option = [];
		whitelist_textArea = new JQuery("#whitelist");
		whitelistUseRegexp_checkbox = new JQuery("#whitelistUseRegexp");
		blacklist_textArea = new JQuery("#blacklist");
		blacklistUseRegexp_checkbox = new JQuery("#blacklistUseRegexp");
		save_clickable = new JQuery("#save");
		
		// テンプレート情報を取得し、中身のHTMLを削除
		unblockTimeTemplate = new Template(unblockTime_select.html());
		unblockTime_select.html("");
		laterKitBase = new Template(laterList_container.html());
		laterList_container.html("");
		unblockTimeDefaultIndexOptionTemplate = new Template(unblockTimeDefaultIndex_select.html());
		unblockTimeDefaultIndex_select.html("");
		
		// イベントの登録
		unblock_clickable.click(unblock_clickHandler);
		endUnblock_clickable.click(endUnblock_clickHandler);
	}
	
	
	/* ================================================================
	 * 描画指示
	 */
	
	/**
	 * blockStateの描画
	 */
	public function drawUnblockState(isFirst:Bool):Void
	{
		Note.log("drawUnblockState");
		localStorageDetail.checkUnblock();
		var unblockState:UnblockState = localStorageDetail.getUnblockState();
		var unblockTimeList:Array<Float> = localStorageDetail.getUnblockTimeList();
		var date:Date = Date.now();
		var full = (isFirst || lastDisplayIsUnblock != unblockState.isUnblock);
		lastDisplayIsUnblock = unblockState.isUnblock;
		if (!lastDisplayIsUnblock){
			// ブロック中
			if (full){
				// 切り替え
				blockDisplay_switch.show();
				unblockDisplay_switch.hide();
			}
			// ブロックしている時間の描画
			if (unblockState.switchTime == -1){
				blockTime_text.html("--- ");
			}else{
				var time:Float = date.getTime() - unblockState.switchTime;
				blockTime_text.html(timeDisplay(time, true));
			}
			if (full){
				// ブロック解除時間のリストを描画
				var innerHtml:String = "";
				for (unblockTimeI in 0...unblockTimeList.length) {
					var value = unblockTimeList[unblockTimeI];
					var context:UnblockTimeContext = {time:Std.string(value), text:timeDisplay(value, false)};
					innerHtml += unblockTimeTemplate.execute(context);
				}
				unblockTime_select.html(innerHtml);	// html描画
				unblockTime_select.val(Std.string(unblockTimeList[localStorageDetail.unblockTimeDefaultIndex]));	// デフォルト選択
			}
		}else{
			// ブロック解除中
			if (full){
				// 切り替え
				blockDisplay_switch.hide();
				unblockDisplay_switch.show();
			}
			// 残り時間の表示
			var time:Float = unblockState.unblockTime + unblockState.switchTime - date.getTime();
			unblockTimeLeft_text.html(timeDisplay(time, true));
		}
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
		
		drawUnblockTimeDefault();
	}
	
	/**
	 * アンブロックデフォルト時間のプルダウンの再描画
	 */
	public function drawUnblockTimeDefault():Void
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
		Note.log("unblock_clickHandler");
		option.unblock_clickHandler(Std.parseFloat(unblockTime_select.val()));
	}
	
	/*
	 * ブロック解除終了をクリック
	 */
	private function endUnblock_clickHandler(event:JqEvent):Void
	{
		Note.log("endUnblock_clickHandler");
	}
	
	/*
	 * あとで見るリンクのクリック
	 */
	private function laterUrlLink_clickHandler(event:JqEvent, index:Int):Void
	{
		Note.log("laterUrlLink_clickHandler " + index);
	}
	
	/*
	 * あとで見る削除のクリック
	 */
	private function laterUrlDelete_clickHandler(event:JqEvent, index:Int):Void
	{
		Note.log("laterUrlDelete_clickHandler " + index);
	}
	
	/*
	 * ブロック解除時間の変更
	 */
	private function unblockTimeList_changeHandler(event:JqEvent):Void
	{
		Note.log("unblockTimeList_changeHandler");
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
	
	/*
	 * 時間の文字列表示
	 */
	private function timeDisplay(time:Float, useSeconds:Bool):String
	{
		var seconds:Int = Std.int(time / 1000) % 60;
		var minutes:Int = Std.int(time / 1000 / 60) % 60;
		var hours:Int = Std.int(time / 1000 / 60 / 60);
//		return hours + ":" + minutes;
		if (hours == 0){
			if (useSeconds) return minutes + "分" + seconds + "秒";
			return minutes + "分";
		}
		if (minutes == 0){
			return hours + "時間";
		}
		return hours + "時間" + minutes + "分";
	}
	
}
private typedef LaterKit = {
	laterUrlLink_clickable:js.JQuery,
	deleteLaterUrl_clickable:js.JQuery
}
private typedef UnblockTimeContext = {
	time:String,
	text:String
}
private typedef LaterKitContext = {
	url:String,
	titleAndUrl:String
}
private typedef UnblockTimeDefaultIndexOptionContext = {
	index:String,
	text:String
}

