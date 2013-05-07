package ;
import Std;
import String;
import Std;
import haxe.Json;
import js.html.Storage;
class LocalStorageDetail {
	
	/* ローカルストレージ本体 */
	private var storage:Storage;
	
	/** ストレージデータのバージョン（将来に備えて） */
	public static inline var STORAGE_VERSION:Int = 1;
	
	/* ================================================================
	 * 実データと、設定
	 */
	
	/** 最後に開いたURL。正直これをLocalStorageでやり取りすると、複数タブを開いた時にバグると思うのだけど、今のところ他のやり方がわからない・・・。 */
	public var lastBlockUrl(default, set):String;
	private function set_lastBlockUrl(value:String):String
	{
		lastBlockUrl = value;
		flushItem(LocalStorageKey.LAST_BLOCK_URL);	// Storageへ反映
		return lastBlockUrl;
	}
	
	/** ブロック解除の選択時間リスト */
	private var unblockTimeList:Array<Float>;
	private function getUnblockTimeList():Array<Float>
	{
		return unblockTimeList.copy();	// クローンを返し、参照に触らせない
	}
	private function setUnblockTimeList(value:Array<Float>):Void
	{
		unblockTimeList = value;	// 性質上、上書き
		flushItem(LocalStorageKey.UNBLOCK_TIME_LIST);	// Storageへ反映
	}
	
	/** ブロック解除選択時間のデフォルト選択のインデックス番号 */
	public var unblockTimeDefaultIndex(default, set):Int;
	private function set_unblockTimeDefaultIndex(value:Int):Int
	{
		unblockTimeDefaultIndex = value;
		flushItem(LocalStorageKey.UNBLOCK_TIME_DEFAULT_INDEX);	// Storageへ反映
		return unblockTimeDefaultIndex;
	}
	
	/** ブロック解除状態の情報 */
	private var unblockState:UnblockState;
	private function getUnblockState():UnblockState
	{
		return unblockState.clone();	// クローンを返し、参照に触らせない
	}
	private function setUnblockState(value:UnblockState):Void
	{
		unblockState = value;	// 性質上、上書き
		flushItem(LocalStorageKey.UNBLOCK_STATE);	// Storageへ反映
	}
	
	/** ホワイトリスト */
	public var whitelist:Array<String>;
	private function getWhitelist():Array<String>
	{
		return whitelist.copy();	// クローンを返し、参照に触らせない
	}
	private function setWhitelist(value:Array<String>):Void
	{
		whitelist = value;	// 性質上、上書き
		flushItem(LocalStorageKey.WHITELIST);	// Storageへ反映
	}
	
	/** ホワイトリストを正規表現で行うかどうか */
	public var whitelistUseRegexp(default, set):Bool;
	private function set_whitelistUseRegexp(value:Bool):Bool
	{
		whitelistUseRegexp = value;
		flushItem(LocalStorageKey.WHITELIST_USE_REGEXP);	// Storageへ反映
		return whitelistUseRegexp;
	}
	
	/** ブラックリスト */
	private var blacklist:Array<String>;
	private function getBlacklist():Array<String>
	{
		return blacklist.copy();	// クローンを返し、参照に触らせない
	}
	private function setBlacklist(value:Array<String>):Void
	{
		blacklist = value;	// 性質上、上書き
		flushItem(LocalStorageKey.BLACKLIST);	// Storageへ反映
	}
	
	/** ブラックリストを正規表現で行うかどうか */
	public var blacklistUseRegexp(default, set):Bool;
	private function set_blacklistUseRegexp(value:Bool):Bool
	{
		blacklistUseRegexp = value;
		flushItem(LocalStorageKey.BLACKLIST_USE_REGEXP);	// Storageへ反映
		return blacklistUseRegexp;
	}
	
