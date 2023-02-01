package main

import (

	"log"
	"net/http"
	"time"
)

func main() {
	links := []string{
		"https://medium.com/itnext/testing-business-continuity-of-a-sample-application-using-gke-and-gcp-cloudsql-a211671257577",
		"https://www.linkedin.com/posts/harinderjit-singh_testing-business-continuity-of-a-sample-application-activity-7024823960915648512-ZedJ?utm_source=share&utm_medium=member_desktop/",

	}

	c := make(chan string)

	for _, link := range links {
		go checkLink(link, c)
	}

	for l := range c {
		go func(link string) {
			time.Sleep(5 * time.Second)
			checkLink(link, c)
		}(l)
	}
}

func checkLink(link string, c chan string) {
	_, err := http.Get(link)
	if err != nil {
		log.Println(link, "might be down!")
		c <- link
		return
	}

	log.Println(link, "is up!")
	c <- link
}