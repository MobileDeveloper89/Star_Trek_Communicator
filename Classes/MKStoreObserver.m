
#import "MKStoreObserver.h"
#import "MKStoreManager.h"

@interface MKStoreManager (InternalMethods)

// these three functions are called from MKStoreObserver
- (void) transactionCanceled: (SKPaymentTransaction *)transaction;
- (void) failedTransaction: (SKPaymentTransaction *)transaction;

- (void) provideContent: (NSString*) productIdentifier 
			forReceipt: (NSData*) recieptData restorePurchase:(BOOL) isRestorePurchase;
@end

@implementation MKStoreObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
	for (SKPaymentTransaction *transaction in transactions)
	{
		switch (transaction.transactionState)
		{
			case SKPaymentTransactionStatePurchased:
				
                [self completeTransaction:transaction];
				
                break;
				
            case SKPaymentTransactionStateFailed:
				
                [self failedTransaction:transaction];
				
                break;
				
            case SKPaymentTransactionStateRestored:
				
                [self restoreTransaction:transaction];
				
            default:
				
                break;
		}			
	}
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{	
	[[MKStoreManager sharedManager] transactionCanceled:transaction];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];	
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction
{		
	
    [[MKStoreManager sharedManager] provideContent:transaction.payment.productIdentifier 
                                        forReceipt:transaction.transactionReceipt restorePurchase:NO];	

    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];	
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{	
    [[MKStoreManager sharedManager] provideContent: transaction.originalTransaction.payment.productIdentifier
									   forReceipt:transaction.transactionReceipt restorePurchase:YES];
	
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];	
}

@end
