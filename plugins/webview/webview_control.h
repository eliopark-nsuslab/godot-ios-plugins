#ifndef WEBVIEW_CONTROL_H
#define WEBVIEW_CONTROL_H

#include "core/object/class_db.h"

class WebviewControl : public Object
{
    GDCLASS(WebviewControl, Object);

    static void _bind_methods();

public:
    WebviewControl();
    ~WebviewControl();
};

#endif //WEBVIEW_CONTROL_H