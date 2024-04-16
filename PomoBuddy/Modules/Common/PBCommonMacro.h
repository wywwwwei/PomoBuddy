//
//  PBCommonMacro.h
//  PomoBuddy
//
//  Created by Wu Yongwei on 2024/4/14.
//

#ifndef PBCommonMacro_h
#define PBCommonMacro_h

#define PBSAFE_CAST(OBJ, CLASS)                                                \
  (                                                                            \
    {                                                                          \
      CLASS *target = nil;                                                     \
      if ([OBJ isKindOfClass:[CLASS class]]) {                                 \
        target = (CLASS *)OBJ;                                                 \
      }                                                                        \
      target;                                                                  \
    }                                                                          \
  )

#define WEAK_REF(obj) __weak __typeof__(obj) weak_##obj = obj
#define STRONG_REF(obj) __strong __typeof__(weak_##obj) obj = weak_##obj

#define HEXCOLOR(hex)   ([UIColor colorWithRGB:hex])
#define HEXACOLOR(hexa) ([UIColor colorWithRGBA:hexa])
#define RGBCOLOR(r,g,b) ([UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0])
#define RGBACOLOR(r,g,b,a) ([UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)])

#endif /* PBCommonMacro_h */
