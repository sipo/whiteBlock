package ;
import chrome.Tab;
import String;
import chrome.Extension;
import chrome.Tabs;
class Background 
{
	public static var background:Background;
	public static var tabs:Class<Tabs> = untyped chrome.tabs;
	
	
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
		Tabs.onUpdated.addListener(function (tabId:Int, changedInfo:UpdateInfo, tab:Tab){
//			js.Lib.alert("ok2");
//			trace("ok2");
			var blockUrl:String = Extension.getURL("block.html");
			if (tab.url == blockUrl) return;
			Tabs.update(tabId, {url:blockUrl}, function (tab:Tab) {});
		});
	}
	
}
