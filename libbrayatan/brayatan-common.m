//
//  brayatan-common.m
//  libbrayatan
//
//  Created by Aldrin Martoq on 7/6/14.
//  Copyright (c) 2014 A0. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "brayatan-common.h"

NSString *br_time_fmt_gmt(time_t t) {
    static char *week[7] = { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" };
    static char *month[12] = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" };
    struct tm *gtm = gmtime(&t);
    gtm->tm_year += 1900;
    return [NSString stringWithFormat:@"%s, %02d %s %d %02d:%02d:%02d GMT", week[gtm->tm_wday], gtm->tm_mday, month[gtm->tm_mon], gtm->tm_year, gtm->tm_hour, gtm->tm_min, gtm->tm_sec];
}

NSString *br_time_fmt_gmt_now() {
    return br_time_fmt_gmt(time(NULL));
}