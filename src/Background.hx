package ;
import js.JQuery;
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
		Tabs.onUpdated.addListener(tab_updated);
	}
	
	/*
	 * タブの更新時
	 */
	private function tab_updated(tabId:Int, changedInfo:UpdateInfo, tab:Tab):Void
	{
		trace("tab_updated");
		trace(tab.url);
		// ブロックページのURlを取得
		var blockUrl:String = Extension.getURL("block.html");
		// 除外処理
		if (tab.url == blockUrl){
			trace("ブロックページなので循環を防ぐために除外");
			return;
		}
		var isWeb:EReg = ~/^(http:)|(https:)/;
		if (!isWeb.match(tab.url)){
			trace("webページじゃない場合除外");	// あとで、httpsはオプション設定にするべきかも
			return;
		}
		if (tab.url != "http://b.hatena.ne.jp/tail_y/"){
			trace("is not test");	// とりあえずテストページに限定する
			return;
		}
		// ページをブロックする
		Tabs.update(tabId, {url:blockUrl}, afterBlock);
	}
	
	/*
	 * ブロック後動作
	 */
	private function afterBlock(tab:Tab):Void
	{
		trace("afterBlock");
//		Tabs.sendMessage(tab.id, );
	}
}
