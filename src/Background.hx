package ;
import chrome.Tabs;
class Background 
{
	private static var background:Background;
	
	/**
	 * 起点
	 */
	public static function main():Void
	{
		background = new Background();
	}
	
	/**
	 * コンストラクタ
	 */
	public function new()
	{
		Tabs.onUpdated.addListener(function (tabId, changedInfo, tab){
//			Tabs.update(tabId, {"url":ext});
		});
//		Extension.
	}
}
