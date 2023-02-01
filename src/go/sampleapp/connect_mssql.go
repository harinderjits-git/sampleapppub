package sampleapp

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"os"

	_ "github.com/microsoft/go-mssqldb"
)

func connectMSSQL() (*sql.DB, error) {
	// Connection parameters
	// Here is example how to use environment variable for that, but it is not secure
	// Better to use integrations with secret stores
	var (
		dbPort string
		dbName = os.Getenv("DBNAME")
		dbUser = os.Getenv("DBUSER")
		dbPwd  = os.Getenv("DBPASS")
		dbHost = os.Getenv("DBHOST")
	)
	//Default port for MSSQL
	if os.Getenv("DBPORT") == "" {
		dbPort = "1433"
	} else {
		dbPort = os.Getenv("DBPORT")
	}
	//create URI for the database connection
	dbURI := fmt.Sprintf("server=%s;user id=%s;password=%s;port=%s;database=%s;", dbHost, dbUser, dbPwd, dbPort, dbName)

	//TODO: SSL connection

	//Create a connection pool
	dbPool, err := sql.Open("sqlserver", dbURI)

	if err != nil {
		log.Fatal("Error creating connection pool: ", err.Error())
	}
	ctx := context.Background()
	err = dbPool.PingContext(ctx)
	if err != nil {
		log.Fatal(err.Error())
	}
	fmt.Printf("Connected!")
	log.Printf("Connected to database!")
	//Configure the pool
	configurePool(dbPool)

	return dbPool, nil

}
