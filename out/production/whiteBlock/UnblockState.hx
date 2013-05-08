package ;
import Std;
class UnblockState 
{
	/** アンブロック中かどうか */
	public var isUnblock:Bool;
	
	/** アンブロックを開始した時間 */
	public var startUnblockTime:Float;
	
	/** 設定されたアンブロック期間（ミリ秒） */
	public var unblockTime:Float;
	
	/**
	 * コンストラクタ
	 */
	public function new()
	{
		isUnblock = false;
		startUnblockTime = 0;
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
	public static function createFromJson(jsonData:Dynamic):UnblockState
	{
		var ans:UnblockState = new UnblockState();
		ans.isUnblock = jsonData.isUnblock == "true";
		ans.startUnblockTime = Std.parseFloat(jsonData.startUnblockTime);
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
		ans.startUnblockTime = startUnblockTime;
		ans.unblockTime = unblockTime;
		return ans;
	}
}
