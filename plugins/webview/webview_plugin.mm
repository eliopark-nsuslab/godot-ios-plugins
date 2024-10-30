#include "webview_plugin.h"
#include "webview_control.h"
#include "core/config/engine.h"

#import <Foundation/Foundation.h>

/**************************************************************************/
NSString* ToNSString(const String& str) {
    return [NSString stringWithUTF8String:str.utf8().get_data()];
}

String FromNSString(NSString* str) {
    return [str UTF8String];
}

NSURL* ToNSURL(const String& str) {
    return [NSURL URLWithString:ToNSString(str)];
}
/**************************************************************************/
class WebviewHandler : public IWebviewHandler
{
public:
    virtual ~WebviewHandler(){ }
};

WebviewPlugin* _singleton = nullptr;

void WebviewPlugin::_bind_methods() {
}

WebviewPlugin *WebviewPlugin::get_singleton() {
	return _singleton;
}

WebviewPlugin::WebviewPlugin() {
    _singleton = this;
}

WebviewPlugin::~WebviewPlugin() {
    _singleton = nullptr;
}

void WebviewPlugin::Init(const String &name, int x, int y, int width, int height) {
    if (get_webview(name) == nullptr) {
        IOSWebViewWrapper* webview = [IOSWebViewWrapper alloc];
        WebviewHandlerPtr handler(new WebviewHandler);
        [webview create:handler useTransparency:true];
        add_webview(name, webview);
        print_line("WebviewPlugin::Create(%s)", name);
    } else {
        print_line("WebviewPlugin::Create(%s): alreay created", name);
    }
}

void WebviewPlugin::Destroy(const String& name) {
    IOSWebViewWrapper* webview = get_webview(name);
    if (webview) {
        [webview close];
        remove_webview(name);
    }
}

void WebviewPlugin::Load(const String &name, const String &url, bool skipEncoding, const String &readAccessURL) {
    IOSWebViewWrapper* webview = get_webview(name);
    if (webview) {
        [webview loadurl: ToNSURL(name)];
        //webview->loadurl(ToNSString(name));
    }
}

IOSWebViewWrapper* WebviewPlugin::get_webview(const String &name) {
    auto result = webview_container.find(name.ptr());
    if (result == webview_container.end())
        return nullptr;
    else 
        return result->second;
}

bool WebviewPlugin::add_webview(const String &name, IOSWebViewWrapper* webview) {
    auto result = webview_container.try_emplace(name.ptr(), webview);
    return result.second;
}

bool WebviewPlugin::remove_webview(const String &name) {
    auto result = webview_container.erase(name.ptr());
    return result > 0;
}
