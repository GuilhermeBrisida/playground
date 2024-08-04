package main

import "core:fmt"
import console "utilities"
import "ticktacktoe"

// The entrypoint of the program
main :: proc() {
    for {
        fmt.println("What do you want to do now?")
        fmt.println(" - 1 : Play tick-tack-toe")
        fmt.println(" - 0 : Exit")
        jogo := console.read_int()

        switch jogo {
        case 0:
            fmt.println("Ok, closing now!")
            return
        case 1:
            ticktacktoe.start_game()
        case 2:
            fmt.println("Nothing here yet :/")
        case:
            fmt.println("Invalid option")
        }
    }
}

