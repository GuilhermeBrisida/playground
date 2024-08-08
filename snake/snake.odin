package snake

import "core:fmt"
import "vendor:raylib"

@(private)
game_speed :: 30

@(private)
SnakeDirection :: enum { Up, Down, Left, Right }

@(private)
Point :: struct {
    x : i32,
    y : i32,
}

@(private)
Snake :: struct {
    head: ^Point,
    direction: SnakeDirection,
    body: [dynamic]Point,
}

@(private)
GameState :: struct {
    snake: ^Snake,
    count: int,
    food: [dynamic]Point,
}

start_game_gui :: proc(open_new_window: bool = true) {
    // Check and open a window if needed
    if open_new_window {
        // Setting up the system window
        raylib.InitWindow(400, 400, "Snake")
        raylib.SetTargetFPS(60)
    } else {
        raylib.SetWindowTitle("Snake")
    }

    game_state := GameState{
        snake = &{
            head = &{ 0, 0 },
            direction = .Right,
            body = [dynamic]Point{},
        },
        count = game_speed,
        // todo: remove the test food
        food = [dynamic]Point{ { 10, 10}, { 5, 5 } },
    }

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

    // Draw snake
    snake_head := game_state.snake.head
    raylib.DrawRectangle(8 + (snake_head.x * 15), 8 + (snake_head.y * 15), 10, 10, raylib.GREEN)

    // Draw food
    for i := 0; i < len(game_state.food); i += 1 {
        food := game_state.food[i]
        raylib.DrawRectangle(8 + (food.x * 15), 8 + (food.y * 15), 10, 10, raylib.RED)
    }
}

@(private)
handle_input :: proc(game_state : ^GameState) {
    #partial switch raylib.GetKeyPressed() {
    case .LEFT:
        game_state.snake.direction = .Left
    case .RIGHT:
        game_state.snake.direction = .Right
    case .UP:
        game_state.snake.direction = .Up
    case .DOWN:
        game_state.snake.direction = .Down
    }

    if game_state.count > 0 {
        game_state.count -= 1
        return
    }

    game_state.count = game_speed

    snake_head := game_state.snake.head

    switch game_state.snake.direction {
    case .Up:
        if snake_head.y > 0 {
            snake_head.y -= 1
        } else {
            // todo: game over
        }
    case .Down:
        if snake_head.y < 25 {
            snake_head.y += 1
        } else {
            // todo: game over
        }
    case .Left:
        if snake_head.x > 0 {
            snake_head.x -= 1
        } else {
            // todo: game over
        }
    case .Right:
        if snake_head.x < 25 {
            snake_head.x += 1
        } else {
            // todo: game over
        }
    }

    food_to_remove := -1

    // Check if there is food at the snake head
    for i := 0; i < len(game_state.food); i += 1 {
        food := game_state.food[i]

        // Mark the food to be removed
        if food.x == snake_head.x && food.y == snake_head.y {
            food_to_remove = i
        }
    }

    // Remove the food from the list
    if food_to_remove >= 0 {
        ordered_remove(&game_state.food, food_to_remove)
    }
}