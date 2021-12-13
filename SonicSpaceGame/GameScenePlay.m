//
//  GameScenePlay.m
//  T7E2_Jasaba
//
//  Created by Shorlo on 21/2/15.
//  Copyright (c) 2015 Shorlo. All rights reserved.
//

#import "GameScenePlay.h"
#import "GameOverScene.h"
@implementation GameScenePlay 

static const uint32_t ringCategory = 0x1 << 0;
static const uint32_t sonicCategory = 0x1 << 1;
static const uint32_t cometaCategory = 0x1 << 2;
static const uint32_t asteroideCategory = 0x1 << 3;



+(NSArray *)loadFramesFromAtlas:(SKTextureAtlas *)textureAtlas withBaseFileName: (NSString *) baseFileName withNumberOfFrames:(int) numberOfFrames
{
    NSMutableArray *frames = [NSMutableArray arrayWithCapacity:numberOfFrames + 1];
    for (int i = 1; i<=numberOfFrames; i++) {
        NSString *fileName = [NSString stringWithFormat:@"%@%d.png", baseFileName, i];
        SKTexture *texture = [textureAtlas textureNamed:fileName];
        [frames addObject:texture];
    }
    return frames;
}

-(void) contador
{
    if (_vida < 0)
    {
        [self gameOver];
        _anillos.text = [NSString stringWithFormat:@"%d", --_vida];
    }
}

-(void) gameOver
{
    [_timerContador invalidate];
    [_timerAsteroide invalidate];
    [_timerCometa invalidate];
    [_timerRing invalidate];
    
    GameOverScene *newScene = [[GameOverScene alloc] initWithSize:self.frame.size];
    newScene.points = _points;
    [self.view presentScene:newScene transition:_gameOverTransition];
}

-(void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if (firstBody.categoryBitMask == ringCategory)
    {
        _anillos.text = [NSString stringWithFormat:@"%d", ++_vida];
        _points++;
        [firstBody.node removeFromParent];
    }
    else if (firstBody.categoryBitMask == sonicCategory)
    {
        if (secondBody.categoryBitMask == cometaCategory)
        {
            if (_vida > 5)
            {
                _vida = _vida + 5;
                _anillos.text= [NSString stringWithFormat:@"%d", _vida];
                [_sonic runAction:self.dano];
            }
            else [self gameOver];
            [self explotaCometa: secondBody.node];
        }
        else
        {
            if (_vida > 10) {
                
                SKAction *accion = [self dano];
                _anillos.text = [NSString stringWithFormat:@"%d", _vida];
                [_sonic runAction:accion];
            }
            else [self gameOver];
        }
    }
    else if (firstBody.categoryBitMask == cometaCategory)
    {
        [self explotaCometa:firstBody.node];
    }
}

-(void) borrarEmisor
{
    SKNode *emisor = [self childNodeWithName:@"explota"];
    [emisor removeFromParent];

}

-(void) explotaCometa:(SKNode *)cometa
{
    SKEmitterNode *emisorExplota = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"explosion" ofType:@"sks"]];
    emisorExplota.name = @"explota";
    emisorExplota.position = cometa.position;
    emisorExplota.targetNode = self;
    [self addChild:emisorExplota];
    [cometa removeFromParent];
    [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(borrarEmisor) userInfo:nil repeats:NO];
    
}



-(void)didMoveToView:(SKView *)view
{
    [self removeAllChildren];
    test = NO;
    _vida = 5;
    self.scaleMode = SKSceneScaleModeAspectFill;
    
    self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
    self.physicsWorld.contactDelegate = self;
    if (!_cargarEscena) {
        [self cargarEscenaConElementos];
        [self cargarEscena];
    }
}

