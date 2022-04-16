package main

import (
	"fmt"
	"os"
	"strconv"
)

func main() {

	argsSlice := os.Args[1:]

	max, _ := strconv.Atoi(argsSlice[0])
	min := max

	for _, v := range argsSlice {

		v, _ := strconv.Atoi(v)
		if v > max {
			max = v
		}

		if v < min {
			min = v
		}
	}

	fmt.Printf("max: %d\nmin: %d\n", max, min)
}
