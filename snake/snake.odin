package snake

import "core:fmt"
import "core:strings"
import "core:math/rand"
import "vendor:raylib"
import "../gui"

@(private)
food_score_value :: 1

@(private)
game_speed :: 30

@(private)
grid_size :: 26

@(private)
max_food_count :: 4

@(private)
EntityType :: enum {
    EmptySpace, SnakeBody, Food
}

@(private)
SnakeDirection :: enum {
    Up, Down, Left, Right
}

@(private)
GamePlayStatus :: enum {
    Running, Paused, Over
}

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
    frames_until_add_food: i32,
    frames_until_remove_food: i32,
    food: [dynamic]Point,
    score: i32,
}

// todo: add points tracker
// todo: show points on game-over
// todo: implement persistent high score
// todo: add special items with effects (shrink potion, slowness potion, etc)
// todo: add static walls
// todo: check collistion agains walls
// todo: implement game-levels?

remove_food :: proc(game_state: ^GameState) {
    // We can't remove food if the game is paused
    if game_state.status == .Paused {
        return
    }

    if game_state.frames_until_remove_food > 0 {
        game_state.frames_until_remove_food -= 1
        return
    }

    // Randomize the time until we try to remove food again
    game_state.frames_until_remove_food = ((rand.int31() % 200) * 4) + 360

    // Check if we can ramove food
    if len(game_state.food) <= 2 {
        return
    }

    // Remove the food
    remove_food_at := rand.int31() % i32(len(game_state.food) - 1)
    ordered_remove(&game_state.food, int(remove_food_at))
}

generate_food :: proc(game_state: ^GameState) {
    // We can't generate food if the game is paused
    if game_state.status == .Paused {
        return
    }

    if game_state.frames_until_add_food > 0 {
        game_state.frames_until_add_food -= 1
        return
    }

    // Check if we reached the maximum amount of food allowed
    if len(game_state.food) >= max_food_count {
        return
    }

    // Randomize time until next food
    game_state.frames_until_add_food = ((rand.int31() % 120) * 4) + 120

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
        raylib.InitWindow(gui.get_window_width(), gui.get_window_height(), "Snake")
        raylib.SetTargetFPS(gui.get_target_fps())
    } else {
        raylib.SetWindowTitle("Snake")
    }

    game_state := GameState{
        status = .Running,
        snake = &{
            head = &{ 0, 0 },
            direction = .Right,
            body = [dynamic]Point{ },
        },
        frames_until_movement = game_speed,
        frames_until_add_food = 0,
        frames_until_remove_food = 0,
        food = [dynamic]Point{ },
        score = 0,
    }

    // Add starter food to the game
    generate_food(&game_state)

    // Game loop
    for !raylib.WindowShouldClose() {
        // Always start the loop by clearing the screen
        raylib.BeginDrawing()
        raylib.ClearBackground(raylib.BLACK)

        handle_input(&game_state)
        remove_food(&game_state)
        generate_food(&game_state)
        draw_snake_game(&game_state)

        raylib.EndDrawing()
    }
}

