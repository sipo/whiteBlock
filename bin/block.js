var Block = function() {
	console.log("constractor block.js");
	var window = js.Browser.window;
	var storage = window.sessionStorage;
	console.log(storage.getItem("checkData"));
};
Block.main = function() {
	Block.mainInstance = new Block();
}
Block.prototype = {
	extension_request: function(request,sender,sendResponse) {
	}
}
var js = js || {}
js.Browser = function() { }
js.Browser.window = typeof window != "undefined" ? window : null;
Block.main();
