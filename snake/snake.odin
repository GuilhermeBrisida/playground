package snake

import "core:fmt"
import "vendor:raylib"

@(private)
game_speed :: 30

@(private)
SnakeDirection :: enum { Up, Down, Left, Right }

@(private)
GameState :: struct {
    x : i32,
    y : i32,
    direction: SnakeDirection,
    count: int,
}

start_game_gui :: proc(open_new_window: bool = true) {
    // Check and open a window if needed
    if open_new_window {
        // Setting up the system window
        raylib.InitWindow(400, 400, "Snake")
        raylib.SetTargetFPS(60)
    }

    game_state := GameState{ 0, 0, .Right, game_speed }

    // Game loop
    for !raylib.WindowShouldClose() {
        // Always start the loop by clearing the screen
        raylib.BeginDrawing()
        raylib.ClearBackground(raylib.BLACK)

        handle_input(&game_state)
        snake_draw(&game_state)

        raylib.EndDrawing()
    }
}

@(private)
snake_draw :: proc(game_state : ^GameState) {
    // Start at the center of the screen
    raylib.DrawRectangleLines(5, 5, 390, 390, raylib.GRAY)

    for i := 0; i < 26; i += 1 {
        raylib.DrawRectangleLines(5 + i32(i * 15), 5, 1, 390, raylib.GRAY)
        raylib.DrawRectangleLines(5, 5 + i32(i * 15), 390, 1, raylib.GRAY)
    }

    raylib.DrawRectangle(8 + (game_state.x * 15), 8 + (game_state.y * 15), 10, 10, raylib.GREEN)
}

@(private)
handle_input :: proc(game_state : ^GameState) {
    #partial switch raylib.GetKeyPressed() {
    case .LEFT:
        game_state.direction = .Left
    case .RIGHT:
        game_state.direction = .Right
    case .UP:
        game_state.direction = .Up
    case .DOWN:
        game_state.direction = .Down
    }

    if game_state.count > 0 {
        game_state.count -= 1
        return
    }

    game_state.count = game_speed

    switch game_state.direction {
    case .Up:
        if game_state.y > 0 {
            game_state.y -= 1
        } else {
            // todo: game over
        }
    case .Down:
        if game_state.y < 25 {
            game_state.y += 1
        } else {
            // todo: game over
        }
    case .Left:
        if game_state.x > 0 {
            game_state.x -= 1
        } else {
            // todo: game over
        }
    case .Right:
        if game_state.x < 25 {
            game_state.x += 1
        } else {
            // todo: game over
        }
    }
}