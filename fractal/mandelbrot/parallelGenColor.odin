package main

import "core:sync"
import "core:thread"
import "core:fmt"
import "core:math"
import rl "vendor:raylib"

// Data passed to each worker thread
MandelGenContextColor :: struct {
	pixels:     [dynamic]rl.Color,
	start_row:  u16,
	upperLeft:  complex32,
	lowerRight: complex32,
	height:     u16,
	width:      u16,
	palette:     PaletteParams,
	wg:         ^sync.Wait_Group,
}

genMandelColorWorker :: proc(t: ^thread.Thread) {
	ctx := cast(^MandelGenContextColor)t.data
	points := generatePoints(
		ctx.upperLeft,
		ctx.lowerRight,
		ctx.height - ctx.start_row,
		ctx.width,
	)
	
	palette := ctx.palette
	start_index := u32(ctx.start_row) * u32(ctx.width)
	for i in 0 ..< len(points) {
		p := points[i]
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
			ctx.pixels[start_index + u32(i)] = color
	}
	sync.wait_group_done(ctx.wg)
}

generateColorInParallel :: proc(
	upperLeft: complex32,
	lowerRight: complex32,
	height: u16,
	width: u16,
	numberOfThreads: u16 = 8,
	palette: PaletteParams,
) -> [dynamic]rl.Color {
	total_points: u32 = u32(height) * u32(width)
	colorPoints := make([dynamic]rl.Color, total_points)
	rows_per_thread := height / numberOfThreads
	wg: sync.Wait_Group

  upperLeftWT := upperLeft 
	yDec := complex32(f32(imag(upperLeft) - imag(lowerRight)) / f32(numberOfThreads)) * complex32(1i)
	lowerRightWT := real(lowerRight)

	for i in 0 ..< numberOfThreads {
		start_row := i * rows_per_thread
		heightWT := (i == numberOfThreads - 1) ? height : (start_row + rows_per_thread )
    defer upperLeftWT -= yDec
		lowerRightWT := complex32(lowerRightWT) + complex32(imag(upperLeftWT) - imag(yDec)) * complex32(1i)
		
		ctx := new(MandelGenContextColor)
		ctx^ = MandelGenContextColor {
			pixels     = colorPoints,
			start_row  = start_row,
			upperLeft  = upperLeftWT,
			lowerRight = lowerRightWT,
			height     = heightWT,
			width      = width,
			palette    = palette,
			wg         = &wg,
		}
		t := thread.create(genMandelColorWorker)
		t.data = ctx

		sync.wait_group_add(&wg, 1)
		thread.start(t)
	}
	fmt.println("Waiting for threads to complete...")

	sync.wait_group_wait(&wg)
	fmt.println("All threads completed.")
	return colorPoints
}
