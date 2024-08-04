package utilities

import "core:os"
import "core:strings"
import "core:strconv"

// Read string from the console input
read_string :: proc() -> string {
    builder := strings.builder_make()
    buf : [32]byte
    n, err := os.read(os.stdin, buf[:])
    if err < 0 {
        return "error"
    }

    strings.write_bytes(&builder, buf[:n])
    return strings.trim_space(strings.to_string(builder))
}

// Read integer from the console input
read_int :: proc() -> int {
    return strconv.atoi(read_string())
}
