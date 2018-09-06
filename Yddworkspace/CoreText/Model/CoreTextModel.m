//
//  CoreTextModel.m
//  Yddworkspace
//
//  Created by ydd on 2018/9/5.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "CoreTextModel.h"
#define KImagePre @"< image src=\""
#define KImageSuf @"\" >"

/* Callbacks */
static void coreTextDeallocCallback( void* ref ){
  ref =nil;
}

static CGFloat coreTextAscentCallback( void *ref ){
  return [(NSString*)[(__bridge NSDictionary*)ref objectForKey:@"height"] floatValue];
}

static CGFloat coreTextDescentCallback( void *ref ){
  return [(NSString*)[(__bridge NSDictionary*)ref objectForKey:@"descent"] floatValue];
}

static CGFloat coreTextWidthCallback( void* ref ){
  return [(NSString*)[(__bridge NSDictionary*)ref objectForKey:@"width"] floatValue];
}


@interface CoreTextModel ()

@property(nonatomic, strong) NSMutableAttributedString *contentAtt;
@property(nonatomic, assign) CGFloat contentOffsetY;
@property(nonatomic, assign) int height;


@end

@implementation CoreTextModel

- (instancetype)initWithContentStr:(NSString *)contentStr contentMaxWidth:(CGFloat)width
{
  self = [super init];
  if (self) {
    _imageArr = [NSMutableArray array];
    _contentMaxWidth = width;
    
    // 生成富文本
    _contentAtt = [self createContentAttWithStr:contentStr];
    
    // 计算文本需要的高度
    _height = [self getAttributedStringHeightWithString];
    
    // 根据高度获取 frameRef
    [self createCTFrameRef];
  }
  return self;
}

- (int)getAttributedStringHeightWithString {
  int total_height = 0;
  if (!_contentAtt) {
    return total_height;
  }
  // string 为要计算高度的NSAttributedString
  CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((
                                                                          CFAttributedStringRef)_contentAtt);
  static int maxHeight = 1000;
  // 这里的高要设置足够大(太大会导致文本计算慢)
  CGRect drawingRect = CGRectMake(0, 0, _contentMaxWidth, maxHeight);
  CGMutablePathRef path = CGPathCreateMutable();
  CGPathAddRect(path, NULL, drawingRect);
  CTFrameRef textFrame =
  CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
  CGPathRelease(path);
  CFRelease(framesetter);
  
  NSArray* linesArray = (NSArray*)CTFrameGetLines(textFrame);
  
  CGPoint origins[[linesArray count]];
  CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), origins);
  
  int line_y =
  (int)origins[[linesArray count] - 1].y;  // 最后一行line的原点y坐标
  
  CGFloat ascent;
  CGFloat descent;
  CGFloat leading;
  
  CTLineRef line =
  (__bridge CTLineRef)[linesArray objectAtIndex:[linesArray count] - 1];
  CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
  // +1为了纠正descent转换成int小数点后舍去的值
  total_height = 1000 - line_y + (int)descent + 1;
  CFRelease(textFrame);
  NSLog(@"文本高度 contentOfSizeY : %d", total_height);
  return total_height;
}

- (void)createCTFrameRef
{
  CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)_contentAtt);
  
  CGMutablePathRef path = CGPathCreateMutable();
  CGPathAddRect(path, NULL, CGRectMake(0, 0, _contentMaxWidth, _height));
  _frameRef = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, _contentAtt.length), path, NULL);
  [self handleActiveRectWithFrame:_frameRef];
  CFRelease(framesetterRef);
  CFRelease(path);
}

