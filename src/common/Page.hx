package common;
class Page {
	
	/** タイトル */
	private var title:String;
	/** URL */
	private var url:String;
	
	public function new(title:String, url:String)
	{
		this.title = title;
		this.url = url;
	}
	
	public function clone():Page
	{
		return new Page(title, url);
	}
	
	/**
	 * クローンを配列で返す
	 */
	public static function arrayClone(list:Array<Page>):Array<Page>
	{
		return [for (i in 0...list.length) list[i].clone()];
	}
	
	/**
	 * Jsonから作る
	 */
	public static function createFromJson(jsonData:Dynamic):Page
	{
		return new Page(jsonData.title, jsonData.url);
	}
	
	/**
	 * Jsonから配列を作る
	 */
	public static function createArrayFromJson(jsonData:Dynamic):Array<Page>
	{
		var ans:Array<Page> = [];
		for (i in 0...jsonData.length) {
			ans.push(new Page(jsonData[i].title, jsonData[i].url));
		}
		return ans;
	}
	
	/** エスケープタイトル */
	public var escapeTitle(get, null):String;
	public function get_escapeTitle():String
	{
		return StringTools.htmlEscape(title);
	}
	/** エスケープURL */
	public var escapeUrl(get, null):String;
	public function get_escapeUrl():String
	{
		return StringTools.htmlEscape(url);
	}
}