	/** あとで見るリスト */
	private var laterList:Array<String>;
	private function getLaterList():Array<String>
	{
		return laterList.copy();	// クローンを返し、参照に触らせない
	}
	private function addLaterList(value:String):Void
	{
		laterList.push(value);	// 追加
		flushItem(LocalStorageKey.LATER_LIST);	// Storageへ反映
	}
	private function removeLaterList(value:String):Void
	{
		laterList.remove(value);	// 削除
		flushItem(LocalStorageKey.LATER_LIST);	// Storageへ反映
	}
	
	/* --------------------------------
	 * 共通処理
	 */
	
	/* キーに対応した値を、Storageに反映する */
	private function flushItem(key:String):Void
	{
		switch(key){
			case LocalStorageKey.LAST_BLOCK_URL:
				storage.setItem(key, lastBlockUrl);
			case LocalStorageKey.UNBLOCK_TIME_LIST:
				setJsonItem(key, unblockTimeList);
			case LocalStorageKey.UNBLOCK_TIME_DEFAULT_INDEX:
				setIntItem(key, unblockTimeDefaultIndex);
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
	}
	/* JSONに変換してからStorageに反映する */
	private function setJsonItem(key:String, value:Dynamic):Void
	{
		storage.setItem(key, Json.stringify(value));
	}
	/* Boolを文字に変換してからStorageに反映する */
	private function setBoolItem(key:String, value:Bool):Void
	{
		storage.setItem(key, if (value) "true" else "false");
	}
	/* Intを文字に変換してからStorageに反映する */
	private function setIntItem(key:String, value:Int):Void
	{
		storage.setItem(key, Std.string(unblockTimeDefaultIndex));
	}
	
	
	/* キーに対応した値を、Storageからロードする */
	private function loadData(key:String):Void
	{
		// TODO:
		switch(key){
			case LocalStorageKey.LAST_BLOCK_URL:
				lastBlockUrl = storage.getItem(key);
			case LocalStorageKey.UNBLOCK_TIME_LIST:
				unblockTimeList = getArrayFloat(key);
			case LocalStorageKey.UNBLOCK_TIME_DEFAULT_INDEX:
				unblockTimeDefaultIndex;
			case LocalStorageKey.UNBLOCK_STATE:
				unblockState;
			case LocalStorageKey.WHITELIST:
				whitelist = getArrayString(key);
			case LocalStorageKey.WHITELIST_USE_REGEXP:
				whitelistUseRegexp;
			case LocalStorageKey.BLACKLIST:
				blacklist;
			case LocalStorageKey.BLACKLIST_USE_REGEXP:
				blacklistUseRegexp;
			case LocalStorageKey.LATER_LIST:
				laterList;
			default :
				throw "対応していない値です key=" + key;
		}
	}
	/* Storageから、配列に変換して取得する */
	private function getArrayFloat(key:String):Array<Float>
	{
		var list:Dynamic = Json.parse(storage.getItem(key));
		return [for (i in 0...list.length) Std.parseFloat(list[i])];
	}
	/* Storageから、配列に変換して取得する */
	private function getArrayString(key:String):Array<String>
	{
		return [];
	}
	
	private function createDefault(key:String):Void
	{
		switch(key){
			case LocalStorageKey.LAST_BLOCK_URL:
				lastBlockUrl = null;
			case LocalStorageKey.UNBLOCK_TIME_LIST:
				unblockTimeList = [
					3 * 60 * 1000,
					5 * 60 * 1000,
					10 * 60 * 1000,
					20 * 60 * 1000,
					30 * 60 * 1000,
					60 * 60 * 1000
				];
			case LocalStorageKey.UNBLOCK_TIME_DEFAULT_INDEX:
				unblockTimeDefaultIndex = 2;
			case LocalStorageKey.WHITELIST:
				whitelist = [
					"https://www.google.co.jp/search",
					"https://www.google.co.jp/calendar",
					"https://www.google.co.jp/map",
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
	public function new(storage:Storage):Void
	{
		this.storage = storage;
	}
	
	/**
	 * バージョンの取得
	 */
	public function getVersion():Int
	{
		var versionText:String = storage.getItem(LocalStorageKey.VERSION);
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
}
