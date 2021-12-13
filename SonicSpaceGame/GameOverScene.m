//
//  GameOverScene.m
//  T9E1_Jasaba
//
//  Created by Shorlo on 13/3/15.
//  Copyright (c) 2015 Shorlo. All rights reserved.
//

#import "GameOverScene.h"
#import "GameScenePlay.h"
@implementation GameOverScene

-(void)didMoveToView:(SKView *)view
{
    [self removeAllChildren];
    self.scaleMode = SKSceneScaleModeAspectFill;
    if (!_cargarEscena) {
        [self cargarEscenaConElementos];
        [self cargarEscena];
    }
}

-(void) cargarEscenaConElementos
{
    self.backgroundColor = [SKColor colorWithRed:0.0 green:23.0/256.0 blue:49.0 alpha:1.0];
    
    
    
    [self addChild:self.gameOverLabel];
    [self addChild:self.puntuacion];
}

-(SKLabelNode *) gameOverLabel
{
    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Helvetica" ];
    label.text = @"GAME OVER!";
    label.fontSize = 24;
    label.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));

    
    return label;
}

-(SKLabelNode *) puntuacion
{
    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    label.text = [NSString stringWithFormat:@"%d", _points];
    label.fontSize = 20.0;
    label.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 50);
    
    
    return label;
}

-(SKTransition *) transicion
{
    SKTransition *miTransicion = [SKTransition fadeWithDuration:3];
    return miTransicion;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        self.transicionInicio = [self transicion];
        GameScenePlay *newScene = [[GameScenePlay alloc] initWithSize:self.frame.size];
        [self.view presentScene:newScene transition:_transicionInicio];
    }
}

@end
