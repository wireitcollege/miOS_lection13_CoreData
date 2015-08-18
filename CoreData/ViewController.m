//
//  ViewController.m
//  CoreData
//
//  Created by Rostyslav Kobizsky on 8/11/15.
//  Copyright (c) 2015 Rostyslav Kobizsky. All rights reserved.
//

#import "ViewController.h"
#import "Country.h"
#import "AppDelegate.h"
#import "NSManagedObject+ActiveRecord.h"
#import "Network.h"

@interface ViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResults;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.fetchedResults = [Country fetchAllSortedBy:@"name" ascending:YES withPredicate:nil groupBy:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.fetchedResults.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.fetchedResults.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSManagedObjectContext *)managedObjectContext {
    return [(AppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
}

#pragma mark - Refresh

- (IBAction)refresh:(UIRefreshControl *)sender {
    NSLog(@"Wants refresh");
    
    [[Network layer] getCountries:^(id result) {
       [self.refreshControl endRefreshing];
        if ([result isKindOfClass:[NSError class]]) {
            UIAlertController *alert = [UIAlertController
                                        alertControllerWithTitle:NSLocalizedString(@"Error", nil)
                                        message:[(NSError *)result localizedDescription]
                                        preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Retry", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self refresh:nil];
            }]];
            
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}



#pragma mark - UIFetchedResultsController Delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationFade)];
            break;
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:(UITableViewRowAnimationFade)];
            break;
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationFade)];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:(UITableViewRowAnimationFade)];
            break;
        case NSFetchedResultsChangeUpdate:
            [self configutateCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

- (void)configutateCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Country *country = [self.fetchedResults objectAtIndexPath:indexPath];
    cell.textLabel.text = country.name;
}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResults sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id  sectionInfo =
    [[self.fetchedResults sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Country Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [self configutateCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableView Delegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Country *countryToRemove = [self.fetchedResults objectAtIndexPath:indexPath];
        [[self managedObjectContext] deleteObject:countryToRemove];
        [[self managedObjectContext] save:nil];
    }
}

//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return UITableViewCellEditingStyleDelete;
//}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Remove";
}

@end
