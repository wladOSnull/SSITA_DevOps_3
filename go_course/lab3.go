package main

import (
	"fmt"
	"os"
	"strconv"
)

func main() {

	fullArgsSlice := os.Args

	x, _ := strconv.ParseFloat(fullArgsSlice[1], 32)
	y, _ := strconv.ParseFloat(fullArgsSlice[2], 32)

	fmt.Printf("a + b = %.2f\n", (x + y))
	fmt.Printf("a - b = %.2f\n", (x - y))
	fmt.Printf("a * b = %.2f\n", (x * y))
	fmt.Printf("a / b = %.2f\n", (x / y))

}
