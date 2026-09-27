package main

import rl "vendor:raylib"

width :: 256
height :: 256

main :: proc() {
	rl.InitWindow(800, 450, "Odin Raylib Draw Texture")
	defer rl.CloseWindow()

	pixels := make([]rl.Color, width * height)
	defer delete(pixels)

	img := rl.GenImageColor(width, height, rl.RAYWHITE)
	defer rl.UnloadImage(img)

	texture := rl.LoadTextureFromImage(img)
	defer rl.UnloadTexture(texture)

	rl.SetTargetFPS(60)
	color_offset: u8 = 0

	for !rl.WindowShouldClose() {
		color_offset += 1
		for y in 0 ..< height {
			for x in 0 ..< width {
				i := y * width + x
				pixels[i] = rl.Color{u8(x) + color_offset, u8(y) - color_offset, 128, 255}
			}
		}
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)
    rl.UpdateTexture(texture, raw_data(pixels))

		rl.DrawTexture(texture, 100, 100, rl.RAYWHITE)

		rl.EndDrawing()
	}
}
