package main

import "core:fmt"
import console "utilities"
import "ticktacktoe"

// The entrypoint of the program
main :: proc() {
    for {
        fmt.println("What do you want to do now?")
        fmt.println(" - 1 : Play tick-tack-toe (console)")
        fmt.println(" - 2 : Play tick-tack-toe (gui)")
        fmt.println(" - 0 : Exit")
        jogo := console.read_int()

        switch jogo {
        case 0:
            fmt.println("Ok, closing now!")
            return
        case 1:
            ticktacktoe.start_game()
        case 2:
            ticktacktoe.start_game_gui()
        case:
            fmt.println("Invalid option")
        }
    }
}

