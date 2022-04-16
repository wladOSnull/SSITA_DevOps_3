package main

import (
	"fmt"
	"math"
	"strconv"
	"strings"
)

func main() {

	var input string

	fmt.Print("string of numbers over coma: ")
	fmt.Scanf("%s", &input)

	splitted := strings.Split(input, ",")
	fmt.Printf("\nsplitted result: %s\n", splitted)

	fmt.Print("\npositive even numbers: ")
	counter := 0

	for i := 0; i < len(splitted); i++ {

		if number, err := strconv.Atoi(splitted[i]); err == nil {

			if !math.Signbit(float64(number)) && number%2 == 0 && number != 0 {
				counter++
				fmt.Print(number, ", ")
			}
		}
	}

	fmt.Printf("\ntotal of positive even numbers: %d\n", counter)
}

/*

30,-1,-6,90,-6,22,52,123,2,35,6

*/
