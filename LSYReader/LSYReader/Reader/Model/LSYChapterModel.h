//
//  LSYChapterModel.h
//  LSYReader
//
//  Created by Labanotation on 16/5/31.
//  Copyright © 2016年 okwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface LSYChapterModel : NSObject<NSCopying,NSCoding>
@property (nonatomic,strong) NSString *content;
@property (nonatomic,strong) NSString *title;
@property (nonatomic) NSUInteger pageCount;
@property (nonatomic,copy) NSString *epubImagePath;
@property (nonatomic,assign) BOOL isEpub;

@property (nonatomic,copy) NSArray *epubContent;
-(NSString *)stringOfPage:(NSUInteger)index;
-(void)updateFont;
+(id)chapterWithEpub:(NSString *)chapterpath title:(NSString *)title imagePath:(NSString *)path;

-(void)parserEpubToDictionary;
@end

