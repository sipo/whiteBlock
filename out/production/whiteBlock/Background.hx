package ;
import String;
import chrome.Extension;
import chrome.Tabs;
class Background 
{
	public static var background:Background;
	public var tabs:Class<Tabs> = Tabs;
	
	/**
	 * 起点
	 */
	public static function main():Void
	{
		background = new Background();
		trace("ok1");
		trace(Tabs);
	}
	
	/**
	 * コンストラクタ
	 */
	public function new()
	{
		trace("ok3");
		trace(Tabs);
		trace(untyped chrome.tabs);
//		Tabs.onUpdated.addListener(function (tabId, changedInfo, tab){
////			js.Lib.alert("ok2");
////			trace("ok2");
//			var blockUrl:String = Extension.getURL("block.html");
//			Tabs.update(tabId, {url:blockUrl}, function (tab:Tab) {});
//		});
		run();
	}
	
	/**
	 * 動作
	 */
	public function run():Void
	{
		trace("ok4");
		trace(Tabs);
		
	}
}
