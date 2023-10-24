[TOC]

# Feedback for Developer Technologies & SDKs

## Please provide a descriptive title for your feedback:

`CTFramesetterSuggestFrameSizeWithConstraints` result does not match with `CTFrameDraw` actual drawing result

## Which platform is most relevant for your report?

iOS

## Which technology does your report involve?

Core Text

## What type of feedback are you reporting?

Incorrect/Unexpected Behavior

## What build does the issue occur on?

iOS 17.1 Seed 3 (21B5066a)

## Where does the issue occur?

On device

## Please describe the issue and what steps we can take to reproduce it:

1. Create NSAttributedString:

   ```objective-c
   int fontSize = 16 * [NSScreen.mainScreen backingScaleFactor];
   NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:@"《眼中星》" attributes:@{
       NSFontAttributeName: [NSFont boldSystemFontOfSize:fontSize],
       NSForegroundColorAttributeName: [NSColor whiteColor],
   }];
   ```

2. Create CTFramesetter:

   ```objective-c
   CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attributedString);
   ```

3. Get suggested size using `CTFramesetterSuggestFrameSizeWithConstraints`:

   ```objective-c
   CGSize stringSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), NULL, CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX), NULL);
   ```

4. Create CTFrame:

   ```objective-c
   float width = ceil(stringSize.width);
   float height = ceil(stringSize.height);
   CGPathRef path = CGPathCreateWithRect(CGRectMake(0.0, 0.0, width, height), NULL);
   CTFrameRef ctFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
   ```

5. Get, print and compare the VisibleStringRange and StringRange:

   ```objective-c
   CFRange stringRange =  CTFrameGetStringRange(ctFrame);
   CFRange visibleStringRange =  CTFrameGetVisibleStringRange(ctFrame);
   NSLog(@"stringRange.location: %@ stringRange.length: %@", @(stringRange.location), @(stringRange.length));
   NSLog(@"visibleStringRange.location: %@ visibleStringRange.length: %@", @(visibleStringRange.location), @(visibleStringRange.length));
   NS
   NSAssert(stringRange.length == visibleStringRange.length, @"StringRange mismatch!");
   ```

On iOS 16.* and below, macOS 13.* and below, the assertion won't be triggered, while devices running iOS 17.* and macOS 14.* does. 

This issue could also be observed by drawing the CTFrame on screen. The expected output should be "《眼中星》", but the actual drawing result shows "《眼中".

**The above code is disassembled from `SpriteKit.framework::SKCLabelNode::rebuildText` and simplified as a demo to explain the issue, which means a simple cross-platform game application using SpriteKit will also reproduce it. There is also a simple game application project to reproduce the issue in the appendix and [Github repo](https://github.com/Autokaka/ios17_core_text_repro).** 

It seems that the UIKit does not rely on `CTFramesetterSuggestFrameSizeWithConstraints` but the `NSStringDrawingEngine` to get the suggest size and draw the final frame since the Symbolic Breakpoint won't be triggered when using `UILabel` in normal applications, so the issue can't be reproduced.