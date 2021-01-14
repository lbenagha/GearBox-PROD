package main

/*
Hello, Traveler! Welcome to the eastereggstravoganza! Not very many candidates care
enough to see what we're doing under the hood for these tests. We hope you enjoy browsing around -
and as we said, this is pretty simple. If you have comments on how to improve this load generation,
we encourage you to provide details of your "code review" in your submission!
*/

import (
	"log"
	"math/rand"
	"net/http"
	"strconv"
)

type server struct{}

const MAX_LOAD int = 10

// CS101 taught me how to generate some load.
// memz.
func fib(n int) uint {
	if n == 0 {
		return 0
	} else if n == 1 {
		return 1
	} else {
		return fib(n-1) + fib(n-2)
	}
}

func (s *server) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	load, err := strconv.Atoi(r.Header.Get("Load-Rate"))
	if load > MAX_LOAD {
		load = MAX_LOAD
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write([]byte(`{"message": "hello from bloodwing"}`))
	println("request received.")
	if err == nil {
		if load != 0 {
			real_load := rand.Intn(load) + 28
			//log.Println("Load rate:", load)
			//log.Println("real_load:", real_load)
			fib(real_load)
		}
	}
}

func main() {
	s := &server{}
	http.Handle("/", s)
	log.Fatal(http.ListenAndServe(":8080", nil))
}
