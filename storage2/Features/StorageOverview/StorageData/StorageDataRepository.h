//
//  StorageDataRepository.h
//  storage2
//
//  Created by LAP14885 on 11/07/2023.
//

#import "StorageRepositoryInterface.h"
#import "StorageManager.h"

@interface StorageDataRepository : NSObject <StorageRepositoryInterface>
-(instancetype) initWithFileDataProvider:(id<FileDataProviderType>)fileDataProvider andStorageManager:(id<StorageManagerType>)storageManager;

@end
