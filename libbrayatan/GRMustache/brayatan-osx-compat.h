/*
 * only certain compilers support __attribute__((deprecated))
 */
#if defined(__has_feature) && defined(__has_attribute)
    #if __has_attribute(deprecated)
        #define DEPRECATED_ATTRIBUTE        __attribute__((deprecated))
        #if __has_feature(attribute_deprecated_with_message)
            #define DEPRECATED_MSG_ATTRIBUTE(s) __attribute__((deprecated(s)))
        #else
            #define DEPRECATED_MSG_ATTRIBUTE(s) __attribute__((deprecated))
        #endif
    #else
        #define DEPRECATED_ATTRIBUTE
        #define DEPRECATED_MSG_ATTRIBUTE(s)
    #endif
#elif defined(__GNUC__) && ((__GNUC__ >= 4) || ((__GNUC__ == 3) && (__GNUC_MINOR__ >= 1)))
    #define DEPRECATED_ATTRIBUTE        __attribute__((deprecated))
    #if (__GNUC__ >= 5) || ((__GNUC__ == 4) && (__GNUC_MINOR__ >= 5))
        #define DEPRECATED_MSG_ATTRIBUTE(s) __attribute__((deprecated(s)))
    #else
        #define DEPRECATED_MSG_ATTRIBUTE(s) __attribute__((deprecated))
    #endif
#else
    #define DEPRECATED_ATTRIBUTE
    #define DEPRECATED_MSG_ATTRIBUTE(s)
#endif

/*
 * only certain compilers support __attribute__((unavailable))
 */
#if defined(__GNUC__) && ((__GNUC__ >= 4) || ((__GNUC__ == 3) && (__GNUC_MINOR__ >= 1)))
    #define UNAVAILABLE_ATTRIBUTE __attribute__((unavailable))
#else
    #define UNAVAILABLE_ATTRIBUTE
#endif

#ifndef NS_ENUM
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#endif

#include <dispatch/dispatch.h>

#if __has_feature(objc_arc)
#else
#define __autoreleasing
#endif
