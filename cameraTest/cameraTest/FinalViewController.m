//
//  TableViewController.m
//  cameraTest
//
//  Created by Michael Chen on 1/10/15.
//  Copyright (c) 2015 Michael Chen. All rights reserved.
//

#import "FinalViewController.h"
#import "Receipts.h"
#import "Users.h"
#import <Venmo-iOS-SDK/Venmo.h>

@implementation FinalViewController
{
    NSArray *tableData;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Initialize table data
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [users count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"Final List";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = getUsername(users, indexPath.row);
    double usertotal = getUserTotal(filteredReceipt, indexPath.row);
    double tax = getPrice(receipt, @"tax");
    double total = getTotal(filteredReceipt);
    double adjusted = adjustForTaxes(usertotal, total, tax);
    cell.detailTextLabel.text = [NSString stringWithFormat: @"$%.2f", adjusted];
    return cell;
}

//- (void)viewDidLoad {
//    [super viewDidLoad];
//    // Do any additional setup after loading the view.
//
//    // Create the colors
//    UIColor *darkOp =
//    [UIColor colorWithRed:0.00f green:0.75f blue:2.45f alpha:1.0];
//    UIColor *lightOp =
//    [UIColor colorWithRed:0.00f green:0.75f blue:2.45f alpha:0.05];
//
//    // Create the gradient
//    CAGradientLayer *gradient = [CAGradientLayer layer];
//
//    // Set colors
//    gradient.colors = [NSArray arrayWithObjects:
//                       (id)lightOp.CGColor,
//                       (id)darkOp.CGColor,
//                       nil];
//
//    // Set bounds
//    gradient.frame = self.view.bounds;
//
//    // Add the gradient to the view
//    [self.view.layer insertSublayer:gradient atIndex:0];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)requestVenmo:(id)sender {
    int hasVenmo = 0;
    for(int i = 0; i < [users count]; i++) {
        if(getUserVenmo(users, i)) {
            hasVenmo = 1;
        }
    }
    if(!hasVenmo) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Can't request payments"
                                                                       message:@"Can't request payments since no Venmo IDs were entered."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];

        return;
    }

    NSLog(@"request venmo");
    [[Venmo sharedInstance] requestPermissions:@[VENPermissionMakePayments]
     withCompletionHandler:^(BOOL success, NSError *error) {
         if (success) {
             [self doVenmoRequest];
         }
         else {
             UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Venmo authentication failed"
                                                                            message:@"Could not authenticate with Venmo."
                                                                     preferredStyle:UIAlertControllerStyleAlert];
             
             UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction * action) {}];
             
             [alert addAction:defaultAction];
             [self presentViewController:alert animated:YES completion:nil];
         }
     }];
}

- (IBAction)resetAll:(id)sender {
    receipt = NULL;
    filteredReceipt = NULL;
    users = NULL;
    maxUsers = 0;
    currentUser = 1;
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController* vc = [sb instantiateViewControllerWithIdentifier:@"PeopleNumberViewController"];
    [self.navigationController pushViewController:vc animated:NO];
}

- (void) doVenmoRequest {
    for(int i = 0; i < [users count]; i++) {
        if(getUserVenmo(users, i)) {
            double usertotal = getUserTotal(filteredReceipt, i);
            double tax = getPrice(receipt, @"tax");
            double total = getTotal(filteredReceipt);
            double adjusted = adjustForTaxes(usertotal, total, tax);
            [[Venmo sharedInstance]
                sendRequestTo: getUsername(users, i)
                amount: adjusted * 100
                note: @"Bill split using OCR"
                completionHandler:^(VENTransaction *transaction, BOOL success, NSError *error) {
                 if (success) {
                     UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Venmo request successful"
                                                                                    message:[NSString stringWithFormat:@"Successfully charged %@ for $%.2f on Venmo.", getUsername(users, i), adjusted]
                                                                             preferredStyle:UIAlertControllerStyleAlert];
                     
                     UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                           handler:^(UIAlertAction * action) {}];
                     
                     [alert addAction:defaultAction];
                     [self presentViewController:alert animated:YES completion:nil];
                 }
                 else {
                     UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Venmo request failed"
                                                                                    message:[NSString stringWithFormat:@"Failed to  charge %@ for $%.2f on Venmo.", getUsername(users, i), adjusted]
                                                                             preferredStyle:UIAlertControllerStyleAlert];
                     
                     UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                           handler:^(UIAlertAction * action) {}];
                     
                     [alert addAction:defaultAction];
                     [self presentViewController:alert animated:YES completion:nil];
                 }
            }];
        }
    }
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
