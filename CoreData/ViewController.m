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

@interface ViewController ()

@property (nonatomic, strong) NSArray *countries;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)countries {
    if (!_countries) {
        _countries = @[];
        [self refetchData];
    }
    return _countries;
}

- (NSManagedObjectContext *)managedObjectContext {
    return [(AppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
}

- (void)refetchData {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Country class])];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    NSError *error;
    self.countries = [[self managedObjectContext] executeFetchRequest:request error:&error];
}

#pragma mark - Refresh

- (IBAction)refresh:(UIRefreshControl *)sender {
    NSLog(@"Wants refresh");
    
    [self downloadListOfCountries:^(id result) {
        [self.refreshControl endRefreshing];
        if (result) {
            NSError *error;
            NSArray *objects = [NSJSONSerialization JSONObjectWithData:result options:0 error:&error];
            if (!error) {
                for (NSDictionary *dictionary in objects) {
                    [Country countryWithDictionary:dictionary inContext:[self managedObjectContext]];
                }
            }
            [self refetchData];
            [self.tableView reloadData];
        }
        
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

#pragma mark - UITableView DataSource

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 1;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.countries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Country Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    Country *country = self.countries[indexPath.row];
    cell.textLabel.text = country.name;
    return cell;
}

#pragma mark - UITableView Delegate

@end
