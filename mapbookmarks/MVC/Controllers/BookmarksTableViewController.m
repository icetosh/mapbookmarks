//
//  BookmarksTableViewController.m
//  mapbookmarks
//
//  Created by Коля on 04.07.15.
//  Copyright (c) 2015 Mykola Prokopiev. All rights reserved.
//

#import "BookmarksTableViewController.h"
#import "CoreDataManager.h"
#import "CoreDataStorage.h"
#import "Bookmark.h"
#import "BookmarkDetailViewController.h"

#import <CoreData/CoreData.h>

@interface BookmarksTableViewController ()

@property (strong, nonatomic) Bookmark *selectedBookmark;

@end

@implementation BookmarksTableViewController


#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    self.selectedBookmark = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"segueToBookmarkDetailViewController" sender:self];
}

#pragma mark - Actions

- (IBAction)barButtonEditAction:(UIBarButtonItem *)sender {
    [self.tableView setEditing:!self.tableView.editing animated:YES];
}

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segueToBookmarkDetailViewController"]) {
        BookmarkDetailViewController *controller = segue.destinationViewController;
        controller.bookmark = self.selectedBookmark;
    }
}

@end
