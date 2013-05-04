var Block = function() {
	console.log("constractor block.js");
	var storage = window.localStorage;
	console.log(storage.getItem("checkData"));
};
Block.main = function() {
	Block.mainInstance = new Block();
}
Block.prototype = {
	extension_request: function(request,sender,sendResponse) {
	}
}
Block.main();
