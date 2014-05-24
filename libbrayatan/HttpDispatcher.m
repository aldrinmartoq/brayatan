//
//  HttpDispatcher.m
//  libbrayatan
//
//  Created by Aldrin Martoq on 5/22/14.
//  Copyright (c) 2014 A0. All rights reserved.
//

#import "HttpDispatcher.h"
#import "Http.h"
#import "HttpController.h"

@implementation HttpDispatcher {
    Http *_http;
    NSString *_templateFolder;
    NSMutableArray *_routes;
}

- (id)initWithIp:(NSString *)ip port:(NSString *)port templateFolder:(NSString *)templateFolder {
    if (self = [super init]) {
        _http = [Http createServerWithIP:ip atPort:port callback:^(HttpRequest *req, HttpResponse *res) {
            br_log_debug("Processing request: %s", [req.urlPath UTF8String]);
            BOOL controlled = NO;
            
            for (NSDictionary *entry in _routes) {
                NSString *route = [entry objectForKey:@"route"];
                Class controller_class = [entry objectForKey:@"controller"];
                NSString *folder = [entry objectForKey:@"folder"];
                folder = (folder == nil) ? _templateFolder : folder;
                br_log_debug("Checking route: %s controller: %s folder: %s", [route UTF8String], [NSStringFromClass(controller_class) UTF8String], [folder UTF8String]);
                if ([req.urlPath hasPrefix:route]) {
                    NSString *path = [req.urlPath substringFromIndex:[route length]];
                    path = [path length] == 0 ? @"index" : path;
                    NSMutableArray *pathElements = [[path componentsSeparatedByString:@"/"] mutableCopy];
                    NSString *method = [pathElements firstObject];
                    [pathElements removeObjectAtIndex:0];
                    path = [pathElements componentsJoinedByString:@"/"];
                    br_log_debug("matched, method: [%s] path: [%s]", [method UTF8String], [path UTF8String]);
                    HttpController *controller = [(HttpController *)[controller_class alloc] initWithTemplateForlder:folder];
                    SEL selector = NSSelectorFromString(method);
                    if ([controller respondsToSelector:selector]) {
                        controlled = YES;
                        // todo este código para ARC no tenga problemas con id response = [controller performSelector:selector];
                        IMP imp = [controller methodForSelector:selector];
                        id (*func)(id, SEL) = (void *)imp;
                        id response = func(controller, selector);
                        if ([response isKindOfClass:[NSString class]]) {
                            [res appendStringToBodyBuffer:response];
                        } else if ([response isKindOfClass:[NSDictionary class]]) {
                            [res dynamicContentForRequest:req Data:response TemplateFolder:folder];
                        }
                    }
                }
                if (controlled) {
                    break;
                }
            }
            if (! controlled) {
                [res staticContentForRequest:req FromFolder:_templateFolder];
            }
            [res send];
        }];
        _routes = [[NSMutableArray alloc] init];
        _templateFolder = templateFolder;
        if (_http == nil || _routes == nil) {
            return nil;
        }
    }

    return self;
}

- (void)addRoute:(NSString *)route withController:(Class)controller {
    [_routes addObject:@{@"route" : route, @"controller" : controller, @"folder" : _templateFolder}];
}

- (void)addRoute:(NSString *)route withStaticContentFromFolder:(NSString *)folder {
    [_routes addObject:@{@"route" : route, @"folder" : folder}];
}

- (NSString *)description {
    NSMutableString *routes = [[NSMutableString alloc] init];
    for (NSDictionary *entry in _routes) {
        NSString *route = [entry objectForKey:@"route"];
        Class controller = [entry objectForKey:@"controller"];
        NSString *folder = [entry objectForKey:@"folder"];
        if (route != nil && controller != nil) {
            [routes appendFormat:@"route: %-20s controller: %-20s folder: %-20s\n", [route UTF8String], [NSStringFromClass(controller) UTF8String], [folder UTF8String]];
        }
    }
    
    return [NSString stringWithFormat:@"HttpDispatcher: 0x%llx %@ configured with %lu routes:\n%@", (unsigned long long)self, _http, [_routes count], routes];
}

- (void)runloop {
    [Http runloop];
}

+ (instancetype)dispatcherWithIP:(NSString *)ip port:(NSString *)port templateFolder:(NSString *)templateFolder {
    return [[HttpDispatcher alloc] initWithIp:ip port:port templateFolder:templateFolder];
}

@end
