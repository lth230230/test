//
//  HomeHeaderView.h
//  iOSStudyApp
//

#import <UIKit/UIKit.h>

@interface HomeHeaderView : UIView

@property (nonatomic, strong, readonly) UIButton *continueBtn;
@property (nonatomic, copy) void (^onContinue)(void);

- (void)refresh;

@end
