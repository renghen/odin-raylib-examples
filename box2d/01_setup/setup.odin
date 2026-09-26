package boxes

import "core:fmt"
import "vendor:box2d"
import rl "vendor:raylib"

PIXEL_WIDTH: i32 : 40
PIXEL_HEIGHT: i32 : 40
SCREEN_WIDTH :: 1280
SCREEN_HEIGHT :: 720
UNITS_PER_METER: f32 : 32.0

setup :: proc() -> (world_id: box2d.WorldId) {
	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Boxes")
	rl.SetTargetFPS(60)
	box2d.SetLengthUnitsPerMeter(UNITS_PER_METER)

	box2dWorld := box2d.DefaultWorldDef()
	box2dWorld.gravity.y = -10.0
	world_id = box2d.CreateWorld(box2dWorld)
	return
}

cleaningUp :: proc(world_id: box2d.WorldId) {
	fmt.println("closing window...")
	rl.CloseWindow()
	box2d.DestroyWorld(world_id)
}

create_ground :: proc(world_id: box2d.WorldId) -> (body_id: box2d.BodyId, rect: rl.Rectangle) {
	ground_posY: f32 : 10.0
	y: f32 : SCREEN_HEIGHT - ground_posY - 10

	rect = rl.Rectangle{0, y, SCREEN_WIDTH, SCREEN_HEIGHT - y}

	ground_body_def := box2d.DefaultBodyDef()
	ground_body_def.type = .staticBody
	ground_body_def.position = box2d.Vec2{SCREEN_WIDTH / (2 * UNITS_PER_METER), ground_posY / UNITS_PER_METER}
	body_id = box2d.CreateBody(world_id, ground_body_def)

	ground_box := box2d.MakeBox(f32(SCREEN_WIDTH / 2) / UNITS_PER_METER, f32(10.0) / UNITS_PER_METER)
	ground_shape_def := box2d.DefaultShapeDef()
	ground_shape := box2d.CreatePolygonShape(body_id, ground_shape_def, &ground_box)
	return
}

main :: proc() {
	world_id := setup()
	defer cleaningUp(world_id)

	ground_body_id, ground_rect := create_ground(world_id)

	body_def := box2d.DefaultBodyDef()
	body_def.type = .dynamicBody
	body_def.fixedRotation = false
	body_def.position = box2d.Vec2{f32(400.0) / UNITS_PER_METER, f32(500.0) / UNITS_PER_METER}
	body_id := box2d.CreateBody(world_id, body_def)

	dynamic_box := box2d.MakeBox(f32(20.0) / UNITS_PER_METER, f32(20.0) / UNITS_PER_METER)
	shape_def := box2d.DefaultShapeDef()
	dynamic_shape := box2d.CreatePolygonShape(body_id, shape_def, &dynamic_box)

	// Simulate the world for a few steps
	TIME_STEP :: 1.0 / 60.0
	SUB_STEP_COUNT :: 4

	fmt.println("Starting raylib 2dboxe setting up...")
	i := 0

	for !rl.WindowShouldClose() {
		//set up		
		box2d.World_Step(world_id, TIME_STEP, SUB_STEP_COUNT)
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)
		rl.DrawRectangleRec(ground_rect, rl.BROWN)

		// Get the updated position of our dynamic box
		position := box2d.Body_GetPosition(body_id)

		if position.y > 2.5 {
			fmt.printf("Step %d: Box Position = (%.2f, %.2f)\n", i, position.x, position.y)
			i += 1
		}

		v2 := rl.Vector2{f32(PIXEL_WIDTH) / 2.0, f32(PIXEL_HEIGHT) / 2.0}
		screenX := i32(position.x * UNITS_PER_METER) - i32(PIXEL_WIDTH / 2.0)
		screenY := SCREEN_HEIGHT - i32(position.y * UNITS_PER_METER) - i32(PIXEL_HEIGHT / 2)
		rl.DrawRectangle(screenX, screenY, PIXEL_WIDTH, PIXEL_HEIGHT, rl.RED)

		rl.EndDrawing()
	}
}
