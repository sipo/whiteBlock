package chrome.remoting;

import js.Dom;
import haxe.remoting.AsyncConnection;

/*
private typedef Data = {
	var id : String;
	var error : String;
}
*/

/**
*/
class ExtensionConnection implements AsyncConnection,
						  implements Dynamic<AsyncConnection> {
	
	var data : { id : String, error : Dynamic->Void };
	var path : Array<String>;
	var div_id : String;
	var event : js.Event;
	var div : Dynamic; //js.HtmlDom;
	var onResult : Dynamic->Void;
	
	function new( data, path, div_id : String = "ext_com" ) {
		
		this.data = data;
		this.path = path;
		this.div_id = div_id;
		
		event = untyped document.createEvent( 'Event' );
		untyped event.initEvent( 'chrome.site.event', true, true );
		div = js.Lib.document.getElementById( div_id );
		div.addEventListener( 'chrome.extension.event', handleContentScriptEvent );
	}
	
	public function resolve( name : String ) : AsyncConnection {
		var c = new ExtensionConnection( data, path.copy(), div_id );
		c.path.push( name );
		return c;
	}

	public function setErrorHandler( h ) {
		data.error = h;
	}
	
	public function call( params : Array<Dynamic>, ?onResult : Dynamic->Void ) {
		this.onResult = onResult;
		var s = new haxe.Serializer();
		s.serialize( path );
		s.serialize( params );
		div.innerText = s.toString();
		div.dispatchEvent( event );	
	}
	
	function handleContentScriptEvent() {
		var v : String = div.innerText;
		var ok = true;
		var ret;
		var error = data.error;
		try {
			if( v.substr( 0, 3 ) != "hxr" )
				throw "Invalid response : '"+v+"'";
			var s = new haxe.Unserializer( v.substr( 3 ) );
			ret = s.unserialize();
		} catch( err : Dynamic ) {
			ret = null;
			ok = false;
			error( err );
		}
		if( ok && onResult != null )
			onResult( ret );
	}
	
	public static function connect( id : String, ?divName : String ) {
		return new ExtensionConnection( { id : id, error : function(e) throw e }, [], divName );
	}
	
}
