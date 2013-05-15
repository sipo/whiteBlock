package ;
/**
 * traceを閉じ込め、その使用意図を明確化するためのクラス
 * 
 * @author sipo
 */
class Note {
	public function new()
	{
	}
	
	/**
	 * comment
	 */
	public static function log(message:Dynamic):Void
	{
		trace(message);
	}
	
	/**
	 * comment
	 */
	public static function debug(message:Dynamic):Void
	{
		trace("D\t" + message);
	}
}
