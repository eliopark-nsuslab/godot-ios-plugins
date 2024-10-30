#include "webview_control.h"

#import "app_delegate.h"
#import "godot_view.h"
#import "view_controller.h"

@implementation IOSWebViewWrapper

@synthesize WebView;
@synthesize WebViewContainer;
@synthesize NextURL;
@synthesize NextContent;

-(void)create:(WebviewHandlerPtr)InWebBrowserWidget useTransparency : (bool)InUseTransparency
{
    WebBrowserWidget = InWebBrowserWidget;
	NextURL = nil;
	NextContent = nil;
	//VideoTexture = nil;
	bNeedsAddToView = true;
	bVideoTextureValid = false;

#if !PLATFORM_TVOS
	dispatch_async(dispatch_get_main_queue(), ^
	{
		WebViewContainer = [[UIView alloc]initWithFrame:CGRectMake(1, 1, 100, 100)];
		[self.WebViewContainer setOpaque : NO];
		[self.WebViewContainer setBackgroundColor : [UIColor clearColor]];

		WKWebViewConfiguration *theConfiguration = [[WKWebViewConfiguration alloc] init];
		//NSString* MessageHandlerName = [NSString stringWithFString : FMobileJSScripting::JSMessageHandler];
		//[theConfiguration.userContentController addScriptMessageHandler:self name: MessageHandlerName];

		WebView = [[WKWebView alloc]initWithFrame:CGRectMake(1, 1, 100, 100)  configuration : theConfiguration];
		[self.WebViewContainer addSubview : WebView];
		WebView.navigationDelegate = self;
		WebView.UIDelegate = self;

		WebView.scrollView.bounces = NO;

		if (InUseTransparency)
		{
			[self.WebView setOpaque : NO];
			[self.WebView setBackgroundColor : [UIColor clearColor]];
		}
		else
		{
			[self.WebView setOpaque : YES];
		}

		//[theConfiguration release];
		[self setDefaultVisibility];
	});
#endif
}

-(void)close;
{
#if !PLATFORM_TVOS
	WebView.navigationDelegate = nil;
	dispatch_async(dispatch_get_main_queue(), ^
	{
		[self.WebViewContainer removeFromSuperview];
		[self.WebView removeFromSuperview];
		
		//[WebView release];
		//[WebViewContainer release];

		WebView = nil;
		WebViewContainer = nil;

		WebBrowserWidget.reset();
	});
#endif
}

-(void)dealloc;
{
#if !PLATFORM_TVOS
	if (WebView != nil)
	{
		WebView.navigationDelegate = nil;
		//[WebView release];
		WebView = nil;
	};

	//[WebViewContainer release];
	WebViewContainer = nil;
#endif
	//[NextContent release];
	NextContent = nil;
	//[NextURL release];
	NextURL = nil;

	//[super dealloc];

	WebBrowserWidget.reset();
}

-(void)updateframe:(CGRect)InFrame;
{
	self.DesiredFrame = InFrame;

#if !PLATFORM_TVOS
	dispatch_async(dispatch_get_main_queue(), ^
	{
		if (WebView != nil)
		{
			WebViewContainer.frame = self.DesiredFrame;
			WebView.frame = WebViewContainer.bounds;
			if (bNeedsAddToView)
			{
				bNeedsAddToView = false;
				//[[IOSAppDelegate GetDelegate].IOSView addSubview : WebViewContainer];
                UIView *view = AppDelegate.viewController.godotView;
                [view addSubview:WebViewContainer];
			}
			else
			{
				if (NextContent != nil)
				{
					// Load web content from string
					[self.WebView loadHTMLString : NextContent baseURL : NextURL];
					NextContent = nil;
					NextURL = nil;
				}
				else
					if (NextURL != nil)
					{
						// Load web content from URL
						NSURLRequest *nsrequest = [NSURLRequest requestWithURL : NextURL];
						[self.WebView loadRequest : nsrequest];
						NextURL = nil;
					}
			}
		}
	});
#endif
}

-(NSString *)UrlDecode:(NSString *)stringToDecode
{
	NSString *result = [stringToDecode stringByReplacingOccurrencesOfString : @"+" withString:@" "];
	result = [result stringByRemovingPercentEncoding];
	return result;
}

#if !PLATFORM_TVOS
-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage : (WKScriptMessage *)message
{
	if ([message.body isKindOfClass : [NSString class]])
	{
		NSString *Message = message.body;
		if (Message != nil)
		{
			NSLog(@"Received message %@", Message);
			WebBrowserWidget->ProcessScriptMessage([Message UTF8String]);
		}

	}
}
#endif

-(void)executejavascript:(NSString*)InJavaScript
{
#if !PLATFORM_TVOS
	dispatch_async(dispatch_get_main_queue(), ^
	{
	//	NSLog(@"executejavascript %@", InJavaScript);
		[self.WebView evaluateJavaScript : InJavaScript completionHandler : nil];
	});
#endif
}

-(void)loadurl:(NSURL*)InURL;
{
	dispatch_async(dispatch_get_main_queue(), ^
	{
		self.NextURL = InURL;
	});
}

-(void)loadstring:(NSString*)InString dummyurl : (NSURL*)InURL;
{
	dispatch_async(dispatch_get_main_queue(), ^
	{
		self.NextContent = InString;
		self.NextURL = InURL;
	});
}

//-(void)set3D:(bool)InIsIOS3DBrowser;
//{
//	dispatch_async(dispatch_get_main_queue(), ^
//	{
//		if (IsIOS3DBrowser != InIsIOS3DBrowser)
//		{
//			//default is 2D
//			IsIOS3DBrowser = InIsIOS3DBrowser;
//			[self setDefaultVisibility];
//		}
//	});
//}

