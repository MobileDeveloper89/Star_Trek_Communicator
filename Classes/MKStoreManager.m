
#import "MKStoreManager.h"
#import "SoundManager.h"
#import "Flurry.h"
#import "KeychainManager.h"

@interface MKStoreManager (PrivateMethods)
- (BOOL) canCurrentDeviceUseFeature: (NSString*) featureID;
- (BOOL) verifyReceipt:(NSData*) receiptData;
- (void) enableContentForThisSession: (NSString*) productIdentifier;
- (void) savePricesToFile;
- (NSString *) getPriceFromFile:(NSString *)featureId;
@end

@implementation MKStoreManager

@synthesize purchasableObjects = _purchasableObjects;
@synthesize storeObserver = _storeObserver;

static NSString *ownServer = nil;

static id<MKStoreKitDelegate> _delegate;
static MKStoreManager* _sharedStoreManager;


- (void)dealloc {
	
	[_purchasableObjects release];
	[_storeObserver release];

	[_sharedStoreManager release];
	[super dealloc];
}

#pragma mark Delegates

+ (id)delegate {
	
    return _delegate;
}

+ (void)setDelegate:(id)newDelegate {
	
    _delegate = newDelegate;	
}

#pragma mark Singleton Methods

+ (MKStoreManager*)sharedManager
{
	@synchronized(self) {
		
        if (_sharedStoreManager == nil) {
						
#if TARGET_IPHONE_SIMULATOR
			NSLog(@"You are running in Simulator MKStoreKit runs only on devices");
#else
            _sharedStoreManager = [[self alloc] init];					
			_sharedStoreManager.purchasableObjects = [[NSMutableArray alloc] init];
			_sharedStoreManager.storeObserver = [[MKStoreObserver alloc] init];
			[[SKPaymentQueue defaultQueue] addTransactionObserver:_sharedStoreManager.storeObserver];			
#endif
        }
    }
    return _sharedStoreManager;
}


+ (id)allocWithZone:(NSZone *)zone

{	
    @synchronized(self) {
		
        if (_sharedStoreManager == nil) {
			
            _sharedStoreManager = [super allocWithZone:zone];			
            return _sharedStoreManager;  // assignment and return on first allocation
        }
    }
	
    return nil; //on subsequent allocation attempts return nil	
}


- (id)copyWithZone:(NSZone *)zone
{
    return self;	
}

- (id)retain
{	
    return self;	
}

- (unsigned)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released
}

- (oneway void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;	
}

#pragma mark Internal MKStoreKit functions

- (void) restorePreviousTransactions
{
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

-(void) requestProductData
{
    //get list of purchase IDs
    NSString *path = [[NSBundle mainBundle] pathForResource:@"purchases" ofType:@"plist"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray *purchases = [dictionary objectForKey:@"Purchases"];
    
    NSMutableSet *purchaseIDs = [[[NSMutableSet alloc] init] autorelease];
    int count = [purchases count];
    int i;
    for (i = 0; i < count; i++)
    {
        NSDictionary* purchaseInfo = [purchases objectAtIndex:i];
        NSString * purchaseID = [purchaseInfo valueForKey:@"PurchaseID"];
        if (purchaseID != nil)
        {
            [purchaseIDs addObject:purchaseID];
        }
    }
    
	SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers:purchaseIDs];
	request.delegate = self;
	[request start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	[self.purchasableObjects addObjectsFromArray:response.products];
	
#ifndef NDEBUG	
	for(int i=0;i<[self.purchasableObjects count];i++)
	{		
		SKProduct *product = [self.purchasableObjects objectAtIndex:i];
		NSLog(@"Feature: %@, Cost: %f, ID: %@",[product localizedTitle],
			  [[product price] doubleValue], [product productIdentifier]);
	}
	
	for(NSString *invalidProduct in response.invalidProductIdentifiers) {
		NSLog(@"Problem in iTunes connect configuration for product: %@", invalidProduct);
    }
#endif
		
    [self savePricesToFile];
	
	if([_delegate respondsToSelector:@selector(productFetchComplete)])
		[_delegate productFetchComplete];
}


- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    [request release];
}

- (void)requestDidFinish:(SKRequest *)request
{
    [request release];    
}

// call this function to check if the user has already purchased your feature
+ (BOOL) isFeaturePurchased:(NSString*) featureId
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:featureId];
}

+ (BOOL) anyFeaturePurchased:(NSArray *) featureIds
{
    for (NSString * featureId in featureIds) {
        if ([MKStoreManager isFeaturePurchased:featureId] == YES) {
            return true;
        }
    }
    return false;
}

// Call this function to populate your UI
// this function automatically formats the currency based on the user's locale

