package ticktacktoe

import console "../utilities"
import raylib "vendor:raylib"
import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"
import "core:time"

@(private)
GameInputState :: struct {
    line: int,
    column: int,
}

// Starts a new game of tick-tack-toe
start_game_gui :: proc(open_new_window: bool = true) {
    // Check and open a window if needed
    if open_new_window {
        // Setting up the system window
        raylib.InitWindow(300, 300, "Tick-tack-toe")
        raylib.SetTargetFPS(60)

        // Setting up the system fps
        raylib.SetTargetFPS(60)
    }

    // Initialize the system textures
    x_image := raylib.LoadImage("./res/x.png")
    o_image := raylib.LoadImage("./res/o.png")
    x_texture := raylib.LoadTextureFromImage(x_image)
    o_texture := raylib.LoadTextureFromImage(o_image)

    // Release image resources
    raylib.UnloadImage(x_image)
    raylib.UnloadImage(o_image)

    // Schedule release textures
    defer raylib.UnloadTexture(x_texture)
    defer raylib.UnloadTexture(o_texture)

    // Initializing game state
    game := TickTackToe{ current = CellValue.X }
    input := GameInputState{ line = 0, column = 0 }

    // Game loop
    for !raylib.WindowShouldClose() {
        // Always start the loop by clearing the screen
        raylib.BeginDrawing()
        raylib.ClearBackground(raylib.LIGHTGRAY)

        // Then we print the game state
        tick_tack_toe_input(&game, &input)
        tick_tack_toe_draw(&game, &input, x_texture, o_texture)

        raylib.EndDrawing()
    }

    if open_new_window {
        raylib.CloseWindow()
    }
}

// Handle the game input
tick_tack_toe_input :: proc(game : ^TickTackToe, input: ^GameInputState) {
    #partial switch raylib.GetKeyPressed() {
    case .LEFT:
        if input.column > 0 {
            input.column -= 1
        }
    case .RIGHT:
        if input.column < 2 {
            input.column += 1
        }
    case .UP:
        if input.line > 0 {
            input.line -= 1
        }
    case .DOWN:
        if input.line < 3 {
            input.line += 1
        }
    case .ENTER:
        if game.game[input.line][input.column] != .None {
            raylib.ClearBackground(raylib.RED)
            return
        }

        // Register current move
        game.game[input.line][input.column] = game.current

        // Change current player
        if game.current == .X {
            game.current = .O
        } else {
            game.current = .X
        }

        // Reset coordinates
        input.line = 0
        input.column = 0

        // Update play counter
        game.play_counter += 1
    }
}

// Print the current game state to the console
tick_tack_toe_draw :: proc(game: ^TickTackToe, input: ^GameInputState, x_texture, o_texture: raylib.Texture) {
    tick_tack_toe_check_win(game)

    if game.play_counter >= 9 {
        raylib.DrawText("The game was a draw", 0, 0, 20, raylib.BLACK)
        raylib.ClearBackground(raylib.GRAY)
        return
    }

    // Check if the game finished already
    #partial switch game.winner {
    case .X:
        raylib.DrawText("Player X won the game!!!", 0, 0, 20, raylib.BLACK)
        raylib.ClearBackground(raylib.GREEN)
        raylib.DrawText("X", 150, 150, 40, raylib.BLUE)
        return
    case .O:
        raylib.DrawText("Player O won the game!!!", 0, 0, 20, raylib.BLACK)
        raylib.ClearBackground(raylib.GREEN)
        raylib.DrawText("O", 150, 150, 40, raylib.BLUE)
        return
    }


    // Draw the lines / columns indicators
    raylib.DrawText("1", 060, 10, 20, raylib.RED)
    raylib.DrawText("2", 110, 10, 20, raylib.RED)
    raylib.DrawText("3", 160, 10, 20, raylib.RED)
    raylib.DrawText("A", 10, 060, 20, raylib.RED)
    raylib.DrawText("B", 10, 110, 20, raylib.RED)
    raylib.DrawText("C", 10, 160, 20, raylib.RED)

    // Print current player
    #partial switch game.current {
    case .X:
        raylib.DrawText("Player: X", 10, 210, 20, raylib.GREEN)
    case .O:
        raylib.DrawText("Player: O", 10, 210, 20, raylib.GREEN)
    }

    // Print the grid values
    for i := 0; i < len(game.game); i += 1 {
        line := game.game[i]

        line_offset : i32 = 55 + i32(i * 50)

        for j := 0; j < len(line); j += 1  {
            column_offset : i32 = 55 + i32(j * 50)
            color := raylib.BLACK

            if input.line == i && input.column == j {
                color = raylib.ORANGE
            }

            switch line[j] {
            case .X:
                raylib.DrawTexture(x_texture, column_offset - 4, line_offset, raylib.LIGHTGRAY)
            case .O:
                raylib.DrawTexture(o_texture, column_offset - 4, line_offset, raylib.LIGHTGRAY)
            case .None:
                raylib.DrawText("?", column_offset, line_offset, 20, color)
            }
            raylib.DrawCircleLines(column_offset + 5, line_offset + 10, 15, color)
        }
    }
}