-(void)cargarEscenaConElementos
{
    self.gameOverTransition = [SKTransition doorsCloseHorizontalWithDuration:1.0];
    
    [_sonic removeAllActions];
    [_sonic removeAllChildren];
    [_fondo1 removeAllActions];
    //INICIO FONDO
    _fondo1 = [SKSpriteNode spriteNodeWithImageNamed:@"fondo_espacio.jpg"];
    _fondo1.xScale = 1;
    _fondo1.yScale = 1;
    _fondo1.alpha = 1.0;
    _fondo1.anchorPoint = CGPointMake(0.5,0.5);
    _fondo1.zPosition = 0.0;
    _fondo1.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    //ANIMACIÓN FONDO
    SKAction *mueveFondo = [SKAction moveByX:-_fondo1.size.width y:0 duration:800];
    SKAction *reiniciaFondo = [SKAction moveTo:CGPointMake(self.view.frame.size.width, CGRectGetMidY(self.frame)) duration:0];
    SKAction *animadoFondo = [SKAction repeatActionForever:[SKAction sequence:@[mueveFondo, reiniciaFondo]]];
    //TEST FONDO
   // NSLog(@"%@", NSStringFromClass(_fondo1.class));
    //TEXTURAS SONIC
//    _contador = 0;
    _sonicSpriteSheet = [SKTexture textureWithImageNamed:@"SuperSonic.gif"];
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *plistName = @"Lista_Sprites.plist";
    NSString *finalPath = [path stringByAppendingPathComponent:plistName];
    _coordenadas = [NSDictionary dictionaryWithContentsOfFile:finalPath];
    //ANIMACIONES EN ARRAY
    self.transSonic = [self loadFramesFromSpriteSheet:_sonicSpriteSheet
                                     withBaseFileName:@"sonic_trans"
                                  withNumbersOfFrames:16
                                      withCoordenadas:_coordenadas];
    self.sonicSonic = [self loadFramesFromSpriteSheet:_sonicSpriteSheet
                                     withBaseFileName:@"sonic"       withNumbersOfFrames:7
                                      withCoordenadas:_coordenadas];
    self.runSonic   = [self loadFramesFromSpriteSheet:_sonicSpriteSheet
                                     withBaseFileName:@"sonic_run"   withNumbersOfFrames:8
                                      withCoordenadas:_coordenadas];
    self.runUpSonic = [self loadFramesFromSpriteSheet:_sonicSpriteSheet
                                     withBaseFileName:@"sonic_run_up"withNumbersOfFrames:6
                                      withCoordenadas:_coordenadas];
    self.flySonic   = [self loadFramesFromSpriteSheet:_sonicSpriteSheet
                                     withBaseFileName:@"sonic_fly"   withNumbersOfFrames:4
                                      withCoordenadas:_coordenadas];
    self.flyUpSonic = [self loadFramesFromSpriteSheet:_sonicSpriteSheet
                                     withBaseFileName:@"sonic_fly_up"withNumbersOfFrames:3
                                      withCoordenadas:_coordenadas];
    self.pushSonic  = [self loadFramesFromSpriteSheet:_sonicSpriteSheet
                                     withBaseFileName:@"sonic_push"  withNumbersOfFrames:4
                                      withCoordenadas:_coordenadas];
    self.downSonic  = [self loadFramesFromSpriteSheet:_sonicSpriteSheet
                                     withBaseFileName:@"sonic_down"  withNumbersOfFrames:5
                                      withCoordenadas:_coordenadas];
    self.chargeSonic= [self loadFramesFromSpriteSheet:_sonicSpriteSheet
                                     withBaseFileName:@"sonic_charge"withNumbersOfFrames:5
                                      withCoordenadas:_coordenadas];
    self.wheelSonic = [self loadFramesFromSpriteSheet:_sonicSpriteSheet
                                     withBaseFileName:@"sonic_wheel" withNumbersOfFrames:5
                                      withCoordenadas:_coordenadas];
    //INICIO SONIC
    self.sonic = [SKSpriteNode spriteNodeWithTexture:_flySonic[1]];
    _sonic.xScale = 1.0;
    _sonic.yScale = 1.0;
    _sonic.zPosition = 1.0;
    _sonic.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(40, 40)];
    _sonic.physicsBody.dynamic = NO;
    _sonic.physicsBody.restitution = 0.8;
    _sonic.physicsBody.angularDamping = 1.5;
    _sonic.physicsBody.linearDamping = 0.2;
    _sonic.physicsBody.density = 1;
    _sonic.physicsBody.usesPreciseCollisionDetection = YES;
    _sonic.physicsBody.categoryBitMask = sonicCategory;
    _sonic.physicsBody.collisionBitMask = asteroideCategory | cometaCategory;
    _sonic.physicsBody.contactTestBitMask = ringCategory | asteroideCategory | cometaCategory;

    
    if (test) {
        SKShapeNode *theShapeNode = [SKShapeNode node];
        CGPathRef thePath = CGPathCreateWithRect(_sonic.frame, nil);
        theShapeNode.path = thePath;
        CGPathRelease(thePath);
        theShapeNode.zPosition = 0.0;
        [_sonic addChild:theShapeNode];
        
    }

    //ANIMACIÓN SONIC
    SKAction *volar = [SKAction repeatAction:[SKAction animateWithTextures:_flyUpSonic timePerFrame:0.1] count:5];
    SKAction *aparece = [SKAction moveTo:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)) duration:2];
    SKAction *volarQuieto = [SKAction repeatActionForever:[SKAction animateWithTextures:_flySonic timePerFrame:0.1]];
    //TEST SONIC
    NSLog(@"%@", NSStringFromClass(_sonic.class));
    //PARTICULAS
    self.emisor = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle]
                                                          pathForResource:@"estela_sonic"
                                                          ofType:@"sks"]];

    _emisor.position = CGPointMake(0, -5);
    _emisor.alpha = 1;
    _emisor.targetNode = self.sonic; // si pongo self.scene las particulas funcionan correctamente pero
                                     // aparece por debajo de la foto de fondo.
    _emisor.zPosition = 1.0;
    
    
    
    //PIEDRAS
    self.atlasPiedra = [SKTextureAtlas atlasNamed:@"piedra"];
    _arrayPiedras = [GameScenePlay loadFramesFromAtlas: _atlasPiedra withBaseFileName: @"piedra" withNumberOfFrames:16];
    _gira = [SKAction repeatActionForever:[SKAction animateWithTextures:_arrayPiedras timePerFrame:0.15]];
    self.timerAsteroide = [NSTimer scheduledTimerWithTimeInterval: 3 + arc4random()%6 target:self
                                                     selector:@selector(generaAsteroide)
                                                     userInfo:nil
                                                      repeats:YES];
    
    
    
    //COMETA
    self.arrayCometa = [GameScenePlay loadFramesFromAtlas:_atlasPiedra withBaseFileName:@"piedra" withNumberOfFrames:16];
    _giraCometa = [SKAction repeatActionForever:[SKAction animateWithTextures:_arrayCometa timePerFrame:0.15]];
    self.timerCometa = [NSTimer scheduledTimerWithTimeInterval: 4 + arc4random() % 6
                                                    target:self
                                                  selector:@selector(generaCometa)
                                                  userInfo:nil
                                                   repeats:YES
                    ];
    
    //RINGS
    self.atlasRings = [SKTextureAtlas atlasNamed:@"ring"];
    self.arrayRings = [self.class loadFramesFromAtlas:_atlasRings withBaseFileName:@"ring" withNumberOfFrames:12];
    _ring = [self ringAnimation];
    _timerRing = [NSTimer scheduledTimerWithTimeInterval:2.5+arc4random()%4 target:self
                                               selector:@selector(generaRings) userInfo:nil repeats:YES];

    self.timerContador = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(contador) userInfo:nil repeats:YES];
    self.anillos = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    _anillos.text = @"60";
    _anillos.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) - 50);
    _anillos.zPosition = 1.0;
    
    
    
    //LLAMADAS ANIMACIONES
    [_fondo1 runAction:animadoFondo];
    [_sonic runAction:[SKAction sequence:@[[SKAction group:@[aparece, volar]], volarQuieto]]];
    //LLAMADAS A ELEMENTOS


    [self addChild:self.fondo1];
    [_sonic addChild:self.emisor];
    [self addChild:self.sonic];
    [self addChild:_anillos];
    
    
}

