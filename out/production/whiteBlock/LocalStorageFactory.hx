package ;
import js.html.Event;
import Std;
import js.Browser;
import js.html.StorageEvent;
import js.html.Storage;
import js.html.DOMWindow;
/**
 * storageDetailの準備と、storageイベントの通知を担当する
 * Viewからここを経由して値を参照するのはOK
 * 
 * @author sipo
 */
class LocalStorageFactory 
{
	/* ================================================================
	 * 基本変数
	 */
	
	/** 必ずデータをクリアするデバッグ挙動 */
	public static inline var DEBUG_CLEAR_DATA:Bool = false;
 
	/* ================================================================
	 * 処理
	 */
	
	/**
	 * コンストラクタ
	 */
	public function new()
	{
	}
	
	/**
	 * detailの生成
	 */
	public function create(callbackStorageChange:String -> Void):LocalStorageDetail
	{
		// ストレージを用意
		var storageDetail:LocalStorageDetail = new LocalStorageDetail(Browser.getLocalStorage(), Browser.window);
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
		storageDetail.setCallback(callbackStorageChange);
		// データの初期化があったのであれば、強制的に変更メソッドを呼ぶ
//		if (isFirstChange) storageDetail.callAllChangeStorage();
		return storageDetail;
	}
	
	
}
