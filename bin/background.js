(function () { "use strict";
var $estr = function() { return js.Boot.__string_rec(this,''); };
var Background = function() {
	chrome.tabs.onUpdated.addListener(function(tabId,changedInfo,tab) {
	});
};
Background.main = function() {
	Background.background = new Background();
}
var chrome = {}
chrome.CaptureFormat = { __constructs__ : ["jpeg","png"] }
chrome.CaptureFormat.jpeg = ["jpeg",0];
chrome.CaptureFormat.jpeg.toString = $estr;
chrome.CaptureFormat.jpeg.__enum__ = chrome.CaptureFormat;
chrome.CaptureFormat.png = ["png",1];
chrome.CaptureFormat.png.toString = $estr;
chrome.CaptureFormat.png.__enum__ = chrome.CaptureFormat;
chrome.QueryStatus = { __constructs__ : ["loading","complete"] }
chrome.QueryStatus.loading = ["loading",0];
chrome.QueryStatus.loading.toString = $estr;
chrome.QueryStatus.loading.__enum__ = chrome.QueryStatus;
chrome.QueryStatus.complete = ["complete",1];
chrome.QueryStatus.complete.toString = $estr;
chrome.QueryStatus.complete.__enum__ = chrome.QueryStatus;
chrome.RunAt = { __constructs__ : ["document_start","document_end","document_idle"] }
chrome.RunAt.document_start = ["document_start",0];
chrome.RunAt.document_start.toString = $estr;
chrome.RunAt.document_start.__enum__ = chrome.RunAt;
chrome.RunAt.document_end = ["document_end",1];
chrome.RunAt.document_end.toString = $estr;
chrome.RunAt.document_end.__enum__ = chrome.RunAt;
chrome.RunAt.document_idle = ["document_idle",2];
chrome.RunAt.document_idle.toString = $estr;
chrome.RunAt.document_idle.__enum__ = chrome.RunAt;
chrome.WindowType = { __constructs__ : ["normal","popup","panel","app"] }
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
chrome.WindowState = { __constructs__ : ["normal","minimized","maximized"] }
chrome.WindowState.normal = ["normal",0];
chrome.WindowState.normal.toString = $estr;
chrome.WindowState.normal.__enum__ = chrome.WindowState;
chrome.WindowState.minimized = ["minimized",1];
chrome.WindowState.minimized.toString = $estr;
chrome.WindowState.minimized.__enum__ = chrome.WindowState;
chrome.WindowState.maximized = ["maximized",2];
chrome.WindowState.maximized.toString = $estr;
chrome.WindowState.maximized.__enum__ = chrome.WindowState;
Background.main();
})();
