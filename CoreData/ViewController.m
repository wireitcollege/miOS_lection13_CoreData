//
//  ViewController.m
//  CoreData
//
//  Created by Rostyslav Kobizsky on 8/11/15.
//  Copyright (c) 2015 Rostyslav Kobizsky. All rights reserved.
//

#import "ViewController.h"
#import "Country.h"
#import "Country+API.h"
#import "AppDelegate.h"
#import "NSManagedObject+ActiveRecord.h"

@interface ViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResults;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.fetchedResults = [Country fetchAllSortedBy:@"name" ascending:YES withPredicate:nil groupBy:nil];
    self.fetchedResults.delegate = self;

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
    
    [self downloadListOfCountries:^(id result) {
        
        if (result) {
            NSError *error;
            NSArray *objects = [NSJSONSerialization JSONObjectWithData:result options:0 error:&error];
            if (!error) {
                for (NSDictionary *dictionary in objects) {
                    [Country countryWithDictionary:dictionary inContext:[self managedObjectContext]];
                    
                    
                }
                
                if (![[self managedObjectContext] save:&error]) {
                    NSLog(@"%@", error);
                }
            }
        }
        
        [self.refreshControl endRefreshing];
    }];
}

- (void)downloadListOfCountries:(void(^)(id result))completion {
    NSURL *url = [NSURL URLWithString:@"https://restcountries.eu/rest/v1/all"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:url];
        if (completion) {
            if (data.length) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(data);
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil);
                });
            }
        }
    });
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
