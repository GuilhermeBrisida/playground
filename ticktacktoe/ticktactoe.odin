package ticktacktoe

import console "../utilities"
import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

// Enum defining the valid values for a cell in the game.
CellValue :: enum {
    None, X, O
}

// A game of tick-tack-toe
TickTackToe :: struct {
    game         : [3][3]CellValue,
    current      : CellValue,
    winner       : CellValue,
    play_counter : int
}

// Starts a new game of tick-tack-toe
start_game :: proc() {
    fmt.println("Starting game")

    game := TickTackToe{
        current = CellValue.X
    }

    for game.play_counter < 9 && game.winner == CellValue.None {
        tick_tack_toe_print(game)
        tick_tack_toe_play(&game)

        if tick_tack_toe_check_win(&game) {
            break
        }
    }

    switch game.winner {
    case .None:
        fmt.println("The game was a draw")
    case .X:
        fmt.println("Player X won the game!!!")
        tick_tack_toe_print(game)
    case .O:
        fmt.println("Player O won the game!!!")
        tick_tack_toe_print(game)
    }
}

// Check the win conditions of the game
tick_tack_toe_check_win :: proc(game : ^TickTackToe) -> bool {
    if game.play_counter < 5 {
    // The game never ends before at least 5 moves
        return false
    }

    for i := 0; i < len(game.game); i += 1 {
        if game.game[0][i] != CellValue.None && game.game[0][i] == game.game[1][i] && game.game[1][i] == game.game[2][i] {
            game.winner = game.game[0][i]
            return true
        }
    }
    for i := 0; i < len(game.game); i += 1 {
        if game.game[i][0] != CellValue.None && game.game[i][0] == game.game[i][1] && game.game[i][1] == game.game[i][2] {
            game.winner = game.game[i][0]
            return true
        }
    }
    if game.game[1][1] != CellValue.None && game.game[0][0] == game.game[1][1] && game.game[2][2] == game.game[1][1] {
        game.winner = game.game[1][1]
        return true
    }
    if game.game[1][1] != CellValue.None && game.game[0][2] == game.game[1][1] && game.game[2][0] == game.game[1][1] {
        game.winner = game.game[1][1]
        return true
    }
    return false
}

// Receives the player input for a move
tick_tack_toe_play :: proc(game : ^TickTackToe) {
    next_player := CellValue.None

    #partial switch game.current {
    case .X:
        fmt.println("Player: X")
        next_player = CellValue.O
    case .O:
        fmt.println("Player: O")
        next_player = CellValue.X
    }

    fmt.println("Choose your next move: ")

    for {
        move := console.read_string()
        line, column, is_valid := decode_move(move)
        if is_valid && game.game[line][column] == CellValue.None {
            game.game[line][column] = game.current
            break
        }

        fmt.println("Invalid move")
    }

    game.play_counter += 1
    game.current = next_player
}

// Decode a move from the game coordinates to the matrix indexes
decode_move :: proc(play: string) -> (int, int, bool) {
    if len(play) != 2 {
        return -1, -1, false
    }

    line, column := -1, -1

    switch play[0] {
    case 'a', 'A':
        line = 0
    case 'b', 'B':
        line = 1
    case 'c', 'C':
        line = 2
    case:
        return -1, -1, false
    }

    switch play[1] {
    case '1':
        column = 0
    case '2':
        column = 1
    case '3':
        column = 2
    case:
        return -1, -1, false
    }

    return line, column, true
}

// Print the current game state to the console
tick_tack_toe_print :: proc(game : TickTackToe) {
    builder := strings.builder_make()
    strings.write_string(&builder, "    1 | 2 | 3 \n")

    for i := 0; i < len(game.game); i += 1 {
        line := game.game[i]
        strings.write_rune(&builder, rune(65 + i))
        strings.write_string(&builder, "   ")
        for j := 0; j < len(line); j += 1  {
            switch line[j] {
            case .X:
                strings.write_string(&builder, "X ")
            case .O:
                strings.write_string(&builder, "0 ")
            case .None:
                strings.write_string(&builder, "  ")
            }
            if j < 2 {
                strings.write_string(&builder, "| ")
            }
        }
        strings.write_string(&builder, "\n")
    }
    fmt.println(strings.to_string(builder))
}