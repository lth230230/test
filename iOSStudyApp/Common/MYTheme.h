//
//  MYTheme.h
//  iOSStudyApp
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MYTheme : NSObject

+ (UIColor *)primaryColor;
+ (UIColor *)primarySoftColor;
+ (UIColor *)accentColor;
+ (UIColor *)backgroundColor;
+ (UIColor *)cardColor;
+ (UIColor *)textPrimaryColor;
+ (UIColor *)textSecondaryColor;
+ (UIColor *)textTertiaryColor;
+ (UIColor *)successColor;
+ (UIColor *)dividerColor;

+ (UIColor *)tagColorForName:(NSString *)tag;
+ (UIColor *)categoryColorForName:(NSString *)name;

+ (void)applyCardStyleToView:(UIView *)view;
+ (void)applySoftShadowToView:(UIView *)view;
+ (UIButton *)primaryButtonWithTitle:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
