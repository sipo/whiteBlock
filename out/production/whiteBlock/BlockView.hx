package ;
import LocalStorageDetail.Page;
import commonView.UnblockTimeDownList;
import js.JQuery;
class BlockView {
	
	/* Blockページ */
	private var block:Block;
	
	/* データ本体。ここで操作したらダメ（本来は依存を消すべきだけど、とりあえず規約で止める） */
	private var localStorageDetail:LocalStorageDetail;
	
	/* --------------------------------
	 * パーツ（JQueryは対象の種類情報が消失するため、変数に種類情報を付与）
	 */
	
	private var title_text:JQuery;	// タイトル表示
	private var url_text:JQuery;	// url表示
	
	private var addLaterList_clickable:JQuery;	// あとで見る追加ボタン
	
	private var unblock_clickable:JQuery;         // ブロック解除開始リンク
	private var unblockTime:UnblockTimeDownList;     // ブロック解除する時間
	private var blockTime_text:JQuery;     // ブロック解除する時間
	
	private var addWhiteList_clickable:JQuery;	// ホワイトリスト追加ボタン
	private var addWhitelistText_input:JQuery;	// ホワイトリスト追加文字フィールド
	
	/* --------------------------------
	 * DOMパラメータ
	 */
	
	private static inline var ADD_WHITELIST_TEXT_MAX_SIZE:Int = 100;
	
	public function new(block:Block)
	{
		this.block = block;
	}
	
	/**
	 * 初期化指示
	 */
	public function initialize()
	{
		// DOMの初期化
		addLaterList_clickable = new JQuery("#addLaterList");
		
		blockTime_text = new JQuery("#blockTime");
		unblockTime = new UnblockTimeDownList(new JQuery("#unblockTime"));
		unblock_clickable = new JQuery("#unblock");
		
		addWhiteList_clickable = new JQuery("#addWhiteList");
		addWhitelistText_input = new JQuery("#addWhitelistText");
		
		// イベントの登録
		unblock_clickable.click(unblock_clickHandler);
	}
	
	/**
	 * 描画
	 */
	public function draw(lastBlockPage:Page):Void
	{
		// 最後にアクセスしたURLを候補に
		var url:String = lastBlockPage.url;
		addWhitelistText_input.val(url);
		// フィールドの長さをURLに合わせる。ただし、大きくなり過ぎないように
		var fieldSize:Int = url.length;
		if (ADD_WHITELIST_TEXT_MAX_SIZE < fieldSize) fieldSize = ADD_WHITELIST_TEXT_MAX_SIZE;
		addWhitelistText_input.attr("size", cast(fieldSize));
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
		block.startUnblock(unblockTime.getValue());
	}
	
	/*
	 * ホワイトリストに追加し、画面遷移
	 */
	private function addWhiteList_clickHandler(event:JqEvent):Void
	{
		Note.log("addWhiteList_clickHandler");
		block.addWhiteList(addWhitelistText_input.val());
	}
}
//OptionViewを真似するところから
