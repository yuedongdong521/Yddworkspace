//
//  ISBrightnessFilter.m
//  iShow
//
//  Created by student on 2017/8/3.
//
//

#import "ISBrightnessFilter.h"

NSString* const kISBrightnessFragmentShaderString = SHADER_STRING(
    varying highp vec2 textureCoordinate;

    uniform sampler2D inputImageTexture; uniform lowp float brightness;

    highp vec3 sethue(highp vec3 rgb, highp float hd, highp float ym,
                      highp float sm) {
      rgb.r = rgb.r * 255.0;
      rgb.g = rgb.g * 255.0;
      rgb.b = rgb.b * 255.0;
      highp vec3 ycbcr;
      ycbcr.x = 0.3 * rgb.r + 0.59 * rgb.g + 0.11 * rgb.b;
      ycbcr.y = 0.7 * rgb.r - 0.59 * rgb.g - 0.11 * rgb.b;
      ycbcr.z = -0.3 * rgb.r - 0.59 * rgb.g + 0.89 * rgb.b;

      highp float fhue;
      highp float length;
      highp float sat;
      highp float hue;
      length = ycbcr.y * ycbcr.y + ycbcr.z * ycbcr.z;
      sat = sqrt(length);
      if (sat > 0.0) {
        //
        fhue = atan(ycbcr.y, ycbcr.z) * 180.0 / 3.14159265;
        if (fhue < 0.0) {
          fhue += 360.0;
        }
        hue = fhue;
      } else {
        hue = 0.0;
      }
      if (ycbcr.x > 128.0) {
        ycbcr.x += (255.0 - ycbcr.x) * ym * 0.5;
      } else {
        ycbcr.x += ycbcr.x * ym * 0.5;
      }
      if (ycbcr.x > 255.0) {
        ycbcr.x = 255.0;
      }
      if (ycbcr.x < 0.0) {
        ycbcr.x = 0.0;
      }
      highp float asfasd = (1.0 + sm);

      sat = sat * asfasd;
      hue += hd;
      if (hue > 360.0) {
        hue -= 360.0;
      }
      if (hue < 0.0) {
        hue += 360.0;
      }
      highp float rad;
      rad = 3.14159265 * hue / 180.0;
      ycbcr.y = sat * sin(rad);
      ycbcr.z = sat * cos(rad);
      rgb.r = ycbcr.x + ycbcr.y;
      if (rgb.r > 255.0) {
        rgb.r = 255.0;
      }
      if (rgb.r < 0.0) {
        rgb.r = 0.0;
      }
      rgb.g = ycbcr.x - 0.3 / 0.59 * ycbcr.y - 0.11 / 0.59 * ycbcr.z;
      if (rgb.g > 255.0) {
        rgb.g = 255.0;
      }
      if (rgb.g < 0.0) {
        rgb.g = 0.0;
      }
      rgb.b = ycbcr.x + ycbcr.z;
      if (rgb.b > 255.0) {
        rgb.b = 255.0;
      }
      if (rgb.b < 0.0) {
        rgb.b = 0.0;
      }
      rgb.r = rgb.r / 255.0;
      rgb.g = rgb.g / 255.0;
      rgb.b = rgb.b / 255.0;
      return rgb;
    }

    void main() {
      highp vec3 textureColor =
          texture2D(inputImageTexture, textureCoordinate).rgb;
      highp vec3 rgbColor = sethue(textureColor, 0.0, brightness, 0.0);

      if (brightness > 0.0) {
        highp vec3 filterColor = vec3(0.8, 0.8, 0.9);

        if (rgbColor.x <= 0.5) {
          rgbColor.x = ((2.0 * rgbColor.x - 1.0) *
                        (rgbColor.x - rgbColor.x * rgbColor.x)) *
                           0.3 +
                       rgbColor.x;
        } else {
          rgbColor.x =
              ((2.0 * rgbColor.x - 1.0) * (sqrt(rgbColor.x) - rgbColor.x)) *
                  0.3 +
              rgbColor.x;
        }

        if (rgbColor.y <= 0.5) {
          rgbColor.y = ((2.0 * rgbColor.y - 1.0) *
                        (rgbColor.y - rgbColor.y * rgbColor.y)) *
                           0.3 +
                       rgbColor.y;
        } else {
          rgbColor.y =
              ((2.0 * rgbColor.y - 1.0) * (sqrt(rgbColor.y) - rgbColor.y)) *
                  0.3 +
              rgbColor.y;
        }

        if (rgbColor.z <= 0.5) {
          rgbColor.z = ((2.0 * rgbColor.z - 1.0) *
                        (rgbColor.z - rgbColor.z * rgbColor.z)) *
                           0.3 +
                       rgbColor.z;
        } else {
          rgbColor.z =
              ((2.0 * rgbColor.z - 1.0) * (sqrt(rgbColor.z) - rgbColor.z)) *
                  0.3 +
              rgbColor.z;
        }

        if (rgbColor.x <= 0.5) {
          rgbColor.x = (rgbColor.x * filterColor.x * 2.0 - rgbColor.x) * 0.4 +
                       rgbColor.x;
        } else {
          rgbColor.x =
              (1.0 - (((1.0 - filterColor.x) * (1.0 - rgbColor.x) * 2.0)) -
               rgbColor.x) *
                  0.4 +
              rgbColor.x;
        }

        if (rgbColor.y <= 0.5) {
          rgbColor.y = (rgbColor.y * filterColor.y * 2.0 - rgbColor.y) * 0.4 +
                       rgbColor.y;
        } else {
          rgbColor.y =
              (1.0 - (((1.0 - filterColor.y) * (1.0 - rgbColor.y) * 2.0)) -
               rgbColor.y) *
                  0.4 +
              rgbColor.y;
        }

        if (rgbColor.z <= 0.5) {
          rgbColor.z = (rgbColor.z * filterColor.z * 2.0 - rgbColor.z) * 0.4 +
                       rgbColor.z;
        } else {
          rgbColor.z =
              (1.0 - (((1.0 - filterColor.z) * (1.0 - rgbColor.z) * 2.0)) -
               rgbColor.z) *
                  0.4 +
              rgbColor.z;
        }
      }

      gl_FragColor = vec4(rgbColor, 1.0);
    });

