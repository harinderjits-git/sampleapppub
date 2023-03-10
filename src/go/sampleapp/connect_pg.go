// Copyright 2022 Gleb Otochkin
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//	http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
package sampleapp

import (
	"database/sql"
	"fmt"
	"log"
	"os"
	_ "github.com/jackc/pgx/v4/stdlib"
)

func connectPostgres() (*sql.DB, error) {
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
	//Default port for Postgres
	if os.Getenv("DBPORT") == "" {
		dbPort = "5432"
	} else {
		dbPort = os.Getenv("DBPORT")
	}
	//create URI for the database connection
	dbURI := fmt.Sprintf("host=%s user=%s password=%s port=%s database=%s", dbHost, dbUser, dbPwd, dbPort, dbName)

	//SSL connection
	if os.Getenv("DBSSLROOTCA") != "" {
		if os.Getenv("DBSSLCA") == "" {
			log.Fatal("Environment variable for clent certificate DBSSLCA should be defined!")
		}
		if os.Getenv("DBSSLKEY") == "" {
			log.Fatal("Environment variable for clent key DBSSLKEY should be defined!")
		}
		dbURI += fmt.Sprintf(" sslmode=require sslrootcert=%s sslcert=%s sslkey=%s", os.Getenv("DBSSLROOTCA"), os.Getenv("DBSSLCA"), os.Getenv("DBSSLKEY"))
	}

	//Create a connection pool
	dbPool, err := sql.Open("pgx", dbURI)
	if err != nil {
		return nil, fmt.Errorf("sql open pool error: %v", err)
	}

	//Configure the pool
	configurePool(dbPool)

	return dbPool, nil

}
