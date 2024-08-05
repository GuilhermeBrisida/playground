package main

import "core:os"
import "core:fmt"

// The entrypoint of the program
main :: proc() {
    if len(os.args) < 2 {
        menu_console()
        return
    }
    switch os.args[1] {
    case "gui":
        menu_gui()
    case:
        menu_console()
    }
}

