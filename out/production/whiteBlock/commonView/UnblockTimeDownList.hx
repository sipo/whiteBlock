package commonView;
import haxe.Template;
import js.JQuery;
/*
 * オプション部分の置き換え設定
 */
private typedef OptionContext = {
	time:String,
	text:String
}
class UnblockTimeDownList {
	
	/* パーツ */
	private var dom:JQuery;
	/* オプションのHTML構成 */
	private var optionTemplate:Template;
	
	public function new(dom:JQuery)
	{
		this.dom = dom;
		optionTemplate = new Template(dom.html());
		dom.html("");
	}
	
	/**
	 * 描画
	 */
	public function draw(timeList:Array<Float>, defaultIndex:Int):Void
	{
		// ブロック解除時間のリストを描画
		var innerHtml:String = "";
		for (unblockTimeI in 0...timeList.length) {
			var value = timeList[unblockTimeI];
			var context:OptionContext = {time:Std.string(value), text:TimeManager.displayText(value, false)};
			innerHtml += optionTemplate.execute(context);
		}
		dom.html(innerHtml);	// html描画
		dom.val(Std.string(timeList[defaultIndex]));	// デフォルト選択
	}
	
	/**
	 * 値の取得
	 */
	public function getValue():Float
	{
		return Std.parseFloat(dom.val());
	}
}
// unblockTimeList[localStorageDetail.unblockTimeDefaultIndex])
