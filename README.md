## Project constructor


- vue-cli：@vue/cli 4.5.7
- python：Python 3.7.0
- flask：1.1.2
- postgresql: 12

### how to run

#### Create a new databae

At plsq:

```
createdb dbname
```

#### Get Data tables

At linux shell
```
psql user_role -h 127.0.0.1 -d some_database -f public.sql
```
The 'user_role' and some_database is the corresponding user and database.

#### initialization front-end

The front-end build and install

```cmd

cd vue-web
npm install
npm run build

```


#### install backend packages

``` cmd
pip install -r requests.txt

```

#### run app

```
python -m flask run
```
or

```
python app.py
```