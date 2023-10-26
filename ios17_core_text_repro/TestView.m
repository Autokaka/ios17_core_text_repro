#import "TestView.h"

#import <CoreText/CoreText.h>

@implementation TestView

+ (NSAttributedString *)createAttributedStringWithText:(NSString *)text color:(UIColor *)color {
    CGFloat fontSize = 16 * UIScreen.mainScreen.scale;
    return [[NSAttributedString alloc] initWithString:text attributes:@{
        NSFontAttributeName: [UIFont boldSystemFontOfSize:fontSize],
        NSForegroundColorAttributeName: color,
    }];
}

// Create CGImage using CoreText
+ (CGImageRef)createCGImageUsingCoreText:(NSString *)text {
    // Step 1, measure the text
    NSAttributedString *attributedString = [TestView createAttributedStringWithText:text color:[UIColor redColor]];
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributedString);
    CGSize stringSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), NULL, CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX), NULL);
    CGFloat width = ceil(stringSize.width);
    CGFloat height = ceil(stringSize.height);
    
    // Step 2, draw the text frame
    CGPathRef path = CGPathCreateWithRect(CGRectMake(0.0, 0.0, width, height), NULL);
    CTFrameRef ctFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    CFRange stringRange =  CTFrameGetStringRange(ctFrame);
    CFRange visibleStringRange =  CTFrameGetVisibleStringRange(ctFrame);
    NSLog(@"stringRange.location: %@ stringRange.length: %@", @(stringRange.location), @(stringRange.length));
    // BUG: Expect visibleStringRange.length to be 5 (the same as stringRange.length), but got 3
    NSLog(@"visibleStringRange.location: %@ visibleStringRange.length: %@", @(visibleStringRange.location), @(visibleStringRange.length));
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 4 * width, CGColorSpaceCreateDeviceRGB(), kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast);
    CTFrameDraw(ctFrame, context);
    return CGBitmapContextCreateImage(context);
}

// Create UIImage using UIKit
+ (UIImage *)createUIImageUsingUIKit:(NSString *)text {
    NSAttributedString *attributedString = [TestView createAttributedStringWithText:text color:[UIColor greenColor]];
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    CGRect rect = [attributedString boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:options context:nil];
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithBounds:rect];
    return [renderer imageWithActions:^(UIGraphicsImageRendererContext *rendererContext) {
        [attributedString drawWithRect:rect options:options context:nil];
    }];
}

- (void)drawRect:(CGRect)rect {
    NSString *text = @"《眼中星》";
    
    // Solution 1, create CGImage using CoreText and draw the result to screen.
    // The the display result will be "《眼中" with red color.
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGImageRef cgImage = [TestView createCGImageUsingCoreText:text];
    CGContextTranslateCTM(context, 0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, 0, 300);
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(cgImage), CGImageGetHeight(cgImage)), cgImage);
    
    // Solution 2, create UIImage using UIKit and draw the result to screen.
    // The the display result will be "《眼中星》" with green color.
    UIImage *uiImage = [TestView createUIImageUsingUIKit:text];
    CGFloat scale = UIScreen.mainScreen.scale;
    CGContextScaleCTM(context, 1 / scale, 1 / scale);
    CGContextTranslateCTM(context, 0, -300);
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(uiImage.CGImage), CGImageGetHeight(uiImage.CGImage)), uiImage.CGImage);
    
    // BUG: Expect the display result to be "《眼中星》" (like the result of Solution 2), but the Solution 1 display text as "《眼中".
}

@end
