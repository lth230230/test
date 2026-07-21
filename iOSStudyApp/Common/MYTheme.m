//
//  MYTheme.m
//  iOSStudyApp
//

#import "MYTheme.h"

@implementation MYTheme

+ (UIColor *)primaryColor {
    return [UIColor colorWithRed:0.10 green:0.45 blue:0.56 alpha:1.0];
}

+ (UIColor *)primarySoftColor {
    return [[self primaryColor] colorWithAlphaComponent:0.10];
}

+ (UIColor *)accentColor {
    return [UIColor colorWithRed:0.93 green:0.55 blue:0.22 alpha:1.0];
}

+ (UIColor *)backgroundColor {
    return [UIColor colorWithRed:0.94 green:0.96 blue:0.97 alpha:1.0];
}

+ (UIColor *)cardColor {
    return [UIColor whiteColor];
}

+ (UIColor *)textPrimaryColor {
    return [UIColor colorWithRed:0.12 green:0.16 blue:0.20 alpha:1.0];
}

+ (UIColor *)textSecondaryColor {
    return [UIColor colorWithRed:0.40 green:0.46 blue:0.52 alpha:1.0];
}

+ (UIColor *)textTertiaryColor {
    return [UIColor colorWithRed:0.62 green:0.67 blue:0.72 alpha:1.0];
}

+ (UIColor *)successColor {
    return [UIColor colorWithRed:0.22 green:0.68 blue:0.45 alpha:1.0];
}

+ (UIColor *)dividerColor {
    return [UIColor colorWithWhite:0.90 alpha:1.0];
}

+ (UIColor *)tagColorForName:(NSString *)tag {
    NSDictionary *map = @{
        @"入门": [UIColor colorWithRed:0.22 green:0.68 blue:0.45 alpha:1.0],
        @"进阶": [self primaryColor],
        @"核心": [UIColor colorWithRed:0.90 green:0.40 blue:0.32 alpha:1.0],
        @"高阶": [UIColor colorWithRed:0.55 green:0.38 blue:0.72 alpha:1.0],
        @"实战": [self accentColor],
    };
    return map[tag] ?: [self primaryColor];
}

+ (UIColor *)categoryColorForName:(NSString *)name {
    NSDictionary *map = @{
        @"teal": [self primaryColor],
        @"coral": [UIColor colorWithRed:0.90 green:0.40 blue:0.32 alpha:1.0],
        @"green": [UIColor colorWithRed:0.22 green:0.68 blue:0.45 alpha:1.0],
        @"amber": [self accentColor],
        @"slate": [UIColor colorWithRed:0.35 green:0.45 blue:0.55 alpha:1.0],
        @"ocean": [UIColor colorWithRed:0.18 green:0.52 blue:0.72 alpha:1.0],
    };
    return map[name] ?: [self primaryColor];
}

+ (void)applyCardStyleToView:(UIView *)view {
    view.backgroundColor = [self cardColor];
    view.layer.cornerRadius = 14;
    view.layer.masksToBounds = NO;
    [self applySoftShadowToView:view];
}

+ (void)applySoftShadowToView:(UIView *)view {
    view.layer.shadowColor = [UIColor colorWithRed:0.10 green:0.20 blue:0.30 alpha:1.0].CGColor;
    view.layer.shadowOpacity = 0.08;
    view.layer.shadowOffset = CGSizeMake(0, 4);
    view.layer.shadowRadius = 10;
}

+ (UIButton *)primaryButtonWithTitle:(NSString *)title {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    btn.backgroundColor = [self primaryColor];
    btn.layer.cornerRadius = 22;
    btn.clipsToBounds = YES;
    return btn;
}

@end
