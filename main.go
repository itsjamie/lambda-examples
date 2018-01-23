package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"net/http"

	"github.com/aws/aws-lambda-go/lambda"
)

type Request struct {
	Resource string `json:"resource"`
	ID       string `json:"id"`
}

var errWentPoorly = errors.New("it didn't work :(")

func swapiProxy(req Request) (json.RawMessage, error) {
	res, err := http.Get(fmt.Sprintf("https://swapi.co/api/%s/%s", req.Resource, req.ID))
	if err != nil {
		return nil, errWentPoorly
	}

	var body json.RawMessage
	if err := json.NewDecoder(res.Body).Decode(&body); err != nil {
		return nil, errWentPoorly
	}

	return body, nil
}

func main() {
	lambda.Start(swapiProxy)
}
