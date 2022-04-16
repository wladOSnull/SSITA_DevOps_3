package main

import (
	"fmt"
	"os"
	"strings"
	"text/tabwriter"
)

type susSubString struct {
	a         int
	b         int
	substring []string
}

func printPalindrom(a []susSubString) {

	writer := tabwriter.NewWriter(os.Stdout, 1, 1, 5, ' ', 0)
	fmt.Fprintln(writer, "a\t b\t palindrom")

	for _, v := range a {
		fmt.Fprintln(writer, v.a, "\t", v.b, "\t", v.substring)
	}

	writer.Flush()
}

func compare(a, b []string) bool {

	if len(a) != len(b) {
		return false
	}

	for i, v := range a {

		if v != b[i] {
			return false
		}
	}

	return true
}

func mirror(a []string) []string {

	var length = len(a)

	reflec := make([]string, length)

	for i, v := range a {
		reflec[length-1-i] = v
	}

	return reflec
}

func search(a []string) []susSubString {

	var length = len(a)
	var scopeA, scopeB int
	var susString []susSubString

	for i, v := range a {

		for j := range a {

			//fmt.Print(v, " vs ", a[length-1-j])
			//fmt.Println(" | ", i, "---", j, "---", length-1-j)

			if j == length-1-i {
				//fmt.Println("BREAK")
				break
			}

			if v == a[length-1-j] {
				//fmt.Println("found!")

				scopeA = i
				scopeB = length - 1 - j

				susString = append(susString, susSubString{scopeA, scopeB, a[scopeA : scopeB+1]})
			}
		}
	}

	return susString
}

func multiPalindromic(str string) ([]susSubString, bool) {

	var resultFlag bool = false

	original := strings.Split(str, "")
	listOfSus := search(original)

	var i int = 0

	for _, v := range listOfSus {

		reflection := mirror(v.substring)

		if compare(v.substring, reflection) {
			listOfSus[i] = v
			i++
		}
	}

	listOfSus = listOfSus[:i]

	if len(listOfSus) != 0 {
		resultFlag = true
	}

	return listOfSus, resultFlag
}

func main() {

	var input string

	fmt.Print("input a string: ")
	fmt.Scanf("%s", &input)

	list, result := multiPalindromic(input)

	if !result {

		fmt.Println("\nunique string ...")

	} else {

		fmt.Print("\ntotal: ", len(list), "\nlist of subpalindroms: \n\n")
		printPalindrom(list)

	}

}

/*

lolasd12321zxcvv
asd12391zxcvv

qwe12321zxcasd

71232100

01234567

71131100

*/
