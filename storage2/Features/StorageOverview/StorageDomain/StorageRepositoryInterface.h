//
//  StorageRepositoryInterface.h
//  storage2
//
//  Created by LAP14885 on 11/07/2023.
//

#import "FileDataProvider.h"

@protocol StorageRepositoryInterface

@property (nonatomic) id<FileDataProviderType> fileDataProvider;
@end

