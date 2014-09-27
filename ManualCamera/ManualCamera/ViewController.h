//
//  ViewController.h
//  ManualCamera
//
//  Created by LoveStar_PC on 9/23/14.
//  Copyright (c) 2014 IT_Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController<NSStreamDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>
{
    AVCaptureSession *_session;
    AVCaptureDeviceInput *_captureInput;
    AVCaptureStillImageOutput *_captureOutput;
    AVCaptureVideoPreviewLayer *_preview;
    AVCaptureDevice *_device;

    NSInputStream	*inputStream;
    NSOutputStream	*outputStream;
    
    UILabel * lblStatus;
}
@property (retain, nonatomic) UIView *cameraView;
@property (nonatomic, retain) CALayer *customLayer;

@property NSString * strServerAddress;
@property NSInteger nPortNumber;
@end

