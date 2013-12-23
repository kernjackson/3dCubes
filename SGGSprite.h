//
//  SGGSprite.h
//  SimpleGLKitGame
//
//  Created by Kern Jackson on 12/23/13.
//  Copyright (c) 2013 Kern Jackson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface SGGSprite : NSObject
/*
This is the interface for our sprite class. As you can see, right now we’re going to start as simple as possible. We’ll allow the user to specify the image file for the sprite to display, and the GLKBaseEffect (shader) that will render it. We also define a routine that the GLKViewController will call to render the sprite.
*/
- (id)initWithFile:(NSString *)fileName effect:(GLKBaseEffect *)effect;
- (void)render;

@end