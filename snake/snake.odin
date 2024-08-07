package snake

import "core:fmt"
import "vendor:raylib"

start_game_gui :: proc(open_new_window: bool = true) {
    // Check and open a window if needed
    if open_new_window {
        // Setting up the system window
        raylib.InitWindow(300, 300, "Snake")
        raylib.SetTargetFPS(60)
    }

    // Game loop
    for !raylib.WindowShouldClose() {
        // Always start the loop by clearing the screen
        raylib.BeginDrawing()
        raylib.ClearBackground(raylib.BLACK)

        raylib.EndDrawing()
    }
}

snake_draw :: proc() {
    fmt.println("here we should draw stuff")
}