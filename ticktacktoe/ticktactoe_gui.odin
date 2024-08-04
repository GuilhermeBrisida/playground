package ticktacktoe

import console "../utilities"
import raylib "vendor:raylib"
import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

GameInputState :: struct {
    line: int,
    column: int
}

// Starts a new game of tick-tack-toe
start_game_gui :: proc() {
    raylib.InitWindow(300, 300, "Tick-tack-toe")

    // Initializing game state
    game := TickTackToe{ current = CellValue.X }
    input := GameInputState{ line = 0, column = 0 }

    // Game loop
    for !raylib.WindowShouldClose() {
    // Always start the loop by clearing the screen
        raylib.BeginDrawing()
        raylib.ClearBackground(raylib.LIGHTGRAY)

        // Then we print the game state
        tick_tack_toe_input(&input)
        tick_tack_toe_draw(&game, &input)

        raylib.EndDrawing()
    }

    raylib.CloseWindow()
}

// Handle the game input
tick_tack_toe_input :: proc(input: ^GameInputState) {
    if raylib.IsKeyDown(.LEFT) {
        fmt.println("go left")
    } else if raylib.IsKeyDown(.RIGHT) {
        fmt.println("go right")
    } else if raylib.IsKeyDown(.UP) {
        fmt.println("go up")
    } else if raylib.IsKeyDown(.DOWN) {
        fmt.println("go down")
    }
}

// Print the current game state to the console
tick_tack_toe_draw :: proc(game : ^TickTackToe, input: ^GameInputState) {
    tick_tack_toe_check_win(game)

    // Check if the game finished already
    #partial switch game.winner {
    case .X:
        raylib.DrawText("Player X won the game!!!", 0, 0, 20, raylib.BLACK)
        raylib.ClearBackground(raylib.GREEN)
        raylib.DrawText("Y", 150, 150, 40, raylib.RED)
        return
    case .O:
        raylib.DrawText("Player O won the game!!!", 0, 0, 20, raylib.BLACK)
        raylib.ClearBackground(raylib.GREEN)
        raylib.DrawText("O", 150, 150, 40, raylib.RED)
        return
    }

    // Draw the lines / columns indicators
    raylib.DrawText("1", 060, 10, 20, raylib.RED)
    raylib.DrawText("2", 110, 10, 20, raylib.RED)
    raylib.DrawText("3", 160, 10, 20, raylib.RED)
    raylib.DrawText("A", 10, 060, 20, raylib.RED)
    raylib.DrawText("B", 10, 110, 20, raylib.RED)
    raylib.DrawText("C", 10, 160, 20, raylib.RED)

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
                raylib.DrawText("X", column_offset, line_offset, 20, color)
            case .O:
                raylib.DrawText("O", column_offset, line_offset, 20, color)
            case .None:
                raylib.DrawText("?", column_offset, line_offset, 20, color)
            }
        }
    }
}