//
//  HomeCell.h
//  iOSStudyApp
//

#import <UIKit/UIKit.h>

@interface HomeCell : UITableViewCell
- (void)configureWithData:(NSDictionary *)data;
- (void)configureWithData:(NSDictionary *)data completed:(BOOL)completed;
@end
