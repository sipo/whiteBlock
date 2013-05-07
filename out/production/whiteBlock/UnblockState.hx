package ;
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
