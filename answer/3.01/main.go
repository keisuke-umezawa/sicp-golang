package main

import (
	"fmt"
)

type Accumlator struct {
	sum int
}

func (a Accumlator) Add(v int) int {
	a.sum += v
	return a.sum
}

func New(v int) Accumlator {
	return Accumlator{v}
}

func main() {
	a := New(5)
	v := 7
	fmt.Printf("Add: %v, %v\n", v, a.Add(v))
}
