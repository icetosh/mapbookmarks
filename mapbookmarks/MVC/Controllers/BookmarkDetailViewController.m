//
//  BookmarkDetailViewController.m
//  mapbookmarks
//
//  Created by Коля on 04.07.15.
//  Copyright (c) 2015 Mykola Prokopiev. All rights reserved.
//

#import "BookmarkDetailViewController.h"
#import "CoreDataManager.h"
#import "Bookmark.h"

@interface BookmarkDetailViewController () <UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *buttonLoadNearbyPlaces;

@end

@implementation BookmarkDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self.bookmark.name isEqualToString:@"Unnamed"]) {
        self.buttonLoadNearbyPlaces.hidden = YES;
    } else {
        self.tableView.hidden = YES;
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    return cell;
}

#pragma mark - Actions

- (IBAction)barButtonDeleteAction:(UIBarButtonItem *)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Bookmark will be deleted. Are you sure?" delegate:self cancelButtonTitle:nil otherButtonTitles:@"No", @"Yes", nil];
    [alertView show];
}

- (IBAction)buttonLoadNearbyPlacesAction:(UIButton *)sender {
    
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 1:
            [[CoreDataManager sharedManager] deleteManagedObject:self.bookmark];
            [self.navigationController popViewControllerAnimated:YES];
            break;

        default:
            break;
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
