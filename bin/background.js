(function () { "use strict";
var $estr = function() { return js.Boot.__string_rec(this,''); };
var Background = function() {
};
Background.__name__ = true;
Background.main = function() {
	chrome.tabs.onUpdated.addListener(function(tabId,changedInfo,tab) {
		js.Lib.alert("ok");
	});
}
var chrome = {}
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
var js = {}
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
js.Lib = function() { }
js.Lib.__name__ = true;
js.Lib.alert = function(v) {
	alert(js.Boot.__string_rec(v,""));
}
String.__name__ = true;
Array.__name__ = true;
Background.main();
})();
