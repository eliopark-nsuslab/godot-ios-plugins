#ifndef WEBVIEW_PLUGIN_H
#define WEBVIEW_PLUGIN_H

#include "core/object/class_db.h"
#include <string>
#include <unordered_map>

#ifdef __OBJC__
@class IOSWebViewWrapper;
#else
typedef void IOSWebViewWrapper;
#endif

class WebviewPlugin : public Object {
	GDCLASS(WebviewPlugin, Object);

	static void _bind_methods();
public:
    static WebviewPlugin *get_singleton();

	WebviewPlugin();
	~WebviewPlugin();

	void Init(const String& name, int x, int y, int width, int height);
	void Destroy(const String& name);
	void Load(const String& name, const String& url, bool skipEncoding, const String& readAccessURL);
	void LoadHTMLString(const String& name, const String& html, const String& baseUrl, bool skipEncoding);
	void Reload(const String& name);
	void Stop(const String& name);
	String GetUrl(const String& name);
	void SetFrame(const String& name, int x, int y, int width, int height);
	//void SetPosition(const String& name, int x, int y);
	//void SetSize(const String& name, int width, int height);
	bool Show(const String& name);
	bool Hide(const String& name);
	void EvaluateJavaScript(const String& name, const String& jsString, const String& identifier);
	bool CanGoBack(const String& name);
	bool CanGoForward(const String& name);
	void GoBack(const String& name);
	void GoForward(const String& name);

private:
	IOSWebViewWrapper* get_webview(const String& name);
	bool add_webview(const String& name, IOSWebViewWrapper* webview);
	bool remove_webview(const String& name);
	
private:
	std::unordered_map<std::u32string, IOSWebViewWrapper*> webview_container;
};

#endif //WEBVIEW_PLUGIN_H