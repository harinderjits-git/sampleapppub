// Copyright 2022 Gleb Otochkin
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
package sampleapp

import (
	"database/sql"
	"fmt"
	"html/template"
	"log"
	"net/http"
	"os"
	"time"

	_ "github.com/jackc/pgx/v4/stdlib"
)

var (
	dbversion string
	db        *sql.DB
)

func renderTmpl(w http.ResponseWriter, r *http.Request, db *sql.DB) {
	//
	var (
		data EmpData
		err  error
	)

	if os.Getenv("DBVERSION") == "" || dbversion == "POSTGRESQL" {
		data, err = getEmployeesPG(db)
		if err != nil {
			log.Printf("func getEmployeesPG: failed to get data: %v", err)
			http.Error(w, "Internal Server Error", http.StatusInternalServerError)
			return
		}
	} else if os.Getenv("DBVERSION") == "ORACLE" || dbversion == "ORACLE" {
		data, err = getEmployeesOra(db)
		if err != nil {
			log.Printf("func getEmployeesOra: failed to get data: %v", err)
			http.Error(w, "Internal Server Error", http.StatusInternalServerError)
			return
		}
	}else if os.Getenv("DBVERSION") == "MSSQL" || dbversion == "MSSQL" {
		data, err = getEmployeesMSSQL(db)
		if err != nil {
			log.Printf("func getEmployeesOra: failed to get data: %v", err)
			http.Error(w, "Internal Server Error", http.StatusInternalServerError)
			return
		}
	} else {
		fmt.Println("Can't find proper database version!")
	}

	indexTmpl := template.Must(template.New("index").Parse(indexFile))
	err = indexTmpl.Execute(w, data)
	if err != nil {
		log.Printf("func renderTmpl: failed to render template: %v", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
		return
	}
}

func postEmployee(w http.ResponseWriter, r *http.Request, db *sql.DB) {
	if os.Getenv("DBVERSION") == "" || dbversion == "POSTGRESQL" {
		postEmployeePG(w, r, db)
	} else if os.Getenv("DBVERSION") == "ORACLE" || dbversion == "ORACLE" {
		postEmployeeOra(w, r, db)
	}else if os.Getenv("DBVERSION") == "MSSQL" || dbversion == "MSSQL" {
		postEmployeeMSSQL(w, r, db)
	}

}

func dbConnect() *sql.DB {
	//
	var (
		db  *sql.DB
		err error
	)
	//fmt.Println(os.Getenv("DBVERSION"))
	if os.Getenv("DBVERSION") == "" || os.Getenv("DBVERSION") == "POSTGRESQL" {
		db, err = connectPostgres()
		dbversion = "POSTGRESQL"
		if err != nil {
			log.Fatalf("connectPostgres: Unable to connect to the database %s", err)
		}
		// if err := initDBPG(db); err != nil {
		// 	log.Fatalf("initDBPG unable to create table: %s", err)
		// }
	} else if os.Getenv("DBVERSION") == "ORACLE" {
		// Connect using Oracle driver
		db, err = connectOracle()
		dbversion = "ORACLE"
		if err != nil {
			log.Fatalf("connectOracle: Unable to connect to the database %s", err)
		}
	} else if os.Getenv("DBVERSION") == "MSSQL" {
		db, err = connectMSSQL()
		dbversion = "MSSQL"
		if err != nil {
			log.Fatalf("connectMSSQL: Unable to connect to the database %s", err)
		}
	} else {
		log.Fatal("This database driver is not supported")
	}

	return db
}

func execStmt(tdll string) error {
	//
	_, err := db.Exec(tdll)
	return err
}

type Employee struct {
	Employee_id int64
	First_name  string
	Last_name   string
	Hire_date   time.Time
	Manager_id  int64
}
type EmpData struct {
	Employees       []Employee
	GetResponseTime string
}

func RunApp(w http.ResponseWriter, r *http.Request) {
	//
	switch r.Method {
	case http.MethodGet:
		renderTmpl(w, r, dbConnect())
	case http.MethodPost:
		//
		postEmployee(w, r, dbConnect())
	default:
		w.WriteHeader(http.StatusMethodNotAllowed)
	}
}

func configurePool(db *sql.DB) {

	// Maximum number of connections in idle connection pool.
	db.SetMaxIdleConns(3)

	// Maximum number of open connections to the database.
	db.SetMaxOpenConns(10)

	// Maximum time (in seconds) that a connection can remain open.
	db.SetConnMaxLifetime(1800 * time.Second)

}

var indexFile = `
<html lang="en">
<head>
  <head>
  	<title>Sample DB app</title>
  	<meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/5.2.1/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/5.2.1/js/bootstrap.min.js"></script>
</head>
<body>
  <div class="container">
    <div class="page-title">
      <h1>Sample App</h1>
      <p class="lead">Sample DB app with Go</p>
      <hr />
    </div>
	<h3>Last 10 added employees</h3>
	<div class="table-responsive">          
	<table class="table">
	  <thead>
		<tr>
		  <th>Employee_id</th>
		  <th>First_name</th>
		  <th>Last_name</th>
		  <th>Hire_date</th>
		  <th>Manager_id</th>
		</tr>
	  </thead>	  
	  <tbody>
	    {{ range .Employees }}
		<tr>
		  <td>{{ .Employee_id }}</td>
		  <td>{{ .First_name }}</td>
		  <td>{{ .Last_name }}</td>
		  <td>{{ .Hire_date }}</td>
		  <td>{{ .Manager_id }}</td>
		</tr>
		{{ end}}
	  </tbody>
	</table>
	<div class="panel panel-default">
        <div class="panel-heading">Response time</div>
        <div class="panel-body">{{ .GetResponseTime}}</div>
    </div>
	</div>





	<h3>Add employee</h3>
	<form class="form-horizontal" method="post">
		<div class="form-group">
			<label class="control-label col-sm-1" for="fname">First Name:</label>
			<div class="col-sm-10">
			<input type="text" class="form-control" id="fname" placeholder="Enter First Name">
			</div>
		</div>
		<div class="form-group">
			<label class="control-label col-sm-1" for="lname">Last Name:</label>
			<div class="col-sm-10">
			<input type="text" class="form-control" id="lname" placeholder="Enter Last Name">
			</div>
		</div>
		<div class="form-group">
			<label class="control-label col-sm-1" for="hdate">Hire Date:</label>
			<div class="col-sm-10">
			<input type="text" class="form-control" id="hdate" placeholder="dd-mm-yyyy">
			</div>
		</div>
		<div class="form-group">
			<label class="control-label col-sm-1" for="mgrid">Manager ID:</label>
			<div class="col-sm-10">
			<input type="text" class="form-control" id="mgrid" placeholder="Enter Manager ID">
			</div>
		</div>
		<div class="form-group">
			<div class="col-sm-offset-2 col-sm-10">
			<button type="button" class="btn btn-default" id="submitEmployee">Submit</button>
			</div>
		</div>
	</form>
  </div>
	<script>
    function postemployee(fname,lname,hdate,mgrid) {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function () {
            if (this.readyState == 4) {
                window.location.reload();
            }
        };
        xhr.open("POST", "/", true);
        xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        xhr.send("fname=" + fname + "&lname=" + lname + "&hdate=" + hdate + "&mgrid=" + mgrid);
    }
    document.getElementById("submitEmployee").addEventListener("click", function () {
        postemployee(fname.value,lname.value,hdate.value,mgrid.value);
    });
	</script>
</body>
</html>
`
