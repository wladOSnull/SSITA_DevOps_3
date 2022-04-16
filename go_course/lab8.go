package main

import (
	"fmt"
	"os"
	"strconv"
)

func getMinMax(a []string) (int, int) {

	max, _ := strconv.Atoi(a[0])
	min := max

	for _, v := range a {

		v, _ := strconv.Atoi(v)
		if v > max {
			max = v
		}

		if v < min {
			min = v
		}
	}

	return min, max
}

func main() {

	args := os.Args[1:]

	a1, a2 := getMinMax(args)

	fmt.Printf("min: %d\nmax: %d\n", a1, a2)
}