- (void)handleActiveRectWithFrame:(CTFrameRef)frame
{
  NSArray *arrlines = (NSArray *)CTFrameGetLines(frame);
  NSInteger count = arrlines.count;
  CGPoint points[count];
  CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), points);
  NSInteger imageCount = 0;
  for (int i = 0; i < count; i++) {
    CTLineRef line = (__bridge CTLineRef)arrlines[i];
    CGFloat lineAscent;
    CGFloat lineDescent;
    CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, NULL);
    _contentOffsetY += lineDescent + lineAscent;
    NSArray *arrGlyphRun = (NSArray *)CTLineGetGlyphRuns(line);
    for (int j = 0; j < arrGlyphRun.count; j++) {
      CTRunRef run = (__bridge CTRunRef)arrGlyphRun[j];
      NSDictionary *attributes = (NSDictionary *)CTRunGetAttributes(run);
      CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[attributes valueForKey:(id)kCTRunDelegateAttributeName];
      CGPoint point = points[i];
      
      NSDictionary *metaDic = CTRunDelegateGetRefCon(delegate);
      if (![metaDic isKindOfClass:[NSDictionary class]]) {
        continue;
      }
      CGRect imageFrame = [self getLocWithFrame:frame CTLine:line CTRun:run origin:point];
      CoreTextImageModel *imageModel = _imageArr[imageCount];
      imageModel.imageFrame = imageFrame;
      [_imageArr replaceObjectAtIndex:imageCount withObject:imageModel];
      imageCount++;
    }
  }
  NSLog(@"handleActiveRectWithFrame: _contentOffsetY : %f", _contentOffsetY);
}

- (CGRect)getLocWithFrame:(CTFrameRef)frame CTLine:(CTLineRef)line CTRun:(CTRunRef)run origin:(CGPoint)origin
{
  CGFloat ascent;//行上边距离
  CGFloat descent;//行下边距离
  CGRect boundsRun;
  
  boundsRun.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);
  boundsRun.size.height = ascent + descent;
  CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
  boundsRun.origin.x = origin.x + xOffset;
  boundsRun.origin.y = origin.y - descent;
  CGPathRef path = CTFrameGetPath(frame);
  CGRect colRect = CGPathGetBoundingBox(path);
  CGRect deleteBounds = CGRectOffset(boundsRun, colRect.origin.x, colRect.origin.y);
  return deleteBounds;
}

// <image src="path">
- (NSMutableAttributedString *)createContentAttWithStr:(NSString *)contentStr
{
  NSString *analyzeStr = [contentStr copy];
  NSMutableAttributedString *mutAtt = [[NSMutableAttributedString alloc] init];
  while (YES) {
    NSRange imagePreRange = [analyzeStr rangeOfString:KImagePre];
    NSRange imageSufRange = [analyzeStr rangeOfString:KImageSuf];
    if (imagePreRange.location != NSNotFound &&
        imageSufRange.location != NSNotFound &&
        imageSufRange.location > NSMaxRange(imagePreRange)) {
      if (imagePreRange.location != 0) {
        NSString *preStr = [analyzeStr substringToIndex:imagePreRange.location];
        NSAttributedString *preAtt = [[NSAttributedString alloc] initWithString:preStr attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
        [mutAtt appendAttributedString:preAtt];
      }
      
      NSString *imageName = [analyzeStr substringWithRange:NSMakeRange(NSMaxRange(imagePreRange),imageSufRange.location - NSMaxRange(imagePreRange))];
      NSAttributedString *imageAtt = [self getImageWithName:imageName location:mutAtt.length];
      [mutAtt appendAttributedString:imageAtt];
      
      analyzeStr = [analyzeStr substringFromIndex:NSMaxRange(imageSufRange)];
    } else {
      if (analyzeStr.length > 0) {
        NSAttributedString *lastAtt = [[NSAttributedString alloc] initWithString:analyzeStr attributes:@{NSForegroundColorAttributeName:[UIColor purpleColor]}];
        [mutAtt appendAttributedString:lastAtt];
      }
      break;
    }
  }
  
  NSDictionary *attDic = [self getAttributesParagraphStyleDic];
  [mutAtt addAttributes:attDic range:NSMakeRange(0, mutAtt.length)];
  [mutAtt addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, mutAtt.length)];
  
  return mutAtt;
}

- (NSAttributedString *)getImageWithName:(NSString *)imageName location:(NSInteger)location
{
  UIImage *image = [UIImage imageNamed:imageName];
  if (!image) {
    return [[NSAttributedString alloc] initWithString:@""];
  }
  CTRunDelegateCallbacks imageCallbacks;
  imageCallbacks.version = kCTRunDelegateVersion1;
  imageCallbacks.dealloc = coreTextDeallocCallback;
  imageCallbacks.getAscent = coreTextAscentCallback;
  imageCallbacks.getDescent = coreTextDescentCallback;
  imageCallbacks.getWidth = coreTextWidthCallback;
  
  CoreTextImageModel *imageModel = [[CoreTextImageModel alloc] initWithImageName:imageName loaction:location];
  [_imageArr addObject:imageModel];
  
  NSDictionary *imageAttrDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:imageModel.width],@"width", [NSNumber numberWithFloat:imageModel.height], @"height", nil];
  
  CTRunDelegateRef runDelegate = CTRunDelegateCreate(&imageCallbacks, (__bridge void *)(imageAttrDic));
  NSMutableAttributedString* attribute = [[NSMutableAttributedString alloc]
                                          initWithString:@" "];  // 空格用于给图片留位置
  [attribute addAttribute:(NSString*)kCTRunDelegateAttributeName
                    value:(__bridge id)runDelegate
                    range:NSMakeRange(0, 1)];
  CFRelease(runDelegate);
  [attribute addAttribute:@"image"
                    value:image
                    range:NSMakeRange(0, 1)];
  return attribute;
}

