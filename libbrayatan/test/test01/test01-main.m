//
//  test01-main.m
//  brayatan
//
//  Created by Aldrin Martoq on 7/3/14.
//  Copyright (c) 2014 A0. All rights reserved.
//

#import "Http.h"

static char *response = "HTTP/1.1 200 OK \n\
Date: Fri, 04 Jul 2014 10:31:17 GMT \n\
Server: Apache/2.2.26 (Unix) DAV/2 PHP/5.4.24 mod_ssl/2.2.26 OpenSSL/0.9.8y \n\
Content-Location: index.html.en \n\
Vary: negotiate \n\
TCN: choice \n\
Last-Modified: Tue, 02 Apr 2013 13:19:09 GMT \n\
Accept-Ranges: bytes \n\
Connection: close \n\
Content-Type: text/html \n\
Content-Language: en \n\
\n\
HOLA %d\n\
";

void http_test() {
    __block int count = 0;
    [Http createServerWithIP:@"0.0.0.0" atPort:@"9999" callback:^(HttpRequest *req, HttpResponse *res) {
        count++;
        BRDebugLog(@"HOLA %3d %@ %@", count, req, res);
        BRDebugLog(@"HEADERS: %@", req.headers);
        [res appendStringToBodyBuffer:@"OK!"];
        [res send];
        BRDebugLog(@"OK");
    }];
    
    [Http runloop];
}

void server_test() {
    __block int count = 0;
    BRServer *server = [[BRServer alloc] initWithHostname:@"0.0.0.0" serviceName:@"9999"];
    server.on_accept_client =  ^void(BRServer *server, BRClient *client) {
        BRDebugLog(@"%@ ACCEPT %@", server, client);
        count++;
    };
    
    server.on_read_client = ^void(BRServer *server, BRClient *client, NSData *data) {
        NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        BRDebugLog(@"%@ READ   %@: %@", server, client, s);
        if ([s hasPrefix:@"w"]) {
            BRDebugLog(@"%@ READ   %@: sending file %@", server, client, @"/tmp/ya.html");
            [client write_file:@"/tmp/ya.html" onOpen:^BOOL(struct stat stat) {
                return YES;
            } onError:^(int err) {
                BRErrorLog(@"%@ FATAL ERROR: %s", client, strerror(err));
            }];
            [client write_close];
        } else if ([s hasPrefix:@"G"]) {
            NSString *string = [NSString stringWithUTF8String:response];
            BRDebugLog(@"%@ READ   %@: sending data %@", server, client, string);
            [client write_string:string];
            [client write_close];
        }
    };
    
    server.on_close_client = ^void(BRServer *server, BRClient *client) {
        BRDebugLog(@"%@ CLOSE  %@", server, client);
    };
    
    [server start_server];
}



int main(int argc, char **argv) {
    BRInforLog(@"STARTING %s", __FUNCTION__);
    server_test();
//    http_test();
    [Http runloop];
}