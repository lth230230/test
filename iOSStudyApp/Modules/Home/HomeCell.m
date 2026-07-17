//
//  HomeCell.m
//  iOSStudyApp
//

#import "HomeCell.h"

@interface HomeCell ()
@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *tagLabel;
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
    self.cardView.backgroundColor = [UIColor whiteColor];
    self.cardView.layer.cornerRadius = 12;
    self.cardView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.cardView.layer.shadowOpacity = 0.04;
    self.cardView.layer.shadowOffset = CGSizeMake(0, 2);
    self.cardView.layer.shadowRadius = 6;
    self.cardView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.cardView];
    
    self.tagLabel = [[UILabel alloc] init];
    self.tagLabel.font = [UIFont systemFontOfSize:10 weight:UIFontWeightBold];
    self.tagLabel.textColor = [UIColor colorWithRed:0.18 green:0.60 blue:0.96 alpha:1.0];
    self.tagLabel.backgroundColor = [[UIColor colorWithRed:0.18 green:0.60 blue:0.96 alpha:1.0] colorWithAlphaComponent:0.1];
    self.tagLabel.layer.cornerRadius = 4;
    self.tagLabel.clipsToBounds = YES;
    self.tagLabel.textAlignment = NSTextAlignmentCenter;
    self.tagLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cardView addSubview:self.tagLabel];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    self.titleLabel.textColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cardView addSubview:self.titleLabel];
    
    self.descLabel = [[UILabel alloc] init];
    self.descLabel.font = [UIFont systemFontOfSize:12];
    self.descLabel.textColor = [UIColor grayColor];
    self.descLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cardView addSubview:self.descLabel];
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.font = [UIFont systemFontOfSize:11];
    self.timeLabel.textColor = [UIColor lightGrayColor];
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    self.timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.cardView addSubview:self.timeLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.cardView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:6],
        [self.cardView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:20],
        [self.cardView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-20],
        [self.cardView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-6],
        
        [self.tagLabel.topAnchor constraintEqualToAnchor:self.cardView.topAnchor constant:14],
        [self.tagLabel.leadingAnchor constraintEqualToAnchor:self.cardView.leadingAnchor constant:16],
        [self.tagLabel.widthAnchor constraintGreaterThanOrEqualToConstant:40],
        [self.tagLabel.heightAnchor constraintEqualToConstant:20],
        
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.cardView.topAnchor constant:14],
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.tagLabel.trailingAnchor constant:10],
        [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.timeLabel.leadingAnchor constant:-8],
        
        [self.timeLabel.centerYAnchor constraintEqualToAnchor:self.titleLabel.centerYAnchor],
        [self.timeLabel.trailingAnchor constraintEqualToAnchor:self.cardView.trailingAnchor constant:-16],
        [self.timeLabel.widthAnchor constraintEqualToConstant:50],
        
        [self.descLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:6],
        [self.descLabel.leadingAnchor constraintEqualToAnchor:self.titleLabel.leadingAnchor],
        [self.descLabel.trailingAnchor constraintEqualToAnchor:self.cardView.trailingAnchor constant:-16],
    ]];
}

- (void)configureWithData:(NSDictionary *)data {
    self.titleLabel.text = data[@"title"];
    self.descLabel.text = data[@"desc"];
    self.timeLabel.text = data[@"time"];
    self.tagLabel.text = data[@"tag"];
    
    NSArray *tagColors = @[
        [UIColor colorWithRed:0.18 green:0.60 blue:0.96 alpha:1.0],
        [UIColor colorWithRed:0.95 green:0.42 blue:0.38 alpha:1.0],
        [UIColor colorWithRed:0.55 green:0.83 blue:0.40 alpha:1.0],
        [UIColor colorWithRed:0.95 green:0.65 blue:0.22 alpha:1.0],
    ];
    UIColor *tagColor = tagColors[arc4random_uniform(4)];
    self.tagLabel.textColor = tagColor;
    self.tagLabel.backgroundColor = [tagColor colorWithAlphaComponent:0.1];
}

@end
