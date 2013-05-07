package ;
class LocalStorageKey {
	public static inline var VERSION:String = "version";
	public static inline var LAST_BLOCK_URL:String = "lastBlockUrl";
	public static inline var UNBLOCK_TIME_LIST:String = "unblockTimeList";
	public static inline var UNBLOCK_TIME_DEFAULT_INDEX:String = "unblockTimeDefaultIndex";
	public static inline var UNBLOCK_STATE:String = "unblockState";
	public static inline var WHITELIST:String = "whitelist";
	public static inline var WHITELIST_USE_REGEXP:String = "whitelistUseRegexp";
	public static inline var BLACKLIST:String = "blacklist";
	public static inline var BLACKLIST_USE_REGEXP:String = "blacklistUseRegexp";
	public static inline var LATER_LIST:String = "laterList";
	
	public static inline function KEY_LIST():Array<String>{
		return [
			LAST_BLOCK_URL,
			UNBLOCK_TIME_LIST,
			UNBLOCK_TIME_DEFAULT_INDEX,
			UNBLOCK_STATE,
			WHITELIST,
			WHITELIST_USE_REGEXP,
			BLACKLIST,
			BLACKLIST_USE_REGEXP,
			LATER_LIST
		];
	}
}
