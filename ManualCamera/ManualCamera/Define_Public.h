//
//  Define_Public.h
//  ManualCamera
//
//  Created by LoveStar_PC on 9/27/14.
//  Copyright (c) 2014 IT_Mobile. All rights reserved.
//

#ifndef ManualCamera_Define_Public_h
#define ManualCamera_Define_Public_h

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_RETINA ([[UIScreen mainScreen] scale] == 2.0f)

#define SCREEN_WIDTH			[[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT			[[UIScreen mainScreen] bounds].size.height

#define MULTIPLY_VALUE          (IS_IPAD ? 2.0 : 1.0)


#endif