-(SKAction *) dano
{
    
    SKAction *color = [SKAction colorizeWithColor:[SKColor redColor]
                                 colorBlendFactor:0.8 duration:0.5];
    SKAction *normal = [SKAction colorizeWithColorBlendFactor:0.0 duration:0.2];
    SKAction *elDano = [SKAction sequence:@[color, normal]];
    return elDano;
}

-(SKShapeNode *) shapeNodeWithCircleOfRadius:(CGFloat)r
{
    SKShapeNode *shapeNode = [SKShapeNode node];
    CGPathRef thePath = CGPathCreateWithEllipseInRect((CGRect){ { -r, -r }, { r* 2, r* 2 } }, NULL);
    shapeNode.path = thePath;
    CGPathRelease(thePath);
    
    return shapeNode;
}

-(void)generaAsteroide
{
    SKSpriteNode *asteroide = [SKSpriteNode spriteNodeWithTexture:_arrayPiedras[arc4random()%16]];
    asteroide.position = CGPointMake(CGRectGetMaxX(self.frame), arc4random()%(int)CGRectGetMaxY(self.frame));
    asteroide.size = CGSizeMake(asteroide.size.width/2, asteroide.size.height/2);
    asteroide.zPosition = 1.0;
    [asteroide runAction:_gira];
    SKAction *mueve = [SKAction moveToX:-1500 duration:5+arc4random()%5];
    [asteroide runAction:mueve completion:^{
        [asteroide removeFromParent];
    }];
    SKEmitterNode *emisorAsteroide = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle]
                                                                                 pathForResource:@"asteroide"
                                                                                          ofType:@"sks"]];
    emisorAsteroide.position = CGPointMake(-15, 0);
    emisorAsteroide.particleSpeed = 100 - mueve.duration * mueve.duration;
    
    asteroide.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:asteroide.size.width/2.0];
    asteroide.physicsBody.density = 300000.0;
    asteroide.physicsBody.velocity = CGVectorMake(-emisorAsteroide.particleSpeed - 100.0, 0.0);
    asteroide.physicsBody.categoryBitMask = asteroideCategory;
    asteroide.physicsBody.collisionBitMask = asteroideCategory | cometaCategory;
    asteroide.physicsBody.dynamic = NO;
    if(test)
    {
        SKShapeNode *theShapeNode = [SKShapeNode shapeNodeWithCircleOfRadius:asteroide.size.width/2];
        [asteroide addChild:theShapeNode];
    }
    [asteroide addChild:emisorAsteroide];
    [self addChild:asteroide];
}

