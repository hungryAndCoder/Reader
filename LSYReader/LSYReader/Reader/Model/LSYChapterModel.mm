//
//  LSYChapterModel.m
//  LSYReader
//
//  Created by Labanotation on 16/5/31.
//  Copyright © 2016年 okwei. All rights reserved.
//

#import "LSYChapterModel.h"
#import "LSYReadConfig.h"
#import "LSYReadParser.h"
#include <vector>
@interface LSYChapterModel ()
@property (nonatomic) std::vector<NSUInteger> pages;
@end

@implementation LSYChapterModel
-(id)copyWithZone:(NSZone *)zone
{
    LSYChapterModel *model = [[LSYChapterModel allocWithZone:zone] init];
    model.content = self.content;
    model.title = self.title;
    model.pageCount = self.pageCount;
    return model;
    
}
-(void)setContent:(NSString *)content
{
    _content = content;
    [self paginateWithBounds:CGRectMake(LeftSpacing, TopSpacing, [UIScreen mainScreen].bounds.size.width-LeftSpacing-RightSpacing, [UIScreen mainScreen].bounds.size.height-TopSpacing-BottomSpacing)];
}
-(void)updateFont
{
    [self paginateWithBounds:CGRectMake(LeftSpacing, TopSpacing, [UIScreen mainScreen].bounds.size.width-LeftSpacing-RightSpacing, [UIScreen mainScreen].bounds.size.height-TopSpacing-BottomSpacing)];
}
-(void)paginateWithBounds:(CGRect)bounds
{
    _pages.clear();
    NSMutableAttributedString *attrString = [[NSMutableAttributedString  alloc] initWithString:self.content];
    NSDictionary *attribute = [LSYReadParser parserAttribute:[LSYReadConfig shareInstance]];
    [attrString setAttributes:attribute range:NSMakeRange(0, attrString.length)];
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef) attrString);
    CGPathRef path = CGPathCreateWithRect(bounds, NULL);
    int currentOffset = 0;
    int currentInnerOffset = 0;
    BOOL hasMorePages = YES;
    // 防止死循环，如果在同一个位置获取CTFrame超过2次，则跳出循环
    int preventDeadLoopSign = currentOffset;
    int samePlaceRepeatCount = 0;
    
    while (hasMorePages) {
        if (preventDeadLoopSign == currentOffset) {
            
            ++samePlaceRepeatCount;
            
        } else {
            
            samePlaceRepeatCount = 0;
        }
        
        if (samePlaceRepeatCount > 1) {
            // 退出循环前检查一下最后一页是否已经加上
            if (_pages.size() == 0) {
                
                _pages.push_back(currentOffset);
                
            } else {
                
                NSUInteger lastOffset = _pages.back();
                
                if (lastOffset != currentOffset) {
                    
                    _pages.push_back(currentOffset);
                }
            }
            break;
        }
        
        _pages.push_back(currentOffset);
        
        CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(currentInnerOffset, 0), path, NULL);
        CFRange range = CTFrameGetVisibleStringRange(frame);
        
        if ((range.location + range.length) != attrString.length) {
            
            currentOffset += range.length;
            currentInnerOffset += range.length;
            
        } else {
            // 已经分完，提示跳出循环
            hasMorePages = NO;
        }
        if (frame) CFRelease(frame);
    }
    
    CGPathRelease(path);
    CFRelease(frameSetter);
    _pageCount = _pages.size();
}
-(NSString *)stringOfPage:(NSUInteger)index
{
    NSUInteger local = _pages[index];
    NSUInteger length;
    if (index<self.pageCount-1) {
        length = _pages[index+1]-_pages[index];
    }
    else{
        length = _content.length-_pages[index];
    }
    return [_content substringWithRange:NSMakeRange(local, length)];
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.content forKey:@"content"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeInteger:self.pageCount forKey:@"pageCount"];
//    [NSValue value:&cValue withObjCType:@encode(typeof(cValue))];
    NSMutableArray *array = [NSMutableArray array];
    for(int i = 0; i < _pages.size(); i++){
       [array addObject:[NSValue value:&_pages[i] withObjCType:@encode(int)]];
    }
//    [aCoder encodeObject:MyGetArrayFromVector(_pages) forKey:@"pages"];
    [aCoder encodeObject:array forKey:@"pages"];
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        _content = [aDecoder decodeObjectForKey:@"content"];
        NSArray *page = [aDecoder decodeObjectForKey:@"pages"];
        for (int i = 0; i<page.count; i++) {
            int value;
            [page[i] getValue:&value];
            _pages.push_back(value);
        }
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.pageCount = [aDecoder decodeIntegerForKey:@"pageCount"];
    }
    return self;
}
@end
