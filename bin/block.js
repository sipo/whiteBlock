var Block = function() {
	console.log("constractor block.js");
	chrome.extension.onRequest.addListener($bind(this,this.extension_request));
};
Block.main = function() {
}
Block.prototype = {
	extension_request: function(request,sender,sendResponse) {
		console.log("extension_request");
		sendResponse({ });
	}
}
var $_;
function $bind(o,m) { var f = function(){ return f.method.apply(f.scope, arguments); }; f.scope = o; f.method = m; return f; };
Block.main();
