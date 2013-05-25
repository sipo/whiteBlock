var $estr = function() { return js.Boot.__string_rec(this,''); };
var EReg = function(r,opt) {
	opt = opt.split("u").join("");
	this.r = new RegExp(r,opt);
};
EReg.__name__ = true;
EReg.prototype = {
	replace: function(s,by) {
		return s.replace(this.r,by);
	}
	,matchedPos: function() {
		if(this.r.m == null) throw "No string matched";
		return { pos : this.r.m.index, len : this.r.m[0].length};
	}
	,matchedRight: function() {
		if(this.r.m == null) throw "No string matched";
		var sz = this.r.m.index + this.r.m[0].length;
		return this.r.s.substr(sz,this.r.s.length - sz);
	}
	,matched: function(n) {
		return this.r.m != null && n >= 0 && n < this.r.m.length?this.r.m[n]:(function($this) {
			var $r;
			throw "EReg::matched";
			return $r;
		}(this));
	}
	,match: function(s) {
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
HxOverrides.iter = function(a) {
	return { cur : 0, arr : a, hasNext : function() {
		return this.cur < this.arr.length;
	}, next : function() {
		return this.arr[this.cur++];
	}};
}
var List = function() {
	this.length = 0;
};
List.__name__ = true;
List.prototype = {
	iterator: function() {
		return { h : this.h, hasNext : function() {
			return this.h != null;
		}, next : function() {
			if(this.h == null) return null;
			var x = this.h[0];
			this.h = this.h[1];
			return x;
		}};
	}
	,isEmpty: function() {
		return this.h == null;
	}
	,pop: function() {
		if(this.h == null) return null;
		var x = this.h[0];
		this.h = this.h[1];
		if(this.h == null) this.q = null;
		this.length--;
		return x;
	}
	,first: function() {
		return this.h == null?null:this.h[0];
	}
	,push: function(item) {
		var x = [item,this.h];
		this.h = x;
		if(this.q == null) this.q = x;
		this.length++;
	}
	,add: function(item) {
		var x = [item];
		if(this.h == null) this.h = x; else this.q[1] = x;
		this.q = x;
		this.length++;
	}
	,__class__: List
}
var IMap = function() { }
IMap.__name__ = true;
var Note = function() {
};
Note.__name__ = true;
Note.log = function(message) {
	console.log(message);
}
Note.debug = function(message) {
	console.log("D\t" + Std.string(message));
}
Note.prototype = {
	__class__: Note
}
var Option = function() {
	var factory = new storage.LocalStorageFactory();
	this.localStorageDetail = factory.create($bind(this,this.storage_changeHandler),false);
	this.view = new OptionView(this,this.localStorageDetail);
	new js.JQuery("document").ready($bind(this,this.document_readyHandler));
	js.Browser.window.setInterval($bind(this,this.window_timeoutHandler),1000);
};
Option.__name__ = true;
Option.main = function() {
	Option.option = new Option();
}
Option.prototype = {
	'delete': function() {
		this.localStorageDetail.createAllDefault();
		this.view.drawConfig();
	}
	,save: function(data) {
		this.localStorageDetail.setUnblockTimeList(data.unblockTimeList);
		this.localStorageDetail.setUnblockTimeDefaultIndex(data.unblockTimeDefaultValue);
		this.localStorageDetail.setWhitelist(data.whitelist);
		this.localStorageDetail.setWhitelistUseRegexp(data.whitelistUseRegexp);
		this.localStorageDetail.setBlacklist(data.blacklist);
		this.localStorageDetail.setBlacklistUseRegexp(data.blacklistUseRegexp);
	}
	,window_timeoutHandler: function() {
	}
	,storage_changeHandler: function(key) {
	}
	,document_readyHandler: function(event) {
		this.view.initialize();
		this.view.drawConfig();
	}
	,__class__: Option
}
var OptionView = function(option,localStorageDetail) {
	this.option = option;
	this.localStorageDetail = localStorageDetail;
};
OptionView.__name__ = true;
OptionView.prototype = {
	cleanBreak: function(original) {
		return new EReg("(\r\n)|(\r)","g").replace(original,"\n");
	}
	,switchChange: function(isChange) {
		this.anyChange = isChange;
		if(isChange) this.save_clickable.removeAttr("disabled"); else this.save_clickable.attr("disabled","disabled");
	}
	,window_unloadHandler: function(event) {
		if(!this.anyChange) return;
		event.returnValue = 'ページから移動しますか？';
		return event;
	}
	,delete_clickHandler: function(event) {
		if(js.Browser.window.confirm("設定やブロック時間の記録などを全て消し、デフォルトに戻します")) this.option["delete"](); else {
		}
	}
	,checkboxToBool: function(checkbox) {
		return checkbox["is"](":" + "checked");
	}
	,textAreaToArray: function(textArea) {
		var tmpList = this.cleanBreak(textArea.val()).split("\n");
		var ans = [];
		var _g1 = 0, _g = tmpList.length;
		while(_g1 < _g) {
			var i = _g1++;
			var text = tmpList[i];
			if(text == "") continue;
			ans.push(text);
		}
		return ans;
	}
	,save_clickHandler: function(event) {
		Note.log("save_clickHandler");
		this.switchChange(false);
		var unblockTimeList = [];
		var unblockTimeListString = this.cleanBreak(this.unblockTimeList_textArea.val()).split("\n");
		var _g1 = 0, _g = unblockTimeListString.length;
		while(_g1 < _g) {
			var i = _g1++;
			unblockTimeList.push(Std.parseFloat(unblockTimeListString[i]) * 60000);
		}
		var unblockTimeDefaultValue = this.unblockTimeDefaultIndex.getValue();
		var whitelist = this.textAreaToArray(this.whitelist_textArea);
		var whitelistUseRegexp = this.checkboxToBool(this.whitelistUseRegexp_checkbox);
		var blacklist = this.textAreaToArray(this.blacklist_textArea);
		var blacklistUseRegexp = this.checkboxToBool(this.blacklistUseRegexp_checkbox);
		var data = { unblockTimeList : unblockTimeList, unblockTimeDefaultValue : unblockTimeDefaultValue, whitelist : whitelist, whitelistUseRegexp : whitelistUseRegexp, blacklist : blacklist, blacklistUseRegexp : blacklistUseRegexp};
		Note.log("save " + Std.string(data));
		this.option.save(data);
	}
	,any_changeHandler: function(event) {
		Note.log("any_changeHandler");
		this.switchChange(true);
	}
	,unblockTimeDefaultIndex_changeHandler: function(event) {
		Note.log("unblockTimeList_changeHandler");
		this.lastUnblockTimeDefaultValue = this.unblockTimeDefaultIndex.getValue();
		this.any_changeHandler(null);
	}
	,unblockTimeList_changeHandler: function(event) {
		Note.log("unblockTimeList_changeHandler");
		this.drawUnblockTimeDefault();
		this.any_changeHandler(null);
	}
	,drawUnblockTimeDefault: function() {
		var unblockTimeList_textAreaValue = this.unblockTimeList_textArea.val();
		unblockTimeList_textAreaValue = this.cleanBreak(unblockTimeList_textAreaValue);
		var unblockMinutesString = this.unblockTimeList_textArea.val().split("\n");
		var timeList = [];
		var _g1 = 0, _g = unblockMinutesString.length;
		while(_g1 < _g) {
			var i = _g1++;
			var minute = Std.parseFloat(unblockMinutesString[i]);
			if(Math.isNaN(minute)) {
				timeList.push(0);
				continue;
			}
			timeList.push(minute * 60000);
		}
		this.unblockTimeDefaultIndex.draw(timeList,this.lastUnblockTimeDefaultValue);
	}
	,drawCheckbox: function(checkbox,value) {
		if(value) checkbox.attr("checked","checked"); else checkbox.removeAttr("checked");
	}
	,drawListTextArea: function(textArea,list) {
		textArea.val(list.join("\n"));
		var rows = list.length + 1;
		rows = rows < 5?5:20 < rows?20:rows;
		textArea.attr("rows",Std.string(rows));
	}
	,drawConfig: function() {
		var unblockTimeList = this.localStorageDetail.getUnblockTimeList();
		var unblockTimeMinuteList = [];
		var _g1 = 0, _g = unblockTimeList.length;
		while(_g1 < _g) {
			var i = _g1++;
			var minute = unblockTimeList[i] / 60000;
			unblockTimeMinuteList.push(minute);
		}
		this.unblockTimeList_textArea.val(unblockTimeMinuteList.join("\n"));
		this.lastUnblockTimeDefaultValue = this.localStorageDetail.unblockTimeDefaultValue;
		this.drawUnblockTimeDefault();
		this.drawListTextArea(this.whitelist_textArea,this.localStorageDetail.getWhitelist());
		this.drawCheckbox(this.whitelistUseRegexp_checkbox,this.localStorageDetail.whitelistUseRegexp);
		this.drawListTextArea(this.blacklist_textArea,this.localStorageDetail.getBlacklist());
		this.drawCheckbox(this.blacklistUseRegexp_checkbox,this.localStorageDetail.blacklistUseRegexp);
		this.switchChange(false);
	}
	,initialize: function() {
		Note.log("optionView initialize");
		this.unblockTimeList_textArea = new js.JQuery("#unblockTimeList");
		this.unblockTimeDefaultIndex = new common.UnblockTimeDownList(new js.JQuery("#unblockTimeDefaultIndex"));
		this.whitelist_textArea = new js.JQuery("#whitelist");
		this.whitelistUseRegexp_checkbox = new js.JQuery("#whitelistUseRegexp");
		this.blacklist_textArea = new js.JQuery("#blacklist");
		this.blacklistUseRegexp_checkbox = new js.JQuery("#blacklistUseRegexp");
		this.save_clickable = new js.JQuery("#save");
		this.delete_clickable = new js.JQuery("#delete");
		this.unblockTimeList_textArea.keyup($bind(this,this.unblockTimeList_changeHandler));
		this.unblockTimeList_textArea.change($bind(this,this.unblockTimeList_changeHandler));
		this.unblockTimeDefaultIndex.change($bind(this,this.unblockTimeDefaultIndex_changeHandler));
		this.whitelist_textArea.keyup($bind(this,this.any_changeHandler));
		this.whitelist_textArea.change($bind(this,this.any_changeHandler));
		this.whitelistUseRegexp_checkbox.change($bind(this,this.any_changeHandler));
		this.blacklist_textArea.keyup($bind(this,this.any_changeHandler));
		this.blacklist_textArea.change($bind(this,this.any_changeHandler));
		this.blacklistUseRegexp_checkbox.change($bind(this,this.any_changeHandler));
		this.save_clickable.click($bind(this,this.save_clickHandler));
		this.delete_clickable.click($bind(this,this.delete_clickHandler));
	}
	,__class__: OptionView
}
var Reflect = function() { }
Reflect.__name__ = true;
Reflect.hasField = function(o,field) {
	return Object.prototype.hasOwnProperty.call(o,field);
}
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
		if(f != "__id__" && f != "hx__closures__" && hasOwnProperty.call(o,f)) a.push(f);
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
var StringTools = function() { }
StringTools.__name__ = true;
StringTools.htmlEscape = function(s,quotes) {
	s = s.split("&").join("&amp;").split("<").join("&lt;").split(">").join("&gt;");
	return quotes?s.split("\"").join("&quot;").split("'").join("&#039;"):s;
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
var common = common || {}
common.Page = function(title,url) {
	this.title = title;
	this.url = url;
};
common.Page.__name__ = true;
common.Page.arrayClone = function(list) {
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
common.Page.createFromJson = function(jsonData) {
	return new common.Page(jsonData.title,jsonData.url);
}
common.Page.createArrayFromJson = function(jsonData) {
	var ans = [];
	var _g1 = 0, _g = jsonData.length;
	while(_g1 < _g) {
		var i = _g1++;
		ans.push(new common.Page(jsonData[i].title,jsonData[i].url));
	}
	return ans;
}
common.Page.prototype = {
	get_escapeUrl: function() {
		return StringTools.htmlEscape(this.url);
	}
	,get_escapeTitle: function() {
		return StringTools.htmlEscape(this.title);
	}
	,clone: function() {
		return new common.Page(this.title,this.url);
	}
	,__class__: common.Page
}
common.StringUtil = function() { }
common.StringUtil.__name__ = true;
common.StringUtil.timeDisplay = function(time,useSeconds) {
	var seconds = (time / 1000 | 0) % 60;
	var minutes = (time / 1000 / 60 | 0) % 60;
	var hours = time / 1000 / 60 / 60 | 0;
	if(hours == 0) {
		if(useSeconds) return minutes + "分" + seconds + "秒";
		return minutes + "分";
	}
	if(minutes == 0) return hours + "時間";
	return hours + "時間" + minutes + "分";
}
common.StringUtil.timeDisplayMinutes = function(time) {
	var seconds = (time / 1000 | 0) % 60;
	var minutes = (time / 1000 / 60 | 0) % 60;
	var hours = time / 1000 / 60 / 60 | 0;
	if(9 < minutes) return minutes + "\""; else {
	}
	var secondsZero = seconds < 10?"0":"";
	return minutes + "\"" + secondsZero + seconds;
}
common.StringUtil.limit = function(original,max) {
	if(original.length <= max) return original;
	return HxOverrides.substr(original,0,max - 3) + "...";
}
common.UnblockTimeDownList = function(dom) {
	this.dom = dom;
	this.optionTemplate = new haxe.Template(dom.html());
	dom.html("");
};
common.UnblockTimeDownList.__name__ = true;
common.UnblockTimeDownList.prototype = {
	change: function(callback) {
		this.dom.change(callback);
	}
	,setValue: function(value) {
		this.dom.val(Std.string(value));
	}
	,getValue: function() {
		return Std.parseFloat(this.dom.val());
	}
	,draw: function(timeList,defaultValue) {
		var innerHtml = "";
		var _g1 = 0, _g = timeList.length;
		while(_g1 < _g) {
			var unblockTimeI = _g1++;
			var value = timeList[unblockTimeI];
			var context = { time : Std.string(value), text : common.StringUtil.timeDisplay(value,false)};
			innerHtml += this.optionTemplate.execute(context);
		}
		this.dom.html(innerHtml);
		this.dom.val(Std.string(defaultValue));
	}
	,__class__: common.UnblockTimeDownList
}
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
			var c = $e[2];
			if(c == String) this.quote(v); else if(c == Array) {
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
			} else if(c == haxe.ds.StringMap) {
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
if(!haxe._Template) haxe._Template = {}
haxe._Template.TemplateExpr = { __ename__ : true, __constructs__ : ["OpVar","OpExpr","OpIf","OpStr","OpBlock","OpForeach","OpMacro"] }
haxe._Template.TemplateExpr.OpVar = function(v) { var $x = ["OpVar",0,v]; $x.__enum__ = haxe._Template.TemplateExpr; $x.toString = $estr; return $x; }
haxe._Template.TemplateExpr.OpExpr = function(expr) { var $x = ["OpExpr",1,expr]; $x.__enum__ = haxe._Template.TemplateExpr; $x.toString = $estr; return $x; }
haxe._Template.TemplateExpr.OpIf = function(expr,eif,eelse) { var $x = ["OpIf",2,expr,eif,eelse]; $x.__enum__ = haxe._Template.TemplateExpr; $x.toString = $estr; return $x; }
haxe._Template.TemplateExpr.OpStr = function(str) { var $x = ["OpStr",3,str]; $x.__enum__ = haxe._Template.TemplateExpr; $x.toString = $estr; return $x; }
haxe._Template.TemplateExpr.OpBlock = function(l) { var $x = ["OpBlock",4,l]; $x.__enum__ = haxe._Template.TemplateExpr; $x.toString = $estr; return $x; }
haxe._Template.TemplateExpr.OpForeach = function(expr,loop) { var $x = ["OpForeach",5,expr,loop]; $x.__enum__ = haxe._Template.TemplateExpr; $x.toString = $estr; return $x; }
haxe._Template.TemplateExpr.OpMacro = function(name,params) { var $x = ["OpMacro",6,name,params]; $x.__enum__ = haxe._Template.TemplateExpr; $x.toString = $estr; return $x; }
haxe.Template = function(str) {
	var tokens = this.parseTokens(str);
	this.expr = this.parseBlock(tokens);
	if(!tokens.isEmpty()) throw "Unexpected '" + Std.string(tokens.first().s) + "'";
};
haxe.Template.__name__ = true;
haxe.Template.prototype = {
	run: function(e) {
		var $e = (e);
		switch( $e[1] ) {
		case 0:
			var v = $e[2];
			this.buf.b += Std.string(Std.string(this.resolve(v)));
			break;
		case 1:
			var e1 = $e[2];
			this.buf.b += Std.string(Std.string(e1()));
			break;
		case 2:
			var eelse = $e[4], eif = $e[3], e1 = $e[2];
			var v = e1();
			if(v == null || v == false) {
				if(eelse != null) this.run(eelse);
			} else this.run(eif);
			break;
		case 3:
			var str = $e[2];
			this.buf.b += Std.string(str);
			break;
		case 4:
			var l = $e[2];
			var $it0 = l.iterator();
			while( $it0.hasNext() ) {
				var e1 = $it0.next();
				this.run(e1);
			}
			break;
		case 5:
			var loop = $e[3], e1 = $e[2];
			var v = e1();
			try {
				var x = $iterator(v)();
				if(x.hasNext == null) throw null;
				v = x;
			} catch( e2 ) {
				try {
					if(v.hasNext == null) throw null;
				} catch( e3 ) {
					throw "Cannot iter on " + Std.string(v);
				}
			}
			this.stack.push(this.context);
			var v1 = v;
			while( v1.hasNext() ) {
				var ctx = v1.next();
				this.context = ctx;
				this.run(loop);
			}
			this.context = this.stack.pop();
			break;
		case 6:
			var params = $e[3], m = $e[2];
			var v = Reflect.field(this.macros,m);
			var pl = new Array();
			var old = this.buf;
			pl.push($bind(this,this.resolve));
			var $it1 = params.iterator();
			while( $it1.hasNext() ) {
				var p = $it1.next();
				var $e = (p);
				switch( $e[1] ) {
				case 0:
					var v1 = $e[2];
					pl.push(this.resolve(v1));
					break;
				default:
					this.buf = new StringBuf();
					this.run(p);
					pl.push(this.buf.b);
				}
			}
			this.buf = old;
			try {
				this.buf.b += Std.string(Std.string(v.apply(this.macros,pl)));
			} catch( e1 ) {
				var plstr = (function($this) {
					var $r;
					try {
						$r = pl.join(",");
					} catch( e2 ) {
						$r = "???";
					}
					return $r;
				}(this));
				var msg = "Macro call " + m + "(" + plstr + ") failed (" + Std.string(e1) + ")";
				throw msg;
			}
			break;
		}
	}
	,makeExpr2: function(l) {
		var p = l.pop();
		if(p == null) throw "<eof>";
		if(p.s) return this.makeConst(p.p);
		switch(p.p) {
		case "(":
			var e1 = this.makeExpr(l);
			var p1 = l.pop();
			if(p1 == null || p1.s) throw p1.p;
			if(p1.p == ")") return e1;
			var e2 = this.makeExpr(l);
			var p2 = l.pop();
			if(p2 == null || p2.p != ")") throw p2.p;
			return (function($this) {
				var $r;
				switch(p1.p) {
				case "+":
					$r = function() {
						return e1() + e2();
					};
					break;
				case "-":
					$r = function() {
						return e1() - e2();
					};
					break;
				case "*":
					$r = function() {
						return e1() * e2();
					};
					break;
				case "/":
					$r = function() {
						return e1() / e2();
					};
					break;
				case ">":
					$r = function() {
						return e1() > e2();
					};
					break;
				case "<":
					$r = function() {
						return e1() < e2();
					};
					break;
				case ">=":
					$r = function() {
						return e1() >= e2();
					};
					break;
				case "<=":
					$r = function() {
						return e1() <= e2();
					};
					break;
				case "==":
					$r = function() {
						return e1() == e2();
					};
					break;
				case "!=":
					$r = function() {
						return e1() != e2();
					};
					break;
				case "&&":
					$r = function() {
						return e1() && e2();
					};
					break;
				case "||":
					$r = function() {
						return e1() || e2();
					};
					break;
				default:
					$r = (function($this) {
						var $r;
						throw "Unknown operation " + p1.p;
						return $r;
					}($this));
				}
				return $r;
			}(this));
		case "!":
			var e = this.makeExpr(l);
			return function() {
				var v = e();
				return v == null || v == false;
			};
		case "-":
			var e3 = this.makeExpr(l);
			return function() {
				return -e3();
			};
		}
		throw p.p;
	}
	,makeExpr: function(l) {
		return this.makePath(this.makeExpr2(l),l);
	}
	,makePath: function(e,l) {
		var p = l.first();
		if(p == null || p.p != ".") return e;
		l.pop();
		var field = l.pop();
		if(field == null || !field.s) throw field.p;
		var f = field.p;
		haxe.Template.expr_trim.match(f);
		f = haxe.Template.expr_trim.matched(1);
		return this.makePath(function() {
			return Reflect.field(e(),f);
		},l);
	}
	,makeConst: function(v) {
		haxe.Template.expr_trim.match(v);
		v = haxe.Template.expr_trim.matched(1);
		if(HxOverrides.cca(v,0) == 34) {
			var str = HxOverrides.substr(v,1,v.length - 2);
			return function() {
				return str;
			};
		}
		if(haxe.Template.expr_int.match(v)) {
			var i = Std.parseInt(v);
			return function() {
				return i;
			};
		}
		if(haxe.Template.expr_float.match(v)) {
			var f = Std.parseFloat(v);
			return function() {
				return f;
			};
		}
		var me = this;
		return function() {
			return me.resolve(v);
		};
	}
	,parseExpr: function(data) {
		var l = new List();
		var expr = data;
		while(haxe.Template.expr_splitter.match(data)) {
			var p = haxe.Template.expr_splitter.matchedPos();
			var k = p.pos + p.len;
			if(p.pos != 0) l.add({ p : HxOverrides.substr(data,0,p.pos), s : true});
			var p1 = haxe.Template.expr_splitter.matched(0);
			l.add({ p : p1, s : p1.indexOf("\"") >= 0});
			data = haxe.Template.expr_splitter.matchedRight();
		}
		if(data.length != 0) l.add({ p : data, s : true});
		var e;
		try {
			e = this.makeExpr(l);
			if(!l.isEmpty()) throw l.first().p;
		} catch( s ) {
			if( js.Boot.__instanceof(s,String) ) {
				throw "Unexpected '" + s + "' in " + expr;
			} else throw(s);
		}
		return function() {
			try {
				return e();
			} catch( exc ) {
				throw "Error : " + Std.string(exc) + " in " + expr;
			}
		};
	}
	,parse: function(tokens) {
		var t = tokens.pop();
		var p = t.p;
		if(t.s) return haxe._Template.TemplateExpr.OpStr(p);
		if(t.l != null) {
			var pe = new List();
			var _g = 0, _g1 = t.l;
			while(_g < _g1.length) {
				var p1 = _g1[_g];
				++_g;
				pe.add(this.parseBlock(this.parseTokens(p1)));
			}
			return haxe._Template.TemplateExpr.OpMacro(p,pe);
		}
		if(HxOverrides.substr(p,0,3) == "if ") {
			p = HxOverrides.substr(p,3,p.length - 3);
			var e = this.parseExpr(p);
			var eif = this.parseBlock(tokens);
			var t1 = tokens.first();
			var eelse;
			if(t1 == null) throw "Unclosed 'if'";
			if(t1.p == "end") {
				tokens.pop();
				eelse = null;
			} else if(t1.p == "else") {
				tokens.pop();
				eelse = this.parseBlock(tokens);
				t1 = tokens.pop();
				if(t1 == null || t1.p != "end") throw "Unclosed 'else'";
			} else {
				t1.p = HxOverrides.substr(t1.p,4,t1.p.length - 4);
				eelse = this.parse(tokens);
			}
			return haxe._Template.TemplateExpr.OpIf(e,eif,eelse);
		}
		if(HxOverrides.substr(p,0,8) == "foreach ") {
			p = HxOverrides.substr(p,8,p.length - 8);
			var e = this.parseExpr(p);
			var efor = this.parseBlock(tokens);
			var t1 = tokens.pop();
			if(t1 == null || t1.p != "end") throw "Unclosed 'foreach'";
			return haxe._Template.TemplateExpr.OpForeach(e,efor);
		}
		if(haxe.Template.expr_splitter.match(p)) return haxe._Template.TemplateExpr.OpExpr(this.parseExpr(p));
		return haxe._Template.TemplateExpr.OpVar(p);
	}
	,parseBlock: function(tokens) {
		var l = new List();
		while(true) {
			var t = tokens.first();
			if(t == null) break;
			if(!t.s && (t.p == "end" || t.p == "else" || HxOverrides.substr(t.p,0,7) == "elseif ")) break;
			l.add(this.parse(tokens));
		}
		if(l.length == 1) return l.first();
		return haxe._Template.TemplateExpr.OpBlock(l);
	}
	,parseTokens: function(data) {
		var tokens = new List();
		while(haxe.Template.splitter.match(data)) {
			var p = haxe.Template.splitter.matchedPos();
			if(p.pos > 0) tokens.add({ p : HxOverrides.substr(data,0,p.pos), s : true, l : null});
			if(HxOverrides.cca(data,p.pos) == 58) {
				tokens.add({ p : HxOverrides.substr(data,p.pos + 2,p.len - 4), s : false, l : null});
				data = haxe.Template.splitter.matchedRight();
				continue;
			}
			var parp = p.pos + p.len;
			var npar = 1;
			while(npar > 0) {
				var c = HxOverrides.cca(data,parp);
				if(c == 40) npar++; else if(c == 41) npar--; else if(c == null) throw "Unclosed macro parenthesis";
				parp++;
			}
			var params = HxOverrides.substr(data,p.pos + p.len,parp - (p.pos + p.len) - 1).split(",");
			tokens.add({ p : haxe.Template.splitter.matched(2), s : false, l : params});
			data = HxOverrides.substr(data,parp,data.length - parp);
		}
		if(data.length > 0) tokens.add({ p : data, s : true, l : null});
		return tokens;
	}
	,resolve: function(v) {
		if(Reflect.hasField(this.context,v)) return Reflect.field(this.context,v);
		var $it0 = this.stack.iterator();
		while( $it0.hasNext() ) {
			var ctx = $it0.next();
			if(Reflect.hasField(ctx,v)) return Reflect.field(ctx,v);
		}
		if(v == "__current__") return this.context;
		return Reflect.field(haxe.Template.globals,v);
	}
	,execute: function(context,macros) {
		this.macros = macros == null?{ }:macros;
		this.context = context;
		this.stack = new List();
		this.buf = new StringBuf();
		this.run(this.expr);
		return this.buf.b;
	}
	,__class__: haxe.Template
}
if(!haxe.ds) haxe.ds = {}
haxe.ds.StringMap = function() { }
haxe.ds.StringMap.__name__ = true;
haxe.ds.StringMap.__interfaces__ = [IMap];
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
js.Boot.__interfLoop = function(cc,cl) {
	if(cc == null) return false;
	if(cc == cl) return true;
	var intf = cc.__interfaces__;
	if(intf != null) {
		var _g1 = 0, _g = intf.length;
		while(_g1 < _g) {
			var i = _g1++;
			var i1 = intf[i];
			if(i1 == cl || js.Boot.__interfLoop(i1,cl)) return true;
		}
	}
	return js.Boot.__interfLoop(cc.__super__,cl);
}
js.Boot.__instanceof = function(o,cl) {
	if(cl == null) return false;
	switch(cl) {
	case Int:
		return (o|0) === o;
	case Float:
		return typeof(o) == "number";
	case Bool:
		return typeof(o) == "boolean";
	case String:
		return typeof(o) == "string";
	case Dynamic:
		return true;
	default:
		if(o != null) {
			if(typeof(cl) == "function") {
				if(o instanceof cl) {
					if(cl == Array) return o.__enum__ == null;
					return true;
				}
				if(js.Boot.__interfLoop(o.__class__,cl)) return true;
			}
		} else return false;
		if(cl == Class && o.__name__ != null) return true;
		if(cl == Enum && o.__ename__ != null) return true;
		return o.__enum__ == cl;
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
var storage = storage || {}
storage.LocalStorageDetail = function(storageEntity,window) {
	Note.log("LocalStorageDetail constractor");
	this.storageEntity = storageEntity;
	window.addEventListener("storage",$bind(this,this.window_storageHandler));
};
storage.LocalStorageDetail.__name__ = true;
storage.LocalStorageDetail.prototype = {
	calcTotalTime: function(date) {
		var ans = { yesterday : 0, today : 0};
		var lastDate = (function($this) {
			var $r;
			var d = new Date();
			d.setTime($this.unblockState.switchTime);
			$r = d;
			return $r;
		}(this));
		var isSameDay = lastDate.getDay() == date.getDay();
		if(this.unblockState.isUnblock) {
			if(isSameDay) {
				var nowUnblockTimeTotal = date.getTime() - this.unblockState.switchTime;
				ans.today = this.unblockState.todayUnblockTotal + nowUnblockTimeTotal;
				ans.yesterday = this.unblockState.yesterdayUnblockTotal;
			} else {
				var today0HourTime = new Date(date.getFullYear(),date.getMonth(),date.getDate(),0,0,0).getTime();
				ans.yesterday = this.unblockState.todayUnblockTotal + today0HourTime - this.unblockState.switchTime;
				ans.today = date.getTime() - today0HourTime;
			}
		} else if(isSameDay) {
			ans.yesterday = this.unblockState.yesterdayUnblockTotal;
			ans.today = this.unblockState.todayUnblockTotal;
		} else {
			ans.yesterday = this.unblockState.todayUnblockTotal;
			ans.today = 0;
		}
		return ans;
	}
	,createEndUnblockState: function(endDate) {
		var totalTimeKit = this.calcTotalTime(endDate);
		this.unblockState = new storage.UnblockState();
		this.unblockState.isUnblock = false;
		this.unblockState.switchTime = endDate.getTime();
		this.unblockState.yesterdayUnblockTotal = totalTimeKit.yesterday;
		this.unblockState.todayUnblockTotal = totalTimeKit.today;
		this.unblockState.unblockTime = -1;
		return this.unblockState;
	}
	,checkUnblock: function() {
		if(!this.unblockState.isUnblock) return false;
		var date = new Date();
		var endTime = this.unblockState.switchTime + this.unblockState.unblockTime;
		if(date.getTime() < endTime) return true;
		var endDate = (function($this) {
			var $r;
			var d = new Date();
			d.setTime(endTime);
			$r = d;
			return $r;
		}(this));
		this.unblockState = this.createEndUnblockState(endDate);
		this.flushItem("unblockState");
		return false;
	}
	,endUnblock: function() {
		this.unblockState = this.createEndUnblockState(new Date());
		this.flushItem("unblockState");
	}
	,startUnblock: function(unblockTime) {
		var date = new Date();
		var nextUnblockState = new storage.UnblockState();
		nextUnblockState.isUnblock = true;
		if(this.unblockState.isUnblock) {
			var passing = this.unblockState.switchTime - date.getTime();
			nextUnblockState.unblockTime = passing + unblockTime;
			nextUnblockState.switchTime = this.unblockState.switchTime;
			nextUnblockState.yesterdayUnblockTotal = this.unblockState.yesterdayUnblockTotal;
			nextUnblockState.todayUnblockTotal = this.unblockState.todayUnblockTotal;
		} else {
			var totalTimeKit = this.calcTotalTime(date);
			nextUnblockState.switchTime = date.getTime();
			nextUnblockState.yesterdayUnblockTotal = totalTimeKit.yesterday;
			nextUnblockState.todayUnblockTotal = totalTimeKit.today;
			nextUnblockState.unblockTime = unblockTime;
		}
		this.unblockState = nextUnblockState;
		this.flushItem("unblockState");
	}
	,window_storageHandler_: function(key) {
		this.loadData(key);
		if(this.callbackStorageChange != null) this.callbackStorageChange(key);
	}
	,window_storageHandler: function(event) {
		Note.log("window_storage " + Std.string(event));
		var storageEvent = event;
		this.window_storageHandler_(storageEvent.key);
	}
	,setCallback: function(callbackStorageChange) {
		this.callbackStorageChange = callbackStorageChange;
	}
	,loadAllValue: function() {
		var _g = 0, _g1 = ["version","unblockTimeList","unblockTimeDefaultIndex","unblockState","whitelist","whitelistUseRegexp","blacklist","blacklistUseRegexp","laterList"];
		while(_g < _g1.length) {
			var key = _g1[_g];
			++_g;
			this.loadData(key);
		}
	}
	,createAllDefault: function() {
		var _g = 0, _g1 = ["version","unblockTimeList","unblockTimeDefaultIndex","unblockState","whitelist","whitelistUseRegexp","blacklist","blacklistUseRegexp","laterList"];
		while(_g < _g1.length) {
			var key = _g1[_g];
			++_g;
			this.createDefault(key);
		}
	}
	,getVersion: function() {
		var versionText = this.storageEntity.getItem("version");
		if(versionText == null) return -1;
		return Std.parseInt(versionText);
	}
	,createDefault: function(key) {
		switch(key) {
		case "version":
			break;
		case "unblockTimeList":
			this.unblockTimeList = [60000,300000,600000,1200000,1800000,3600000];
			break;
		case "unblockTimeDefaultIndex":
			this.unblockTimeDefaultValue = this.unblockTimeList[1];
			break;
		case "unblockState":
			this.unblockState = storage.UnblockState.createDefault();
			break;
		case "whitelist":
			this.whitelist = ["http://t.co","https://www.google.co.jp/webhp","https://www.google.co.jp/search","https://www.google.com/calendar","https://chrome.google.com/","https://maps.google.co.jp/","https://drive.google.com","https://github.com","http://www.alc.co.jp","http://eow.alc.co.jp"];
			break;
		case "whitelistUseRegexp":
			this.whitelistUseRegexp = false;
			break;
		case "blacklist":
			this.blacklist = [];
			break;
		case "blacklistUseRegexp":
			this.blacklistUseRegexp = false;
			break;
		case "laterList":
			this.laterList = [];
			break;
		default:
			throw "対応していない値です key=" + key;
		}
		this.flushItem(key);
	}
	,getObject: function(key) {
		return haxe.Json.parse(this.storageEntity.getItem(key));
	}
	,getArrayBool: function(key) {
		return this.storageEntity.getItem(key) == "true";
	}
	,getArrayString: function(key) {
		return haxe.Json.parse(this.storageEntity.getItem(key));
	}
	,getArrayFloat: function(key) {
		var list = haxe.Json.parse(this.storageEntity.getItem(key));
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
		Note.log("loadData " + key);
		switch(key) {
		case "version":
			break;
		case "unblockTimeList":
			this.unblockTimeList = this.getArrayFloat(key);
			break;
		case "unblockTimeDefaultIndex":
			this.unblockTimeDefaultValue = Std.parseFloat(this.storageEntity.getItem(key));
			break;
		case "unblockState":
			this.unblockState = storage.UnblockState.createFromJson(this.storageEntity.getItem(key));
			break;
		case "whitelist":
			this.whitelist = this.getArrayString(key);
			break;
		case "whitelistUseRegexp":
			this.whitelistUseRegexp = this.getArrayBool(key);
			break;
		case "blacklist":
			this.blacklist = this.getArrayString(key);
			break;
		case "blacklistUseRegexp":
			this.blacklistUseRegexp = this.getArrayBool(key);
			break;
		case "laterList":
			this.laterList = common.Page.createArrayFromJson(this.getObject(key));
			break;
		default:
			throw "対応していない値です key=" + key;
		}
	}
	,setFloatItem: function(key,value) {
		this.storageEntity.setItem(key,Std.string(value));
	}
	,setIntItem: function(key,value) {
		this.storageEntity.setItem(key,Std.string(value));
	}
	,setBoolItem: function(key,value) {
		this.storageEntity.setItem(key,value?"true":"false");
	}
	,setJsonItem: function(key,value) {
		this.storageEntity.setItem(key,haxe.Json.stringify(value));
	}
	,flushItem: function(key) {
		Note.log("flushItem " + key);
		switch(key) {
		case "version":
			this.setIntItem(key,1);
			break;
		case "unblockTimeList":
			this.setJsonItem(key,this.unblockTimeList);
			break;
		case "unblockTimeDefaultIndex":
			this.setFloatItem(key,this.unblockTimeDefaultValue);
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
		this.window_storageHandler_(key);
	}
	,removeLaterList: function(index) {
		this.laterList.splice(index,1);
		this.flushItem("laterList");
	}
	,addLaterList: function(value) {
		this.laterList.push(value);
		this.flushItem("laterList");
	}
	,getLaterList: function() {
		return common.Page.arrayClone(this.laterList);
	}
	,setBlacklistUseRegexp: function(value) {
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
	,setWhitelistUseRegexp: function(value) {
		this.whitelistUseRegexp = value;
		this.flushItem("whitelistUseRegexp");
		return this.whitelistUseRegexp;
	}
	,addWhitelist: function(value) {
		Note.log("addWhitelist" + Std.string(this.whitelist));
		this.whitelist.push(value);
		this.flushItem("whitelist");
	}
	,setWhitelist: function(value) {
		this.whitelist = value;
		this.flushItem("whitelist");
	}
	,getWhitelist: function() {
		return this.whitelist.slice();
	}
	,getUnblockState: function() {
		return this.unblockState.clone();
	}
	,setUnblockTimeDefaultIndex: function(value) {
		this.unblockTimeDefaultValue = value;
		this.flushItem("unblockTimeDefaultIndex");
		return this.unblockTimeDefaultValue;
	}
	,setUnblockTimeList: function(value) {
		this.unblockTimeList = value;
		this.flushItem("unblockTimeList");
	}
	,getUnblockTimeList: function() {
		return this.unblockTimeList.slice();
	}
	,__class__: storage.LocalStorageDetail
}
storage.LocalStorageFactory = function() {
};
storage.LocalStorageFactory.__name__ = true;
storage.LocalStorageFactory.prototype = {
	create: function(callbackStorageChange,forceClear) {
		var storageDetail = new storage.LocalStorageDetail(js.Browser.getLocalStorage(),js.Browser.window);
		var isFirstChange = false;
		var version = storageDetail.getVersion();
		if(version == -1 || forceClear) {
			storageDetail.createAllDefault();
			Note.log("ストレージデータを生成しました");
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
	,__class__: storage.LocalStorageFactory
}
storage.LocalStorageKey = function() { }
storage.LocalStorageKey.__name__ = true;
storage.LocalStorageKey.KEY_LIST = function() {
	return ["version","unblockTimeList","unblockTimeDefaultIndex","unblockState","whitelist","whitelistUseRegexp","blacklist","blacklistUseRegexp","laterList"];
}
storage.UnblockState = function() {
	this.isUnblock = false;
	this.todayUnblockTotal = 0;
	this.yesterdayUnblockTotal = -1;
	this.switchTime = new Date().getTime();
	this.unblockTime = 0;
};
storage.UnblockState.__name__ = true;
storage.UnblockState.createDefault = function() {
	return new storage.UnblockState();
}
storage.UnblockState.createFromJson = function(jsonText) {
	var jsonData = haxe.Json.parse(jsonText);
	var ans = new storage.UnblockState();
	ans.isUnblock = jsonData.isUnblock;
	ans.todayUnblockTotal = Std.parseFloat(jsonData.todayUnblockTotal);
	ans.yesterdayUnblockTotal = Std.parseFloat(jsonData.yesterdayUnblockTotal);
	ans.switchTime = Std.parseFloat(jsonData.switchTime);
	ans.unblockTime = Std.parseFloat(jsonData.unblockTime);
	return ans;
}
storage.UnblockState.prototype = {
	clone: function() {
		var ans = new storage.UnblockState();
		ans.isUnblock = this.isUnblock;
		ans.todayUnblockTotal = this.todayUnblockTotal;
		ans.yesterdayUnblockTotal = this.yesterdayUnblockTotal;
		ans.switchTime = this.switchTime;
		ans.unblockTime = this.unblockTime;
		return ans;
	}
	,__class__: storage.UnblockState
}
function $iterator(o) { if( o instanceof Array ) return function() { return HxOverrides.iter(o); }; return typeof(o.iterator) == 'function' ? $bind(o,o.iterator) : o.iterator; };
var $_, $fid = 0;
function $bind(o,m) { if( m == null ) return null; if( m.__id__ == null ) m.__id__ = $fid++; var f; if( o.hx__closures__ == null ) o.hx__closures__ = {}; else f = o.hx__closures__[m.__id__]; if( f == null ) { f = function(){ return f.method.apply(f.scope, arguments); }; f.scope = o; f.method = m; o.hx__closures__[m.__id__] = f; } return f; };
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
Date.prototype.__class__ = Date;
Date.__name__ = ["Date"];
var Int = { __name__ : ["Int"]};
var Dynamic = { __name__ : ["Dynamic"]};
var Float = Number;
Float.__name__ = ["Float"];
var Bool = Boolean;
Bool.__ename__ = ["Bool"];
var Class = { __name__ : ["Class"]};
var Enum = { };
if(typeof(JSON) != "undefined") haxe.Json = JSON;
var q = window.jQuery;
js.JQuery = q;
OptionView.MINUTE_TIME = 60000;
OptionView.CHECKBOX_ATTR = "checked";
OptionView.TEXTAREA_ROWS_ATTR = "rows";
OptionView.TEXTAREA_ROWS_MIN = 5;
OptionView.TEXTAREA_ROWS_MAX = 20;
OptionView.SAVE_DISABLED_ATTR = "disabled";
common.StringUtil.DOT_NUM = 3;
common.StringUtil.DOTS = "...";
haxe.Template.splitter = new EReg("(::[A-Za-z0-9_ ()&|!+=/><*.\"-]+::|\\$\\$([A-Za-z0-9_-]+)\\()","");
haxe.Template.expr_splitter = new EReg("(\\(|\\)|[ \r\n\t]*\"[^\"]*\"[ \r\n\t]*|[!+=/><*.&|-]+)","");
haxe.Template.expr_trim = new EReg("^[ ]*([^ ]+)[ ]*$","");
haxe.Template.expr_int = new EReg("^[0-9]+$","");
haxe.Template.expr_float = new EReg("^([+-]?)(?=\\d|,\\d)\\d*(,\\d*)?([Ee]([+-]?\\d+))?$","");
haxe.Template.globals = { };
js.Browser.window = typeof window != "undefined" ? window : null;
storage.LocalStorageDetail.STORAGE_VERSION = 1;
storage.LocalStorageKey.VERSION = "version";
storage.LocalStorageKey.UNBLOCK_TIME_LIST = "unblockTimeList";
storage.LocalStorageKey.UNBLOCK_TIME_DEFAULT_VALUE = "unblockTimeDefaultIndex";
storage.LocalStorageKey.UNBLOCK_STATE = "unblockState";
storage.LocalStorageKey.WHITELIST = "whitelist";
storage.LocalStorageKey.WHITELIST_USE_REGEXP = "whitelistUseRegexp";
storage.LocalStorageKey.BLACKLIST = "blacklist";
storage.LocalStorageKey.BLACKLIST_USE_REGEXP = "blacklistUseRegexp";
storage.LocalStorageKey.LATER_LIST = "laterList";
Option.main();

//@ sourceMappingURL=option.js.map