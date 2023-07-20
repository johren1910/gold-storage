# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

def app_pods
  pod 'IGListKit', '~> 4.0.0'
end

def testing_pods
    pod 'Quick'
    pod 'Nimble'
    pod 'OCMock'
    pod 'IGListKit', '~> 4.0.0'
end

target 'storage2' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  app_pods
  # Pods for storage2
  
  
end

target 'storage2Tests' do
    use_frameworks!
    testing_pods
    app_pods
end

#target 'MyUITests' do
#    testing_pods
#end