- (NSMutableArray*) purchasableObjectsDescription
{
	NSMutableArray *productDescriptions = [[NSMutableArray alloc] initWithCapacity:[self.purchasableObjects count]];
	for(int i=0;i<[self.purchasableObjects count];i++)
	{
		SKProduct *product = [self.purchasableObjects objectAtIndex:i];
		
		NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
		[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
		[numberFormatter setLocale:product.priceLocale];
		NSString *formattedString = [numberFormatter stringFromNumber:product.price];
		[numberFormatter release];
		
		// you might probably need to change this line to suit your UI needs
		NSString *description = [NSString stringWithFormat:@"%@ (%@)",[product localizedTitle], formattedString];
		
#ifndef NDEBUG
		NSLog(@"Product %d - %@", i, description);
#endif
		[productDescriptions addObject: description];
	}
	
	[productDescriptions autorelease];
	return productDescriptions;
}

- (NSString *) getProductPrice:(NSString *)featureId
{
    // check if we have price in memory first
    for(int i=0;i<[self.purchasableObjects count];i++) {
        SKProduct *product = [self.purchasableObjects objectAtIndex:i];
        if ([product.productIdentifier isEqualToString:featureId]) {
            NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
            [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            [numberFormatter setLocale:product.priceLocale];
            NSString * formattedString = [numberFormatter stringFromNumber:product.price];
            [numberFormatter autorelease];
            return formattedString;
        }
    }
    // if price is not in memory, load from file
    return [self getPriceFromFile:featureId];
}

- (void) buyFeature:(NSString*) featureId
{	
	if ([SKPaymentQueue canMakePayments])
	{
		SKPayment *payment = [SKPayment paymentWithProductIdentifier:featureId];
		[[SKPaymentQueue defaultQueue] addPayment:payment];
	}
	else
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"In App Purchase disabled"
														message:@"Check your parental control settings and try again later"
													   delegate:self 
											  cancelButtonTitle:@"OK"
											  otherButtonTitles: nil];
		[alert show];
		[alert release];
	}
}

- (BOOL) canConsumeProduct:(NSString*) productIdentifier
{
	int count = [[NSUserDefaults standardUserDefaults] integerForKey:productIdentifier];
	
	return (count > 0);
	
}

- (BOOL) canConsumeProduct:(NSString*) productIdentifier quantity:(int) quantity
{
	int count = [[NSUserDefaults standardUserDefaults] integerForKey:productIdentifier];
	return (count >= quantity);
}

- (BOOL) consumeProduct:(NSString*) productIdentifier quantity:(int) quantity
{
	int count = [[NSUserDefaults standardUserDefaults] integerForKey:productIdentifier];
	if(count < quantity)
	{
		return NO;
	}
	else 
	{
		count -= quantity;
		[[NSUserDefaults standardUserDefaults] setInteger:count forKey:productIdentifier];
		return YES;
	}
	
}

-(void) enableContentForThisSession: (NSString*) productIdentifier
{
	if([_delegate respondsToSelector:@selector(productPurchased:)])
		[_delegate productPurchased:productIdentifier];
}

#pragma mark - price serialization / deserialization methods

- (void) savePricesToFile
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // save prices
    NSString *packPricesFilePath = [documentsDirectory stringByAppendingPathComponent:@"soundPackPrices.plist"];
    NSMutableDictionary * prices = [[NSMutableDictionary alloc] init];
    for(int i=0;i<[self.purchasableObjects count];i++) {
        SKProduct *product = [self.purchasableObjects objectAtIndex:i];
        NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [numberFormatter setLocale:product.priceLocale];
        NSString * formattedString = [numberFormatter stringFromNumber:product.price];
        [prices setObject:formattedString forKey:product.productIdentifier];
        [numberFormatter release];
    }
    [prices writeToFile:packPricesFilePath atomically:YES];
    [prices release];
}

- (NSString *) getPriceFromFile:(NSString *)featureId
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // load prices
    NSString *packPricesFilePath = [documentsDirectory stringByAppendingPathComponent:@"soundPackPrices.plist"];
    NSDictionary *prices = [NSDictionary dictionaryWithContentsOfFile:packPricesFilePath];
    return [prices objectForKey:featureId];
}

#pragma mark In-App purchases callbacks

// In most cases you don't have to touch these methods
-(void) provideContent: (NSString*) productIdentifier 
forReceipt:(NSData*) receiptData restorePurchase:(BOOL) isRestorePurchase
{
	if(ownServer != nil && SERVER_PRODUCT_MODEL)
	{
		// ping server and get response before serializing the product
		// this is a blocking call to post receipt data to your server
		// it should normally take a couple of seconds on a good 3G connection
		if(![self verifyReceipt:receiptData]) return;
	}

    // only call delegate if product was not previously purchased (user may be trying to 
    // restore purchases and these purchases may already be known)
    if ([[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier] == NO)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];		

        [[NSUserDefaults standardUserDefaults] synchronize];

        // unlocking sounds in here instead of in the delegate to make sure this happens even
        // if the appropriate delegate ui is not present.
        [[SoundManager manager] unlockSoundsForPurchaseID:productIdentifier];
        
        if (!isRestorePurchase)
        {
            [Flurry logEvent:@"Sound Pack Purchased" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:productIdentifier, @"ProductId", [[KeychainManager manager] getDeviceID], @"DeviceId", nil]];
        }
        
        if([_delegate respondsToSelector:@selector(productPurchased:)])
            [_delegate productPurchased:productIdentifier];
    }
}

- (void) transactionCanceled: (SKPaymentTransaction *)transaction
{
    if ([transaction.error.domain isEqualToString:SKErrorDomain] && transaction.error.code != SKErrorPaymentCancelled) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[transaction.error localizedDescription] 
                                                        message:[transaction.error localizedRecoverySuggestion]
                                                       delegate:self 
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }

#ifndef NDEBUG
	NSLog(@"User cancelled transaction: %d %@", transaction.error.code, [transaction.error localizedDescription]);
#endif
	
	if([_delegate respondsToSelector:@selector(transactionCanceled)])
		[_delegate transactionCanceled];
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[transaction.error localizedFailureReason] 
													message:[transaction.error localizedRecoverySuggestion]
												   delegate:self 
										  cancelButtonTitle:@"OK"
										  otherButtonTitles: nil];
	[alert show];
	[alert release];
}

@end
