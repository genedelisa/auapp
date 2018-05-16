platform :ios, "11.0"
use_frameworks!

project 'AUApp'

def shared_pods
    #pod 'SwiftMusicKit', :path => '/Users/gene/Development/xcode/gene/Swift/Music/SwiftMusicKit'
    
    #pod 'PianoKeyboard', :path => '/Users/gene/Development/xcode/gene/Swift/mypods/PianoKeyboard/PianoKeyboard'

    #pod 'CommonMusicNotation', :path => '/Users/gene/Development/xcode/gene/Swift/mypods/CommonMusicNotation'
    
    # pod 'GDViews', :path => '/Users/gene/Development/xcode/gene/Swift/mypods/GDViews'
    
    pod 'GDLogger', :path => '/Users/gene/Development/xcode/gene/Swift/mypods/GDLogger'

end

def testing_pods
    pod 'Quick', '~> 1.2.0'
    pod 'Nimble', '~> 7.0.2'
end

target 'AUApp' do
    shared_pods
end

target 'AUAppTests' do
    shared_pods
    testing_pods
end

