#ifndef WEBVIEW_CONTROL_H
#define WEBVIEW_CONTROL_H

#include "core/object/class_db.h"
#include <memory>

class IWebviewHandler
{
public:
    virtual ~IWebviewHandler() = 0;
    virtual void ProcessScriptMessage(const String& message) {}
    virtual bool HandleShouldOverrideUrlLoading(const String& Url) { return false; }
    virtual void HandleReceivedTitle(const String& Title) {}
    virtual void HandlePageLoad(const String& InCurrentUrl, bool bIsLoading) {}
    virtual void HandleReceivedError(int ErrorCode, const String& InCurrentUrl) {}
};

typedef std::shared_ptr<IWebviewHandler> WebviewHandlerPtr;

#ifdef __OBJC__
#import <WebKit/WebKit.h>
#import <MetalKit/MetalKit.h>

@interface IOSWebViewWrapper : NSObject <WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>
{
    WebviewHandlerPtr WebBrowserWidget;
//	FTextureRHIRef VideoTexture;
	bool bNeedsAddToView;
	bool bVideoTextureValid;
}
@property(strong) WKWebView* WebView;
@property(strong) UIView* WebViewContainer;
@property(copy) NSURL* NextURL;
@property(copy) NSString* NextContent;
@property CGRect DesiredFrame;

-(void)create:(WebviewHandlerPtr)InWebBrowserWidget useTransparency : (bool)InUseTransparency;
-(void)close;
-(void)dealloc;
-(void)updateframe:(CGRect)InFrame;
-(void)loadstring:(NSString*)InString dummyurl:(NSURL*)InURL;
-(void)loadurl:(NSURL*)InURL;
-(void)executejavascript:(NSString*)InJavaScript;
-(void)setDefaultVisibility;
-(void)setVisibility:(bool)InIsVisible;
-(void)stopLoading;
-(void)reload;
-(void)goBack;
-(void)goForward;
-(bool)canGoBack;
-(bool)canGoForward;
//-(FTextureRHIRef)GetVideoTexture;
//-(void)SetVideoTexture:(FTextureRHIRef)Texture;
-(void)SetVideoTextureValid:(bool)Condition;
-(bool)IsVideoTextureValid;
-(bool)UpdateVideoFrame:(void*)ptr;
-(void)updateWebViewMetalTexture : (id<MTLTexture>)texture;
-(void)webView:(WKWebView*)InWebView decidePolicyForNavigationAction : (WKNavigationAction*)InNavigationAction decisionHandler : (void(^)(WKNavigationActionPolicy))InDecisionHandler;
-(void)webView:(WKWebView*)InWebView didCommitNavigation : (WKNavigation*)InNavigation;
@end

#else
typedef void IOSWebViewWrapper;
#endif

#endif //WEBVIEW_CONTROL_H