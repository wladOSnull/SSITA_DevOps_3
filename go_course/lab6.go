package main

import (
	"fmt"
	"os"
	"strings"
)

func main() {

	arg := os.Args[1]
	str := strings.Split(arg, "")

	for _, v := range str {
		fmt.Println(v)
	}
}
