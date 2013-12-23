//
//  SGGViewController.m
//  SimpleGLKitGame
//
//  Created by Kern Jackson on 12/23/13.
//  Copyright (c) 2013 Kern Jackson. All rights reserved.
//

/*
This is a bare bones implementation of a GLKViewController subclass. When the view loads it creates an OpenGL ES 2.0 context that it will use for further drawing, and associated it with the view. It also implements glkView:drawInRect to clear the screen to a green color. For review on this, check the previous tutorial.
*/

#import "SGGViewController.h"
#import "SGGSprite.h"
#import "ColorfulCube.h"

#define M_TAU (2*M_PI)

@interface SGGViewController ()
@property (strong, nonatomic) EAGLContext *context;
@property (strong) GLKBaseEffect * effect;
@property (strong) SGGSprite * player;
@property (strong) NSMutableArray *cubes;
@end

@implementation SGGViewController
@synthesize context = _context;
@synthesize player = _player;
@synthesize cubes;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    [EAGLContext setCurrentContext:self.context];
    
    
    self.effect = [[GLKBaseEffect alloc] init];
    
    //GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, 480, 0, 320, -1024, 1024);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), 1.0f, 0.1f, 100.0f);
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    self.player = [[SGGSprite alloc] initWithFile:@"Player.png" effect:self.effect];
    
    
    cubes = [[NSMutableArray alloc] init];
    
    ColorfulCube *cube = [[ColorfulCube alloc] init];
    cube.position = GLKVector3Make(0.25, 0.25, 0.0);
    cube.scale = GLKVector3Make(0.5, 0.5, 0.5);
    cube.rotation = GLKVector3Make(1.0/8*M_TAU, 1.0/8*M_TAU, 0);
    cube.rps = GLKVector3Make(0.5, 0.4, 0.3);
    [cubes addObject:cube];
    
    ColorfulCube *cube2 = [[ColorfulCube alloc] init];
    cube2.position = GLKVector3Make(-0.5, -0.25, 0.0);
    cube2.scale = GLKVector3Make(0.4, 0.4, 0.4);
    cube2.rotation = GLKVector3Make(1.0/8*M_TAU, 0, 1.0/8*M_TAU);
    cube2.rps = GLKVector3Make(0.3, 0.5, 0.4);
    [cubes addObject:cube2];
    
    ColorfulCube *cube3 = [[ColorfulCube alloc] init];
    cube3.position = GLKVector3Make(0.5, -0.25, 0.0);
    cube3.scale = GLKVector3Make(0.4, 0.4, 0.4);
    cube3.rotation = GLKVector3Make(1.0/8*M_TAU, 0, 1.0/8*M_TAU);
    cube3.rps = GLKVector3Make(0.3, 1.5, 0.4);
    [cubes addObject:cube3];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(1, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    
    [cubes makeObjectsPerformSelector:@selector(draw)];
    [self.player render];
}

- (void)update {
    NSTimeInterval dt = [self timeSinceLastDraw];
    for (id cube in cubes)
        [((ColorfulCube *)cube) updateRotations:dt];
}

@end