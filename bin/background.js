var $estr = function() { return js.Boot.__string_rec(this,''); };
var Background = function() {
	var factory = new LocalStorageFactory();
	this.localStorageDetail = factory.create($bind(this,this.storage_changeHandler),true);
	chrome.tabs.onUpdated.addListener($bind(this,this.tab_updatedHandler));
};
Background.__name__ = true;
Background.main = function() {
	Background.background = new Background();
}
Background.prototype = {
	afterBlock: function(tab) {
		console.log("afterBlock");
	}
	,checkList: function(targetUrl,list,useRegexp) {
		console.log("checkList " + Std.string(list));
		var _g = 0;
		while(_g < list.length) {
			var url = list[_g];
			++_g;
			if(useRegexp) {
				if(new EReg(url,"").match(targetUrl)) {
					console.log("match" + url);
					return true;
				}
			} else if(targetUrl.indexOf(url) != -1) {
				console.log("indexOf" + url);
				return true;
			}
		}
		return false;
	}
	,tab_updatedHandler: function(tabId,changedInfo,tab) {
		console.log("tab_updated");
		var targetUrl = tab.url;
		var blockUrl = chrome.extension.getURL("block.html");
		if(targetUrl == blockUrl) {
			console.log("ブロックページなので循環を防ぐために除外");
			return;
		}
		var isWeb = new EReg("^(http:)|(https:)","");
		if(!isWeb.match(targetUrl)) {
			console.log("webページじゃない場合除外");
			return;
		}
		if(this.checkList(targetUrl,this.localStorageDetail.getWhitelist(),this.localStorageDetail.whitelistUseRegexp)) {
			if(!this.checkList(targetUrl,this.localStorageDetail.getBlacklist(),this.localStorageDetail.blacklistUseRegexp)) return;
		}
		this.localStorageDetail.set_lastBlockUrl(targetUrl);
		chrome.tabs.update(tabId,{ url : blockUrl},$bind(this,this.afterBlock));
	}
	,storage_changeHandler: function(key) {
	}
	,__class__: Background
}
var EReg = function(r,opt) {
	opt = opt.split("u").join("");
	this.r = new RegExp(r,opt);
};
EReg.__name__ = true;
EReg.prototype = {
	match: function(s) {
		if(this.r.global) this.r.lastIndex = 0;
		this.r.m = this.r.exec(s);
		this.r.s = s;
		return this.r.m != null;
	}
	,__class__: EReg
}
var HxOverrides = function() { }
HxOverrides.__name__ = true;
HxOverrides.cca = function(s,index) {
	var x = s.charCodeAt(index);
	if(x != x) return undefined;
	return x;
}
HxOverrides.substr = function(s,pos,len) {
	if(pos != null && pos != 0 && len != null && len < 0) return "";
	if(len == null) len = s.length;
	if(pos < 0) {
		pos = s.length + pos;
		if(pos < 0) pos = 0;
	} else if(len < 0) len = s.length + len - pos;
	return s.substr(pos,len);
}
HxOverrides.remove = function(a,obj) {
	var i = 0;
	var l = a.length;
	while(i < l) {
		if(a[i] == obj) {
			a.splice(i,1);
			return true;
		}
		i++;
	}
	return false;
}
HxOverrides.iter = function(a) {
	return { cur : 0, arr : a, hasNext : function() {
		return this.cur < this.arr.length;
	}, next : function() {
		return this.arr[this.cur++];
	}};
}
var LaterPage = function(title,url) {
	this.title = title;
	this.url = url;
};
LaterPage.__name__ = true;
LaterPage.arrayClone = function(list) {
	return (function($this) {
		var $r;
		var _g = [];
		{
			var _g2 = 0, _g1 = list.length;
			while(_g2 < _g1) {
				var i = _g2++;
				_g.push(list[i].clone());
			}
		}
		$r = _g;
		return $r;
	}(this));
}
LaterPage.createArrayFromJson = function(jsonData) {
	var ans = [];
	var _g1 = 0, _g = jsonData.length;
	while(_g1 < _g) {
		var i = _g1++;
		ans.push(new LaterPage(jsonData[i].title,jsonData[i].url));
	}
	return ans;
}
LaterPage.prototype = {
	clone: function() {
		return new LaterPage(this.title,this.url);
	}
	,__class__: LaterPage
}
var LocalStorageDetail = function(storage,window) {
	this.storage = storage;
	window.addEventListener("storage",$bind(this,this.window_storageHandler));
};
LocalStorageDetail.__name__ = true;
LocalStorageDetail.prototype = {
	window_storageHandler_: function(key) {
		console.log("window_storage_" + key);
		this.loadData(key);
		if(this.callbackStorageChange != null) this.callbackStorageChange(key);
	}
	,window_storageHandler: function(event) {
		console.log("window_storage " + Std.string(event));
		var storageEvent = event;
		this.window_storageHandler_(storageEvent.key);
	}
	,setCallback: function(callbackStorageChange) {
		this.callbackStorageChange = callbackStorageChange;
	}
	,loadAllValue: function() {
		var _g = 0, _g1 = ["version","lastBlockUrl","unblockTimeList","unblockTimeDefaultIndex","unblockState","whitelist","whitelistUseRegexp","blacklist","blacklistUseRegexp","laterList"];
		while(_g < _g1.length) {
			var key = _g1[_g];
			++_g;
			this.loadData(key);
		}
	}
	,createAllDefault: function() {
		var _g = 0, _g1 = ["version","lastBlockUrl","unblockTimeList","unblockTimeDefaultIndex","unblockState","whitelist","whitelistUseRegexp","blacklist","blacklistUseRegexp","laterList"];
		while(_g < _g1.length) {
			var key = _g1[_g];
			++_g;
			this.createDefault(key);
		}
	}
	,getVersion: function() {
		var versionText = this.storage.getItem("version");
		if(versionText == null) return -1;
		return Std.parseInt(versionText);
	}
	,createDefault: function(key) {
		switch(key) {
		case "version":
			break;
		case "lastBlockUrl":
			this.set_lastBlockUrl(null);
			break;
		case "unblockTimeList":
			this.unblockTimeList = [180000,300000,600000,1200000,1800000,3600000];
			break;
		case "unblockTimeDefaultIndex":
			this.set_unblockTimeDefaultIndex(2);
			break;
		case "unblockState":
			this.unblockState = UnblockState.createDefault();
			break;
		case "whitelist":
			this.whitelist = ["https://www.google.co.jp/search","https://www.google.co.jp/calendar","https://www.google.co.jp/map","https://drive.google.com","https://github.com","http://www.alc.co.jp","http://eow.alc.co.jp"];
			break;
		case "whitelistUseRegexp":
			this.set_whitelistUseRegexp(false);
			break;
		case "blacklist":
			this.blacklist = [];
			break;
		case "blacklistUseRegexp":
			this.set_blacklistUseRegexp(false);
			break;
		case "laterList":
			this.laterList = [];
			break;
		default:
			throw "対応していない値です key=" + key;
		}
		this.flushItem(key);
	}
	,getArrayBool: function(key) {
		return this.storage.getItem(key) == "true";
	}
	,getArrayString: function(key) {
		return haxe.Json.parse(this.storage.getItem(key));
	}
	,getArrayFloat: function(key) {
		var list = haxe.Json.parse(this.storage.getItem(key));
		return (function($this) {
			var $r;
			var _g = [];
			{
				var _g2 = 0, _g1 = list.length;
				while(_g2 < _g1) {
					var i = _g2++;
					_g.push(Std.parseFloat(list[i]));
				}
			}
			$r = _g;
			return $r;
		}(this));
	}
	,loadData: function(key) {
		switch(key) {
		case "version":
			break;
		case "lastBlockUrl":
			this.set_lastBlockUrl(this.storage.getItem(key));
			break;
		case "unblockTimeList":
			this.unblockTimeList = this.getArrayFloat(key);
			break;
		case "unblockTimeDefaultIndex":
			this.set_unblockTimeDefaultIndex(Std.parseInt(this.storage.getItem(key)));
			break;
		case "unblockState":
			this.unblockState = UnblockState.createFromJson(this.storage.getItem(key));
			break;
		case "whitelist":
			this.whitelist = this.getArrayString(key);
			break;
		case "whitelistUseRegexp":
			this.set_whitelistUseRegexp(this.getArrayBool(key));
			break;
		case "blacklist":
			this.blacklist = this.getArrayString(key);
			break;
		case "blacklistUseRegexp":
			this.set_blacklistUseRegexp(this.getArrayBool(key));
			break;
		case "laterList":
			this.laterList = LaterPage.createArrayFromJson(this.storage.getItem(key));
			break;
		default:
			throw "対応していない値です key=" + key;
		}
	}
	,setIntItem: function(key,value) {
		this.storage.setItem(key,Std.string(this.unblockTimeDefaultIndex));
	}
	,setBoolItem: function(key,value) {
		this.storage.setItem(key,value?"true":"false");
	}
	,setJsonItem: function(key,value) {
		this.storage.setItem(key,haxe.Json.stringify(value));
	}
	,flushItem: function(key) {
		switch(key) {
		case "version":
			this.setIntItem(key,1);
			break;
		case "lastBlockUrl":
			this.storage.setItem(key,this.lastBlockUrl);
			break;
		case "unblockTimeList":
			this.setJsonItem(key,this.unblockTimeList);
			break;
		case "unblockTimeDefaultIndex":
			this.setIntItem(key,this.unblockTimeDefaultIndex);
			break;
		case "unblockState":
			this.setJsonItem(key,this.unblockState);
			break;
		case "whitelist":
			this.setJsonItem(key,this.whitelist);
			break;
		case "whitelistUseRegexp":
			this.setBoolItem(key,this.whitelistUseRegexp);
			break;
		case "blacklist":
			this.setJsonItem(key,this.blacklist);
			break;
		case "blacklistUseRegexp":
			this.setBoolItem(key,this.blacklistUseRegexp);
			break;
		case "laterList":
			this.setJsonItem(key,this.laterList);
			break;
		default:
			throw "対応していない値です key=" + key;
		}
	}
	,removeLaterList: function(value) {
		HxOverrides.remove(this.laterList,value);
		this.flushItem("laterList");
	}
	,addLaterList: function(value) {
		this.laterList.push(value);
		this.flushItem("laterList");
	}
	,getLaterList: function() {
		return LaterPage.arrayClone(this.laterList);
	}
	,set_blacklistUseRegexp: function(value) {
		this.blacklistUseRegexp = value;
		this.flushItem("blacklistUseRegexp");
		return this.blacklistUseRegexp;
	}
	,setBlacklist: function(value) {
		this.blacklist = value;
		this.flushItem("blacklist");
	}
	,getBlacklist: function() {
		return this.blacklist.slice();
	}
	,set_whitelistUseRegexp: function(value) {
		this.whitelistUseRegexp = value;
		this.flushItem("whitelistUseRegexp");
		return this.whitelistUseRegexp;
	}
	,addWhitelist: function(value) {
		this.whitelist.push(value);
		console.log("addWhitelist" + Std.string(this.whitelist));
		this.flushItem("whitelist");
	}
	,setWhitelist: function(value) {
		this.whitelist = value;
		this.flushItem("whitelist");
	}
	,getWhitelist: function() {
		return this.whitelist.slice();
	}
	,setUnblockState: function(value) {
		this.unblockState = value;
		this.flushItem("unblockState");
	}
	,getUnblockState: function() {
		return this.unblockState.clone();
	}
	,set_unblockTimeDefaultIndex: function(value) {
		this.unblockTimeDefaultIndex = value;
		this.flushItem("unblockTimeDefaultIndex");
		return this.unblockTimeDefaultIndex;
	}
	,setUnblockTimeList: function(value) {
		this.unblockTimeList = value;
		this.flushItem("unblockTimeList");
	}
	,getUnblockTimeList: function() {
		return this.unblockTimeList.slice();
	}
	,set_lastBlockUrl: function(value) {
		this.lastBlockUrl = value;
		this.flushItem("lastBlockUrl");
		return this.lastBlockUrl;
	}
	,__class__: LocalStorageDetail
}
var LocalStorageFactory = function() {
};
LocalStorageFactory.__name__ = true;
LocalStorageFactory.prototype = {
	create: function(callbackStorageChange,forceClear) {
		var storageDetail = new LocalStorageDetail(js.Browser.getLocalStorage(),js.Browser.window);
		var isFirstChange = false;
		var version = storageDetail.getVersion();
		if(version == -1 || forceClear) {
			storageDetail.createAllDefault();
			console.log("ストレージデータを生成しました");
			version = storageDetail.getVersion();
			isFirstChange = true;
		}
		if(version < 1) {
			version = storageDetail.getVersion();
			isFirstChange = true;
		}
		if(1 < version) {
			storageDetail.createAllDefault();
			version = storageDetail.getVersion();
			isFirstChange = true;
			throw "保存されているデータに対して、古いバージョンのエクステンションが使用されました。";
		}
		storageDetail.loadAllValue();
		storageDetail.setCallback(callbackStorageChange);
		return storageDetail;
	}
	,__class__: LocalStorageFactory
}
var LocalStorageKey = function() { }
LocalStorageKey.__name__ = true;
LocalStorageKey.KEY_LIST = function() {
	return ["version","lastBlockUrl","unblockTimeList","unblockTimeDefaultIndex","unblockState","whitelist","whitelistUseRegexp","blacklist","blacklistUseRegexp","laterList"];
}
var Reflect = function() { }
Reflect.__name__ = true;
Reflect.field = function(o,field) {
	var v = null;
	try {
		v = o[field];
	} catch( e ) {
	}
	return v;
}
Reflect.fields = function(o) {
	var a = [];
	if(o != null) {
		var hasOwnProperty = Object.prototype.hasOwnProperty;
		for( var f in o ) {
		if(f != "__id__" && hasOwnProperty.call(o,f)) a.push(f);
		}
	}
	return a;
}
Reflect.isFunction = function(f) {
	return typeof(f) == "function" && !(f.__name__ || f.__ename__);
}
var Std = function() { }
Std.__name__ = true;
Std.string = function(s) {
	return js.Boot.__string_rec(s,"");
}
Std.parseInt = function(x) {
	var v = parseInt(x,10);
	if(v == 0 && (HxOverrides.cca(x,1) == 120 || HxOverrides.cca(x,1) == 88)) v = parseInt(x);
	if(isNaN(v)) return null;
	return v;
}
Std.parseFloat = function(x) {
	return parseFloat(x);
}
var StringBuf = function() {
	this.b = "";
};
StringBuf.__name__ = true;
StringBuf.prototype = {
	addSub: function(s,pos,len) {
		this.b += len == null?HxOverrides.substr(s,pos,null):HxOverrides.substr(s,pos,len);
	}
	,__class__: StringBuf
}
var ValueType = { __ename__ : true, __constructs__ : ["TNull","TInt","TFloat","TBool","TObject","TFunction","TClass","TEnum","TUnknown"] }
ValueType.TNull = ["TNull",0];
ValueType.TNull.toString = $estr;
ValueType.TNull.__enum__ = ValueType;
ValueType.TInt = ["TInt",1];
ValueType.TInt.toString = $estr;
ValueType.TInt.__enum__ = ValueType;
ValueType.TFloat = ["TFloat",2];
ValueType.TFloat.toString = $estr;
ValueType.TFloat.__enum__ = ValueType;
ValueType.TBool = ["TBool",3];
ValueType.TBool.toString = $estr;
ValueType.TBool.__enum__ = ValueType;
ValueType.TObject = ["TObject",4];
ValueType.TObject.toString = $estr;
ValueType.TObject.__enum__ = ValueType;
ValueType.TFunction = ["TFunction",5];
ValueType.TFunction.toString = $estr;
ValueType.TFunction.__enum__ = ValueType;
ValueType.TClass = function(c) { var $x = ["TClass",6,c]; $x.__enum__ = ValueType; $x.toString = $estr; return $x; }
ValueType.TEnum = function(e) { var $x = ["TEnum",7,e]; $x.__enum__ = ValueType; $x.toString = $estr; return $x; }
ValueType.TUnknown = ["TUnknown",8];
ValueType.TUnknown.toString = $estr;
ValueType.TUnknown.__enum__ = ValueType;
var Type = function() { }
Type.__name__ = true;
Type["typeof"] = function(v) {
	var _g = typeof(v);
	switch(_g) {
	case "boolean":
		return ValueType.TBool;
	case "string":
		return ValueType.TClass(String);
	case "number":
		if(Math.ceil(v) == v % 2147483648.0) return ValueType.TInt;
		return ValueType.TFloat;
	case "object":
		if(v == null) return ValueType.TNull;
		var e = v.__enum__;
		if(e != null) return ValueType.TEnum(e);
		var c = v.__class__;
		if(c != null) return ValueType.TClass(c);
		return ValueType.TObject;
	case "function":
		if(v.__name__ || v.__ename__) return ValueType.TObject;
		return ValueType.TFunction;
	case "undefined":
		return ValueType.TNull;
	default:
		return ValueType.TUnknown;
	}
}
Type.enumIndex = function(e) {
	return e[1];
}
var UnblockState = function() {
	this.isUnblock = false;
	this.todayBlockTotal = 0;
	this.yesterdayBlockTotal = 0;
	this.startUnblockTime = 0;
	this.unblockTime = 0;
	this.startBlockTime = 0;
};
UnblockState.__name__ = true;
UnblockState.createDefault = function() {
	return new UnblockState();
}
UnblockState.createFromJson = function(jsonData) {
	var ans = new UnblockState();
	ans.isUnblock = jsonData.isUnblock == "true";
	ans.todayBlockTotal = Std.parseFloat(jsonData.todayBlockTotal);
	ans.yesterdayBlockTotal = Std.parseFloat(jsonData.yesterdayBlockTotal);
	ans.startUnblockTime = Std.parseFloat(jsonData.startUnblockTime);
	ans.unblockTime = Std.parseFloat(jsonData.unblockTime);
	ans.startBlockTime = Std.parseFloat(jsonData.startBlockTime);
	return ans;
}
UnblockState.prototype = {
	clone: function() {
		var ans = new UnblockState();
		ans.isUnblock = this.isUnblock;
		ans.todayBlockTotal = this.todayBlockTotal;
		ans.yesterdayBlockTotal = this.yesterdayBlockTotal;
		ans.startUnblockTime = this.startUnblockTime;
		ans.unblockTime = this.unblockTime;
		ans.startBlockTime = this.startBlockTime;
		return ans;
	}
	,__class__: UnblockState
}
var chrome = chrome || {}
chrome.CaptureFormat = { __ename__ : true, __constructs__ : ["jpeg","png"] }
chrome.CaptureFormat.jpeg = ["jpeg",0];
chrome.CaptureFormat.jpeg.toString = $estr;
chrome.CaptureFormat.jpeg.__enum__ = chrome.CaptureFormat;
chrome.CaptureFormat.png = ["png",1];
chrome.CaptureFormat.png.toString = $estr;
chrome.CaptureFormat.png.__enum__ = chrome.CaptureFormat;
chrome.QueryStatus = { __ename__ : true, __constructs__ : ["loading","complete"] }
chrome.QueryStatus.loading = ["loading",0];
chrome.QueryStatus.loading.toString = $estr;
chrome.QueryStatus.loading.__enum__ = chrome.QueryStatus;
chrome.QueryStatus.complete = ["complete",1];
chrome.QueryStatus.complete.toString = $estr;
chrome.QueryStatus.complete.__enum__ = chrome.QueryStatus;
chrome.RunAt = { __ename__ : true, __constructs__ : ["document_start","document_end","document_idle"] }
chrome.RunAt.document_start = ["document_start",0];
chrome.RunAt.document_start.toString = $estr;
chrome.RunAt.document_start.__enum__ = chrome.RunAt;
chrome.RunAt.document_end = ["document_end",1];
chrome.RunAt.document_end.toString = $estr;
chrome.RunAt.document_end.__enum__ = chrome.RunAt;
chrome.RunAt.document_idle = ["document_idle",2];
chrome.RunAt.document_idle.toString = $estr;
chrome.RunAt.document_idle.__enum__ = chrome.RunAt;
chrome.WindowType = { __ename__ : true, __constructs__ : ["normal","popup","panel","app"] }
chrome.WindowType.normal = ["normal",0];
chrome.WindowType.normal.toString = $estr;
chrome.WindowType.normal.__enum__ = chrome.WindowType;
chrome.WindowType.popup = ["popup",1];
chrome.WindowType.popup.toString = $estr;
chrome.WindowType.popup.__enum__ = chrome.WindowType;
chrome.WindowType.panel = ["panel",2];
chrome.WindowType.panel.toString = $estr;
chrome.WindowType.panel.__enum__ = chrome.WindowType;
chrome.WindowType.app = ["app",3];
chrome.WindowType.app.toString = $estr;
chrome.WindowType.app.__enum__ = chrome.WindowType;
chrome.WindowState = { __ename__ : true, __constructs__ : ["normal","minimized","maximized"] }
chrome.WindowState.normal = ["normal",0];
chrome.WindowState.normal.toString = $estr;
chrome.WindowState.normal.__enum__ = chrome.WindowState;
chrome.WindowState.minimized = ["minimized",1];
chrome.WindowState.minimized.toString = $estr;
chrome.WindowState.minimized.__enum__ = chrome.WindowState;
chrome.WindowState.maximized = ["maximized",2];
chrome.WindowState.maximized.toString = $estr;
chrome.WindowState.maximized.__enum__ = chrome.WindowState;
var haxe = haxe || {}
haxe.Json = function() {
};
haxe.Json.__name__ = true;
haxe.Json.parse = function(text) {
	return new haxe.Json().doParse(text);
}
haxe.Json.stringify = function(value,replacer) {
	return new haxe.Json().toString(value,replacer);
}
haxe.Json.prototype = {
	parseNumber: function(c) {
		var start = this.pos - 1;
		var minus = c == 45, digit = !minus, zero = c == 48;
		var point = false, e = false, pm = false, end = false;
		while(true) {
			c = this.str.charCodeAt(this.pos++);
			switch(c) {
			case 48:
				if(zero && !point) this.invalidNumber(start);
				if(minus) {
					minus = false;
					zero = true;
				}
				digit = true;
				break;
			case 49:case 50:case 51:case 52:case 53:case 54:case 55:case 56:case 57:
				if(zero && !point) this.invalidNumber(start);
				if(minus) minus = false;
				digit = true;
				zero = false;
				break;
			case 46:
				if(minus || point) this.invalidNumber(start);
				digit = false;
				point = true;
				break;
			case 101:case 69:
				if(minus || zero || e) this.invalidNumber(start);
				digit = false;
				e = true;
				break;
			case 43:case 45:
				if(!e || pm) this.invalidNumber(start);
				digit = false;
				pm = true;
				break;
			default:
				if(!digit) this.invalidNumber(start);
				this.pos--;
				end = true;
			}
			if(end) break;
		}
		var f = Std.parseFloat(HxOverrides.substr(this.str,start,this.pos - start));
		var i = f | 0;
		return i == f?i:f;
	}
	,invalidNumber: function(start) {
		throw "Invalid number at position " + start + ": " + HxOverrides.substr(this.str,start,this.pos - start);
	}
	,parseString: function() {
		var start = this.pos;
		var buf = new StringBuf();
		while(true) {
			var c = this.str.charCodeAt(this.pos++);
			if(c == 34) break;
			if(c == 92) {
				buf.addSub(this.str,start,this.pos - start - 1);
				c = this.str.charCodeAt(this.pos++);
				switch(c) {
				case 114:
					buf.b += "\r";
					break;
				case 110:
					buf.b += "\n";
					break;
				case 116:
					buf.b += "\t";
					break;
				case 98:
					buf.b += "";
					break;
				case 102:
					buf.b += "";
					break;
				case 47:case 92:case 34:
					buf.b += String.fromCharCode(c);
					break;
				case 117:
					var uc = Std.parseInt("0x" + HxOverrides.substr(this.str,this.pos,4));
					this.pos += 4;
					buf.b += String.fromCharCode(uc);
					break;
				default:
					throw "Invalid escape sequence \\" + String.fromCharCode(c) + " at position " + (this.pos - 1);
				}
				start = this.pos;
			} else if(c != c) throw "Unclosed string";
		}
		buf.addSub(this.str,start,this.pos - start - 1);
		return buf.b;
	}
	,parseRec: function() {
		while(true) {
			var c = this.str.charCodeAt(this.pos++);
			switch(c) {
			case 32:case 13:case 10:case 9:
				break;
			case 123:
				var obj = { }, field = null, comma = null;
				while(true) {
					var c1 = this.str.charCodeAt(this.pos++);
					switch(c1) {
					case 32:case 13:case 10:case 9:
						break;
					case 125:
						if(field != null || comma == false) this.invalidChar();
						return obj;
					case 58:
						if(field == null) this.invalidChar();
						obj[field] = this.parseRec();
						field = null;
						comma = true;
						break;
					case 44:
						if(comma) comma = false; else this.invalidChar();
						break;
					case 34:
						if(comma) this.invalidChar();
						field = this.parseString();
						break;
					default:
						this.invalidChar();
					}
				}
				break;
			case 91:
				var arr = [], comma = null;
				while(true) {
					var c1 = this.str.charCodeAt(this.pos++);
					switch(c1) {
					case 32:case 13:case 10:case 9:
						break;
					case 93:
						if(comma == false) this.invalidChar();
						return arr;
					case 44:
						if(comma) comma = false; else this.invalidChar();
						break;
					default:
						if(comma) this.invalidChar();
						this.pos--;
						arr.push(this.parseRec());
						comma = true;
					}
				}
				break;
			case 116:
				var save = this.pos;
				if(this.str.charCodeAt(this.pos++) != 114 || this.str.charCodeAt(this.pos++) != 117 || this.str.charCodeAt(this.pos++) != 101) {
					this.pos = save;
					this.invalidChar();
				}
				return true;
			case 102:
				var save = this.pos;
				if(this.str.charCodeAt(this.pos++) != 97 || this.str.charCodeAt(this.pos++) != 108 || this.str.charCodeAt(this.pos++) != 115 || this.str.charCodeAt(this.pos++) != 101) {
					this.pos = save;
					this.invalidChar();
				}
				return false;
			case 110:
				var save = this.pos;
				if(this.str.charCodeAt(this.pos++) != 117 || this.str.charCodeAt(this.pos++) != 108 || this.str.charCodeAt(this.pos++) != 108) {
					this.pos = save;
					this.invalidChar();
				}
				return null;
			case 34:
				return this.parseString();
			case 48:case 49:case 50:case 51:case 52:case 53:case 54:case 55:case 56:case 57:case 45:
				return this.parseNumber(c);
			default:
				this.invalidChar();
			}
		}
	}
	,invalidChar: function() {
		this.pos--;
		throw "Invalid char " + this.str.charCodeAt(this.pos) + " at position " + this.pos;
	}
	,doParse: function(str) {
		this.str = str;
		this.pos = 0;
		return this.parseRec();
	}
	,quote: function(s) {
		this.buf.b += "\"";
		var i = 0;
		while(true) {
			var c = s.charCodeAt(i++);
			if(c != c) break;
			switch(c) {
			case 34:
				this.buf.b += "\\\"";
				break;
			case 92:
				this.buf.b += "\\\\";
				break;
			case 10:
				this.buf.b += "\\n";
				break;
			case 13:
				this.buf.b += "\\r";
				break;
			case 9:
				this.buf.b += "\\t";
				break;
			case 8:
				this.buf.b += "\\b";
				break;
			case 12:
				this.buf.b += "\\f";
				break;
			default:
				this.buf.b += String.fromCharCode(c);
			}
		}
		this.buf.b += "\"";
	}
	,toStringRec: function(k,v) {
		if(this.replacer != null) v = this.replacer(k,v);
		var _g = Type["typeof"](v);
		var $e = (_g);
		switch( $e[1] ) {
		case 8:
			this.buf.b += "\"???\"";
			break;
		case 4:
			this.objString(v);
			break;
		case 1:
			var v1 = v;
			this.buf.b += Std.string(v1);
			break;
		case 2:
			this.buf.b += Std.string(Math.isFinite(v)?v:"null");
			break;
		case 5:
			this.buf.b += "\"<fun>\"";
			break;
		case 6:
			var _g_eTClass_0 = $e[2];
			if(_g_eTClass_0 == String) this.quote(v); else if(_g_eTClass_0 == Array) {
				var v1 = v;
				this.buf.b += "[";
				var len = v1.length;
				if(len > 0) {
					this.toStringRec(0,v1[0]);
					var i = 1;
					while(i < len) {
						this.buf.b += ",";
						this.toStringRec(i,v1[i++]);
					}
				}
				this.buf.b += "]";
			} else if(_g_eTClass_0 == haxe.ds.StringMap) {
				var v1 = v;
				var o = { };
				var $it0 = v1.keys();
				while( $it0.hasNext() ) {
					var k1 = $it0.next();
					o[k1] = v1.get(k1);
				}
				this.objString(o);
			} else this.objString(v);
			break;
		case 7:
			var i = Type.enumIndex(v);
			var v1 = i;
			this.buf.b += Std.string(v1);
			break;
		case 3:
			var v1 = v;
			this.buf.b += Std.string(v1);
			break;
		case 0:
			this.buf.b += "null";
			break;
		}
	}
	,objString: function(v) {
		this.fieldsString(v,Reflect.fields(v));
	}
	,fieldsString: function(v,fields) {
		var first = true;
		this.buf.b += "{";
		var _g = 0;
		while(_g < fields.length) {
			var f = fields[_g];
			++_g;
			var value = Reflect.field(v,f);
			if(Reflect.isFunction(value)) continue;
			if(first) first = false; else this.buf.b += ",";
			this.quote(f);
			this.buf.b += ":";
			this.toStringRec(f,value);
		}
		this.buf.b += "}";
	}
	,toString: function(v,replacer) {
		this.buf = new StringBuf();
		this.replacer = replacer;
		this.toStringRec("",v);
		return this.buf.b;
	}
	,__class__: haxe.Json
}
if(!haxe.ds) haxe.ds = {}
haxe.ds.StringMap = function() { }
haxe.ds.StringMap.__name__ = true;
haxe.ds.StringMap.prototype = {
	keys: function() {
		var a = [];
		for( var key in this.h ) {
		if(this.h.hasOwnProperty(key)) a.push(key.substr(1));
		}
		return HxOverrides.iter(a);
	}
	,get: function(key) {
		return this.h["$" + key];
	}
	,__class__: haxe.ds.StringMap
}
var js = js || {}
js.Boot = function() { }
js.Boot.__name__ = true;
js.Boot.__string_rec = function(o,s) {
	if(o == null) return "null";
	if(s.length >= 5) return "<...>";
	var t = typeof(o);
	if(t == "function" && (o.__name__ || o.__ename__)) t = "object";
	switch(t) {
	case "object":
		if(o instanceof Array) {
			if(o.__enum__) {
				if(o.length == 2) return o[0];
				var str = o[0] + "(";
				s += "\t";
				var _g1 = 2, _g = o.length;
				while(_g1 < _g) {
					var i = _g1++;
					if(i != 2) str += "," + js.Boot.__string_rec(o[i],s); else str += js.Boot.__string_rec(o[i],s);
				}
				return str + ")";
			}
			var l = o.length;
			var i;
			var str = "[";
			s += "\t";
			var _g = 0;
			while(_g < l) {
				var i1 = _g++;
				str += (i1 > 0?",":"") + js.Boot.__string_rec(o[i1],s);
			}
			str += "]";
			return str;
		}
		var tostr;
		try {
			tostr = o.toString;
		} catch( e ) {
			return "???";
		}
		if(tostr != null && tostr != Object.toString) {
			var s2 = o.toString();
			if(s2 != "[object Object]") return s2;
		}
		var k = null;
		var str = "{\n";
		s += "\t";
		var hasp = o.hasOwnProperty != null;
		for( var k in o ) { ;
		if(hasp && !o.hasOwnProperty(k)) {
			continue;
		}
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__" || k == "__properties__") {
			continue;
		}
		if(str.length != 2) str += ", \n";
		str += s + k + " : " + js.Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str += "\n" + s + "}";
		return str;
	case "function":
		return "<function>";
	case "string":
		return o;
	default:
		return String(o);
	}
}
js.Browser = function() { }
js.Browser.__name__ = true;
js.Browser.getLocalStorage = function() {
	try {
		var s = js.Browser.window.localStorage;
		s.getItem("");
		return s;
	} catch( e ) {
		return null;
	}
}
function $iterator(o) { if( o instanceof Array ) return function() { return HxOverrides.iter(o); }; return typeof(o.iterator) == 'function' ? $bind(o,o.iterator) : o.iterator; };
var $_;
function $bind(o,m) { var f = function(){ return f.method.apply(f.scope, arguments); }; f.scope = o; f.method = m; return f; };
if(Array.prototype.indexOf) HxOverrides.remove = function(a,o) {
	var i = a.indexOf(o);
	if(i == -1) return false;
	a.splice(i,1);
	return true;
}; else null;
Math.__name__ = ["Math"];
Math.NaN = Number.NaN;
Math.NEGATIVE_INFINITY = Number.NEGATIVE_INFINITY;
Math.POSITIVE_INFINITY = Number.POSITIVE_INFINITY;
Math.isFinite = function(i) {
	return isFinite(i);
};
Math.isNaN = function(i) {
	return isNaN(i);
};
String.prototype.__class__ = String;
String.__name__ = true;
Array.prototype.__class__ = Array;
Array.__name__ = true;
if(typeof(JSON) != "undefined") haxe.Json = JSON;
var q = window.jQuery;
js.JQuery = q;
Background.DEBUG_CLEAR_DATA = true;
LocalStorageDetail.STORAGE_VERSION = 1;
LocalStorageKey.VERSION = "version";
LocalStorageKey.LAST_BLOCK_URL = "lastBlockUrl";
LocalStorageKey.UNBLOCK_TIME_LIST = "unblockTimeList";
LocalStorageKey.UNBLOCK_TIME_DEFAULT_INDEX = "unblockTimeDefaultIndex";
LocalStorageKey.UNBLOCK_STATE = "unblockState";
LocalStorageKey.WHITELIST = "whitelist";
LocalStorageKey.WHITELIST_USE_REGEXP = "whitelistUseRegexp";
LocalStorageKey.BLACKLIST = "blacklist";
LocalStorageKey.BLACKLIST_USE_REGEXP = "blacklistUseRegexp";
LocalStorageKey.LATER_LIST = "laterList";
js.Browser.window = typeof window != "undefined" ? window : null;
Background.main();
