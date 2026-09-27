package main
import "core:fmt"

demoASCII :: proc() {
	rows: u16 = 40
	cols: u16 = 120
	upperLeft: complex32 = -2.0 + 2.0i
	lowerRight: complex32 = 2.0 + -2.0i

	generatedPoints := generatePoints(upperLeft, lowerRight, rows, cols)
	for r in 0 ..< rows {
		for c in 0 ..< cols {
			p := generatedPoints[(r * cols) + c]
			if p < 255 {
				ch := rune(p + 31)
				fmt.print(ch)
			} else {
				fmt.print(" ")
			}
		}
		fmt.println("")
	}
}