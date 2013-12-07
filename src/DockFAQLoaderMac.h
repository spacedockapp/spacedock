#import <Foundation/Foundation.h>


#import "DockFAQLoader.h"

@interface DockFAQLoaderMac : DockFAQLoader

@property (strong, nonatomic) NSURLRequest* request;
@property (strong, nonatomic) NSURLDownload* download;

@end
