//
//  PopoverTableViewController.m
//  mapbookmarks
//
//  Created by Коля on 04.07.15.
//  Copyright (c) 2015 Mykola Prokopiev. All rights reserved.
//

#import "PopoverTableViewController.h"

@interface PopoverTableViewController ()

@end

@implementation PopoverTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate popoverTableViewController:self didSelectBookmark:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

@end
