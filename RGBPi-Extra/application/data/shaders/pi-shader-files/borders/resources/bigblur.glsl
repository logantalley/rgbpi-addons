// A recreation of the blur border commonly used for portrait cell phone videos
// Created by hunterk
// License: public domain

#pragma parameter aspect_x "Aspect Ratio Numerator" 64.0 1.0 256. 0.5
#pragma parameter aspect_y "Aspect Ratio Denominator" 49.0 1.0 256. 0.5
#pragma parameter ZOOM "Border Zoom" 1.5 0.5 10 0.01
#pragma parameter BRIGHTNESS "Border Brightness Mod" 0.0 -1.0 1.0 0.05
#pragma parameter integer_scale "Force Integer Scaling" 1.0 0.0 1.0 1.0
#pragma parameter overscale "Integer Overscale" 0.0 0.0 1.0 1.0
#pragma parameter scanline_toggle "Scanline Toggle" 0.0 0.0 1.0 1.0
#pragma parameter interp_toggle "Sharpen Linear Scaling" 0.0 0.0 1.0 1.0
#pragma parameter THICKNESS "Scanline Thickness" 2.0 1.0 12.0 1.0
#pragma parameter DARKNESS "Scanline Darkness" 0.35 0.0 1.0 0.05
#pragma parameter OS_MASK_TOP "OS Mask Top" 0.0 0.0 1.0 0.0025
#pragma parameter OS_MASK_BOTTOM "OS Mask Bottom" 0.0 0.0 1.0 0.0025
#pragma parameter OS_MASK_LEFT "OS Mask Left" 0.0 0.0 1.0 0.0025
#pragma parameter OS_MASK_RIGHT "OS Mask Right" 0.0 0.0 1.0 0.0025
#ifndef PARAMETER_UNIFORM
#define aspect_x 64.0
#define aspect_y 49.0
#define ZOOM 1.5
#define integer_scale 1.0
#define overscale 0.0
#define scanline_toggle 0.0
#define THICKNESS 2.0
#define DARKNESS 0.35
#define interp_toggle 0.0
#define OS_MASK_TOP 0.0
#define OS_MASK_BOTTOM 0.0
#define OS_MASK_LEFT 0.0
#define OS_MASK_RIGHT 0.0
#endif

#if defined(VERTEX)

#if __VERSION__ >= 130
#define COMPAT_VARYING out
#define COMPAT_ATTRIBUTE in
#define COMPAT_TEXTURE texture
#else
#define COMPAT_VARYING varying 
#define COMPAT_ATTRIBUTE attribute 
#define COMPAT_TEXTURE texture2D
#endif

#ifdef GL_ES
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif

COMPAT_ATTRIBUTE vec4 VertexCoord;
COMPAT_ATTRIBUTE vec4 COLOR;
COMPAT_ATTRIBUTE vec4 TexCoord;
COMPAT_VARYING vec4 COL0;
COMPAT_VARYING vec4 TEX0;
COMPAT_VARYING vec2 tex_border;

vec4 _oPosition1; 
uniform mat4 MVPMatrix;
uniform COMPAT_PRECISION int FrameDirection;
uniform COMPAT_PRECISION int FrameCount;
uniform COMPAT_PRECISION vec2 OutputSize;
uniform COMPAT_PRECISION vec2 TextureSize;
uniform COMPAT_PRECISION vec2 InputSize;

// compatibility #defines
#define vTexCoord TEX0.xy
#define SourceSize vec4(TextureSize, 1.0 / TextureSize) //either TextureSize or InputSize
#define OutSize vec4(OutputSize, 1.0 / OutputSize)

#ifdef PARAMETER_UNIFORM
uniform COMPAT_PRECISION float aspect_x;
uniform COMPAT_PRECISION float aspect_y;
uniform COMPAT_PRECISION float ZOOM;
uniform COMPAT_PRECISION float BRIGHTNESS;
uniform COMPAT_PRECISION float integer_scale;
uniform COMPAT_PRECISION float overscale;
uniform COMPAT_PRECISION float scanline_toggle;
uniform COMPAT_PRECISION float THICKNESS;
uniform COMPAT_PRECISION float DARKNESS;
uniform COMPAT_PRECISION float interp_toggle;
uniform COMPAT_PRECISION float OS_MASK_TOP;
uniform COMPAT_PRECISION float OS_MASK_BOTTOM;
uniform COMPAT_PRECISION float OS_MASK_LEFT;
uniform COMPAT_PRECISION float OS_MASK_RIGHT;
#endif

