package main

import "core:sync"
import "core:thread"
import "core:fmt"

// Data passed to each worker thread
MandelContext :: struct {
	pixels:     [dynamic]u8,
	start_row:  u16,
	upperLeft:  complex32,
	lowerRight: complex32,
	height:     u16,
	width:      u16,
	wg:         ^sync.Wait_Group,
}

mandel_worker :: proc(t: ^thread.Thread) {
	ctx := cast(^MandelContext)t.data
	points := generatePoints(
		ctx.upperLeft,
		ctx.lowerRight,
		ctx.height - ctx.start_row,
		ctx.width,
	)

	start_index := u32(ctx.start_row) * u32(ctx.width)
	for i in 0 ..< len(points) {
		ctx.pixels[start_index + u32(i)] = points[i]
	}
	sync.wait_group_done(ctx.wg)
}

generatePointsInParallel :: proc(
	upperLeft: complex32,
	lowerRight: complex32,
	height: u16,
	width: u16,
	numberOfThreads: u16 = 8,
) -> [dynamic]u8 {
	total_points: u32 = u32(height) * u32(width)
	points := make([dynamic]u8, total_points)
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
		
		ctx := new(MandelContext)
		ctx^ = MandelContext {
			pixels     = points,
			start_row  = start_row,
			upperLeft  = upperLeftWT,
			lowerRight = lowerRightWT,
			height     = heightWT,
			width      = width,
			wg         = &wg,
		}		
		t := thread.create(mandel_worker)
		t.data = ctx

		sync.wait_group_add(&wg, 1)
		thread.start(t)
	}
	fmt.println("Waiting for threads to complete...")

	sync.wait_group_wait(&wg)
	fmt.println("All threads completed.")
	return points
}