-(void)generaCometa
{
    SKSpriteNode *cometa = [SKSpriteNode spriteNodeWithTexture:_arrayPiedras [arc4random()%16]];
    cometa.size = CGSizeMake(cometa.size.width, cometa.size.height);
    cometa.position = CGPointMake(CGRectGetMaxX(self.frame), arc4random()%(int)CGRectGetMaxY(self.frame));
    cometa.zPosition = 1.0;
    [cometa runAction:_gira];
    SKAction *mueve = [SKAction moveToX: -1500 duration: 2 + arc4random()%5];
    [cometa runAction:mueve completion:^{
        [cometa removeFromParent];
    }];
    SKEmitterNode *emisorCometa = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle]
                                                                              pathForResource:@"cometa"
                                                                              ofType:@"sks"]];
    emisorCometa.position = CGPointMake(-7, 0);
    emisorCometa.particleSpeed = 80 - mueve.duration * mueve.duration;
    cometa.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:cometa.size.width/2];
    cometa.physicsBody.density = 3000;
    cometa.physicsBody.velocity = CGVectorMake(-emisorCometa.particleSpeed - 100.0, 0.0);
    cometa.physicsBody.categoryBitMask = cometaCategory;
    cometa.physicsBody.collisionBitMask = 0;
    cometa.physicsBody.contactTestBitMask = asteroideCategory | cometaCategory;
        cometa.physicsBody.dynamic = NO;
    if(test)
    {
        SKShapeNode *theShapeNode = [SKShapeNode shapeNodeWithCircleOfRadius:cometa.size.width/2];
        [cometa addChild:theShapeNode];
    }
    [cometa addChild:emisorCometa];
    [self addChild:cometa];
}

