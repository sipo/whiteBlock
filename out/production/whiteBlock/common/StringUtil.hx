package common;
import js.JQuery;
class StringUtil {


	/*
	 * 時間の文字列表示
	 */
	public static function timeDisplay(time:Float, useSeconds:Bool):String
	{
		var seconds:Int = Std.int(time / 1000) % 60;
		var minutes:Int = Std.int(time / 1000 / 60) % 60;
		var hours:Int = Std.int(time / 1000 / 60 / 60);
//		return hours + ":" + minutes;
		if (hours == 0){
			if (useSeconds) return minutes + "分" + seconds + "秒";
			return minutes + "分";
		}
		if (minutes == 0){
			return hours + "時間";
		}
		return hours + "時間" + minutes + "分";
	}
	
	/** ドットの数 */
	public static inline var DOT_NUM:Int = 3;
	public static inline var DOTS:String = "...";
	/*
	 * 長すぎる文字を AAA... の形に 
	 */
	public static function limit(original:String, max:Int):String
	{
		if (original.length <= max) return original;
		return original.substr(0, max - DOT_NUM) + DOTS;
	}
}
