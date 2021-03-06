package storage;
import common.Page;
import js.html.StorageEvent;
import js.html.Event;
import js.html.DOMWindow;
import Std;
import String;
import Std;
import haxe.Json;
import js.html.Storage;
class LocalStorageDetail {
	
	/* ローカルストレージ本体 */
	private var storageEntity:Storage;
	
	/** ストレージデータのバージョン（将来に備えて） */
	public static inline var STORAGE_VERSION:Int = 1;
	
	/* イベントコールバック */
	private var callbackStorageChange:String -> Void;
	
	/* ================================================================
	 * 実データと、設定
	 */
	
	/** ブロック解除の選択時間リスト */
	private var unblockTimeList:Array<Float>;
	public function getUnblockTimeList():Array<Float>
	{
		return unblockTimeList.copy();	// クローンを返し、参照に触らせない
	}
	public function setUnblockTimeList(value:Array<Float>):Void
	{
		unblockTimeList = value;	// 性質上、上書き
		flushItem(LocalStorageKey.UNBLOCK_TIME_LIST);	// Storageへ反映
	}
	
	/** ブロック解除選択時間のデフォルト選択の時間値 */
	public var unblockTimeDefaultValue(default, null):Float;
	public function setUnblockTimeDefaultIndex(value:Float):Float
	{
		unblockTimeDefaultValue = value;
		flushItem(LocalStorageKey.UNBLOCK_TIME_DEFAULT_VALUE);	// Storageへ反映
		return unblockTimeDefaultValue;
	}
	
	/** ブロック解除状態の情報 */
	private var unblockState:UnblockState;
	public function getUnblockState():UnblockState
	{
		return unblockState.clone();	// クローンで返して、触らせない。
	}
	
	/** ホワイトリスト */
	private var whitelist:Array<String>;
	public function getWhitelist():Array<String>
	{
		return whitelist.copy();	// クローンを返し、参照に触らせない
	}
	public function setWhitelist(value:Array<String>):Void
	{
		whitelist = value;	// 性質上、上書き
		flushItem(LocalStorageKey.WHITELIST);	// Storageへ反映
	}
	public function addWhitelist(value:String):Void
	{
		Note.log("addWhitelist" + whitelist);
		whitelist.push(value);	// 追加
		flushItem(LocalStorageKey.WHITELIST);	// Storageへ反映
	}
	
	/** ホワイトリストを正規表現で行うかどうか */
	public var whitelistUseRegexp(default, null):Bool;
	public function setWhitelistUseRegexp(value:Bool):Bool
	{
		whitelistUseRegexp = value;
		flushItem(LocalStorageKey.WHITELIST_USE_REGEXP);	// Storageへ反映
		return whitelistUseRegexp;
	}
	
	/** ブラックリスト */
	private var blacklist:Array<String>;
	public function getBlacklist():Array<String>
	{
		return blacklist.copy();	// クローンを返し、参照に触らせない
	}
	public function setBlacklist(value:Array<String>):Void
	{
		blacklist = value;	// 性質上、上書き
		flushItem(LocalStorageKey.BLACKLIST);	// Storageへ反映
	}
	
	/** ブラックリストを正規表現で行うかどうか */
	public var blacklistUseRegexp(default, null):Bool;
	public function setBlacklistUseRegexp(value:Bool):Bool
	{
		blacklistUseRegexp = value;
		flushItem(LocalStorageKey.BLACKLIST_USE_REGEXP);	// Storageへ反映
		return blacklistUseRegexp;
	}
	
	/** あとで見るリスト */
	private var laterList:Array<Page>;
	public function getLaterList():Array<Page>
	{
		return Page.arrayClone(laterList);	// クローンを返し、参照に触らせない
	}
	public function addLaterList(value:Page):Void
	{
		laterList.push(value);	// 追加
		flushItem(LocalStorageKey.LATER_LIST);	// Storageへ反映
	}
	public function removeLaterList(index:Int):Void
	{
		laterList.splice(index, 1);	// 削除
		flushItem(LocalStorageKey.LATER_LIST);	// Storageへ反映
	}
	
	/* --------------------------------
	 * 共通処理
	 */
	
