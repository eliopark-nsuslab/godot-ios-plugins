#include "webview_plugin.h"
#include "webview_control.h"

void init_ios_webview() {
    ClassDB::register_class<WebviewControl>();
}

void deinit_ios_webview() {
}
