package main

import "core:math"

// AI generated color palette for Mandelbrot sets.
// This is a more advanced and flexible approach to coloring the fractal,
// allowing for dynamic and visually appealing gradients based on mathematical functions.
// The palette is defined using cosine gradients, which can create smooth transitions between colors.

// Color represent a normalized RGB value
MyColor :: struct {
	r: f32,
	g: f32,
	b: f32
}

// Cosine gradient generator formula: color(t) = a + b * cos(2 * PI * (c * t + d))
// Adjusting these parameters lets you instantly change the entire fractal aesthetic.
PaletteParams :: struct {
	a: MyColor, // Brightness/offset
	b: MyColor, // Contrast/amplitude
	c: MyColor, // Frequency
	d: MyColor, // Phase shift
}

// Pre-defined color palettes for Mandelbrot sets
get_palette_preset :: proc(name: string) -> PaletteParams {
	switch name {

	case "cosmic_violet_blue":
		return PaletteParams{
			a = {0.20, 0.40, 0.60}, // Biased heavily toward a bright blue baseline
			b = {0.20, 0.30, 0.40}, // Subtle shifts
			c = {1.00, 1.00, 1.00},
			d = {0.80, 0.90, 0.30}, // Pushes the blue channel to fire at maximum intensity
		}

	case "electric_blue_white":
		return PaletteParams{
			a = {0.45, 0.70, 0.90}, // High baseline brightness (forces a bright white/blue core)
			b = {0.45, 0.30, 0.10}, // High red/green contrast, low blue variance (keeps blue locked high)
			c = {1.00, 1.00, 1.00}, 
			d = {0.70, 0.85, 0.00}, // Aligns green and red to peak together, creating bright white highlights
		}	
    
	case "electric_blue":
		return PaletteParams {
			// a = {0.5, 0.5,0.5},
			// b = {0.5, 0.5, 0.5},
			// c = {1.0, 1.0, 1.0},
			// d = {0.0, 0.33, 0.67}
			a = {0.05, 0.45, 0.55}, // Low red brightness, high blue base
			b = {0.00, 0.45, 0.45}, // Red doesn't oscillate, high green/blue contrast
			c = {1.00, 1.00, 1.00}, // Even frequency
			d = {0.00, 0.15, 0.25}, // Phase shifted to align green & blue into deep cyan/neon
		}
	case "fire_and_gold":
		return PaletteParams {
			a = {0.5, 0.5, 0.5},
			b = {0.5, 0.5, 0.5},
			c = {2.0, 1.0, 0.0},
			d = {0.5, 0.20, 0.25},
		}
	case "psychedelic_neon":
		return PaletteParams {
			a = {0.8, 0.5, 0.4},
			b = {0.2, 0.4, 0.2},
			c = {2.0, 1.0, 1.0},
			d = {0.0, 0.25, 0.25},
		}
	case:
		// Default fallback (Classic Wikipedia-like blue/orange palette)
		return PaletteParams {
			a = {0.5, 0.5, 0.5},
			b = {0.5, 0.5, 0.5},
			c = {1.0, 0.7, 0.4},
			d = {0.00, 0.15, 0.20},
		}
	}
}

// Evaluates the cosine gradient at a specific position 't' (normalized between 0.0 and 1.0)
evaluate_palette :: proc(p: PaletteParams, t: f32) -> MyColor {
	TAU :: 2.0 * math.PI

	r := p.a.r + p.b.r * math.cos(TAU * (p.c.r * t + p.d.r))
	g := p.a.g + p.b.g * math.cos(TAU * (p.c.g * t + p.d.g))
	b := p.a.b + p.b.b * math.cos(TAU * (p.c.b * t + p.d.b))

	// Clamp values to ensure they remain inside valid color boundaries
	return MyColor{math.clamp(r, 0.0, 1.0), math.clamp(g, 0.0, 1.0), math.clamp(b, 0.0, 1.0)}

}

// Converts a normalized color space to standard 8-bit RGB bytes
color_to_rgb255 :: proc(c: MyColor) -> (u8, u8, u8) {
	return u8(c.r * 255.0), u8(c.g * 255.0), u8(c.b * 255.0)
}
