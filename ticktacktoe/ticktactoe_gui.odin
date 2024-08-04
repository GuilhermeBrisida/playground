package ticktacktoe

import console "../utilities"
import raylib "vendor:raylib"
import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"
import "core:time"

@(private)
fps_value :: 60

@(private)
GameInputState :: struct {
    line: int,
    column: int,
    burn_pool: int
}

@(private)
next_line :: proc(input: ^GameInputState) {
    if input.line >= 2 {
        return
    }
    if input.burn_pool > 0 {
        input.burn_pool -= 1
    } else {
        input.line += 1
        input.burn_pool = 4
    }
}

@(private)
previous_line :: proc(input: ^GameInputState) {
    if input.line <= 0 {
        return
    }
    if input.burn_pool > 0 {
        input.burn_pool -= 1
    } else {
        input.line -= 1
        input.burn_pool = 4
    }
}

@(private)
previous_column :: proc(input: ^GameInputState) {
    if input.column <= 0 {
        return
    }
    if input.burn_pool > 0 {
        input.burn_pool -= 1
    } else {
        input.column -= 1
        input.burn_pool = 4
    }
}

@(private)
next_column :: proc(input: ^GameInputState) {
    if input.column >= 2 {
        return
    }
    if input.burn_pool > 0 {
        input.burn_pool -= 1
    } else {
        input.column += 1
        input.burn_pool = 4
    }
}

@(private)
play_move :: proc(game : ^TickTackToe, input: ^GameInputState) {
    if game.game[input.line][input.column] != CellValue.None {
        fmt.println("show invalid play message")
        input.burn_pool = 4
        return
    }

    if input.burn_pool > 0 {
        input.burn_pool -= 1
    } else {
        game.game[input.line][input.column] = game.current
        game.play_counter += 1
        input.line = 0
        input.column = 0
        input.burn_pool = 4

        #partial switch game.current {
        case .X:
            game.current = .O
        case .O:
            game.current = .X
        }
    }
}

// Starts a new game of tick-tack-toe
start_game_gui :: proc() {
    raylib.InitWindow(300, 300, "Tick-tack-toe")
    raylib.SetTargetFPS(fps_value)

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
        tick_tack_toe_draw(&game, &input)

        raylib.EndDrawing()
    }

    raylib.CloseWindow()
}

// Handle the game input
tick_tack_toe_input :: proc(game : ^TickTackToe, input: ^GameInputState) {
    if raylib.IsKeyDown(.LEFT) {
        previous_column(input)
    } else if raylib.IsKeyDown(.RIGHT) {
        next_column(input)
    } else if raylib.IsKeyDown(.UP) {
        previous_line(input)
    } else if raylib.IsKeyDown(.DOWN) {
        next_line(input)
    } else if raylib.IsKeyDown(.ENTER) {
        play_move(game, input)
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
                raylib.DrawText("X", column_offset, line_offset, 20, color)
            case .O:
                raylib.DrawText("O", column_offset, line_offset, 20, color)
            case .None:
                raylib.DrawText("?", column_offset, line_offset, 20, color)
            }
        }
    }
}