// (
// varying highp vec2 textureCoordinate;
//
// uniform sampler2D inputImageTexture;
// uniform lowp float brightness;
//
// highp vec3 sethue(highp vec3 rgb,highp float hd,highp float ym,highp float sm)
// {
//     rgb.r = rgb.r*255.0;
//     rgb.g = rgb.g*255.0;
//     rgb.b = rgb.b*255.0;
//     highp vec3 ycbcr;
//     ycbcr.x = 0.3*rgb.r+0.59*rgb.g+0.11*rgb.b;
//     ycbcr.y = 0.7*rgb.r-0.59*rgb.g-0.11*rgb.b;
//     ycbcr.z = -0.3*rgb.r-0.59*rgb.g+0.89*rgb.b;
//
//     highp float fhue;
//     highp float length;
//     highp float sat;
//     highp float hue;
//     length = ycbcr.y*ycbcr.y+ycbcr.z*ycbcr.z;
//     sat = sqrt(length);
//     if(sat > 0.0)
//     {
//         fhue = atan(ycbcr.y,ycbcr.z)*180.0/3.14159265;
//         if(fhue < 0.0)
//         {
//             fhue += 360.0;
//         }
//         hue =fhue;
//     }
//     else
//     {
//         hue  = 0.0;
//     }
//     if(ycbcr.x > 128.0)
//     {
//         ycbcr.x += (255.0-ycbcr.x)*ym*0.5;
//     }
//     else
//     {
//         ycbcr.x += ycbcr.x*ym*0.5;
//     }
//     if(ycbcr.x > 255.0)
//     {
//         ycbcr.x = 255.0;
//     }
//     if(ycbcr.x < 0.0)
//     {
//         ycbcr.x = 0.0;
//     }
//     highp float asfasd = (1.0+sm);
//
//     sat = sat  * asfasd;
//     hue += hd;
//     if(hue > 360.0)
//     {
//         hue -= 360.0;
//     }
//     if(hue < 0.0)
//     {
//         hue += 360.0;
//     }
//     highp float rad;
//     rad = 3.14159265 * hue / 180.0;
//     ycbcr.y = sat*sin(rad);
//     ycbcr.z = sat*cos(rad);
//     rgb.r = ycbcr.x + ycbcr.y;
//     if(rgb.r > 255.0)
//     {
//         rgb.r = 255.0;
//     }
//     if(rgb.r < 0.0)
//     {
//         rgb.r = 0.0;
//     }
//     rgb.g = ycbcr.x - 0.3/0.59*ycbcr.y - 0.11/0.59*ycbcr.z;
//     if(rgb.g > 255.0)
//     {
//         rgb.g = 255.0;
//     }
//     if(rgb.g < 0.0)
//     {
//         rgb.g = 0.0;
//     }
//     rgb.b = ycbcr.x + ycbcr.z;
//     if(rgb.b > 255.0)
//     {
//         rgb.b = 255.0;
//     }
//     if(rgb.b < 0.0)
//     {
//         rgb.b = 0.0;
//     }
//     rgb.r = rgb.r/255.0;
//     rgb.g = rgb.g/255.0;
//     rgb.b = rgb.b/255.0;
//     return rgb;
// }
//
// void main()
// {
//     highp vec3 textureColor = texture2D(inputImageTexture, textureCoordinate).rgb;
//     gl_FragColor = vec4(sethue(textureColor,0.0,brightness,0.0),1.0);
// }
// );

@implementation ISBrightnessFilter

#pragma mark -
#pragma mark Initialization and teardown

- (id)init;
{
  if (!(self = [super initWithFragmentShaderFromString:
                          kISBrightnessFragmentShaderString])) {
    return nil;
  }

  brightnessUniform = [filterProgram uniformIndex:@"brightness"];
  self.brightness = 0.0;

  return self;
}

#pragma mark -
#pragma mark Accessors

- (void)setBrightness:(CGFloat)newValue;
{
  _brightness = newValue * 0.5;

  [self setFloat:_brightness
      forUniform:brightnessUniform
         program:filterProgram];
}

@end
