//
//  LocalizationSystem.h
//
//  Created by Martins Rudens.
//  Copyright (c) 2014 RUDENS. All rights reserved.
//

#import "LocalizationSystem.h"

@interface LocalizationSystem()
@property (nonatomic, strong) NSArray *bundles;
@end

@implementation LocalizationSystem

#pragma mark - NSObject

+ (LocalizationSystem *)sharedInstance
{
    static LocalizationSystem *_default = nil;
    if (_default != nil) {
        return _default;
    }
    static dispatch_once_t safer;
    dispatch_once(&safer, ^(void) {
        _default = [LocalizationSystem new];
    });
    return _default;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSString *language = [[NSUserDefaults standardUserDefaults] objectForKey:@"ICPreferredLanguage"];
        if (language && ![language isEqualToString:@""]) {
            [self setLanguage:language];
        }
        else {
            self.bundles = [[NSArray alloc] initWithObjects:[NSBundle mainBundle], nil];
        }
    }
    return self;
}

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName;
{
    @try {
        NSBundle *bundle = [self.bundles objectAtIndex:0];
        return [bundle localizedStringForKey:key value:value table:tableName];
    }
    @catch (NSException *exception) {
        
    }
    return key;
}

- (NSMutableArray *)preferredLanguages
{
    return [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"]];
}

- (void)setLanguage:(NSString *)language
{
    NSMutableArray *appleLangs = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"]];
    [appleLangs removeObject:language];
    [appleLangs insertObject:language atIndex:0];
    [[NSUserDefaults standardUserDefaults] setObject:appleLangs forKey:@"AppleLanguages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] setObject:language forKey:@"ICPreferredLanguage"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSMutableArray *languages = [NSMutableArray array];
	NSString *path = [[NSBundle mainBundle] pathForResource:language ofType:@"lproj" ];
    if (nil != path) {
        [languages addObject:[NSBundle bundleWithPath:path]];
    }
	if ([language rangeOfString:@"-"].location != NSNotFound) {
		language = [[language componentsSeparatedByString:@"-"] objectAtIndex:0];
        path = [[NSBundle mainBundle] pathForResource:language ofType:@"lproj" ];
        if (nil != path) {
            [languages addObject:[NSBundle bundleWithPath:path]];
        }
    }
    [languages addObject:[NSBundle mainBundle]];
    self.bundles = languages;
}

- (NSString *)language
{
    NSString *lang = [[NSUserDefaults standardUserDefaults] objectForKey:@"ICPreferredLanguage"];
    if (!lang) {
        NSMutableArray *appleLangs = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"]];
        lang = [appleLangs objectAtIndex:0];
    }
    return lang;
}

@end
