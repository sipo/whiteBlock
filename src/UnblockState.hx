package ;
import Std;
class UnblockState 
{
	/** アンブロック中かどうか */
	public var isUnblock:Bool;
	
	/** 今日のアンブロック時間合計 */
	public var todayBlockTotal:Float;
	/** 今日のアンブロック時間合計 */
	public var yesterdayBlockTotal:Float;
	
	/* --------------------------------
	 * アンブロック中
	 */
	
	/** アンブロックを開始した時間 */
	public var startUnblockTime:Float;
	
	/** 設定されたアンブロック期間（ミリ秒） */
	public var unblockTime:Float;
	
	/* --------------------------------
	 * ブロック中
	 */
	
	/** ブロックを開始した時間 */
	public var startBlockTime:Float;
	
	/* ================================================================
	 * 処理
	 */
	
	/**
	 * コンストラクタ
	 */
	private function new()
	{
		isUnblock = false;
		todayBlockTotal = 0;
		yesterdayBlockTotal = 0;
		startUnblockTime = 0;
		unblockTime = 0;
		startBlockTime = 0;
	}
	
	/**
	 * 初期値を生成
	 */
	public static function createDefault():UnblockState
	{
		return new UnblockState();
	}
	
	/**
	 * Jsonからインスタンスを生成
	 */
	public static function createFromJson(jsonData:Dynamic):UnblockState
	{
		var ans:UnblockState = new UnblockState();
		ans.isUnblock = jsonData.isUnblock == "true";
		ans.todayBlockTotal = Std.parseFloat(jsonData.todayBlockTotal);
		ans.yesterdayBlockTotal = Std.parseFloat(jsonData.yesterdayBlockTotal);
		ans.startUnblockTime = Std.parseFloat(jsonData.startUnblockTime);
		ans.unblockTime = Std.parseFloat(jsonData.unblockTime);
		ans.startBlockTime = Std.parseFloat(jsonData.startBlockTime);
		return ans;
	}
	
	/**
	 * 複製を返す
	 */
	public function clone():UnblockState
	{
		var ans:UnblockState = new UnblockState();
		ans.isUnblock = isUnblock;
		ans.todayBlockTotal = todayBlockTotal;
		ans.yesterdayBlockTotal = yesterdayBlockTotal;
		ans.startUnblockTime = startUnblockTime;
		ans.unblockTime = unblockTime;
		ans.startBlockTime = startBlockTime;
		return ans;
	}
}
