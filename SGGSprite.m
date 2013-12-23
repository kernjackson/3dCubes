//
//  SGGSprite.m
//  SimpleGLKitGame
//
//  Created by Kern Jackson on 12/23/13.
//  Copyright (c) 2013 Kern Jackson. All rights reserved.
//

#import "SGGSprite.h"

typedef struct {
    CGPoint geometryVertex;
    CGPoint textureVertex;
} TexturedVertex;

typedef struct {
    TexturedVertex bl;
    TexturedVertex br;
    TexturedVertex tl;
    TexturedVertex tr;
} TexturedQuad;

/*
Here we create a private category of SGGSprite. This is a fancy way of creating private variables in Objective-C. Since we define them here, inside the implementation file (.m), nobody outside our class knows about these. This makes for better encapsulation, and is a general good practice.
 */

@interface SGGSprite()

@property (strong) GLKBaseEffect * effect; // The effect (shader) that we’ll use to render the sprite. More on this later.
@property (assign) TexturedQuad quad; // The instance of our TexturedQuad structure. We’ll fill this in as described above soon.
@property (strong) GLKTextureInfo * textureInfo; // We’re going to use GLKit’s GLKTextureLoader class to easily load our texture. It will return some info about the texture, which we’ll store here.

@end

@implementation SGGSprite
@synthesize effect = _effect;
@synthesize quad = _quad;
@synthesize textureInfo = _textureInfo;

// Here we create the initializer for our class. Let’s go over this line by line:

- (id)initWithFile:(NSString *)fileName effect:(GLKBaseEffect *)effect {
    if ((self = [super init])) {
        // 1 Stores the GLKBaseEffect that will be used to render the sprite.
        self.effect = effect;
        
        // 2 Sets up the options so that when we load the texture, the origin of the texture will be considered the bottom left. If you don’t do this, the origin will be the top left (which we don’t want, because it won’t match OpenGL’s coordinate system).
        NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithBool:YES],
                                  GLKTextureLoaderOriginBottomLeft,
                                  nil];
        
        // 3 Gets the path to the file we’re going to load. The filename is passed in. Note that if you pass nil as the type, it will allow you to enter the full filename in the first parameter. Believe it or not, I just learned this after 2 years of iOS dev :P
        NSError * error;
        NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
        // 4 Finally loads the texture with the handy GLKTextureLoader class. You should appreciate this – it used to take tons of code to accomplish this :]
        self.textureInfo = [GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
        if (self.textureInfo == nil) {
            NSLog(@"Error loading file: %@", [error localizedDescription]);
            return nil;
        }
        
        // TODO: Set up Textured Quad
        TexturedQuad newQuad;
        newQuad.bl.geometryVertex = CGPointMake(0, 0);
        newQuad.br.geometryVertex = CGPointMake(self.textureInfo.width, 0);
        newQuad.tl.geometryVertex = CGPointMake(0, self.textureInfo.height);
        newQuad.tr.geometryVertex = CGPointMake(self.textureInfo.width, self.textureInfo.height);
        
        newQuad.bl.textureVertex = CGPointMake(0, 0);
        newQuad.br.textureVertex = CGPointMake(1, 0);
        newQuad.tl.textureVertex = CGPointMake(0, 1);
        newQuad.tr.textureVertex = CGPointMake(1, 1);
        self.quad = newQuad;
        
    }
    return self;
}

- (void)render {
    
    // 1 When you use a GLKBaseEffect to render geometry, you can specify a texture to use for the drawing. You do this by setting the texture2d0.name to the textureInfo.name, and setting texture2d0.enabled to YES. There’s also a second texture unit for more advanced effects
    self.effect.texture2d0.name = self.textureInfo.name;
    self.effect.texture2d0.enabled = YES;
    
    // 2 Before you draw anything, you have to call prepareToDraw on the GLKBaseEffect. Note that you should only call this after you have finished configuring the parameters on the GLKBaseEffect the way you want.
    [self.effect prepareToDraw];
    
    // 3 There are two pieces of information we want to pass to the effect/shader: the position and texture coordinate of each vertex. We use this function to enable us to pass the values through.
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    
    // 4 Next we need to actually send each piece of data. We do that via the glVertexAttribPointer method. For example, the first function says “I want to send some position values. I’m going to send 2 floats over. After you read the first two floats, advance the size of the TexturedVertex structure to find the next two. And here’s a pointer to where you can find the first vertex.”
    long offset = (long)&_quad;
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, geometryVertex)));
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, textureVertex)));
    
    // 5 Finally, we draw the geometry, specifying 4 vertices of data drawn as a triangle strip. This warrants some special discussion, continued below.
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
}

@end