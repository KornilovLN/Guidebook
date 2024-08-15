## Quick start QuestDB

### Install QuestDB

**_Docker_**
```
docker run \
    -p 9000:9000 -p 9009:9009 -p 8812:8812 -p 9003:9003 \
    questdb/questdb:8.1.0
```

**_Binaries_**
```
questdb-8.1.0-rt-linux-amd64.tar.gz
tar -xvf questdb-8.1.0-rt-linux-amd64.tar.gz

```

The default directory becomes:
```
$HOME/.questdb
```

### Run QuestDB

```
./questdb.sh [start|stop|status] [-d dir] [-f] [-n] [-t tag]
```

**_Option	Description:_**

- d	Expects a dir directory value which is a folder that will be used as QuestDB's root directory.
- t	Expects a tag string value which will be as a tag for the service. This option allows users to run several QuestDB services and manage them separately. If this option is omitted, the default tag will be questdb.
- f	Force re-deploying the Web Console. Without this option, the Web Console is cached and deployed only when missing.
- n	Do not respond to the HUP signal. This keeps QuestDB alive after you close the terminal window where you started it.


**_The QuestDB Web Console is available by default at:_**
```
http://localhost:9000.
```

**_Also by default, QuestDB will use the following ports:_**
```
9000 - REST API and Web Console
9000 - InfluxDB Line Protocol (ILP)
8812 - Postgres Wire Protocol (PGWire)
9003 - Min health server
```

### Choose from one of our premium ingest-only language clients:

* C & C++
* .NET
* Go
* Java
* Node.js
* Python
* Rust

### Create new data

**_There are several quick options:_**

- QuestDB demo instance: **https://demo.questdb.io/**
<br>Hosted, fully loaded and ready to go. Quickly explore the Web Console and SQL syntax.
- Create my first data set guide: **https://questdb.io/docs/guides/create-database/**
<br>create tables, use rnd_ functions and make your own data.
- Sample dataset repos: **https://github.com/questdb/sample-datasets**
<br>IoT, e-commerce, finance or git logs? Check them out!
- Quick start repos: **https://github.com/questdb/questdb-quickstart**
<br>Code-based quick starts that cover ingestion, querying and data visualization using common programming languages and use cases. Also, a cat in a tracksuit.
- Time series streaming analytics template: **https://github.com/questdb/time-series-streaming-analytics-template**
<br>A handy template for near real-time analytics using open source technologies.

### Learn QuestDB
<br>For operators or developers looking for next steps to run an efficient instance, see:

- Capacity planning for recommended configurations for operating QuestDB in production
- Configuration to see all of the available options in your server.conf file **https://questdb.io/docs/configuration/**
- Design for performance for tips and tricks **https://questdb.io/docs/operations/design-for-performance/**
- Visualize with Grafana to create useful dashboards and visualizations from your data
<br>**https://questdb.io/docs/third-party-tools/grafana/**
<br>Looking for inspiration? Checkout our real-time crypto dashboard.

### Python Client Documentation
<br>**https://questdb.io/docs/clients/ingest-python/**

