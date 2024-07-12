// based on webviewscreensaver by @liquidx
//
// https://github.com/liquidx/webviewscreensaver
//
//  Created by Alastair Tse on 8/8/10.
//
//  Copyright 2015 Alastair Tse.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "NftScreenSaverView.h"
#import "WKWebViewPrivate.h"
#import "nft_screen_saver-Swift.h"

static NSString *const kScreenSaverName = @"NftScreenSaverView";
@interface NftScreenSaverView () <WKUIDelegate, WKNavigationDelegate> @end

@implementation NftScreenSaverView {
    WKWebView *_webView;
    BOOL _isPreview;
}

+ (BOOL)performGammaFade {
    return YES;
}

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview {
    NSUserDefaults *prefs = [ScreenSaverDefaults defaultsForModuleWithName:kScreenSaverName];
    self = [self initWithFrame:frame isPreview:isPreview prefsStore:prefs];
    [NSDistributedNotificationCenter.defaultCenter addObserver:self
                                                      selector:@selector(screensaverWillStop:)
                                                          name:@"com.apple.screensaver.willstop"
                                                        object:nil];
    
    return self;
}

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview prefsStore:(NSUserDefaults *)prefs {
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [self setAutoresizesSubviews:YES];
        _isPreview = isPreview;
        if (_isPreview) {
            // TODO: better preview
            NSBundle *bundle = [NSBundle bundleForClass:self.class];
            NSImageView *logoView = [NSImageView imageViewWithImage:[bundle imageForResource:@"thumbnail"]];
            logoView.frame = self.bounds;
            logoView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
            [self addSubview:logoView];
        }
    }
    return self;
}

- (void)dealloc {
    [NSDistributedNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark NftScreenSaverView

+ (WKWebView *)makeWebView:(NSRect)frame {
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    WKPreferences *preferences = [[WKPreferences alloc] init];
    preferences.javaScriptCanOpenWindowsAutomatically = NO;
    configuration.preferences = preferences;
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:frame configuration:configuration];
    webView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    
    NSColor *color = [NSColor colorWithCalibratedWhite:0.0 alpha:1.0];
    webView.layer.backgroundColor = color.CGColor;
    [webView setValue:@(YES) forKey:@"drawsTransparentBackground"];
    return webView;
}

- (void)startAnimation {
    [super startAnimation];
    if (_isPreview) return;
    _webView = [self.class makeWebView:self.bounds];
    _webView.UIDelegate = self;
    _webView.navigationDelegate = self;
    [_webView wvss_setWindowOcclusionDetectionEnabled: NO];
    [self addSubview:_webView];
    [self loadFromStart];
}

- (void)stopAnimation {
    [super stopAnimation];
    if (!_isPreview) return;
    [_webView removeFromSuperview];
    _webView = nil;
}

#pragma mark Loading URLs

- (void)loadFromStart {
    [self.class load:_webView];
}

+ (void)load:(WKWebView *)webView {
    NSString *html = [ScreenSaverHelper generateHtml];
    [webView loadHTMLString:html baseURL:nil];
}

- (void)animateOneFrame {
    [super animateOneFrame];
}

#pragma mark Focus Overrides

- (NSView *)hitTest:(NSPoint)aPoint {
    return self;
}

- (BOOL)acceptsFirstResponder {
    return NO;
}

- (BOOL)resignFirstResponder {
    return NO;
}

#pragma mark WKNavigationDelegate

- (void)webView:(WKWebView *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if (navigationAction.targetFrame == nil) {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

// Inspired by: https://github.com/JohnCoates/Aerial/commit/8c78e7cc4f77f4417371966ae7666125d87496d1
- (void)screensaverWillStop:(NSNotification *)notification {
    if (@available(macOS 14.0, *)) {
        if (!_isPreview) {
            exit(0);
        }
    }
}

@end
