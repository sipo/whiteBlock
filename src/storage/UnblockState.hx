package storage;
import haxe.Json;
import Std;
class UnblockState 
{
	/** アンブロック中かどうか */
	public var isUnblock:Bool;
	
	/** 今日のアンブロック時間合計（現在アンブロック中の場合、それを含まない） */
	public var todayUnblockTotal:Float;
	/** 昨日のアンブロック時間合計 */
	public var yesterdayUnblockTotal:Float;
	/** isUnblockが最後に切り替わった時間（ブロック中ならブロック開始時間、アンブロック中はアンブロック開始時間。延長の場合は切り替わっt事にしない） */
	public var switchTime:Float;
	
	/* --------------------------------
	 * アンブロック中
	 */
	
	/** 設定されたアンブロック期間（ミリ秒） */
	public var unblockTime:Float;
	
	/* ================================================================
	 * 処理
	 */
	
	/**
	 * コンストラクタ
	 */
	public function new()
	{
		isUnblock = false;
		todayUnblockTotal = 0;
		yesterdayUnblockTotal = -1;
		switchTime = Date.now().getTime();
		unblockTime = 0;
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
	public static function createFromJson(jsonText:String):UnblockState
	{
		var jsonData:Dynamic = Json.parse(jsonText);
		var ans:UnblockState = new UnblockState();
		ans.isUnblock = jsonData.isUnblock;
		ans.todayUnblockTotal = Std.parseFloat(jsonData.todayUnblockTotal);
		ans.yesterdayUnblockTotal = Std.parseFloat(jsonData.yesterdayUnblockTotal);
		ans.switchTime = Std.parseFloat(jsonData.switchTime);
		ans.unblockTime = Std.parseFloat(jsonData.unblockTime);
		return ans;
	}
	
	/**
	 * 複製を返す
	 */
	public function clone():UnblockState
	{
		var ans:UnblockState = new UnblockState();
		ans.isUnblock = isUnblock;
		ans.todayUnblockTotal = todayUnblockTotal;
		ans.yesterdayUnblockTotal = yesterdayUnblockTotal;
		ans.switchTime = switchTime;
		ans.unblockTime = unblockTime;
		return ans;
	}
}
