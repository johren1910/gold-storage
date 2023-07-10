//
//  DIAssemblyInterface.h
//  storage2
//
//  Created by LAP14885 on 10/07/2023.
//

@protocol ViewModelType
    
@end

@protocol ViewControllerType <NSObject>

- (instancetype)initWithViewModel:(id<ViewModelType>)viewModel;
- (id<ViewModelType>)viewModel;

@end
