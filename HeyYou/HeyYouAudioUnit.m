//
// AUApp
// HeyYouAudioUnit.m
//
// last build: macOS 10.13, Swift 4.0
//
// Created by Gene De Lisa on 5/9/18.

//  Copyright ©(c) 2018 Gene De Lisa. All rights reserved.
//
//  This source code is licensed under the MIT license found in the
//  LICENSE file in the root directory of this source tree.
//
//  In addition:
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright
//  notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright
//  notice, this list of conditions and the following disclaimer in the
//  documentation and/or other materials provided with the distribution.
//
//  3. Neither the name of the copyright holder nor the names of its
//  contributors may be used to endorse or promote products derived from
//  this software without specific prior written permission.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//



#import "HeyYouAudioUnit.h"
#import "IntervalPlugin.h"

#import <AVFoundation/AVFoundation.h>

// Define parameter addresses.
const AudioUnitParameterID myParam1 = 0;

@interface HeyYouAudioUnit ()

@property (nonatomic, readwrite) AUParameterTree *parameterTree;

@property AUAudioUnitBus *inputBus;
@property AUAudioUnitBus *outputBus;
@property AUAudioUnitBusArray *inputBusArray;
@property AUAudioUnitBusArray *outputBusArray;

@end


@implementation HeyYouAudioUnit
@synthesize parameterTree = _parameterTree;

@synthesize inputBus = _inputBus;
@synthesize outputBus = _outputBus;
@synthesize inputBusArray = _inputBusArray;
@synthesize outputBusArray = _outputBusArray;

BOOL hasMIDIOutput = YES; // not really necessary. the MIDI names array is.

AUHostMusicalContextBlock _musicalContext;
AUMIDIOutputEventBlock _outputEventBlock;
AUHostTransportStateBlock _transportStateBlock;
AUScheduleMIDIEventBlock _scheduleMIDIEventBlock;

AudioStreamBasicDescription asbd; // local copy of the asbd that the render block can capture

IntervalPlugin *intervalPlugin;


- (instancetype)initWithComponentDescription:(AudioComponentDescription)componentDescription options:(AudioComponentInstantiationOptions)options error:(NSError **)outError {
    
    NSLog( @"calling: %s", __PRETTY_FUNCTION__ );
    
    self = [super initWithComponentDescription:componentDescription options:options error:outError];
    
    if (self == nil) {
        return nil;
    }
    
    intervalPlugin = [[IntervalPlugin alloc] init];
    
    // Create parameter objects.
    AUParameter *param1 = [AUParameterTree createParameterWithIdentifier:@"param1" name:@"Parameter 1" address:myParam1 min:0 max:100 unit:kAudioUnitParameterUnit_Percent unitName:nil flags:0 valueStrings:nil dependentParameters:nil];
    
    // Initialize the parameter values.
    param1.value = 0.5;
    
    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[ param1 ]];
    
    // Create the input and output busses (AUAudioUnitBus).
    // Create the input and output bus arrays (AUAudioUnitBusArray).
    
    // A function to provide string representations of parameter values.
    _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
        AUValue value = valuePtr == nil ? param.value : *valuePtr;
        
        switch (param.address) {
            case myParam1:
                return [NSString stringWithFormat:@"%.f", value];
            default:
                return @"?";
        }
    };
    
    self.maximumFramesToRender = 512;
    
    
    AVAudioFormat *defaultFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:44100.0 channels:2];
    asbd = *defaultFormat.streamDescription;
    
    _inputBus = [[AUAudioUnitBus alloc]
                 initWithFormat:defaultFormat error:nil];
    
    _outputBus = [[AUAudioUnitBus alloc]
                  initWithFormat:defaultFormat error:nil];
    
    _inputBusArray  = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self busType:AUAudioUnitBusTypeInput busses: @[_inputBus]];
    
    _outputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self busType:AUAudioUnitBusTypeOutput busses: @[_outputBus]];
    
    
    return self;
}

#pragma mark - AUAudioUnit Overrides

// If an audio unit has input, an audio unit's audio input connection points.
// Subclassers must override this property getter and should return the same object every time.
// See sample code.
- (AUAudioUnitBusArray *)inputBusses {
    NSLog( @"calling: %s", __PRETTY_FUNCTION__ );
    
    return _inputBusArray;
}

// An audio unit's audio output connection points.
// Subclassers must override this property getter and should return the same object every time.
// See sample code.
- (AUAudioUnitBusArray *)outputBusses {
    NSLog( @"calling: %s", __PRETTY_FUNCTION__ );
    return _outputBusArray;
}

