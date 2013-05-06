package ;
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
	private var lastBlockUrl(default, set):String;
	private function set_lastBlockUrl(value:String):Void
	{
		lastBlockUrl = value;
		storage.setItem(LocalStorageKey.LAST_BLOCK_URL, lastBlockUrl);
	}
	/** ブロック解除の選択時間リスト */
	private var unblockMinutesList:String;
	/** ブロック解除選択時間のデフォルト選択 */
	private var unblockMinutesDefault(default, set):Int;
	/** ブロック解除状態の情報 */
	private var unblockState(default, null):UnblockState;
	/** ホワイトリスト */
	private var whitelist:Array<String>;
	/** ホワイトリストを正規表現で行うかどうか */
	private var whitelistUseRegexp(default, set):Bool;
	/** ブラックリスト */
	private var blacklist:Array<String>;
	/** ブラックリストを正規表現で行うかどうか */
	private var blacklistUseRegexp(get, set):Bool;
	/** あとで見るリスト */
	private var laterList(default, null):Array<String>;
	private function addLaterList(value:String):Void
	{
		laterList.push(value);
		setJsonItem(LocalStorageKey.LAST_BLOCK_URL, laterList);
	}
	private function removeLaterList(value:String):Void
	{
		laterList.remove(value);
		setJsonItem(LocalStorageKey.LAST_BLOCK_URL, laterList);
	}
	
	/* --------------------------------
	 * 共通処理
	 */
	
	private function setJsonItem(key:String, value:Dynamic):Void
	{
		storage.setItem(key, Json.stringify(value));
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
	public function createDefaultValue():Void
	{
		
	}
	
	/**
	 * データロード
	 */
	public function loadValue():Void
	{
		lastBlockUrl = storage.getItem(LocalStorageKey.)
	}
}
