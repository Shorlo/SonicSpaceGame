//
//  GameSceneIntro.h
//  SonicSpaceGame
//
//  Created by Shorlo on 11/3/15.
//  Copyright (c) 2015 Shorlo. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameSceneIntro : SKScene
@property int contador;
@property BOOL    cargarEscena;
@property NSString *path;
@property NSString *plistName;
@property NSString *finalPath;
@property NSDictionary *coordenadasTexturaSonic;
@property SKTexture *texturaSonic;
@property SKSpriteNode *miSonic;



@end
