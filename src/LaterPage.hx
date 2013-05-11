package ;
class LaterPage {
	
	/** タイトル */
	public var title:String;
	/** URL */
	public var url:String;
	
	public function new(title:String, url:String)
	{
		this.title = title;
		this.url = url;
	}
	
	public function clone():LaterPage
	{
		return new LaterPage(title, url);
	}
	
	/**
	 * クローンを配列で返す
	 */
	public static function arrayClone(list:Array<LaterPage>):Array<LaterPage>
	{
		return [for (i in 0...list.length) list[i].clone()];
	}
	
	/**
	 * Jsonから配列を作る
	 */
	public static function createArrayFromJson(jsonData:Dynamic):Array<LaterPage>
	{
		var ans:Array<LaterPage> = [];
		for (i in 0...jsonData.length) {
			ans.push(new LaterPage(jsonData[i].title, jsonData[i].url));
		}
		return ans;
	}
}
