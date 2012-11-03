//
//  PromoCollectionTableViewController.h
//  Parkify
//
//  Created by Me on 10/26/12.
//
//

#import <UIKit/UIKit.h>
#import "Promo.h"
#import "ExtraTypes.h"

@interface PromoCollectionTableViewController : UITableViewController
@property (strong, nonatomic) NSArray* promos;
@property (strong, nonatomic) id<PromoSource> promoSource;

@end
