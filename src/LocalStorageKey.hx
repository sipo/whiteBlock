package ;
class LocalStorageKey {
	public static inline var VERSION:String = "version";
	public static inline var LAST_BLOCK_URL:String = "lastBlockUrl";
	public static inline var UNBLOCK_MINUTES_LIST:String = "unblockMinutesList";
	public static inline var UNBLOCK_MINUTES_LIST_DEFAULT:String = "unblockMinutesListDefault";
	public static inline var WHITELIST:String = "whitelist";
	
	public static inline function KEY_LIST():Array<String>{
		return [
		LAST_BLOCK_URL,
		UNBLOCK_MINUTES_LIST,
		UNBLOCK_MINUTES_LIST_DEFAULT,
		WHITELIST
		]
	}
}