	/* キーに対応した値を、Storageに反映する */
	private function flushItem(key:String):Void
	{
		Note.log("flushItem " + key);
		switch(key){
			case LocalStorageKey.VERSION:
				setIntItem(key, STORAGE_VERSION);
			case LocalStorageKey.UNBLOCK_TIME_LIST:
				setJsonItem(key, unblockTimeList);
			case LocalStorageKey.UNBLOCK_TIME_DEFAULT_VALUE:
				setFloatItem(key, unblockTimeDefaultValue);
			case LocalStorageKey.UNBLOCK_STATE:
				setJsonItem(key, unblockState);
			case LocalStorageKey.WHITELIST:
				setJsonItem(key, whitelist);
			case LocalStorageKey.WHITELIST_USE_REGEXP:
				setBoolItem(key, whitelistUseRegexp);
			case LocalStorageKey.BLACKLIST:
				setJsonItem(key, blacklist);
			case LocalStorageKey.BLACKLIST_USE_REGEXP:
				setBoolItem(key, blacklistUseRegexp);
			case LocalStorageKey.LATER_LIST:
				setJsonItem(key, laterList);
			default :
				throw "対応していない値です key=" + key;
		}
		window_storageHandler_(key);
	}
	/* JSONに変換してからStorageに反映する */
	private function setJsonItem(key:String, value:Dynamic):Void
	{
		storageEntity.setItem(key, Json.stringify(value));
	}
	/* Boolを文字に変換してからStorageに反映する */
	private function setBoolItem(key:String, value:Bool):Void
	{
		storageEntity.setItem(key, if (value) "true" else "false");
	}
	/* Intを文字に変換してからStorageに反映する */
	private function setIntItem(key:String, value:Int):Void
	{
		storageEntity.setItem(key, Std.string(value));
	}
	/* Floatを文字に変換してからStorageに反映する */
	private function setFloatItem(key:String, value:Float):Void
	{
		storageEntity.setItem(key, Std.string(value));
	}
	
	
	/* キーに対応した値を、Storageからロードする */
	private function loadData(key:String):Void
	{
		Note.log("loadData " + key);
		switch(key){
			case LocalStorageKey.VERSION:
				// 特殊なので値なし
			case LocalStorageKey.UNBLOCK_TIME_LIST:
				unblockTimeList = getArrayFloat(key);
			case LocalStorageKey.UNBLOCK_TIME_DEFAULT_VALUE:
				unblockTimeDefaultValue = Std.parseFloat(storageEntity.getItem(key));
			case LocalStorageKey.UNBLOCK_STATE:
				unblockState = UnblockState.createFromJson(storageEntity.getItem(key));
			case LocalStorageKey.WHITELIST:
				whitelist = getArrayString(key);
			case LocalStorageKey.WHITELIST_USE_REGEXP:
				whitelistUseRegexp = getArrayBool(key);
			case LocalStorageKey.BLACKLIST:
				blacklist = getArrayString(key);
			case LocalStorageKey.BLACKLIST_USE_REGEXP:
				blacklistUseRegexp = getArrayBool(key);
			case LocalStorageKey.LATER_LIST:
				laterList = Page.createArrayFromJson(getObject(key));
			default :
				throw "対応していない値です key=" + key;
		}
	}
	/* Storageから、配列に変換して取得する */
	private function getArrayFloat(key:String):Array<Float>
	{
		var list:Dynamic = Json.parse(storageEntity.getItem(key));
		return [for (i in 0...list.length) Std.parseFloat(list[i])];
	}
	/* Storageから、配列に変換して取得する */
	private function getArrayString(key:String):Array<String>
	{
		return cast(Json.parse(storageEntity.getItem(key)));
	}
	/* Storageから、Boolに変換して取得する */
	private function getArrayBool(key:String):Bool
	{
		return storageEntity.getItem(key) == "true";
	}
	/* Storageから、Boolに変換して取得する */
	private function getObject(key:String):Dynamic
	{
		return Json.parse(storageEntity.getItem(key));
	}
	