- (CGFloat)contentHeight
{
  return _height;
}

- (CTFrameRef)getFrameRef
{
  return _frameRef;
}

- (NSDictionary *)getAttributesParagraphStyleDic
{
  // 创建文本,    行间距
  CTParagraphStyleSetting lineSpaceStyle = [self linespace:3];
  // 换行模式

  CTParagraphStyleSetting lineBreakMode = [self lineBreakMode:kCTLineBreakByCharWrapping];
  
  // 设置  段落间距
  CTParagraphStyleSetting paragraphStyle = [self specifierParagraphspace:5];
 
  CTParagraphStyleSetting alignment = [self getTextAlignment:kCTJustifiedTextAlignment];
  
  CTParagraphStyleSetting wd = [self writingDirection:kCTWritingDirectionRightToLeft];
  
  const CTParagraphStyleSetting settings[] = {lineBreakMode, lineSpaceStyle,
    paragraphStyle, alignment, wd};
  
  CTParagraphStyleRef style = CTParagraphStyleCreate(settings, 5);
  
  // build attributes
  NSDictionary* attributesDic = @{(id)kCTParagraphStyleAttributeName:(id)style};
  return attributesDic;
}

#pragma mark 文本对齐方式
- (CTParagraphStyleSetting)getTextAlignment:(CTTextAlignment)alignment
{
  /*
  kCTLeftTextAlignment = 0,                //左对齐
  kCTRightTextAlignment = 1,               //右对齐
  kCTCenterTextAlignment = 2,              //居中对齐
  kCTJustifiedTextAlignment = 3,           //文本对齐
  kCTNaturalTextAlignment = 4              //自然文本对齐
   */
  CTParagraphStyleSetting alignmentStyle;
  alignmentStyle.spec = kCTParagraphStyleSpecifierAlignment;//指定为对齐属性
  alignmentStyle.valueSize = sizeof(alignment);
  alignmentStyle.value = &alignment;
  return alignmentStyle;
}

#pragma mark 首行缩进
- (CTParagraphStyleSetting)fristlineIndent:(CGFloat)indent
{
  //首行缩进
  CGFloat fristlineindent = indent; // 24.0f;
  CTParagraphStyleSetting fristline;
  fristline.spec = kCTParagraphStyleSpecifierFirstLineHeadIndent;
  fristline.value = &fristlineindent;
  fristline.valueSize = sizeof(float);
  return fristline;
}
#pragma mark 段头缩进
- (CTParagraphStyleSetting)headIndent:(CGFloat)indent
{
  CGFloat headindent = indent; // 10.0f;
  CTParagraphStyleSetting head;
  head.spec = kCTParagraphStyleSpecifierHeadIndent;
  head.value = &headindent;
  head.valueSize = sizeof(float);
  return head;
}

#pragma mark 段尾缩进
- (CTParagraphStyleSetting)tailindent:(CGFloat)indent
{
  CGFloat tailindent = indent; // 50.0f;
  CTParagraphStyleSetting tail;
  tail.spec = kCTParagraphStyleSpecifierTailIndent;
  tail.value = &tailindent;
  tail.valueSize = sizeof(float);
  return tail;
}

#pragma mark 制表符（tab）代码：
- (CTParagraphStyleSetting)tabalignment
{
  CTTextAlignment tabalignment = kCTJustifiedTextAlignment;
  CTTextTabRef texttab = CTTextTabCreate(tabalignment, 24, NULL);
  CTParagraphStyleSetting tab;
  tab.spec = kCTParagraphStyleSpecifierTabStops;
  tab.value = &texttab;
  tab.valueSize = sizeof(CTTextTabRef);
  return tab;
}