-(void)setDefaultVisibility;
{
#if !PLATFORM_TVOS
	dispatch_async(dispatch_get_main_queue(), ^
	{
		//if (IsIOS3DBrowser)
        if (false)
		{
			[self.WebViewContainer setHidden : YES];
		}
		else
		{
			[self.WebViewContainer setHidden : NO];
		}
	});
#endif
}

-(void)setVisibility:(bool)InIsVisible;
{
#if !PLATFORM_TVOS
	dispatch_async(dispatch_get_main_queue(), ^
	{
		if (InIsVisible)
		{
			[self setDefaultVisibility];
		}
		else
		{
			[self.WebViewContainer setHidden : YES];
		}
	});
#endif
}

-(void)stopLoading;
{
#if !PLATFORM_TVOS
	dispatch_async(dispatch_get_main_queue(), ^
	{
		[self.WebView stopLoading];
	});
#endif
}

-(void)reload;
{
#if !PLATFORM_TVOS
	dispatch_async(dispatch_get_main_queue(), ^
	{
		[self.WebView reload];
	});
#endif
}

-(void)goBack;
{
#if !PLATFORM_TVOS
	dispatch_async(dispatch_get_main_queue(), ^
	{
		[self.WebView goBack];
	});
#endif
}

-(void)goForward;
{
#if !PLATFORM_TVOS
	dispatch_async(dispatch_get_main_queue(), ^
	{
		[self.WebView goForward];
	});
#endif
}

-(bool)canGoBack;
{
#if PLATFORM_TVOS
	return false;
#else
	return [self.WebView canGoBack];
#endif
}

-(bool)canGoForward;
{
#if PLATFORM_TVOS
	return false;
#else
	return [self.WebView canGoForward];
#endif
}

//-(FTextureRHIRef)GetVideoTexture;
//{
//	return VideoTexture;
//}
//
//-(void)SetVideoTexture:(FTextureRHIRef)Texture;
//{
//	VideoTexture = Texture;
//}

-(void)SetVideoTextureValid:(bool)Condition;
{
	bVideoTextureValid = Condition;
}

-(bool)IsVideoTextureValid;
{
	return bVideoTextureValid;
}

-(bool)UpdateVideoFrame:(void*)ptr;
{
#if !PLATFORM_TVOS
	@synchronized(self) // Briefly block render thread
	{
		id<MTLTexture> ptrToMetalTexture = (__bridge id<MTLTexture>)ptr;
		//NSUInteger width = [ptrToMetalTexture width];
		//NSUInteger height = [ptrToMetalTexture height];

		[self updateWebViewMetalTexture : ptrToMetalTexture];
	}
#endif
	return true;
}

-(void)updateWebViewMetalTexture:(id<MTLTexture>)texture
{
#if !PLATFORM_TVOS
	@autoreleasepool {
		UIGraphicsBeginImageContextWithOptions(WebView.frame.size, NO, 1.0f);
		[WebView drawViewHierarchyInRect : WebView.bounds afterScreenUpdates : NO];
		UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		NSUInteger width = [texture width];
		NSUInteger height = [texture height];
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 4 * width, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
		CGContextDrawImage(context, CGRectMake(0, 0, width, height), image.CGImage);
		[texture replaceRegion : MTLRegionMake2D(0, 0, width, height)
			mipmapLevel : 0
			withBytes : CGBitmapContextGetData(context)
			bytesPerRow : 4 * width];
		CGColorSpaceRelease(colorSpace);
		CGContextRelease(context);
		image = nil;
	}
#endif
}

#if !PLATFORM_TVOS
- (void)webView:(WKWebView*)InWebView decidePolicyForNavigationAction : (WKNavigationAction*)InNavigationAction decisionHandler : (void(^)(WKNavigationActionPolicy))InDecisionHandler
{
	NSURLRequest *request = InNavigationAction.request;
	NSString* UrlStr = [[request URL] absoluteString];
	
	WebBrowserWidget->HandleShouldOverrideUrlLoading([UrlStr UTF8String]);
	InDecisionHandler(WKNavigationActionPolicyAllow);
}

-(void)webView:(WKWebView *)InWebView didCommitNavigation : (WKNavigation *)InNavigation
{
	NSString* CurrentUrl = [self.WebView URL].absoluteString;
	NSString* Title = [self.WebView title];
	
	NSLog(@"didCommitNavigation: %@", CurrentUrl);
	WebBrowserWidget->HandleReceivedTitle([Title UTF8String]);
	WebBrowserWidget->HandlePageLoad([CurrentUrl UTF8String], true);
}

-(void)webView:(WKWebView *)InWebView didFinishNavigation : (WKNavigation *)InNavigation
{
	NSString* CurrentUrl = [self.WebView URL].absoluteString;
	NSString* Title = [self.WebView title];
	NSLog(@"didFinishNavigation: %@", CurrentUrl);
	WebBrowserWidget->HandleReceivedTitle([Title UTF8String]);
	WebBrowserWidget->HandlePageLoad([CurrentUrl UTF8String], false);
}
-(void)webView:(WKWebView *)InWebView didFailNavigation : (WKNavigation *)InNavigation withError : (NSError*)InError
{
	if (InError.domain == NSURLErrorDomain && InError.code == NSURLErrorCancelled)
	{
		//ignore this one, interrupted load
		return;
	}
	NSString* CurrentUrl = [InError.userInfo objectForKey : @"NSErrorFailingURLStringKey"];
	NSLog(@"didFailNavigation: %@, error %@", CurrentUrl, InError);
	WebBrowserWidget->HandleReceivedError(InError.code, [CurrentUrl UTF8String]);
}
#endif

@end

