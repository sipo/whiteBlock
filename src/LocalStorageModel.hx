package ;
import Std;
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
	
	
	/* ================================================================
	 * 処理
	 */
	
	/**
	 * コンストラクタ
	 */
	public function new()
	{
		// ストレージを用意
		var window:DOMWindow = Browser.window;
		var storage:Storage = window.localStorage;
		storageDetail = new LocalStorageDetail(storage);
		// データの初期化などが起きた場合のフラグ
		var isFirstChange:Bool = false;
		// データバージョンを取得
		var version:Int = storageDetail.getVersion();
		// データが存在しない場合、初期化
		if (version == -1){
			storageDetail.createDefaultValue();
			trace("ストレージデータを生成しました");
			version = storageDetail.getVersion();
			isFirstChange = true;
		}
		// データが古い場合、バージョンに応じた変換処理
		if (version < STORAGE_VERSION){
			// まだなし
			version = storageDetail.getVersion();
			isFirstChange = true;
		}
		// データのほうが新しければ、エラーで落ちる。再インストールで消さないといけないかも
		// 頻出するようなら、バックアップデータを表示する仕組みが必要。
		if (STORAGE_VERSION < version){
			storageDetail.createDefaultValue();
			version = storageDetail.getVersion();
			isFirstChange = true;
			throw "保存されているデータに対して、古いバージョンのエクステンションが使用されました。";
		}
		// 値をロードする
		storageDetail.loadValue();
		// イベント登録
		window.addEventListener("storage", changeStorage);
		// データの初期化があったのであれば、強制的に変更メソッドを呼ぶ
		if (isFirstChange) allChangeStorage();
	}
	
	/*
	 * 初期データの生成
	 */
	private function createDefaultStorage():Void
	{
		// TODO:
		 
	}
	
	/*
	 * ストレージ内容に変更有った場合の処理（このインスタンスで書き換えが合った場合も含む）
	 */
	private function window_storage(event:StorageEvent):Void
	{
		trace("window_storage");
		trace(event);
		// TODO:
	}
}
