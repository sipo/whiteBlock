package commonView;
import js.JQuery;
class TimeManager {


	/*
	 * 時間の文字列表示
	 */
	public static function displayText(time:Float, useSeconds:Bool):String
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
}
