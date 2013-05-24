package ;
import common.Page;
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
	urlFull:String,
	urlShort:String,
	title:String
}
private typedef TodayUnblockTotalContext = {
	time:String
}
private typedef TotalDisplayContext = {
	isYesterdayData:Bool,
	yesterdayBlockTotal:String,
	todayBlockTotal:String
}
private typedef LaterListBlockMessageContext = {
	num:Int
}
class PopupView {
	
	
	/* 本体 */
	private var popup:Popup;
	/* データ本体。ここで操作したらダメ（本来は依存を消すべきだけど、とりあえず規約で止める） */
	private var localStorageDetail:LocalStorageDetail;
	/* 最終描画のブロック状態がどうなっているか */
	private var lastDisplayIsUnblock:Bool;
	
	private static inline var URL_LIMIT:Int = 50;
	private static inline var TITLE_LIMIT:Int = 50;
	
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
	
	private var laterListBlockMessage_switch:JQuery;
	private var laterListBlockMessageBase:Template;
	private var laterList_container:JQuery; // あとで見るリスト
	private var laterKits:Array<LaterKit>; // 追加されたあとで見るリストの１つずつの情報
	
	private var totalDisplay_container:JQuery;
	private var totalDisplayBase:Template;
	
	
	
	// <li class="laterKit"><a href="::urlFull::">::title::(::urlShort::)</a>(<a href="#" class="deleteLaterUrl">削除</a>)</li>
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
		
		laterListBlockMessage_switch = new JQuery("#laterListBlockMessage");
		laterList_container = new JQuery("#laterList");
		laterKits = [];
		
		totalDisplay_container = new JQuery("#totalDisplay");
		
		// テンプレート情報を取得し、中身のHTMLを削除
		todayUnblockTotalBase = new Template(todayUnblockTotal_container.html());
		todayUnblockTotal_container.html("");
		laterKitBase = new Template(laterList_container.html());
		laterList_container.html("");
		totalDisplayBase = new Template(totalDisplay_container.html());
		totalDisplay_container.html("");
		laterListBlockMessageBase = new Template(laterListBlockMessage_switch.html());
		laterListBlockMessage_switch.html("");
		
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
		// あとでリスト
		// 合計表示
	}
	
	/**
	 * あとで見るリストの描画
	 */
	public function drawLaterList():Void
	{
		Note.log("drawLaterList");
		var laterList:Array<Page> = localStorageDetail.getLaterList();
		Note.log("laterList = " + laterList);
		laterList_container.html("");	// 一度クリア
		
		if (!localStorageDetail.getUnblockState().isUnblock){
			var laterListBlockMessageContext:LaterListBlockMessageContext = {num:laterList.length};
			laterListBlockMessage_switch.show();
			laterListBlockMessage_switch.html(laterListBlockMessageBase.execute(laterListBlockMessageContext));
			
			return;	// 以下の処理をカット
		}else{
			laterListBlockMessage_switch.hide();
		}
		for (i in 0...laterList.length) {
			// htmlを配置
			var page = laterList[i];
			var laterKitContext:LaterKitContext = {
				urlFull:page.escapeUrl,
				urlShort:StringUtil.limit(page.escapeUrl, URL_LIMIT),
				title:StringUtil.limit(page.escapeTitle, URL_LIMIT)
			}
			laterList_container.append(laterKitBase.execute(laterKitContext));
			// 要素を取得
			var laterKit_container:JQuery = laterList_container.children(".laterKit").eq(i);
			var laterKit_linkLaterUrl_clickable:JQuery = laterKit_container.children(".linkLaterUrl");
			var laterKit_deleteLaterUrl_clickable:JQuery = laterKit_container.children(".deleteLaterUrl");
			// イベントを追加
			laterKit_linkLaterUrl_clickable.click(function (event:JqEvent){	laterUrlLink_clickHandler(event, i);});
			laterKit_deleteLaterUrl_clickable.click(function (event:JqEvent){	laterUrlDelete_clickHandler(event, i);});
		}
	}
	
	/**
	 * 合計時間描画
	 */
	public function drawTotal():Void
	{
		Note.log("drawTotal");
		var unblockState:UnblockState = localStorageDetail.getUnblockState();
		var date:Date = Date.now();
		var yesterdayBlockTotalTime:Float = 24 * 60 * 60 * 1000 - unblockState.yesterdayUnblockTotal;
		var today0:Date = new Date(date.getFullYear(), date.getMonth(), date.getDate(), 0, 0, 0);
		var todayBlockTotalTime:Float = date.getTime() - today0.getTime() - unblockState.todayUnblockTotal;
		var totalDisplayContext:TotalDisplayContext = {
			isYesterdayData:(unblockState.yesterdayUnblockTotal != -1),
			yesterdayBlockTotal:StringUtil.timeDisplay(yesterdayBlockTotalTime, false),
			todayBlockTotal:StringUtil.timeDisplay(todayBlockTotalTime, false)
		};
		totalDisplay_container.html(totalDisplayBase.execute(totalDisplayContext));
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
		popup.openLater(index);
	}
	
	/*
	 * あとで見る削除のクリック
	 */
	private function laterUrlDelete_clickHandler(event:JqEvent, index:Int):Void
	{
		Note.log("laterUrlDelete_clickHandler " + index);
		popup.deleteLater(index);
	}
}