void main()
{
    gl_Position = MVPMatrix * VertexCoord;
	vec2 out_res = OutputSize;
	vec2 corrected_size = InputSize * vec2(aspect_x / aspect_y, 1.0)
		 * vec2(InputSize.y / InputSize.x, 1.0);
	float full_scale = (integer_scale > 0.5) ? floor(OutputSize.y /
		InputSize.y) + overscale : OutputSize.y / InputSize.y;
	vec2 scale = (OutputSize / corrected_size) / full_scale;
	vec2 middle = vec2(0.49999, 0.49999) * InputSize / TextureSize;
	vec2 diff = TexCoord.xy - middle;
	TEX0.xy = middle + diff * scale;
	vec2 zoom_coord = (((TexCoord.xy - middle) / ZOOM) * vec2(OutputSize.x / OutputSize.y, 1.0)
		/ vec2(aspect_x / aspect_y, 1.0)) + middle;
	tex_border = zoom_coord;
}

#elif defined(FRAGMENT)

#if __VERSION__ >= 130
#define COMPAT_VARYING in
#define COMPAT_TEXTURE texture
out vec4 FragColor;
#else
#define COMPAT_VARYING varying
#define FragColor gl_FragColor
#define COMPAT_TEXTURE texture2D
#endif

#ifdef GL_ES
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif

uniform COMPAT_PRECISION int FrameDirection;
uniform COMPAT_PRECISION int FrameCount;
uniform COMPAT_PRECISION vec2 OutputSize;
uniform COMPAT_PRECISION vec2 TextureSize;
uniform COMPAT_PRECISION vec2 InputSize;
uniform sampler2D Texture;
uniform sampler2D OrigTexture;
COMPAT_VARYING vec4 TEX0;
COMPAT_VARYING vec2 tex_border;

// compatibility #defines
#define Source Texture
#define vTexCoord TEX0.xy

#define SourceSize vec4(TextureSize, 1.0 / TextureSize) //either TextureSize or InputSize
#define OutSize vec4(OutputSize, 1.0 / OutputSize)

#ifdef PARAMETER_UNIFORM
uniform COMPAT_PRECISION float aspect_x;
uniform COMPAT_PRECISION float aspect_y;
uniform COMPAT_PRECISION float ZOOM;
uniform COMPAT_PRECISION float BRIGHTNESS;
uniform COMPAT_PRECISION float integer_scale;
uniform COMPAT_PRECISION float overscale;
uniform COMPAT_PRECISION float scanline_toggle;
uniform COMPAT_PRECISION float THICKNESS;
uniform COMPAT_PRECISION float DARKNESS;
uniform COMPAT_PRECISION float interp_toggle;
uniform COMPAT_PRECISION float OS_MASK_TOP;
uniform COMPAT_PRECISION float OS_MASK_BOTTOM;
uniform COMPAT_PRECISION float OS_MASK_LEFT;
uniform COMPAT_PRECISION float OS_MASK_RIGHT;
#endif

vec4 scanlines(vec4 frame, vec2 coord, vec2 texture_size, vec2
	video_size, vec2 output_size)
{
	float lines = fract(coord.y * texture_size.y);
	float scale_factor = floor((output_size.y / video_size.y) + 0.4999);
    float lightness = 1.0 - DARKNESS;
	return (scanline_toggle > 0.5 && (lines < (1.0 / scale_factor * THICKNESS)))
		? frame * vec4(lightness, lightness, lightness, lightness) : frame;
}

vec2 interp_coord(vec2 coord, vec2 texture_size)
{
	vec2 p = coord.xy;
	p = p * texture_size.xy + vec2(0.5, 0.5);
	vec2 i = floor(p);
	vec2 f = p - i;
	// Smoothstep - amazingly, smoothstep() is slower than calculating directly the expression!
	f = f * f * f * f * (f * (f * (-20.0 * f + vec2(70.0, 70.0)) - vec2(84.0, 84.0)) + vec2(35.0, 35.0));
	p = i + f;
	p = (p - vec2(0.5, 0.5)) * 1.0 / texture_size;
	return p;
}

vec4 border(vec2 texture_size, vec2 video_size, vec2 output_size,
	float frame_count, vec2 tex, sampler2D decal, vec2 tex_border, sampler2D ORIG)
{
	vec4 effect = COMPAT_TEXTURE(decal, tex_border);
	effect += vec4(vec3(BRIGHTNESS), effect.w);
	
	vec2 coord = (interp_toggle < 0.5) ? tex : interp_coord(tex, texture_size);
	vec4 frame = COMPAT_TEXTURE(ORIG, coord);
	frame = scanlines(frame, tex, texture_size, video_size, output_size);
	vec2 fragcoord = (tex.xy * (TextureSize.xy/InputSize.xy));
	if (fragcoord.x < 1.0 - OS_MASK_RIGHT && fragcoord.x > 0.0 + OS_MASK_LEFT &&
		fragcoord.y < 1.0 - OS_MASK_BOTTOM && fragcoord.y > 0.0 + OS_MASK_TOP)
		return frame;
	
	else return effect;
}

void main()
{
    FragColor = border(TextureSize, InputSize, OutputSize,
		float(FrameCount), vTexCoord, Source, tex_border, OrigTexture);
} 
#endif
