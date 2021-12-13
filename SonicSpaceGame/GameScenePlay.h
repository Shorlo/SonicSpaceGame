//
//  GameScenePlay.h
//  T7E2_Jasaba
//
//  Created by Shorlo on 21/2/15.
//  Copyright (c) 2015 Shorlo. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameScenePlay : SKScene <SKPhysicsContactDelegate>
{
    BOOL test;
}

@property BOOL              cargarEscena;
//@property int               contador;
@property NSDictionary      *coordenadas;
@property SKTexture         *sonicSpriteSheet;
@property SKTextureAtlas    *atlasPiedra;
@property SKTextureAtlas    *atlasRings;
@property SKEmitterNode     *emisor;
@property SKSpriteNode      *sonic;
@property SKSpriteNode      *fondo1;
@property int               points;
@property int               vida;
@property SKLabelNode       *anillos;
@property SKAction          *gira;
@property SKAction          *giraCometa;
@property SKAction          *ring;
@property NSArray           *transSonic;
@property NSArray           *sonicSonic;
@property NSArray           *runSonic;
@property NSArray           *runUpSonic;
@property NSArray           *flySonic;
@property NSArray           *flyUpSonic;
@property NSArray           *pushSonic;
@property NSArray           *downSonic;
@property NSArray           *chargeSonic;
@property NSArray           *wheelSonic;
@property NSArray           *arrayPiedras;
@property NSArray           *arrayCometa;
@property NSArray           *arrayRings;
@property NSTimer           *timerAsteroide;
@property NSTimer           *timerCometa;
@property NSTimer           *timerRing;
@property NSTimer           *timerContador;
@property SKTransition      *gameOverTransition;




+(NSArray *)loadFramesFromAtlas:(SKTextureAtlas *)textureAtlas withBaseFileName: (NSString *) baseFileName withNumberOfFrames:(int) numberOfFrames;
-(void)generaAsteroide;
-(void)generaCometa;

@end
