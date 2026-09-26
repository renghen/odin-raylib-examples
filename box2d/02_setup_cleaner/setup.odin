package boxes

import "core:fmt"
import b2 "vendor:box2d"
import rl "vendor:raylib"

PIXEL_WIDTH: i32 : 40
PIXEL_HEIGHT: i32 : 40
SCREEN_WIDTH :: 1280
SCREEN_HEIGHT :: 720
PIXELS_PER_METER :: 32.0

setup :: proc() -> (world_id: b2.WorldId) {
	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Box 2d Setup")
	rl.SetTargetFPS(60)
	// b2.SetLengthUnitsPerMeter(UNITS_PER_METER)

	box2dWorld := b2.DefaultWorldDef()
	box2dWorld.gravity.y = -10.0
	world_id = b2.CreateWorld(box2dWorld)
	return
}

cleaningUp :: proc(world_id: b2.WorldId) {
	b2.DestroyWorld(world_id)
	fmt.println("closing window...")
	rl.CloseWindow()
}

to_raylib :: proc(pos: b2.Vec2) -> rl.Vector2 {
	return rl.Vector2{pos.x * PIXELS_PER_METER, f32(SCREEN_HEIGHT) - (pos.y * PIXELS_PER_METER)}
}

create_ground :: proc(world_id: ^b2.WorldId) -> b2.BodyId {
	body_def := b2.DefaultBodyDef()
	body_def.position = b2.Vec2{SCREEN_WIDTH / (2.0 * PIXELS_PER_METER), 1.0}
	id := b2.CreateBody(world_id^, body_def)

	box := b2.MakeBox(SCREEN_WIDTH / (2.0 * PIXELS_PER_METER), 0.5)
	shape_def := b2.DefaultShapeDef()
	_ = b2.CreatePolygonShape(id, shape_def, &box)
	return id
}

create_dynamic_box :: proc(world_id: ^b2.WorldId) -> (b2.BodyId, b2.Vec2) {
	body_def := b2.DefaultBodyDef()
	body_def.type = .dynamicBody
	body_def.position = b2.Vec2{SCREEN_WIDTH / (2.0 * PIXELS_PER_METER), 15.0}
	body_id := b2.CreateBody(world_id^, body_def)

	size_m := b2.Vec2{1, 1} //2 x 2 meter box
	box := b2.MakeBox(size_m.x, size_m.y)
	shape_def := b2.DefaultShapeDef()
	shape_def.density = 1.0
	shape_def.material.restitution = 0.4
	_ = b2.CreatePolygonShape(body_id, shape_def, &box)
	return body_id, size_m
}

main :: proc() {
	world_id := setup()
	defer cleaningUp(world_id)
	ground_id := create_ground(&world_id)
	box_id, box_size := create_dynamic_box(&world_id)

	TIME_STEP :: 1.0 / 60.0
	SUB_STEP_COUNT :: 4

	for !rl.WindowShouldClose() {
		b2.World_Step(world_id, TIME_STEP, SUB_STEP_COUNT)
		box_pos := b2.Body_GetPosition(box_id)
		box_rot := b2.Body_GetRotation(box_id)
		box_angle_deg := b2.Rot_GetAngle(box_rot) * rl.RAD2DEG

		rl.BeginDrawing()
		rl.ClearBackground(rl.WHITE)
		ground_pos := b2.Body_GetPosition(ground_id)
		ground_screen := to_raylib(ground_pos)
		rl.DrawRectanglePro(
			rl.Rectangle{ground_screen.x, ground_screen.y, SCREEN_WIDTH, 1.0 * PIXELS_PER_METER},
			rl.Vector2{SCREEN_WIDTH / 2.0, 0.5 * PIXELS_PER_METER},
			0.0,
			rl.BROWN,
		)

		box_screen := to_raylib(box_pos)
		rl.DrawRectanglePro(
			rl.Rectangle {
				box_screen.x,
				box_screen.y,
				box_size.x * 2.0 * PIXELS_PER_METER,
				box_size.y * 2.0 * PIXELS_PER_METER,
			},
			rl.Vector2{box_size.x * PIXELS_PER_METER, box_size.y * PIXELS_PER_METER},
			-box_angle_deg,
			rl.BLUE,
		)

		rl.DrawFPS(10, 10)
		rl.EndDrawing()
	}
}
