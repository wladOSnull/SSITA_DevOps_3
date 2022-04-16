package main

import (
	"fmt"
	"os"
	"strconv"
)

func main() {

	argsSlice := os.Args[1:]
	for _, v := range argsSlice {

		v, _ := strconv.Atoi(v)

		if !((v >= -5) && (v <= 5)) {
			fmt.Println("Wrong")
			return
		}

	}

	fmt.Println("OK")
}
