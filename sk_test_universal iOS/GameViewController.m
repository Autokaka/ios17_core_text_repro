//
//  GameViewController.m
//  sk_test_universal iOS
//
//  Created by 鲁澳 on 2023/10/19.
//

#import "GameViewController.h"
#import "GameScene.h"

@implementation GameViewController

SKLabelNode *createLabelNode(void) {
    CGFloat scale = [UIScreen.mainScreen scale];
    NSLog(@"FUCK?%@", @(scale));
    int fontSize = 16 * scale;
    NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:@"《眼中《星》眼中星眼中星眼中星眼中星眼中星》" attributes:@{
        NSFontAttributeName: [UIFont boldSystemFontOfSize:fontSize],
        NSForegroundColorAttributeName: [UIColor whiteColor],
    }];
    SKLabelNode *node = [SKLabelNode labelNodeWithAttributedText:attrText];
    node.numberOfLines = 0;
    node.preferredMaxLayoutWidth = 0;
    node.fontSize = fontSize;
    node.fontName = [UIFont boldSystemFontOfSize:fontSize].fontName;
    NSLog(@"node size: %@x%@", @(node.frame.size.width), @(node.frame.size.height));
    return node;
}

- (SKView *)skView {
    return (SKView *)self.view;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Load the SKScene from 'GameScene.sks'
    SKScene *scene = [SKScene sceneWithSize:self.skView.frame.size];
    scene.anchorPoint = CGPointMake(0.5, 0.5);
    
    // Set the scale mode to scale to fit the window
    scene.scaleMode = SKSceneScaleModeAspectFit;
    [scene addChild:createLabelNode()];
    
    // Present the scene
    [self.skView presentScene:scene];
    
    self.skView.showsFPS = YES;
    self.skView.showsNodeCount = YES;
}

- (void)viewDidLayout {
    self.skView.scene.size = self.skView.frame.size;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
