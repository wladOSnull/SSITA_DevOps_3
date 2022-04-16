package main

import (
	"fmt"
)

func main() {

	var x_axis, y_axis int
	var symbol string

	fmt.Print("width <space> heigth <space> symbol: ")
	fmt.Scanf("%d%d%s", &x_axis, &y_axis, &symbol)
	fmt.Printf("\nparameters: %d %d %s \n\n", x_axis, y_axis, symbol)

	shift := true
	for i := 0; i < y_axis; i++ {
		for j := 0; j < x_axis; j++ {
			fmt.Print(symbol + " ")
		}

		fmt.Println()

		if shift {
			fmt.Print(" ")
			shift = false
		} else {
			shift = true
		}
	}

}
