#import "TestView.h"

#import <CoreText/CoreText.h>

@implementation TestView

- (CTFrameRef)createCTFrame {
    int fontSize = 16 * UIScreen.mainScreen.scale;
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:@"《眼中星》" attributes:@{
        NSFontAttributeName: [UIFont boldSystemFontOfSize:fontSize],
        NSForegroundColorAttributeName: [UIColor redColor],
    }];
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributedString);
    CGSize stringSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), NULL, CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX), NULL);
    float width = ceil(stringSize.width);
    float height = ceil(stringSize.height);
    CGPathRef path = CGPathCreateWithRect(CGRectMake(0.0, 0.0, width, height), NULL);
    CTFrameRef ctFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    CFRange stringRange =  CTFrameGetStringRange(ctFrame);
    CFRange visibleStringRange =  CTFrameGetVisibleStringRange(ctFrame);
    NSLog(@"stringRange.location: %@ stringRange.length: %@", @(stringRange.location), @(stringRange.length));
    NSLog(@"visibleStringRange.location: %@ visibleStringRange.length: %@", @(visibleStringRange.location), @(visibleStringRange.length));
    // NSAssert(stringRange.length == visibleStringRange.length, @"StringRange mismatch!");
    return ctFrame;
}

- (void)drawRect:(CGRect)rect {
    CTFrameRef ctFrame = [self createCTFrame];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, 0, rect.size.height / 2);
    CTFrameDraw(ctFrame, context);
}

@end
