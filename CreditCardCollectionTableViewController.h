//
//  CreditCardCollectionTableViewController.h
//  Parkify
//
//  Created by Me on 10/25/12.
//
//

#import <UIKit/UIKit.h>
#import "CreditCard.h"
#import "ExtraTypes.h"

@interface CreditCardCollectionTableViewController : UITableViewController
@property (strong, nonatomic) NSArray* creditCards;
@property (strong, nonatomic) id<CreditCardsSource> creditCardsSource;
@end
