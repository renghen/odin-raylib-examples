package main

import "core:fmt"
import "core:math"
import rl "vendor:raylib"

SCREEN_WIDTH :: 1600
SCREEN_HEIGHT :: 800
NUM_THREADS :: 24

main :: proc() {
	fmt.println("Simple Mandelbrot Set")
	upperLeft: complex32 = -2.0 + 2.0i
	lowerRight: complex32 = 2.0 + -2.0i
	palette := get_palette_preset("electric_blue_white")
	generatedPoints := generatePointsInParallel(
		upperLeft,
		lowerRight,
		SCREEN_HEIGHT,
		SCREEN_WIDTH,
		NUM_THREADS,
	)

	fmt.println("Generated points: ", len(generatedPoints))
	defer delete(generatedPoints)
	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Mandelbrot Set")

	for (!rl.WindowShouldClose()) {
		rl.BeginDrawing()
		drawMandelbrotSet(generatedPoints, SCREEN_HEIGHT, SCREEN_WIDTH, palette)
		rl.EndDrawing()
	}
	rl.CloseWindow()
}

drawMandelbrotSet :: proc(points: [dynamic]u8, height: u32, width: u32, palette: PaletteParams) {
	for r in 0 ..< height {
		for c in 0 ..< width {
			p := points[(r * width) + c]
			color := rl.Color{0, 0, 0, 255}
			if p < 255 {
				smooth_i := f32(p)
				t := smooth_i / f32(255)
				frequency_multiplier: f32 = 15.0
				t = math.mod(t * frequency_multiplier, 1.0)
				pixel_color := evaluate_palette(palette, t)
				r, g, b := color_to_rgb255(pixel_color)
				color = rl.Color{r, g, b, 255}
			}
			rl.DrawPixel(i32(c), i32(r), color)
		}
	}
}

point :: proc(p: complex32) -> u8 {
	iter: u8 = 0
	z := complex32(0 + 0i)
	for iter < 255 {
		if abs(z) > 2.0 {
			break
		}
		z = z * z + p
		iter += 1
	}
	return iter
}

generatePoints :: proc(
	upperLeft: complex32,
	lowerRight: complex32,
	height: u16,
	width: u16,
) -> [dynamic]u8 {
	stepX := f32(real(lowerRight) - real(upperLeft)) / f32(width)
	stepY := f32(imag(upperLeft) - imag(lowerRight)) / f32(height)
	total_points: u32 = u32(height) * u32(width)
	points := make([dynamic]u8, total_points, total_points)
	i := 0

	for y in 0 ..< height {
		for x in 0 ..< width {
			p :=
				complex32(f32(real(upperLeft)) + (f32(x) * stepX)) +
				complex32(f32(imag(upperLeft)) - (f32(y) * stepY)) * complex32(1i)
			iter := point(p)
			points[i] = iter
			i += 1
		}
	}
	return points
}