-(void) generaRings
{
    float y = 60.0 + (float)(arc4random()%((unsigned int)CGRectGetMaxY(self.frame) - 120));
    float duracion = (float)(2+arc4random()%4);
    for (int i = 0; i <= arc4random()%4; i++) {
        SKSpriteNode *anillo = [SKSpriteNode spriteNodeWithTexture:_arrayRings[0]];
        anillo.position = CGPointMake(CGRectGetMaxX(self.frame)+ 25*i, y);
        [anillo runAction:self.ring];
        anillo.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:anillo.size.width/2.0];
        anillo.physicsBody.categoryBitMask = ringCategory;
        anillo.physicsBody.contactTestBitMask = sonicCategory;
        anillo.physicsBody.collisionBitMask = 0;
        SKAction *mueve = [SKAction moveToX:-100+20*i duration:duracion];
        [anillo runAction:mueve completion:^{
            [anillo removeFromParent];
        }];
        if (test)
        {
            SKShapeNode *shapeNode = [SKShapeNode shapeNodeWithCircleOfRadius:anillo.size.width/2.0];
            [anillo addChild:shapeNode];
        }
        [self addChild:anillo];
    }
    
}

-(SKAction *) ringAnimation
{
    SKAction *accion = [SKAction repeatActionForever:[SKAction animateWithTextures:_arrayRings
                                                   timePerFrame:0.2]];
    return accion;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    /* Called when a touch begins */
    UITouch *touch = [touches anyObject];
    CGPoint pulsacion = [touch locationInNode:self];
    SKNode *nodo = [self nodeAtPoint:pulsacion];
    
    for (UITouch *touch in touches)
    {
       [[self nodesAtPoint:[touch locationInNode:self]] containsObject:_sonic];
        if (_sonic != (SKSpriteNode *)[self nodeAtPoint:[touch locationInNode:self]])
        {
            [self moveSonicTo:[touch locationInNode:self]];
        }
    }
}

-(void)update:(CFTimeInterval)currentTime
{
    /* Called before each frame is rendered */
}

-(void) moveSonicTo:(CGPoint) location
{
    [_sonic removeActionForKey:@"mover"];
    float base = 0;
    CGFloat distancia = sqrtf((location.x - _sonic.position.x)*(location.x - _sonic.position.x) + (location.y - _sonic.position.y) * (location.y - _sonic.position.y));
    
    if (_sonic.position.x > location.x && _sonic.position.y <= location.y)
    {
        base = M_PI;
    }
    else if (_sonic.position.x > location.x && _sonic.position.y > location.y)
    {
        base = 3 * M_PI / 2;
    }
    else if (_sonic.position.x <= location.x && _sonic.position.y > location.y)
    {
        base = 2 * M_PI;
    }
    float angulo = asinf(fabsf(location.y - _sonic.position.y) / distancia);
    if (base !=0) {
        angulo = base - angulo;
        
        SKAction *giroInicio = [SKAction rotateToAngle:angulo duration:angulo / 20 shortestUnitArc:YES];
        SKAction *mover = [SKAction moveTo:location duration:angulo/200];
        SKAction *giroFin = [SKAction rotateToAngle:0 duration:angulo / 20 shortestUnitArc:YES];
        [_sonic runAction:[SKAction sequence:@[[SKAction group:@[giroInicio,mover]],giroFin]]withKey:@"mover"];
    }
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        if (![_sonic actionForKey:@"mover"])
        {
            if (_sonic == (SKSpriteNode *)[self nodeAtPoint:[touch locationInNode:self]])
            {
                _sonic.position = [touch locationInNode:self];
            }
        }
    }
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