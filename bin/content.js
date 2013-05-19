/**
 * Created with IntelliJ IDEA.
 * User: sipo
 * Date: 13/05/19
 * Time: 11:48
 * To change this template use File | Settings | File Templates.
 */
console.log("contents");
chrome.extension.sendRequest({greeting: "hello"}, function(response) {
  console.log(response.farewell);
});
