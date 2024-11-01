#include "webview_plugin.h"
#include "webview_wrapper.h"
#include "core/config/engine.h"

#import <Foundation/Foundation.h>

/**************************************************************************/
NSString* ToNSString(const String& str) {
    return [NSString stringWithUTF8String:str.utf8().get_data()];
}

NSURL* ToNSURL(const String& str) {
    return [NSURL URLWithString:ToNSString(str)];
}

#define LOG_D(msg) printf("%s[%d]" msg "\n",__FUNCTION__, __LINE__)
#define LOG_V(fmt, ...) printf("%s[%d] " fmt "\n",__FUNCTION__, __LINE__, ##__VA_ARGS__)
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
    ClassDB::bind_method(D_METHOD("Init", "name", "x", "y", "width", "height"), &WebviewPlugin::Init);
    ClassDB::bind_method(D_METHOD("Load", "name", "url", "skipEncoding", "readAccessURL"), &WebviewPlugin::Load);
    ClassDB::bind_method(D_METHOD("LoadHTMLString", "name", "html", "baseUrl", "skipEncoding"), &WebviewPlugin::LoadHTMLString);
    ClassDB::bind_method(D_METHOD("Reload", "name"), &WebviewPlugin::Reload);
    ClassDB::bind_method(D_METHOD("Stop", "name"), &WebviewPlugin::Stop);
    ClassDB::bind_method(D_METHOD("SetFrame", "name", "x", "y", "width", "height"), &WebviewPlugin::SetFrame);
    ClassDB::bind_method(D_METHOD("Show", "name"), &WebviewPlugin::Show);
    ClassDB::bind_method(D_METHOD("Hide", "name"), &WebviewPlugin::Hide);
    ClassDB::bind_method(D_METHOD("EvaluateJavaScript", "name", "jsString", "identifier"), &WebviewPlugin::EvaluateJavaScript);
    ClassDB::bind_method(D_METHOD("CanGoBack", "name"), &WebviewPlugin::CanGoBack);
    ClassDB::bind_method(D_METHOD("CanGoForward", "name"), &WebviewPlugin::CanGoForward);
    ClassDB::bind_method(D_METHOD("GoBack", "name"), &WebviewPlugin::GoBack);
    ClassDB::bind_method(D_METHOD("GoForward", "name"), &WebviewPlugin::GoForward);
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
        LOG_V("WebviewPlugin::Create(%s)", name.utf8().ptr());
    } else {
        LOG_V("WebviewPlugin::Create(%s): alreay created", name.utf8().ptr());
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
        [webview loadurl: ToNSURL(url)];
    }
}

void WebviewPlugin::LoadHTMLString(const String &name, const String &html, const String &baseUrl, bool skipEncoding) {
    IOSWebViewWrapper* webview = get_webview(name);
    if (webview) {
        [webview loadstring: ToNSString(html) dummyurl: ToNSURL(baseUrl)];
    }
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

bool WebviewPlugin::Show(const String &name) {
    IOSWebViewWrapper* webview = get_webview(name);
    if (webview) {
        [webview setVisibility:true];
        return true;
    }
	return false;
}

bool WebviewPlugin::Hide(const String &name) {
    IOSWebViewWrapper* webview = get_webview(name);
    if (webview) {
        [webview setVisibility:false];
        return true;
    }
	return false;
}

void WebviewPlugin::EvaluateJavaScript(const String &name, const String &jsString, const String &identifier) {
    IOSWebViewWrapper* webview = get_webview(name);
    if (webview) {
        [webview executejavascript:ToNSString(jsString)];
    }
}

bool WebviewPlugin::CanGoBack(const String &name) {
	IOSWebViewWrapper* webview = get_webview(name);
    if (webview) {
        return [webview canGoBack];
    }
	return false;
}

bool WebviewPlugin::CanGoForward(const String &name) {
	IOSWebViewWrapper* webview = get_webview(name);
    if (webview) {
        return [webview canGoForward];
    }
	return false;
}

void WebviewPlugin::GoBack(const String &name) {
    IOSWebViewWrapper* webview = get_webview(name);
    if (webview) {
        [webview goBack];
    }
}

void WebviewPlugin::GoForward(const String &name) {
    IOSWebViewWrapper* webview = get_webview(name);
    if (webview) {
        [webview goForward];
    }
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
