package main

import (
	"fmt"
)

// Rational number
type Rational struct {
	numerator   int
	denominator int
}

// MakeRat creates Rational.
func MakeRat(numerator int, denominator int) Rational {
	rat := Rational{numerator, denominator}
	return rat
}

func main() {
	r := MakeRat(15, 21)
	fmt.Printf("%v", r)
}
