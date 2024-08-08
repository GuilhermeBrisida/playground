package snake

import "core:fmt"
import "core:math/rand"
import "vendor:raylib"

@(private)
game_speed :: 30

@(private)
grid_size :: 26

@(private)
SnakeDirection :: enum { Up, Down, Left, Right }

@(private)
GamePlayStatus :: enum { Running, Paused, Over }

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
    status: GamePlayStatus,
    snake: ^Snake,
    frames_until_movement: i32,
    frames_until_food: i32,
    food: [dynamic]Point,
}

generate_food :: proc(game_state: ^GameState) {
    // We can't generate food if the game is paused
    if game_state.status == .Paused {
        return
    }

    if game_state.frames_until_food > 0 {
        game_state.frames_until_food -= 1
        return
    }

    // Randomize time until next food
    game_state.frames_until_food = ((rand.int31() % 120) * 4) + 120

    did_add_food := false

    // Keep trying to add food until it succeds
    food_loop : for !did_add_food {
        rand_x := rand.int31() % grid_size
        rand_y := rand.int31() % grid_size

        // Can't add food to the snake head
        if game_state.snake.head.x == rand_x && game_state.snake.head.y == rand_y {
            continue food_loop
        }

        // Can't add food to the snake body
        for i := 0; i < len(game_state.snake.body); i += 1 {
            snake_point := game_state.snake.body[i]

            if snake_point.x == rand_x && snake_point.y == rand_y {
                continue food_loop
            }
        }

        // Can't add food to already existing food
        for i := 0; i < len(game_state.food); i += 1 {
            food := game_state.food[i]

            // Can't add food to this position
            if food.x == rand_x && food.y == rand_y {
                continue food_loop
            }
        }

        // Add food to the grid
        append(&game_state.food, Point{ rand_x, rand_y })
        did_add_food = true
    }
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
        status = .Running,
        snake = &{
            head = &{ 0, 0 },
            direction = .Right,
            body = [dynamic]Point{},
        },
        frames_until_movement = game_speed,
        frames_until_food = 0,
        food = [dynamic]Point{},
    }

    // Add starter food to the game
    generate_food(&game_state)

    // Game loop
    for !raylib.WindowShouldClose() {
        // Always start the loop by clearing the screen
        raylib.BeginDrawing()
        raylib.ClearBackground(raylib.BLACK)

        handle_input(&game_state)
        snake_draw(&game_state)
        generate_food(&game_state)

        raylib.EndDrawing()
    }
}

@(private)
snake_draw :: proc(game_state : ^GameState) {
    // Draw "Pause" indicator
    if game_state.status == .Paused {
        raylib.DrawRectangleLines(5, 5, 390, 390, raylib.GREEN)
        raylib.DrawRectangle(110, 90, 70, 175, raylib.GREEN)
        raylib.DrawRectangle(220, 90, 70, 175, raylib.GREEN)
        raylib.DrawText("Game Paused", 135, 290, 20, raylib.GREEN)
        raylib.DrawText("Press \"P\" to Resume", 125, 320, 15, raylib.GREEN)
        return
    }

    // Draw "Game-Over" page
    if game_state.status == .Over {
        raylib.ClearBackground(raylib.RED)
        raylib.DrawRectangleLines(5, 5, 390, 390, raylib.BLACK)
        raylib.DrawRectangle(110, 90, 70, 175, raylib.BLACK)
        raylib.DrawRectangle(220, 90, 70, 175, raylib.BLACK)
        raylib.DrawText("GAME OVER", 135, 290, 25, raylib.BLACK)
        raylib.DrawText("Press \"ESC\" to exit", 125, 320, 15, raylib.BLACK)
        return
    }

    // Drawing game corners
    raylib.DrawRectangleLines(5, 5, 390, 390, raylib.GRAY)

    for i := 0; i < grid_size; i += 1 {
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
    // If the game is over, we don't need to handle input, only the standar "Escape" function
    if game_state.status == .Over {
        return
    }

    pressed_key := raylib.GetKeyPressed()

    // If the game is paused, we ignore any
    if pressed_key == .P {
        if game_state.status == .Paused {
            game_state.status = .Running
        } else {
            game_state.status = .Paused
        }
    } else if game_state.status == .Paused {
        return
    }

    #partial switch pressed_key {
    case .LEFT:
        game_state.snake.direction = .Left
    case .RIGHT:
        game_state.snake.direction = .Right
    case .UP:
        game_state.snake.direction = .Up
    case .DOWN:
        game_state.snake.direction = .Down
    }

    if game_state.frames_until_movement > 0 {
        game_state.frames_until_movement -= 1
        return
    }

    game_state.frames_until_movement = game_speed

    snake_head := game_state.snake.head

    switch game_state.snake.direction {
    case .Up:
        if snake_head.y > 0 {
            snake_head.y -= 1
        } else {
            game_state.status = .Over
            return
        }
    case .Down:
        if snake_head.y < 25 {
            snake_head.y += 1
        } else {
            game_state.status = .Over
            return
        }
    case .Left:
        if snake_head.x > 0 {
            snake_head.x -= 1
        } else {
            game_state.status = .Over
            return
        }
    case .Right:
        if snake_head.x < 25 {
            snake_head.x += 1
        } else {
            game_state.status = .Over
            return
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

        // If all food is gone, we add more food now
        if len(game_state.food) <= 0 {
            game_state.frames_until_food = 0
        }
    }
}