//
//  GameSceneIntro.m
//  SonicSpaceGame
//
//  Created by Shorlo on 11/3/15.
//  Copyright (c) 2015 Shorlo. All rights reserved.
//

#import "GameSceneIntro.h"
#import "GameScenePlay.h"

@implementation GameSceneIntro

-(void)didMoveToView:(SKView *)view
{
    if (!_cargarEscena) {
        [self cargarEscenaConElementos];
        [self cargarEscena];
    }
}

-(void)cargarEscenaConElementos
{

    _path = [[NSBundle mainBundle] bundlePath];
    _plistName = @"Lista_Sprites.plist";
    _finalPath = [_path stringByAppendingPathComponent:_plistName];
    _coordenadasTexturaSonic = [NSDictionary dictionaryWithContentsOfFile:_finalPath];
    _texturaSonic = [SKTexture textureWithImage:[UIImage imageNamed:@"SuperSonic.gif"]];
    _contador = 0;
    self.miSonic = [self sonic];
    self.scaleMode = SKSceneScaleModeAspectFill;
    self.backgroundColor = [SKColor colorWithRed:3.0 /256.0 green:17.0/256.0 blue:36.0/256.0 alpha:1.0];
    [self addChild:self.fondo];
    [self addChild:self.titulo];
    [self addChild:self.subTitulo];
    [self addChild:self.botonJugar];
    [self addChild:_miSonic];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint pulsacion = [touch locationInNode:self];
    SKNode *nodo = [self nodeAtPoint:pulsacion];
    
    if ([nodo.name isEqualToString:@"botonJugar"])
    {
        NSArray *sonicCharge = [self loadFramesFromSpriteSheet:_texturaSonic withBaseFileName:@"sonic_charge" withNumbersOfFrames:5 withCoordenadas:_coordenadasTexturaSonic];
        SKAction *cargando = [SKAction animateWithTextures:sonicCharge timePerFrame:0.2];
        SKAction *sonido = [SKAction playSoundFileNamed:@"dash.mp3" waitForCompletion:NO];
        SKAction *entrada = [SKAction group:@[cargando, sonido]];
        [_miSonic runAction:entrada completion:^{
            [_miSonic removeAllActions];
            //_rodando = true;
            NSArray *ruedaSonic = [self loadFramesFromSpriteSheet:_texturaSonic withBaseFileName:@"sonic_wheel" withNumbersOfFrames:5 withCoordenadas:_coordenadasTexturaSonic];
            SKAction *rueda = [SKAction animateWithTextures: ruedaSonic timePerFrame: 0.1];
            SKAction *mover = [SKAction moveTo:CGPointMake(CGRectGetMaxX(self.frame), CGRectGetMaxY(self.frame)) duration: 0.5 - _contador * 0.05];
            SKAction *giro1 = [SKAction moveByX:    60 y:  20     duration: 0.15 - _contador * 0.01];
            SKAction *giro2 = [SKAction moveByX:    20 y:  60     duration: 0.15 - _contador * 0.01];
            SKAction *giro3 = [SKAction moveByX:   -20 y:  60     duration: 0.15 - _contador * 0.01];
            SKAction *giro4 = [SKAction moveByX:   -60 y:  20     duration: 0.15 - _contador * 0.01];
            SKAction *giro5 = [SKAction moveByX:   -60 y: -20     duration: 0.15 - _contador * 0.01];
            SKAction *giro6 = [SKAction moveByX:   -20 y: -60     duration: 0.15 - _contador * 0.01];
            SKAction *giro7 = [SKAction moveByX:    20 y: -60     duration: 0.15 - _contador * 0.01];
            SKAction *giro8 = [SKAction moveByX:    60 y: -20     duration: 0.15 - _contador * 0.01];
            SKAction *animacionMueve = [SKAction group:@[rueda, [SKAction sequence:@[giro1,giro2,giro3,giro4,giro5,giro6,giro7,giro8,mover]]]];
            [_miSonic runAction:animacionMueve completion:^
            {
                SKTransition *transicionDeEscena = [SKTransition doorsOpenHorizontalWithDuration:0.8];
                GameScenePlay *nuevaScene = [[GameScenePlay alloc] initWithSize:self.frame.size];
                [self.view presentScene:nuevaScene transition:transicionDeEscena];
            }];
            SKAction *grande = [SKAction scaleBy:4 duration:2];
            SKAction *mueve = [SKAction moveByX:-200 y:-200 duration:2];
            [self.fondo runAction:[SKAction group:@[grande, mueve]]];
        }];
    }
     
    
}

