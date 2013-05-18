package ;
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
		trace("optionView initialize");
		// 必要変数
		
		
		unblockTimeList_textArea = new JQuery("#unblockTimeList");
		unblockTimeDefaultIndex = new UnblockTimeDownList(new JQuery("#unblockTimeDefaultIndex"));
		whitelist_textArea = new JQuery("#whitelist");
		whitelistUseRegexp_checkbox = new JQuery("#whitelistUseRegexp");
		blacklist_textArea = new JQuery("#blacklist");
		blacklistUseRegexp_checkbox = new JQuery("#blacklistUseRegexp");
		save_clickable = new JQuery("#save");
	}
	
	
	/* ================================================================
	 * 描画指示
	 */
	
	
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
	
	
}
