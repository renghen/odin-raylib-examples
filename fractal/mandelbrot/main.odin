package main

import "core:fmt"
import "core:math"
import rl "vendor:raylib"

SCREEN_WIDTH :: 1200
SCREEN_HEIGHT :: 640
NUM_THREADS :: 16

main :: proc() {
	fmt.println("Simple Mandelbrot Set")
	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Mandelbrot Set")
	defer rl.CloseWindow()
	
	upperLeft: complex32 = -2.0 + 2.0i
	lowerRight: complex32 = 2.0 + -2.0i
	palette := get_palette_preset("electric_blue_white")

	img := rl.GenImageColor(SCREEN_WIDTH, SCREEN_HEIGHT, rl.RAYWHITE)
	defer rl.UnloadImage(img)

	texture := rl.LoadTextureFromImage(img)
	defer rl.UnloadTexture(texture)
	
	for (!rl.WindowShouldClose()) {
		colors := generateColorInParallel(
			upperLeft,
			lowerRight,
			SCREEN_HEIGHT,
			SCREEN_WIDTH,
			NUM_THREADS,
			palette
		)
		fmt.println("Generated colorer points: ", len(colors))
		defer delete(colors)

		// Send new pixel data to the GPU		
		rl.UpdateTexture(texture, raw_data(colors))

		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)
		rl.DrawTexture(texture, 0, 0, rl.RAYWHITE)
		rl.DrawFPS(SCREEN_WIDTH - 100, 10) 
		rl.EndDrawing()
	}
}