@(private)
draw_snake_game :: proc(game_state : ^GameState) {
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

    // Draw game score
    raylib.DrawText(strings.clone_to_cstring(fmt.aprintf("SCORE: %d", game_state.score)), 5, 405, 15, raylib.GRAY)

    // Drawing game corners
    raylib.DrawRectangleLines(5, 5, 390, 390, raylib.GRAY)

    for i := 0; i < grid_size; i += 1 {
        raylib.DrawRectangleLines(5 + i32(i * 15), 5, 1, 390, raylib.GRAY)
        raylib.DrawRectangleLines(5, 5 + i32(i * 15), 390, 1, raylib.GRAY)
    }

    // Draw snake head
    snake_head := game_state.snake.head
    raylib.DrawRectangle(8 + (snake_head.x * 15), 8 + (snake_head.y * 15), 10, 10, raylib.GREEN)

    // Draw snake body
    for i := len(game_state.snake.body) -1; i >= 0; i -= 1 {
        snake_body_point := game_state.snake.body[i]
        raylib.DrawRectangle(8 + (snake_body_point.x * 15), 8 + (snake_body_point.y * 15), 10, 10, raylib.GREEN)
    }

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
        if game_state.snake.direction != .Right {
            game_state.snake.direction = .Left
        }

    case .RIGHT:
        if game_state.snake.direction != .Left {
            game_state.snake.direction = .Right
        }
    case .UP:
        if game_state.snake.direction != .Down {
            game_state.snake.direction = .Up
        }
    case .DOWN:
        if game_state.snake.direction != .Up {
            game_state.snake.direction = .Down
        }
    }

    if game_state.frames_until_movement > 0 {
        game_state.frames_until_movement -= 1
        return
    }


    game_state.frames_until_movement = get_frames_until_movement(game_state)

    snake_head := game_state.snake.head
    next_snake_head_x := snake_head.x
    next_snake_head_y := snake_head.y

    switch game_state.snake.direction {
    case .Up:
        if next_snake_head_y > 0 {
            next_snake_head_y -= 1
        } else {
            game_state.status = .Over
            return
        }
    case .Down:
        if next_snake_head_y < 25 {
            next_snake_head_y += 1
        } else {
            game_state.status = .Over
            return
        }
    case .Left:
        if next_snake_head_x > 0 {
            next_snake_head_x -= 1
        } else {
            game_state.status = .Over
            return
        }
    case .Right:
        if next_snake_head_x < 25 {
            next_snake_head_x += 1
        } else {
            game_state.status = .Over
            return
        }
    }

    next_snake_head := Point { next_snake_head_x , next_snake_head_y }
    check_snake_move(game_state, next_snake_head)
}

@(private)
check_snake_move :: proc(game_state : ^GameState, next_place : Point) {
    snake_head := game_state.snake.head

    collision_type, colision_index :=  check_entity_collision(game_state, next_place)
    switch collision_type {
    case .Food:
        game_state.score += food_score_value
        ordered_remove(&game_state.food, colision_index)

        // Current head of the snake becomes part of the body
        if len(game_state.snake.body) == 0 {
            append(&game_state.snake.body, Point{ snake_head.x, snake_head.y })
            // Head moves to the next position
            snake_head.x = next_place.x
            snake_head.y = next_place.y
        } else {
            // Add placeholder piece to the snake body
            append(&game_state.snake.body, Point{ 0, 0 })
            move_snake_body_forward(game_state, next_place)
        }

        // If all food is gone, we add more food now
        if len(game_state.food) <= 0 {
            game_state.frames_until_add_food = 0
        }
    case .SnakeBody:
        // Collision agains snake body causes a game-over
        game_state.status = .Over
    case .EmptySpace:
        move_snake_body_forward(game_state, next_place)
    }
}

check_entity_collision :: proc(game_state: ^GameState, next_place: Point) -> (EntityType, int) {
    // Check collision agains snake body
    for i := 0; i < len(game_state.snake.body); i += 1 {
        snake_body := game_state.snake.body[i]

        if snake_body.x == next_place.x && snake_body.y == next_place.y {
            return .SnakeBody, i
        }
    }

    // Check collision agains food
    for i := 0; i < len(game_state.food); i += 1 {
        food := game_state.food[i]

        // Mark the food to be removed
        if food.x == next_place.x && food.y == next_place.y {
            return .Food, i
        }
    }

    return .EmptySpace, 0
}

move_snake_body_forward :: proc(game_state: ^GameState, next_place: Point) {
    snake_head := game_state.snake.head

    next_x := snake_head.x
    next_y := snake_head.y

    // Move snake body forward
    for i := 0; i < len(game_state.snake.body); i += 1 {
        current_body_part := &game_state.snake.body[i]
        current_body_x := current_body_part.x
        current_body_y := current_body_part.y

        current_body_part.x = next_x
        current_body_part.y = next_y

        next_x = current_body_x
        next_y = current_body_y
    }

    // Head moves to the next position
    snake_head.x = next_place.x
    snake_head.y = next_place.y
}

get_frames_until_movement :: proc(game_state: ^GameState) -> i32 {
    switch len(game_state.snake.body) {
    case 0..<3:
        return game_speed
    case 3..<6:
        return game_speed - 4
    case 6..<9:
        return game_speed - 8
    case 9..<12:
        return game_speed - 12
    case 12..<15:
        return game_speed - 16
    case 15..<18:
        return game_speed - 20
    case:
        return game_speed - 24
    }
}
