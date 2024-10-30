#include "webview.h"
#include "webview_plugin.h"
#include "core/config/engine.h"

WebviewPlugin *plugin = nullptr;

void init_ios_webview() {
    plugin = memnew(WebviewPlugin);
	Engine::get_singleton()->add_singleton(Engine::Singleton("WebviewPlugin", plugin));
}

void deinit_ios_webview() {
    if (plugin) {
		memdelete(plugin);
        plugin = nullptr;
	}
}