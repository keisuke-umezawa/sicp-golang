package main

import (
	"fmt"
)

// Expression is the interface for all expression type.
type Expression interface {
	Add(exp Expression) Expression
}

// Poly is the struct for polynomial expressino.
type Poly struct {
}

// Add implementation
func (p Poly) Add(exp Poly) Poly {
	return p
}

func main() {
	{
		p1 := Poly{}
		p2 := Poly{}
		fmt.Printf("Add: %v\n", p1.Add(p2))
	}
}
