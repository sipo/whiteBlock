package ;
import chrome.Tabs;
class Background 
{
	
	/**
	 * 起点
	 */
	public static function main():Void
	{
//		chrome.remoting.tabs.onUpdated.addListener(
//			function(tabId, changedInfo, tab){
//				js.Lib.alert("ok");
//			}
//		);
		Tabs.onUpdated.addListener(function (tabId, changedInfo, tab){
			js.Lib.alert("ok");
		});
	}
	
	/**
	 * コンストラクタ
	 */
	public function new()
	{
		
	}
}
