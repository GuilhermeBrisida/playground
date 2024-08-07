package main

import "core:os"
import "core:fmt"
import "vendor:raylib"
import "ticktacktoe"
import "snake"
import console "utilities"

MenuOptions :: enum {
    TickTackToeGUI,
    SnakeGUI,
    Quit,
}

MenuGuiState :: struct {
    current: MenuOptions
}

menu_gui :: proc() {
    raylib.InitWindow(300, 400, "Game menu")
    raylib.SetTargetFPS(60)
    defer raylib.CloseWindow()

    menu_state := MenuGuiState{ current = .TickTackToeGUI }

    for !raylib.WindowShouldClose() {
        raylib.BeginDrawing()
        raylib.ClearBackground(raylib.LIGHTGRAY)

        menu_gui_handle_input(&menu_state)
        menu_gui_draw_options(&menu_state)

        raylib.EndDrawing()
    }
}

menu_gui_draw_options :: proc(menu_state: ^MenuGuiState) {
    if menu_state.current == .TickTackToeGUI {
        raylib.DrawText("1 - Tick tack toe", 0, 0, 20, raylib.RED)
    } else {
        raylib.DrawText("1 - Tick tack toe", 0, 0, 20, raylib.BLACK)
    }
    if menu_state.current == .SnakeGUI {
        raylib.DrawText("2 - Snake", 0, 50, 20, raylib.RED)
    } else {
        raylib.DrawText("2 - Snake", 0, 50, 20, raylib.BLACK)
    }
    if menu_state.current == .Quit {
        raylib.DrawText("0 - Quit", 0, 100, 20, raylib.RED)
    } else {
        raylib.DrawText("0 - Quit", 0, 100, 20, raylib.BLACK)
    }
}

menu_gui_handle_input :: proc(menu_state: ^MenuGuiState) {
    current_index := int(menu_state.current)

    #partial switch raylib.GetKeyPressed() {
    case .UP:
        if current_index > 0 {
            menu_state.current = MenuOptions(current_index - 1)
        }
    case .DOWN:
        if current_index < len(MenuOptions) - 1 {
            menu_state.current = MenuOptions(current_index + 1)
        }
    case .ENTER:
        menu_options(menu_state.current)
    }
}

menu_console :: proc() {
    for {
        fmt.println("What do you want to do now?")
        fmt.println(" - 1 : Play tick-tack-toe (gui)")
        fmt.println(" - 2 : Play snake (gui)")
        fmt.println(" - 0 : Exit")

        switch console.read_int() {
        case 0:
            fmt.println("Ok, closing now!")
            return
        case 1:
            ticktacktoe.start_game_gui()
        case 2:
            snake.start_game_gui()
        case:
            fmt.println("Invalid option")
        }
    }
}

menu_options :: proc(option: MenuOptions) {
    switch option {
    case .Quit:
        fmt.println("closing application")
        os.exit(0)
    case .SnakeGUI:
        snake.start_game_gui(false)
    case .TickTackToeGUI:
        ticktacktoe.start_game_gui(false)
    }
}