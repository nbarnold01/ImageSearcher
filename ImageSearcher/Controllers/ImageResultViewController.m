//
//  MasterViewController.m
//  ImageSearcher
//
//  Created by Nathan Arnold on 11/5/15.
//  Copyright © 2015 Nathan Arnold. All rights reserved.
//

#import "ImageResultViewController.h"
#import "DetailViewController.h"
#import "ImageSearch.h"
#import "ImageSearchResult.h"
#import "ImageCell.h"
#import "CollectionViewSearchHeader.h"

@interface ImageResultViewController() <UISearchBarDelegate>
@property (strong) ImageSearch *imageSearch;
@property (strong) NSMutableArray *images;
@property (strong) dispatch_queue_t imageQueue;

@end

static NSUInteger const ITEMS_BEFORE_PULLING = 10;


@implementation ImageResultViewController


- (instancetype)init {
    
    if (self = [super init]) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    
    if (self = [super initWithCollectionViewLayout:layout]) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    
    return self;
}


- (void)commonInit {
    
    self.imageQueue = dispatch_queue_create("com.gingerandthecyclist.imageCollectionQueue", DISPATCH_QUEUE_SERIAL);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems]firstObject];
//        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        
        ImageSearchResult *result = [self resultForIndexPath:indexPath];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setImage:result];
        
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Collection View Datasource


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
//    return [[self.fetchedResultsController sections] count];
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
//    return [sectionInfo numberOfObjects];
    
    return [self.images count];
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ImageCell *cell = (ImageCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
    
}


- (void)configureCell:(ImageCell *)cell atIndexPath:(NSIndexPath *)indexPath {

    ImageSearchResult *result = [self resultForIndexPath:indexPath];
    [cell.imageView sd_setImageWithURL:result.thumbURL];
}

- (ImageSearchResult *)resultForIndexPath:(NSIndexPath *)indexPath {
    return self.images[indexPath.row];
}


#pragma mark - Collection View Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [self performSegueWithIdentifier:@"showDetail" sender:nil];
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];

    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.collectionView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            return;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    
    UICollectionView *collectionView = self.collectionView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [collectionView insertItemsAtIndexPaths:@[newIndexPath]];
            break;
            
        case NSFetchedResultsChangeDelete:
            [collectionView deleteItemsAtIndexPaths:@[newIndexPath]];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[collectionView cellForItemAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [collectionView deleteItemsAtIndexPaths:@[indexPath]];
            [collectionView insertItemsAtIndexPaths:@[newIndexPath]];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.collectionView endUpdates];
}

#pragma mark - Collection View Flow Layout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
        
    CGSize size = CGSizeMake((collectionView.frame.size.width/3)-2 , 150);
    return size;
}


- (UICollectionReusableView *)collectionView: (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    //Custom class for the header view. Controls are defined in the Storyboard
    CollectionViewSearchHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:
                              UICollectionElementKindSectionHeader withReuseIdentifier:@"SearchHeader" forIndexPath:indexPath];
    
    headerView.searchBar.delegate = self;
    return headerView;
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.collectionView reloadData];
}
 */


#pragma mark - Scroll View Delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height) {
        // we are at the end
        
        [self pullBatchIfNessecary];
//        [self pullBatchIfNessecary];

    }
}


#pragma mark - Search Bar Delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
   // called when keyboard search button pressed
    [self search:searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    // called when cancel button pressed
    [searchBar resignFirstResponder];
    
}

#pragma mark - Private

- (void)search:(NSString *)searchTerm {
    
    if (searchTerm) {
        self.images = nil;
        [self.collectionView reloadData];

        self.imageSearch = [[ImageSearch alloc]initWithQuery:searchTerm];
        [self.imageSearch executeWithComplete:^(NSArray *results, NSError *error) {
            if (error){
                NSLog(@"error: %@", error);
            } else {
                [self addImages:results];
                [self pullBatchIfNessecary];
                [self pullBatchIfNessecary];
                [self pullBatchIfNessecary];

            }
        }];
    } else {
        [self.imageSearch cancel];
        self.imageSearch = nil;
    }
}

- (void)pullBatchIfNessecary {
    
    //TODO: Check if the images search is done
//    if (![self.imageSearch isRetrievingImages]  && ![self.imageSearch isFinished]) {
    if ([self.imageSearch numberOfRequests] < 4){
        [self.imageSearch getMoreResultsWithComplete:^(NSArray *results, NSError *error) {
            if (!error) {
                [self addImages:results];
            } else {
                //show error I
            }
        }];
    }
}

- (void)addImages:(NSArray *)images {
    
    dispatch_async(self.imageQueue, ^{
        
        if (!self.images && images) {
            self.images = [NSMutableArray array];
        }

        if ([images count]) {
            
            
            NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:[images count]];
            
            NSUInteger startingIndex = [self.images count];
            
            for (NSUInteger i = startingIndex; i <startingIndex+[images count]; i++) {
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [indexPaths addObject:indexPath];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.images addObjectsFromArray:images];
                
                [self.collectionView insertItemsAtIndexPaths:indexPaths];
            });
        }
    });
}


@end
