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
#import "FoursquareNearbyPlacesRequest.h"
#import <SAMHUDView/SAMHUDView.h>

NSString *const kName = @"name";

@interface BookmarkDetailViewController () <UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *buttonLoadNearbyPlaces;
@property (strong, nonatomic) NSArray *placesArray;

@end

@implementation BookmarkDetailViewController

#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self.bookmark.name isEqualToString:@"Unnamed"]) {
        self.buttonLoadNearbyPlaces.hidden = YES;
        [self getNearbyPlaces];
    }
}

#pragma mark - Request

- (void)getNearbyPlaces {
    SAMHUDView *hudView = [[SAMHUDView alloc] initWithTitle:@"Getting nearby places..."];
    
    __weak typeof(self)weakSelf = self;

    [hudView show];
    
    [FoursquareNearbyPlacesRequest getNearbyPlacesForBookmark:self.bookmark success:^(NSArray *venues) {
        self.placesArray = venues;
        weakSelf.tableView.hidden = NO;
        [weakSelf.tableView reloadData];
        [hudView dismiss];
        self.buttonLoadNearbyPlaces.hidden = YES;
    } failure:^(NSError *error) {
        [hudView dismiss];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.placesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlaceCell" forIndexPath:indexPath];
    cell.textLabel.text = self.placesArray[indexPath.row][kName];
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.bookmark.name = self.placesArray[indexPath.row][kName];
    [[CoreDataManager sharedManager] saveContext];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Actions

- (IBAction)barButtonDeleteAction:(UIBarButtonItem *)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Bookmark will be deleted. Are you sure?" delegate:self cancelButtonTitle:nil otherButtonTitles:@"No", @"Yes", nil];
    [alertView show];
}

- (IBAction)buttonLoadNearbyPlacesAction:(UIButton *)sender {
    [self getNearbyPlaces];
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

@end
