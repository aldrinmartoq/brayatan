#import <Foundation/Foundation.h>

/* This is a hack because neither Apple's CoreFoundation nor GNUstep's CoreFoundation work well with clang ARC.
   Please Note file is not compiled in Xcode.
 */
void CFRelease(id o) {
  [o release];
}