	private function createDefault(key:String):Void
	{
		switch(key){
			case LocalStorageKey.VERSION:
				// 特殊なので値なし
			case LocalStorageKey.UNBLOCK_TIME_LIST:
				unblockTimeList = [
					1 * 60 * 1000,
					5 * 60 * 1000,
					10 * 60 * 1000,
					20 * 60 * 1000,
					30 * 60 * 1000,
					60 * 60 * 1000
				];
			case LocalStorageKey.UNBLOCK_TIME_DEFAULT_VALUE:
				unblockTimeDefaultValue = unblockTimeList[1];
			case LocalStorageKey.UNBLOCK_STATE:
				unblockState = UnblockState.createDefault();
			case LocalStorageKey.WHITELIST:
				whitelist = [
					"http://t.co",
					"https://www.google.co.jp/webhp",
					"https://www.google.co.jp/search",
					"https://www.google.com/calendar",
					"https://chrome.google.com/",
					"https://maps.google.co.jp/",
					"https://drive.google.com",
					"https://github.com",
					"http://www.alc.co.jp",
					"http://eow.alc.co.jp"
				];
			case LocalStorageKey.WHITELIST_USE_REGEXP:
				whitelistUseRegexp = false;
			case LocalStorageKey.BLACKLIST:
				blacklist = [];
			case LocalStorageKey.BLACKLIST_USE_REGEXP:
				blacklistUseRegexp = false;
			case LocalStorageKey.LATER_LIST:
				laterList = [];
			default :
				throw "対応していない値です key=" + key;
		}
		flushItem(key);	// storageに反映
	}
	
	/* ================================================================
	 * 処理
	 */
	
	/**
	 * コンストラクタ
	 */
	public function new(storageEntity:Storage, window:DOMWindow):Void
	{
		Note.log("LocalStorageDetail constractor");
		this.storageEntity = storageEntity;
		window.addEventListener("storage", window_storageHandler);
	}
	
	/**
	 * バージョンの取得
	 */
	public function getVersion():Int
	{
		var versionText:String = storageEntity.getItem(LocalStorageKey.VERSION);
		if (versionText == null) return -1;
		return Std.parseInt(versionText);
	}
	
	/**
	 * データ初期化
	 */
	public function createAllDefault():Void
	{
		for (key in LocalStorageKey.KEY_LIST()) {
			createDefault(key);
		}
	}
	
	/**
	 * データロード
	 */
	public function loadAllValue():Void
	{
		for (key in LocalStorageKey.KEY_LIST()) {
			loadData(key);
		}
	}
	
	/**
	 * コールバックの設定
	 */
	public function setCallback(callbackStorageChange:String -> Void):Void
	{
		this.callbackStorageChange = callbackStorageChange;
	}
	
	/*
	 * ストレージ内容に変更があった場合の処理（このインスタンスで書き換えが合った場合も含む）
	 */
	private function window_storageHandler(event:Event):Void
	{
		Note.log("window_storage " + event);
		var storageEvent:StorageEvent = cast(event);
		window_storageHandler_(storageEvent.key);
	}
	private function window_storageHandler_(key:String):Void
	{
		loadData(key);
		if (callbackStorageChange != null) callbackStorageChange(key);
	}
	
	
	/**
	 * ブロック解除を開始する
	 */
	public function startUnblock(unblockTime:Float):Void
	{
		var date:Date = Date.now();
		var nextUnblockState:UnblockState = new UnblockState();
		nextUnblockState.isUnblock = true;
		if (unblockState.isUnblock){	// 既にブロック解除されている場合は、終了時間の延長だけを行う
			// 経過時間を取得
			var passing:Float = unblockState.switchTime - date.getTime();
			// 設定時間と足して、解除時間として代入
			nextUnblockState.unblockTime = passing + unblockTime;
			// 後は一緒
			nextUnblockState.switchTime = unblockState.switchTime;
			nextUnblockState.yesterdayUnblockTotal = unblockState.yesterdayUnblockTotal;
			nextUnblockState.todayUnblockTotal = unblockState.todayUnblockTotal;
		}else {	// 延長でなく新規の場合、switchTimeのとトータル時間の更新もする
			var totalTimeKit:TotalTimeKit = calcTotalTime(date);
			// 現在がswitchTime
			nextUnblockState.switchTime = date.getTime();
			nextUnblockState.yesterdayUnblockTotal = totalTimeKit.yesterday;
			nextUnblockState.todayUnblockTotal = totalTimeKit.today;
			nextUnblockState.unblockTime = unblockTime;
		}
		// 上書き
		unblockState = nextUnblockState;
		flushItem(LocalStorageKey.UNBLOCK_STATE);	// Storageへ反映
	}
	
