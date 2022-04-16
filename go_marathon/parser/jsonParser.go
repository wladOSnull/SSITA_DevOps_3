package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"sort"
)

const type1 = "persons"
const type2 = "places"
const type3 = "things"

type Person struct {
	Name string `json:"name"`
	Age  int    `json:"age"`
}

type Place struct {
	City    string `json:"city"`
	Country string `json:"country"`
}

type ThingsPerson struct {
	Things []Person `json:"things"`
}

type ThingsPlace struct {
	Things []Place `json:"things"`
}

func Decode(data []byte) ([]Person, []Place) {

	// persons
	var thingsPerson ThingsPerson
	json.Unmarshal(data, &thingsPerson)

	var persons []Person
	for _, v := range thingsPerson.Things {
		if v.Name != "" && v.Age != 0 {
			persons = append(persons, Person{v.Name, v.Age})
		}
	}

	sort.SliceStable(persons, func(i, j int) bool {
		return persons[i].Age < persons[j].Age
	})

	// places
	var thingsPlace ThingsPlace
	json.Unmarshal(data, &thingsPlace)

	var places []Place
	for _, v := range thingsPlace.Things {
		if v.City != "" && v.Country != "" {
			places = append(places, Place{v.City, v.Country})
		}
	}

	sort.SliceStable(places, func(i, j int) bool {
		return len(places[i].City) < len(places[j].City)
	})

	return persons, places
}

func writeJsonSeparate(a interface{}, name string) map[string]interface{} {

	mapJson := make(map[string]interface{})
	mapJson[name] = a

	content, err := json.MarshalIndent(mapJson, "", "\t")
	if err != nil {
		fmt.Println(err)
		return nil
	}

	err = ioutil.WriteFile((name + "Output.json"), content, 0644)
	if err != nil {
		log.Fatal(err)
		return nil
	}

	//fmt.Printf("%v\n%T\n", string(content), a)
	return mapJson
}

func writeJsonAll(a []map[string]interface{}, name string) {

	mapJson := make(map[string][]map[string]interface{})
	mapJson[name] = a

	content, err := json.MarshalIndent(mapJson, "", "\t")
	if err != nil {
		fmt.Println(err)
		return
	}

	err = ioutil.WriteFile((name + "Output.json"), content, 0644)
	if err != nil {
		log.Fatal(err)
	}
}

func main() {

	// logger
	logger := log.New(os.Stdout, "INFO: ", 0)

	// open file
	jsonFile, err := os.Open(os.Args[1])

	if err != nil {
		fmt.Println(err)
	}
	defer jsonFile.Close()

	// reading data from file
	byteValue, _ := ioutil.ReadAll(jsonFile)

	// processing json
	personsSlice, placesSlice := Decode(byteValue)

	// printing json
	logger.Println(personsSlice)
	logger.Println(placesSlice)

	// write json to separate files
	var jsonSlice []map[string]interface{}
	jsonSlice = append(jsonSlice, writeJsonSeparate(personsSlice, type1))
	jsonSlice = append(jsonSlice, writeJsonSeparate(placesSlice, type2))

	// write all json to main file
	writeJsonAll(jsonSlice, type3)
}

/*

go run jsonParser.go file.json

*/
