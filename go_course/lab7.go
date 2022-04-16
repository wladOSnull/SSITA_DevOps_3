package main

import (
	"fmt"
	"os"
	"strconv"
)

func basicOperations(a string, b string) (float64, float64, float64, float64) {

	x, _ := strconv.ParseFloat(a, 32)
	y, _ := strconv.ParseFloat(b, 32)

	return (x + y), (x - y), (x * y), (x / y)
}

func main() {

	args := os.Args[1:]

	a1, a2, a3, a4 := basicOperations(args[0], args[1])

	fmt.Printf("a + b = %.2f\n", a1)
	fmt.Printf("a - b = %.2f\n", a2)
	fmt.Printf("a * b = %.2f\n", a3)
	fmt.Printf("a / b = %.2f\n", a4)

}
