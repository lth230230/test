//
//  HomeCell.m
//  iOSStudyApp
//

#import "HomeCell.h"
#import "MYTheme.h"

@interface HomeCell ()
@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *tagLabel;
@property (nonatomic, strong) UIImageView *statusIcon;
@end

@implementation HomeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) [self setupUI];
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.cardView = [[UIView alloc] init];
    [MYTheme applyCardStyleToView:self.cardView];
    self.cardView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.cardView];
    
    self.tagLabel = [[UILabel alloc] init];
    self.tagLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightBold];
    self.tagLabel.layer.cornerRadius = 6;
    self.tagLabel.clipsToBounds = YES;
    self.tagLabel.textAlignment = NSTextAlignmentCenter;
    self.tagLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cardView addSubview:self.tagLabel];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    self.titleLabel.textColor = [MYTheme textPrimaryColor];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cardView addSubview:self.titleLabel];
    
    self.descLabel = [[UILabel alloc] init];
    self.descLabel.font = [UIFont systemFontOfSize:13];
    self.descLabel.textColor = [MYTheme textSecondaryColor];
    self.descLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cardView addSubview:self.descLabel];
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    self.timeLabel.textColor = [MYTheme textTertiaryColor];
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    self.timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cardView addSubview:self.timeLabel];
    
    self.statusIcon = [[UIImageView alloc] init];
    self.statusIcon.contentMode = UIViewContentModeScaleAspectFit;
    self.statusIcon.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cardView addSubview:self.statusIcon];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.cardView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:6],
        [self.cardView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20],
        [self.cardView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-20],
        [self.cardView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-6],
        
        [self.tagLabel.topAnchor constraintEqualToAnchor:self.cardView.topAnchor constant:16],
        [self.tagLabel.leadingAnchor constraintEqualToAnchor:self.cardView.leadingAnchor constant:16],
        [self.tagLabel.widthAnchor constraintGreaterThanOrEqualToConstant:44],
        [self.tagLabel.heightAnchor constraintEqualToConstant:22],
        
        [self.titleLabel.centerYAnchor constraintEqualToAnchor:self.tagLabel.centerYAnchor],
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.tagLabel.trailingAnchor constant:10],
        [self.titleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.timeLabel.leadingAnchor constant:-8],
        
        [self.timeLabel.centerYAnchor constraintEqualToAnchor:self.tagLabel.centerYAnchor],
        [self.timeLabel.trailingAnchor constraintEqualToAnchor:self.statusIcon.leadingAnchor constant:-8],
        
        [self.statusIcon.centerYAnchor constraintEqualToAnchor:self.tagLabel.centerYAnchor],
        [self.statusIcon.trailingAnchor constraintEqualToAnchor:self.cardView.trailingAnchor constant:-16],
        [self.statusIcon.widthAnchor constraintEqualToConstant:18],
        [self.statusIcon.heightAnchor constraintEqualToConstant:18],
        
        [self.descLabel.topAnchor constraintEqualToAnchor:self.tagLabel.bottomAnchor constant:10],
        [self.descLabel.leadingAnchor constraintEqualToAnchor:self.cardView.leadingAnchor constant:16],
        [self.descLabel.trailingAnchor constraintEqualToAnchor:self.cardView.trailingAnchor constant:-16],
        [self.descLabel.bottomAnchor constraintLessThanOrEqualToAnchor:self.cardView.bottomAnchor constant:-14],
    ]];
}

- (void)configureWithData:(NSDictionary *)data {
    [self configureWithData:data completed:NO];
}

- (void)configureWithData:(NSDictionary *)data completed:(BOOL)completed {
    self.titleLabel.text = data[@"title"];
    self.descLabel.text = data[@"desc"];
    self.timeLabel.text = data[@"time"];
    
    NSString *tag = data[@"tag"] ?: @"";
    self.tagLabel.text = [NSString stringWithFormat:@"  %@  ", tag];
    UIColor *tagColor = [MYTheme tagColorForName:tag];
    self.tagLabel.textColor = tagColor;
    self.tagLabel.backgroundColor = [tagColor colorWithAlphaComponent:0.12];
    
    if (completed) {
        self.statusIcon.image = [UIImage systemImageNamed:@"checkmark.circle.fill"];
        self.statusIcon.tintColor = [MYTheme successColor];
        self.cardView.alpha = 0.92;
    } else {
        self.statusIcon.image = [UIImage systemImageNamed:@"chevron.right"];
        self.statusIcon.tintColor = [MYTheme textTertiaryColor];
        self.cardView.alpha = 1.0;
    }
}

@end
