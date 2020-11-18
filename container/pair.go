package container

// Pair for any type
type Pair struct {
	A interface{}
	D interface{}
}

// IsPair
func IsPair(v interface{}) bool {
	_, ok := v.(Pair)
	return ok
}

func MakePair(a, b interface{}) Pair {
	return Pair{a, b}
}

func MakeList3(a, b, c interface{}) Pair {
	return Pair{a, Pair{b, c}}
}

func MakeList4(a, b, c, d interface{}) Pair {
	return Pair{a, Pair{b, Pair{c, d}}}
}