-(SKSpriteNode *) sonic
{
    NSArray *sonicTrans = [self loadFramesFromSpriteSheet:_texturaSonic withBaseFileName:@"sonic_trans" withNumbersOfFrames:16 withCoordenadas:_coordenadasTexturaSonic];
    NSArray *sonicDown = [self loadFramesFromSpriteSheet:_texturaSonic withBaseFileName:@"sonic_down" withNumbersOfFrames:5 withCoordenadas:_coordenadasTexturaSonic];
    
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithTexture:sonicTrans[1]];
    sprite.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    sprite.zPosition = 1.0;
    
    SKAction *entrada = [SKAction sequence:@[[SKAction animateWithTextures:sonicTrans timePerFrame:0.1 resize:true restore:true], [SKAction repeatActionForever:[SKAction animateWithTextures:sonicDown timePerFrame:0.1]]]];
    [sprite runAction:entrada];

    return sprite;
}

-(SKSpriteNode *) fondo
{
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"fondo_intro.jpg"];
    sprite.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 200);
    sprite.zPosition = 0.0;
    sprite.scale = 0.3;
    return sprite;
}

-(SKLabelNode *) titulo
{
    SKLabelNode *label = [SKLabelNode labelNodeWithText:@"Super Sonic"];
    label.fontColor = [SKColor colorWithRed:186.0/256.0 green:165.0/256.0 blue:84.0/256.0 alpha:1.0];
    label.position = CGPointMake(CGRectGetMinX(self.frame) - 100, CGRectGetMaxY(self.frame) + 350);
    label.zPosition = 0.5;
    label.fontSize = 30.0;
    label.fontName = @"Helvetica";
    
    SKAction *accion = [SKAction moveTo:CGPointMake(CGRectGetMidX(self.frame) - 100, CGRectGetMidY(self.frame) + 300) duration:1.0];
    [label runAction:accion];
    
    return label;
}

-(SKLabelNode *) subTitulo
{
    SKLabelNode *label = [SKLabelNode labelNodeWithText:@"Game"];
    label.fontColor = [SKColor colorWithRed:186.0/256.0 green:165.0/256.0 blue:84.0/256.0 alpha:1.0];
    label.position = CGPointMake(CGRectGetMinX(self.frame) + 100, CGRectGetMaxY(self.frame) - 350);
    label.zPosition = 0.5;
    label.fontSize = 30.0;
    label.fontName = @"Helvetica";
    
    SKAction *accion = [SKAction moveTo:CGPointMake(CGRectGetMidX(self.frame) - 100, CGRectGetMidY(self.frame) + 250) duration:1.0];
    [label runAction:accion];
    
    return label;
}

-(SKLabelNode *) botonJugar
{
    SKLabelNode *label = [SKLabelNode labelNodeWithText:@"Play"];
    label.fontColor = [SKColor colorWithRed:186.0/256.0 green:165.0/256.0 blue:84.0/256.0 alpha:1.0];
    label.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 100);
    label.zPosition = 0.5;
    label.fontSize = 30.0;
    label.fontName = @"Helvetica";
    label.name = @"botonJugar";
    
    return label;
    
}

-(NSArray *)loadFramesFromSpriteSheet:(SKTexture *)textureSpriteSheet withBaseFileName: (NSString *) baseFileName withNumbersOfFrames:(int) numberOfFrames withCoordenadas: (NSDictionary *) coordenadasSpriteSheet
{
    NSMutableArray *frames = [NSMutableArray arrayWithCapacity:numberOfFrames + 1];
    for (int i = 1; i <= numberOfFrames; i++)
    {
        NSDictionary * coordenadasSprite = [coordenadasSpriteSheet objectForKey:[NSString stringWithFormat:@"%@%d",baseFileName, i]];
        NSString *x = [coordenadasSprite objectForKey:@"x"];
        NSString *y = [coordenadasSprite objectForKey:@"y"];
        NSString *width = [coordenadasSprite objectForKey:@"width"];
        NSString *height = [coordenadasSprite objectForKey:@"height"];
        SKTexture *texture = [SKTexture textureWithRect:
                              CGRectMake((CGFloat)[x floatValue]/ textureSpriteSheet.size.width,
                                         (textureSpriteSheet.size.height - (CGFloat)[y floatValue]-((CGFloat)[height floatValue]))/ textureSpriteSheet.size.height,
                                         (CGFloat)[width floatValue]/ textureSpriteSheet.size.width,
                                         (CGFloat)[height floatValue]/ textureSpriteSheet.size.height)
                                              inTexture:textureSpriteSheet];
        [frames addObject:texture];
    }
    return frames;
}


@end