#pragma mark 换行模式
/*
 kCTLineBreakByWordWrapping = 0,        //出现在单词边界时起作用，如果该单词不在能在一行里显示时，整体换行。此为段的默认值。
 kCTLineBreakByCharWrapping = 1,        //当一行中最后一个位置的大小不能容纳一个字符时，才进行换行。
 kCTLineBreakByClipping = 2,            //超出画布边缘部份将被截除。
 kCTLineBreakByTruncatingHead = 3,      //截除前面部份，只保留后面一行的数据。前部份以...代替。
 kCTLineBreakByTruncatingTail = 4,      //截除后面部份，只保留前面一行的数据，后部份以...代替。
 kCTLineBreakByTruncatingMiddle = 5     //在一行中显示段文字的前面和后面文字，中间文字使用...代替。
 */
- (CTParagraphStyleSetting)lineBreakMode:(CTLineBreakMode)model
{
  CTParagraphStyleSetting lineBreakMode;
  CTLineBreakMode lineBreak = model;//kCTLineBreakByCharWrapping;//换行模式
  lineBreakMode.spec = kCTParagraphStyleSpecifierLineBreakMode;
  lineBreakMode.value = &lineBreak;
  lineBreakMode.valueSize = sizeof(CTLineBreakMode);
  return lineBreakMode;
}

#pragma mark 多行高
- (CTParagraphStyleSetting)mutLineHeight:(CGFloat)height
{
  CGFloat MutiHeight = height; // 10.0f;
  CTParagraphStyleSetting Muti;
  Muti.spec = kCTParagraphStyleSpecifierLineHeightMultiple;
  Muti.value = &MutiHeight;
  Muti.valueSize = sizeof(float);
  return Muti;
}

#pragma mark 最大行高
- (CTParagraphStyleSetting)lineMaxHeight:(CGFloat)maxHeight
{
  CGFloat MaxHeight =  maxHeight; // 5.0f;
  CTParagraphStyleSetting Max;
  Max.spec = kCTParagraphStyleSpecifierLineHeightMultiple;
  Max.value = &MaxHeight;
  Max.valueSize = sizeof(float);
  return Max;
}

#pragma mark 行距
- (CTParagraphStyleSetting)linespace:(CGFloat)space
{
  CGFloat _linespace = space; // 5.0f;
  CTParagraphStyleSetting lineSpaceSetting;
  lineSpaceSetting.spec = kCTParagraphStyleSpecifierLineSpacingAdjustment;
  lineSpaceSetting.value = &_linespace;
  lineSpaceSetting.valueSize = sizeof(float);
  return lineSpaceSetting;
}

#pragma mark 段前间隔
- (CTParagraphStyleSetting)paragraphspace:(CGFloat)space
{
  CGFloat paragraphspace = space; // 5.0f;
  CTParagraphStyleSetting paragraph;
  paragraph.spec = kCTParagraphStyleSpecifierMaximumLineSpacing;
  paragraph.value = &paragraphspace;
  paragraph.valueSize = sizeof(float);
  return paragraph;
}
#pragma mark 段落间距
- (CTParagraphStyleSetting)specifierParagraphspace:(CGFloat)space
{
  CGFloat paragraph = 0.5;
  CTParagraphStyleSetting paragraphStyle;
  paragraphStyle.spec = kCTParagraphStyleSpecifierParagraphSpacing;
  paragraphStyle.valueSize = sizeof(CGFloat);
  paragraphStyle.value = &paragraph;
  return paragraphStyle;
}

#pragma mark 基本书写方向代码：
/*
 kCTWritingDirectionNatural = -1,            //普通书写方向，一般习惯是从左到右写
 kCTWritingDirectionLeftToRight = 0,         //从左到右写
 kCTWritingDirectionRightToLeft = 1          //从右到左写
 */
- (CTParagraphStyleSetting)writingDirection:(CTWritingDirection)wd
{
  //书写方向
//  CTWritingDirection wd = kCTWritingDirectionRightToLeft;
  CTParagraphStyleSetting writedic;
  writedic.spec = kCTParagraphStyleSpecifierBaseWritingDirection;
  writedic.value = &wd;
  writedic.valueSize = sizeof(CTWritingDirection);
  return writedic;
}

- (void)dealloc
{
  NSLog(@"dealloc %@", NSStringFromClass(self.class));
}


@end
