package ;
import common.StringUtil;
import storage.UnblockState;
import storage.LocalStorageDetail;
import haxe.Template;
import common.UnblockTimeDownList;
import js.JQuery;
private typedef LaterKit = {
	laterUrlLink_clickable:js.JQuery,
	deleteLaterUrl_clickable:js.JQuery
}
private typedef LaterKitContext = {
	url:String,
	titleAndUrl:String
}
private typedef TodayUnblockTotalContext = {
	time:String
}
class PopupView {
	
	
	/* 本体 */
	private var popup:Popup;
	/* データ本体。ここで操作したらダメ（本来は依存を消すべきだけど、とりあえず規約で止める） */
	private var localStorageDetail:LocalStorageDetail;
	/* 最終描画のブロック状態がどうなっているか */
	private var lastDisplayIsUnblock:Bool;
	
	/* --------------------------------
	 * パーツ（JQueryは対象の種類情報が消失するため、変数に種類情報を付与）
	 */
	
	private var blockDisplay_switch:JQuery;    // ブロック時に表示するエリア
	private var blockTime_text:JQuery;       // ブロックしている時間の表示
	private var unblockTime:UnblockTimeDownList;     // ブロック解除する時間
	private var unblock_clickable:JQuery;         // ブロック解除開始リンク
	
	private var unblockDisplay_switch:JQuery;  // ブロック解除時に表示するエリア
	private var unblockTimeLeft_text:JQuery; // ブロック解除の残り時間
	private var endUnblock_clickable:JQuery; // ブロック解除を終了する
	private var todayUnblockTotal_container:JQuery;     // ブロック解除する時間
	private var todayUnblockTotalBase:Template;
	
	private var laterList_container:JQuery; // あとで見るリスト
	private var laterKits:Array<LaterKit>; // 追加されたあとで見るリストの１つずつの情報
	
	
	// <li class="laterUrl"><a href="::url::" class="laterUrlLink">::titleAndUrl::</a>(<a href="#" class="deleteLaterUrl">削除</a>)</li>
	private var laterKitBase:Template;
	
	/* ================================================================
	 * 初期化
	 */
		
	/**
	 * コンストラクタ
	 */
	public function new(popup:Popup, localStorageDetail:LocalStorageDetail)
	{
		this.popup = popup;
		this.localStorageDetail = localStorageDetail;
	}
	
	
	/* ================================================================
	 * 描画指示
	 */
	
	/**
	 * 初期化指示
	 */
	public function initialize()
	{
		Note.log("optionView initialize");
		// 必要変数
		
		// DOMの初期化
		blockDisplay_switch = new JQuery("#blockDisplay");
		blockTime_text = new JQuery("#blockTime");
		unblockTime = new UnblockTimeDownList(new JQuery("#unblockTime"));
		unblock_clickable = new JQuery("#unblock");
		todayUnblockTotal_container = new JQuery("#todayUnblockTotal");
		
		unblockDisplay_switch = new JQuery("#unblockDisplay");
		unblockTimeLeft_text = new JQuery("#unblockTimeLeft");
		endUnblock_clickable = new JQuery("#endUnblock");
		
		laterList_container = new JQuery("#laterList");
		laterKits = [];
		
		
		// テンプレート情報を取得し、中身のHTMLを削除
		todayUnblockTotalBase = new Template(todayUnblockTotal_container.html());
		todayUnblockTotal_container.html("");
		laterKitBase = new Template(laterList_container.html());
		laterList_container.html("");
		
		// イベントの登録
		unblock_clickable.click(unblock_clickHandler);
		endUnblock_clickable.click(endUnblock_clickHandler);
	}
	
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
				blockTime_text.html(StringUtil.timeDisplay(time, true));
			}
			if (full){
				// ブロック解除時間のリストを描画
				unblockTime.draw(unblockTimeList, localStorageDetail.unblockTimeDefaultValue);
			}
			var todayUnblockTotalContext:TodayUnblockTotalContext = {time:StringUtil.timeDisplay(unblockState.todayUnblockTotal, false)};
			todayUnblockTotal_container.html(todayUnblockTotalBase.execute(todayUnblockTotalContext));
		}else{
			// ブロック解除中
			if (full){
				// 切り替え
				blockDisplay_switch.hide();
				unblockDisplay_switch.show();
			}
			// 残り時間の表示
			var time:Float = unblockState.unblockTime + unblockState.switchTime - date.getTime();
			unblockTimeLeft_text.html(StringUtil.timeDisplay(time, true));
		}
	}
	
	/**
	 * あとで見るリストの描画
	 */
	public function drawLaterList():Void
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
		popup.startUnblock(unblockTime.getValue());
	}
	
	/*
	 * ブロック解除終了をクリック
	 */
	private function endUnblock_clickHandler(event:JqEvent):Void
	{
		Note.log("endUnblock_clickHandler");
		popup.endUnblock();
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
}
