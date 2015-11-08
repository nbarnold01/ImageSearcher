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
        ImageCell *cell = (ImageCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
//        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        
        ImageSearchResult *result = [self resultForIndexPath:indexPath];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setImageSearchResult:result placeholder:cell.imageView.image];
        
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Collection View Datasource


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
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
        // we are at the bottom of the content
        [self pullBatchIfNessecary];
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
        
        self.imageSearch = [ImageSearch queryForSearchString:searchTerm managedObjectContext:self.managedObjectContext];
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
        [self.managedObjectContext save:nil];
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