	/**
	 * ブロック解除を終了する
	 */
	public function endUnblock():Void
	{
		unblockState = createEndUnblockState(Date.now());
		flushItem(LocalStorageKey.UNBLOCK_STATE);	// Storageへ反映
	}
	
	/**
	 * ブロック解除が終了しないかどうかチェックする
	 * @return Unblockならtrue
	 */
	public function checkUnblock():Bool
	{
		if (!unblockState.isUnblock) return false;
		var date:Date = Date.now();
		var endTime:Float = unblockState.switchTime + unblockState.unblockTime;
		// 終了しているかチェック
		if (date.getTime() < endTime){
			return true;	// まだ終了していないなら、trueを返す
		}
		// 終了していた場合、終了したのは今ではなく少し前なはずなので、その時間でdateを作り、TotalTimeを計算
		var endDate:Date = Date.fromTime(endTime);
		// unblockStateを作る
		unblockState = createEndUnblockState(endDate);
		flushItem(LocalStorageKey.UNBLOCK_STATE);	// Storageへ反映
		// 結果を返す
		return false;
	}
	
	/*
	 * ブロック解除終了のデータを生成する
	 */
	private function createEndUnblockState(endDate:Date):UnblockState
	{
		var totalTimeKit:TotalTimeKit = calcTotalTime(endDate);
		unblockState = new UnblockState();
		unblockState.isUnblock = false;
		unblockState.switchTime = endDate.getTime();
		unblockState.yesterdayUnblockTotal = totalTimeKit.yesterday;
		unblockState.todayUnblockTotal = totalTimeKit.today;
		unblockState.unblockTime = -1;
		return unblockState;
	}
	
	/*
	 * 前日と当日の解除時間を出す
	 * unblockStateが更新される場合は、「今」ではなく切り替わりがあった時間を使用すること
	 * リアルタイム時間を算出する場合は今でいい。
	 */
	private function calcTotalTime(date:Date):TotalTimeKit
	{
		var ans:TotalTimeKit = {yesterday:0, today:0}
		// 前回の更新時間を取得
		var lastDate:Date = Date.fromTime(unblockState.switchTime);
		// 日付の変動があったかどうか
		var isSameDay:Bool = (lastDate.getDay() == date.getDay());
		// 場合分け
		if (unblockState.isUnblock){
			if (isSameDay){
				// 日付またぎなし、ブロック解除中
				// 今日の合計は、それまでの合計と、今現在進行中の数値を足す
				var nowUnblockTimeTotal:Float = date.getTime() - unblockState.switchTime;
				ans.today = unblockState.todayUnblockTotal + nowUnblockTimeTotal;
				ans.yesterday = unblockState.yesterdayUnblockTotal;
			}else{
				// 日付またぎありyear : Int, month : Int, day : Int, hour : Int, min : Int, sec : Int
				var today0HourTime:Float = new Date(date.getFullYear(), date.getMonth(), date.getDate(), 0, 0, 0).getTime();
				ans.yesterday = unblockState.todayUnblockTotal + today0HourTime - unblockState.switchTime;
				ans.today = date.getTime() - today0HourTime;
			}
		}else{
			if (isSameDay){
				// 単純パターン（日付またぎ無し、ブロック中）
				ans.yesterday = unblockState.yesterdayUnblockTotal;
				ans.today = unblockState.todayUnblockTotal;
			}else{
				// 日付またぎあり、ブロック中
				ans.yesterday = unblockState.todayUnblockTotal;
				ans.today = 0;
			}
		}
		return ans;
	}
	
}
typedef TotalTimeKit = {
	today:Float,
	yesterday:Float
}

