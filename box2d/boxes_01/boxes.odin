package boxes

import "core:fmt"
import "core:math"
import "vendor:box2d"
import rl "vendor:raylib"

PIXEL_WIDTH: i32 : 40
PIXEL_HEIGHT: i32 : 40
SCREEN_WIDTH :: 1280
SCREEN_HEIGHT :: 720
SCALE: f32 : 32.0

box2DToRaylibVec :: proc(boxd2Pos : box2d.Vec2) -> (raylibPos: box2d.Vec2) {
	  raylibPos = { boxd2Pos.x * SCALE, boxd2Pos.y * SCALE };
    return 
}

Box :: struct {
	x:    i32,
	y:    i32,
	body: box2d.BodyDef,
}

makeBox :: proc(x: i32, y: i32) -> (box: Box) {
	box = Box {
		x = x,
		y = y,
		body = box2d.BodyDef {
			position = box2d.Vec2{f32(x), f32(y)},
			type = box2d.BodyType.dynamicBody,
		},
	}
	return
}

display :: proc(b: Box) {
	rl.DrawRectangle(b.x, b.y, PIXEL_WIDTH, PIXEL_HEIGHT, rl.BLACK)
}

setup :: proc() -> (world_id: box2d.WorldId) {
	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Boxes")
	rl.SetTargetFPS(60)

	box2dWorld := box2d.DefaultWorldDef()
	box2dWorld.gravity = box2d.Vec2{0, -1.0}
	world_id = box2d.CreateWorld(box2dWorld)
	return
}

cleaningUp :: proc(world_id: box2d.WorldId) {
	fmt.println("closing window...")
	rl.CloseWindow()
	box2d.DestroyWorld(world_id)
}

main :: proc() {
	boxes: [dynamic]Box
	defer delete(boxes)

	world_id := setup()
	defer cleaningUp(world_id)

	ground_rect := rl.Rectangle{0, 600, 1280, 120}
	ground_body_def := box2d.DefaultBodyDef()
	ground_body_def.type = .staticBody
	ground_body_def.position = box2d.Vec2{10.0, 0.0}
	ground_body_id := box2d.CreateBody(world_id, ground_body_def)

	ground_box := box2d.MakeBox(100.0, 1.0)
	ground_shape_def := box2d.DefaultShapeDef()
	ground_shape := box2d.CreatePolygonShape(
		ground_body_id,
		ground_shape_def,
		&ground_box,
	)

	// 4. Create a dynamic body (the falling box)
	body_def := box2d.DefaultBodyDef()
	body_def.type = .dynamicBody
	body_def.fixedRotation = false
	body_def.position = box2d.Vec2{5.0, 51.0} // Spawn 20 units in the air
	body_id := box2d.CreateBody(world_id, body_def)

	// Define its shape
	shape_def := box2d.DefaultShapeDef()
	shape_def.density = 1.0 // Needed for dynamic bodies to calculate mass
	shape_def.material.friction = 0.3

	dynamic_box := box2d.MakeBox(1.0, 1.0) // 2x2 box size (half-extents)
	dynamic_shape := box2d.CreatePolygonShape(body_id, shape_def, &dynamic_box)


	// 5. Simulate the world for a few steps
	TIME_STEP: f32 : 1.0 / 120.0
	SUB_STEP_COUNT: i32 : 20

	fmt.println("Starting raylib boxes...")

	i := 0

	for !rl.WindowShouldClose() {
		defer i += 1
		rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)
		rl.DrawRectangleRec(ground_rect, rl.BROWN)

		box2d.World_Step(world_id, TIME_STEP, SUB_STEP_COUNT)

		// Get the updated position of our dynamic box
		position := box2d.Body_GetPosition(body_id)
		angleInDegrees := box2d.Rot_GetAngle(box2d.Body_GetRotation(body_id)) *  rl.RAD2DEG

		if position.y > 2.0 {
			fmt.printf(
				"Step %d: Box Position = (%.2f, %.2f)\n",
				i,
				position.x,
				position.y,
			)
		}
		screenPos := box2DToRaylibVec(position)
		
		v2 := rl.Vector2{ f32(PIXEL_WIDTH) / 2.0, f32(PIXEL_HEIGHT) / 2.0 }
    rl.DrawRectanglePro(
    rl.Rectangle{ screenPos.x, 600-(screenPos.y) * 1.1, f32(PIXEL_WIDTH), f32(PIXEL_HEIGHT) },
    v2,
    angleInDegrees,
    rl.RED
		)

		// if rl.IsMouseButtonPressed(.LEFT) {
		// 	mouseX := rl.GetMouseX()
		// 	mouseY := rl.GetMouseY()
		// 	box := makeBox(mouseX, mouseY)
		// 	append(&boxes, box)
		// }

		// for box in boxes {
		// 	display(box)
		// }

		rl.EndDrawing()
	}
}
