#### SFTPOperator + PythonOperator + MySQL Example

This example copies data from an FTP server to a MySQL database.

This environment used (`sftp-mysql-example`) includes containers for:

 - A SFTP server;
 - A MySQL instance;
 - The core Airflow component.
 
The environment contains two startup scripts in the `whirl.setup.d/` folder:

 - `01_prepare_sftp.sh` which adds a SFTP connection to Airflow;
 - `02_prepare_mysql.sh` which adds a MySQL connection to Airflow.

To run this example:

```bash
$ cd ./examples/sftp-mysql-example
$ whirl
```

Open your browser to [http://localhost:5000](http://localhost:5000) to access the Airflow UI. Manually enable the DAG and watch the pipeline run to successful completion.

The environment to be used is set in the `.whirl.env` in the DAG directory. In the environment folder there is also a `.whirl.env` which specifies how `MOCK_DATA_FOLDER` is set. The DAG folder also contains a `whirl.setup.d/` directory which contains the script `01_cp_mock_data_to_sftp.sh`. This script gets executed in the container after the environment specific scripts have run and will do a couple of things:

1. It will rename the file `mocked-data-#ds_nodash#.csv` that is in the `./mock-data/` folder. It will replace `#ds_nodash#` with the same value that Apache Airflow will use when templating `ds_nodash` in the Python files. This means we have a file available for our specific DAG run. (The logic to rename these files is located in `/etc/airflow/functions/date_replacement.sh` in the Airflow container.)
2. It will copy this file to the SFTP server, where the DAG expects to find it. When the DAG starts it will try to copy that file from the SFTP server to the local filesystem.

The DAG contains 2 tasks that use:
- The SFTPOperator to copy the file from the FTPserver to the local directory
- The Python operator using the MySQL Hook to load the csv data into the database.

The SFTP server is exposed to the host on an ephemeral port. Run `docker ps` to find out the local port number.