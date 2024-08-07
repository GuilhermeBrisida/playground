package snake

import "core:fmt"
import "vendor:raylib"

start_game_gui :: proc(open_new_window: bool = true) {
    // Check and open a window if needed
    if open_new_window {
        // Setting up the system window
        raylib.InitWindow(400, 400, "Snake")
        raylib.SetTargetFPS(60)
    }

    // Game loop
    for !raylib.WindowShouldClose() {
        // Always start the loop by clearing the screen
        raylib.BeginDrawing()
        raylib.ClearBackground(raylib.BLACK)

        snake_draw()

        raylib.EndDrawing()
    }
}

snake_draw :: proc() {
    // Start at the center of the screen
    raylib.DrawCircle(195, 195, 5, raylib.GREEN)
}