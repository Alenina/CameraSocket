//
//  ViewController.m
//  ManualCamera
//
//  Created by LoveStar_PC on 9/23/14.
//  Copyright (c) 2014 IT_Mobile. All rights reserved.
//

#import "ViewController.h"
#import "Define_Public.h"

@interface ViewController ()

- (IBAction)onBack:(id)sender;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initNetworkCommunication];
    
    self.cameraView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH * 0.9, SCREEN_HEIGHT * 0.7)];
    self.cameraView.center = CGPointMake(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.45);
    [self.view addSubview:self.cameraView];
    
    lblStatus = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300 * MULTIPLY_VALUE, 30 * MULTIPLY_VALUE)];
    [lblStatus setCenter:CGPointMake(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.9)];
    [lblStatus setTextAlignment:NSTextAlignmentCenter];
    [lblStatus setText:@"Server Status : Disconneted"];
    [lblStatus setFont:[UIFont systemFontOfSize:20 * MULTIPLY_VALUE]];
    [self.view addSubview:lblStatus];

    _session = [[AVCaptureSession alloc] init];
//    [_session setSessionPreset:AVCaptureSessionPreset640x480];
    [_session setSessionPreset:AVCaptureSessionPreset352x288];
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
    {
        if (device.position == AVCaptureDevicePositionBack)
        {
            _captureInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        }
    }
    NSError *error;
    if (!_captureInput)
    {
        NSLog(@"Error: %@", error);
        return;
    }
    [_session addInput:_captureInput];
    
    ///out put
    AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc]
                                               init];
    captureOutput.alwaysDiscardsLateVideoFrames = YES;
    //captureOutput.minFrameDuration = CMTimeMake(1, 10);
    
    dispatch_queue_t queue;
    queue = dispatch_queue_create("cameraQueue", NULL);
    [captureOutput setSampleBufferDelegate:self queue:queue];
    
//    dispatch_release(queue);
    NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
    NSNumber* value = [NSNumber
                       numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
    NSDictionary* videoSettings = [NSDictionary
                                   dictionaryWithObject:value forKey:key];
    [captureOutput setVideoSettings:videoSettings];
    [_session addOutput:captureOutput];
    
    ///custom Layer
    self.customLayer = [CALayer layer];
    self.customLayer.frame = self.view.bounds;
    self.customLayer.transform = CATransform3DRotate(
                                                     CATransform3DIdentity, M_PI/2.0f, 0, 0, 1);
    self.customLayer.contentsGravity = kCAGravityResizeAspectFill;
    [self.view.layer addSublayer:self.customLayer];
    
    //3.创建、配置输出
    _captureOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
    [_captureOutput setOutputSettings:outputSettings];
    [_session addOutput:_captureOutput];
    
    ////////////
    _preview = [AVCaptureVideoPreviewLayer layerWithSession: _session];
    _preview.frame = CGRectMake(0, 0, self.cameraView.frame.size.width, self.cameraView.frame.size.height);
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [self.cameraView.layer addSublayer:_preview];
    [_session startRunning];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initNetworkCommunication {
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)self.strServerAddress, (UInt32)self.nPortNumber, &readStream, &writeStream);
    
    inputStream = (__bridge NSInputStream *)readStream;
    outputStream = (__bridge NSOutputStream *)writeStream;
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];
    [outputStream open];
    
/*    NSString * str = @"OKOKOKOK";
    NSData *imageData = [str dataUsingEncoding:NSUTF32StringEncoding];
    NSInteger OO = [outputStream write:[imageData bytes] maxLength:[imageData length]];
*/
    
}

- (IBAction)onBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSData*) imageToBuffer:(CMSampleBufferRef)source {
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(source);
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
//    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    void *src_buff = CVPixelBufferGetBaseAddress(imageBuffer);
    
    NSData *data = [NSData dataWithBytes:src_buff length:bytesPerRow * height];
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    return data;
}
#pragma mark -
#pragma mark AVCaptureSession delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    
/*    CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    // access the data
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    unsigned char *rawPixelBase = (unsigned char *)CVPixelBufferGetBaseAddress(pixelBuffer);
    
    // Do something with the raw pixels here
    // ...
    
    // Fill in the AVFrame
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    AVFrame *pFrame;
    pFrame = avcodec_alloc_frame();
    
    avpicture_fill((AVPicture*)pFrame, rawPixelBase, PIX_FMT_RGB32, (int)width, (int)height);
    
 */
    //    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
//    NSData * dataFrame = [self imageToBuffer:sampleBuffer];
//    [outputStream write:[dataFrame bytes] maxLength:[dataFrame length]];

    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef newContext = CGBitmapContextCreate(baseAddress,
                                                    width, height, 8, bytesPerRow, colorSpace,
                                                    kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef newImage = CGBitmapContextCreateImage(newContext);
    
    CGContextRelease(newContext);
    CGColorSpaceRelease(colorSpace);
    
    
//    NSLog(@"get image");
          
    UIImage *image= [UIImage imageWithCGImage:newImage scale:1 orientation:UIImageOrientationLeftMirrored];
    
    CGImageRelease(newImage);
    
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    NSData *imageData = UIImageJPEGRepresentation(image, 0.2);
    if (outputStream.hasSpaceAvailable) {
        NSInteger numberBytes = [outputStream write:[imageData bytes] maxLength:[imageData length]];
        NSLog(@"Bytes : %ld, %d", (long)numberBytes, [imageData length]);

    }
    
//    image = [UIImage imageWithData:imageData];
//    image = [image fixOrientation];
    
    
//    [self performSelectorOnMainThread:@selector(detectForFacesInUIImage:) withObject: (id) image waitUntilDone:NO];
    
    
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
//    [pool drain];
    
    
}
- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    
//    NSLog(@"stream event %lu", streamEvent);
    
    switch (streamEvent) {
            
        case NSStreamEventOpenCompleted:
            NSLog(@"Stream opened");
            [lblStatus setText:@"Server Status : Connected"];
            break;
        case NSStreamEventHasBytesAvailable:
            
            if (theStream == inputStream) {
                
                uint8_t buffer[1024];
                int len;
                
                while ([inputStream hasBytesAvailable]) {
                    len = [inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        
                        if (nil != output) {
                            
                            NSLog(@"server said: %@", output);
                            [self messageReceived:output];
                            
                        }
                    }
                }
            }
            break;
        case NSStreamEventHasSpaceAvailable:
            
            
            break;
            
            
        case NSStreamEventErrorOccurred:
            
            [lblStatus setText:@"Server Status : Disconnected"];
            NSLog(@"NSStreamEventErrorOccurred");
            break;
            
        case NSStreamEventEndEncountered:
            
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            theStream = nil;
            
            break;
        default:
            NSLog(@"Unknown event");
    }
    
}

- (void) messageReceived:(NSString *)message {
    
//    [self.messages addObject:message];
//    NSIndexPath *topIndexPath = [NSIndexPath indexPathForRow:messages.count-1
//                                                   inSection:0];
//    [self.tView scrollToRowAtIndexPath:topIndexPath
//                      atScrollPosition:UITableViewScrollPositionMiddle
//                              animated:YES];
    
}
@end
