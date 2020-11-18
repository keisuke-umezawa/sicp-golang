package container

import (
	"fmt"
	"testing"
)

func TestMakePair(t *testing.T) {
	v := Pair{1.0, 2.0}
	fmt.Printf("%v\n", v)
}

func TestMakeList(t *testing.T) {
	{
		v := MakeList3("+", 2.0, 3.0)
		fmt.Printf("%v\n", v)
	}
	{
		v := MakeList4("*", 2.0, 3.0, 4.0)
		fmt.Printf("%v\n", v)
	}
}
