package ;
import js.html.Event;
import Std;
import js.Browser;
import js.html.StorageEvent;
import js.html.Storage;
import js.html.DOMWindow;
class LocalStorageModel 
{
	/* ================================================================
	 * 基本変数
	 */
	
	/* 実際に保存を行うストレージ */
	private var storageDetail:LocalStorageDetail;
	
	/** 必ずデータをクリアするデバッグ挙動 */
	public static inline var DEBUG_CLEAR_DATA:Bool = true;
	
	/* Storageデータに変更が合った場合に返すコールバック */
	private var callbackStorageChange:String -> Void;
	
	/* ================================================================
	 * 処理
	 */
	
	/**
	 * コンストラクタ
	 */
	public function new(callbackStorageChange:String -> Void)
	{
		this.callbackStorageChange = callbackStorageChange;
		// ストレージを用意
		var window:DOMWindow = Browser.window;
		var storage:Storage = Browser.getLocalStorage();
		storageDetail = new LocalStorageDetail(storage);
		// データの初期化などが起きた場合のフラグ
		var isFirstChange:Bool = false;
		// データバージョンを取得
		var version:Int = storageDetail.getVersion();
		// データが存在しない場合、初期化
		if (version == -1 || DEBUG_CLEAR_DATA){
			storageDetail.createAllDefault();
			trace("ストレージデータを生成しました");
			version = storageDetail.getVersion();
			isFirstChange = true;
		}
		// データが古い場合、バージョンに応じた変換処理
		if (version < LocalStorageDetail.STORAGE_VERSION){
			// まだなし
			version = storageDetail.getVersion();
			isFirstChange = true;
		}
		// データのほうが新しければ、エラーで落ちる。再インストールで消さないといけないかも
		// 頻出するようなら、バックアップデータを表示する仕組みが必要。
		if (LocalStorageDetail.STORAGE_VERSION < version){
			storageDetail.createAllDefault();
			version = storageDetail.getVersion();
			isFirstChange = true;
			throw "保存されているデータに対して、古いバージョンのエクステンションが使用されました。";
		}
		// 値をロードする
		storageDetail.loadAllValue();
		// イベント登録
		window.addEventListener("storage", window_storage);
		// データの初期化があったのであれば、強制的に変更メソッドを呼ぶ
		if (isFirstChange) allChangeStorage();
	}
	
	
	/*
	 * ストレージ内容に変更があった場合の処理（このインスタンスで書き換えが合った場合も含む）
	 */
	private function window_storage(event:Event):Void
	{
		var storageEvent:StorageEvent = cast(event);
		trace("window_storage");
		trace(event);
		// TODO:
		window_storage_(storageEvent.key);
	}
	private function window_storage_(key:String):Void
	{
		trace("window_storage_" + key)
		if (callbackStorageChange != null) callbackStorageChange(key);
	}
	
	/*
	 * 全てのストレージの内容に変更があったというイベントを起動する
	 */
	private function allChangeStorage():Void
	{
		// TODO:
	}
}
