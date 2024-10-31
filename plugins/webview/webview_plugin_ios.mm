#include "webview_plugin.h"
#include "webview_control.h"
#include "core/config/engine.h"

#import <Foundation/Foundation.h>

/**************************************************************************/
NSString* ToNSString(const String& str) {
    return [NSString stringWithUTF8String:str.utf8().get_data()];
}

NSURL* ToNSURL(const String& str) {
    return [NSURL URLWithString:ToNSString(str)];
}
/**************************************************************************/
class WebviewHandler : public IWebviewHandler
{
    WebviewPlugin* plugin;
    String name;
public:
    WebviewHandler(WebviewPlugin* _plugin, const String& _name)
        : plugin(_plugin)
        , name(_name)
    {
    }
    virtual ~WebviewHandler(){ }

    virtual void ProcessScriptMessage(const String& message) {}
    virtual bool HandleShouldOverrideUrlLoading(const String& Url) { return false; }
    virtual void HandleReceivedTitle(const String& Title) {}
    virtual void HandlePageLoad(const String& InCurrentUrl, bool bIsLoading) {}
    virtual void HandleReceivedError(int ErrorCode, const String& InCurrentUrl) {}
};
/**************************************************************************/

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
        WebviewHandlerPtr handler(new WebviewHandler(this, name));
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
    }
}

void WebviewPlugin::LoadHTMLString(const String &name, const String &html, const String &baseUrl, bool skipEncoding) {
}

void WebviewPlugin::Reload(const String &name) {
    IOSWebViewWrapper* webview = get_webview(name);
    if (webview) {
        [webview reload];
    }
}

void WebviewPlugin::Stop(const String &name) {
    IOSWebViewWrapper* webview = get_webview(name);
    if (webview) {
        [webview stopLoading];
    }
}

String WebviewPlugin::GetUrl(const String &name) {
	IOSWebViewWrapper* webview = get_webview(name);
    if (webview) {
        NSString* currentUrl = [[webview WebView] URL].absoluteString;
        return [currentUrl UTF8String];
    }

    return String();
}

void WebviewPlugin::SetFrame(const String &name, int x, int y, int width, int height) {
    IOSWebViewWrapper* webview = get_webview(name);
    if (webview) {
        CGRect NewFrame;
        NewFrame.origin.x = x;
        NewFrame.origin.y = y;
        NewFrame.size.width = width;
        NewFrame.size.height = height;

        [webview updateframe : NewFrame];
    }
}

void WebviewPlugin::SetPosition(const String &name, int x, int y) {
}

void WebviewPlugin::SetSize(const String &name, int width, int height) {
}

bool WebviewPlugin::Show(const String &name) {
    IOSWebViewWrapper* webview = get_webview(name);
    if (webview) {
        [webview setVisibility:true];
    }
	return false;
}

bool WebviewPlugin::Hide(const String &name) {
    IOSWebViewWrapper* webview = get_webview(name);
    if (webview) {
        [webview setVisibility:false];
    }
	return false;
}

/**************************************************************************/
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
