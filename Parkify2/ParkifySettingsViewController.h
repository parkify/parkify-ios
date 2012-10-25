//
//  ParkifySettingsViewController.h
//  Parkify
//
//  Created by Me on 8/24/12.
//
//

#import <UIKit/UIKit.h>

@interface ParkifySettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
- (IBAction)cancelButtonTapped:(UIBarButtonItem *)sender;
- (IBAction)aboutButtonTapped:(UIButton*)sender;
- (IBAction)authButtonTapped:(UIButton *)sender;

@property (strong, nonatomic) NSArray* tableData;
@property (strong, nonatomic) NSArray* tableImages;
@property (strong, nonatomic) NSArray* tableOnTap;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)testTapped:(id)sender;

- (IBAction)callParkify:(UIButton *)sender;

@end
