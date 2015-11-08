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

#import <SDWebImage/UIImageView+WebCache.h>
#import <MBProgressHUD/MBProgressHUD.h>

static NSInteger const MAX_REQUEST_COUNT = 2;

@interface ImageResultViewController() <UISearchBarDelegate>

@property (strong) ImageSearch *imageSearch;
@property (strong) NSMutableArray *images;
@property (weak) UISearchBar *searchBar;

@end

@implementation ImageResultViewController

#pragma mark - View Lifecycle

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
    [self.searchBar resignFirstResponder];
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
    self.searchBar = headerView.searchBar;
    return headerView;
}

#pragma mark - Scroll View Delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height) {
        // we are at the bottom of the content
        [self pullBatchIfNessecary];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
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
        
        [self showLoadingIndicator];
        
        [self.imageSearch executeWithComplete:^(NSArray *results, NSError *error) {
          
            [self hideLoadingIndicator];

            if (error){
                [self showError:error];
            } else {
                
                [self addImages:results];
                
                //Search untill the whole screen is populated
                if (!error && self.collectionView.frame.size.height > self.collectionView.contentSize.height) {
                    [self pullBatchIfNessecary];
                }
            }
        }];
        [self.managedObjectContext save:nil];
    } else {
        [self.imageSearch cancel];
        self.imageSearch = nil;
    }
}

- (void)pullBatchIfNessecary {
    
    if ([self.imageSearch numberOfRequests] < MAX_REQUEST_COUNT && ![self.imageSearch isFinished] ){
        
        [self showLoadingIndicator];
        [self.imageSearch getMoreResultsWithComplete:^(NSArray *results, NSError *error) {
    
            [self hideLoadingIndicator];
            
            if (error){
                [self showError:error];
            } else {
                
                [self addImages:results];
                
                //Search untill the whole screen is populated
                if (!error && self.collectionView.frame.size.height > self.collectionView.contentSize.height) {
                    [self pullBatchIfNessecary];
                }
            }
        }];
    }
}

- (void)addImages:(NSArray *)images {
    
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
        
        [self.images addObjectsFromArray:images];
        
        [self.collectionView insertItemsAtIndexPaths:indexPaths];
    }
}

#pragma mark - Network Activity

- (void)showLoadingIndicator {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)hideLoadingIndicator {
    
    if (![self.imageSearch isRetrievingImages]){
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

#pragma mark - Error Handling

- (void)showError:(NSError *)error {
    
    NSLog(@"error: %@", error);

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oh No!" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:NULL]];
    [self presentViewController:alert animated:YES completion:NULL];
}


@end