// Allocate resources required to render.
// Subclassers should call the superclass implementation.
- (BOOL)allocateRenderResourcesAndReturnError:(NSError **)outError {
    NSLog( @"calling: %s", __PRETTY_FUNCTION__ );
    
    if (![super allocateRenderResourcesAndReturnError:outError]) {
        return NO;
    }
    
    // Validate that the bus formats are compatible.
    // Allocate your resources.
    
    if (self.musicalContextBlock) {
        _musicalContext = self.musicalContextBlock;
        NSLog(@"have a non nil musicalContextBlock");
    } else {
        _musicalContext = nil;
    }
    
    if (self.MIDIOutputEventBlock) {
        _outputEventBlock = self.MIDIOutputEventBlock;
        NSLog(@"have a non nil MIDIOutputEventBlock");
        intervalPlugin.outputEventBlock = _outputEventBlock;
    } else {
        _outputEventBlock = nil;
    }
    
    if (self.transportStateBlock) {
        _transportStateBlock = self.transportStateBlock;
        NSLog(@"have a non nil transportStateBlock");
        
    } else {
        _transportStateBlock = nil;
    }
    
    if (self.scheduleMIDIEventBlock) {
        _scheduleMIDIEventBlock = self.scheduleMIDIEventBlock;
        NSLog(@"have a non nil scheduleMIDIEventBlock");
    } else {
        _scheduleMIDIEventBlock = nil;
    }
    
    return YES;
}

// Deallocate resources allocated in allocateRenderResourcesAndReturnError:
// Subclassers should call the superclass implementation.
- (void)deallocateRenderResources {
    NSLog( @"calling: %s", __PRETTY_FUNCTION__ );
    
    // Deallocate your resources.
    [super deallocateRenderResources];
    
    _transportStateBlock = nil;
    _outputEventBlock = nil;
    _musicalContext = nil;
    _scheduleMIDIEventBlock = nil;
}

- (NSArray<NSString *>*) MIDIOutputNames {
    NSLog( @"calling: %s", __PRETTY_FUNCTION__ );
    
    return @[@"HeyYouMidiOut"];
}

#pragma mark - AUAudioUnit (AUAudioUnitImplementation)

// Block which subclassers must provide to implement rendering.
- (AUInternalRenderBlock)internalRenderBlock {
    
    // Capture in locals to avoid Obj-C member lookups. If "self" is captured in render, we're doing it wrong. See sample code.
    
    IntervalPlugin *plugin = intervalPlugin;
    
    return ^AUAudioUnitStatus(AudioUnitRenderActionFlags *actionFlags, const AudioTimeStamp *timestamp, AVAudioFrameCount frameCount, NSInteger outputBusNumber, AudioBufferList *outputData, const AURenderEvent *realtimeEventListHead, AURenderPullInputBlock pullInputBlock) {
        
        // make this a parameter
        uint8_t interval = 4;
        
        AURenderEvent const* event = realtimeEventListHead;
        [plugin handleEvent: event];
        
        // I moved this logic to the plugin. This has a reference cycle. Don't use self in the render block!
        // it's better to put the processing in dedidicated classes anyway.
        // I left it here to match the blog post so you can compare
        // the refactoring.
        
        if(NO) {
            
            // it's possible to receive a null eventlist, so check first.
            while (event != NULL) {
                
                if (event->head.eventType == AURenderEventMIDI) {
                    
                    AUMIDIEvent midiEvent = event->MIDI;
                    uint8_t midiStatus = midiEvent.data[0] & 0xF0;
                    // uint8_t channel = midiEvent.data[0] & 0x0F;
                    uint8_t data1 = midiEvent.data[1];
                    uint8_t data2 = midiEvent.data[2];
                    
                    // AUEventSampleTime now = midiEvent.eventSampleTime - timestamp->mSampleTime;
                    AUEventSampleTime now = AUEventSampleTimeImmediate;
                    
                    if( _outputEventBlock) {
                        
                        // send back the original unchanged
                        _outputEventBlock(now, 0, event->MIDI.length, event->MIDI.data);
                        // AUEventSampleTime eventSampleTime, uint8_t cable, NSInteger length, const uint8_t *midiBytes);
                        
                        // note on
                        uint8_t bytes[3];
                        bytes[0] = 0x90;
                        bytes[1] = data1;
                        bytes[2] = data2;
                        if (midiStatus == 0x90 && data2 != 0) {
                            bytes[1] = data1 + interval;
                            _outputEventBlock(now, 0, 3, bytes);
                        }
                        
                        // note off
                        bytes[0] = 0x90;
                        bytes[1] = data1;
                        bytes[2] = 0;
                        if (midiStatus == 0x90 && data2 == 0) {
                            bytes[1] = data1 + interval;
                            _outputEventBlock(now, 0, 3, bytes);
                        }
                    }
                }
                
                event = event->head.next;
            }
        }
        
        return noErr;
    };
}

@end

