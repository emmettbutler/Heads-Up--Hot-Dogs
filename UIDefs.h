#define IPAD_SCALE_FACTOR_X 2.1333333333
#define IPAD_SCALE_FACTOR_Y 2.4
#define IPHONE_4_INCH_SCALE_FACTOR_X 1.18
#define IPHONE_HEADER_TEXT_SIZE 50.0
#define IPAD_HEADER_TEXT_SiZE 90.0
#define BASE_X_RESOLUTION 480

#define VERSION_STRING @"1.0"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)