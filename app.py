from flask import Flask, render_template, jsonify, g, request, session, Response,redirect, url_for, send_file
from flask_cors import CORS
import random
from config import Config
import psycopg2
from collections import defaultdict
import click
import json
from PIL import Image
import uuid
import os
import base64
from io import BytesIO
import numpy as np

def emptystr():
    return ''

def create_app():
    app = Flask(__name__,  static_folder='./static/static')
    app.config.from_object(Config())
    CORS(app, resources={r"/api/*": {"origins": "*"}, r"/static/*": {"origins": "*"}})
    return app

app = create_app()

conf = app.config

thumbSize = 40


def get_db():
    if 'db' not in g:
        g.db = psycopg2.connect(host=conf['DB_SERVER'], database=conf['DB'], user=conf['USER'], password=conf['PASSWORD'])
    return g.db

def close_db():
    db = g.pop('db', None)
    if db is not None:
        db.close()

@app.route('/')
def hello_world():
    return render_template('index.html')


@app.route('/api/getRandomNum')
def get_random_num():
    res = {
        'getRandomNum': random.randint(1, 100)
    }
    return jsonify(res)

@app.route('/api/list_user')
def list_user():
    rows = []
    cur = get_db().cursor()
    cur.execute("SELECT * from account;")
    result = cur.fetchall()
    for row in result:
        rows.append({'id': row[0], 'first_name': row[1], 'last_name': row[2], 
            'email': row[3], 'gender': row[4], 'telephone': row[5]})
    return jsonify(rows)

@app.route('/api/create_user', methods=['post'])
def create_user():
    cur = get_db().cursor()
    if request.is_json:
        jdata = defaultdict(emptystr)
        jdata.update(request.json)
        cur.execute('select * from account where email=%s', (jdata['email'],))
        result = cur.fetchall()
        if(len(result)<=0):
            cur.execute('''Insert into account(first_name, last_name, email, gender, telephone)
                Values(%s, %s, %s, %s, %s) RETURNING id;''',
                (jdata['first_name'], jdata['last_name'], jdata['email'], jdata['gender'],jdata['telephone']))
            result = cur.fetchall()
            print(result)
            if(len(result) == 1):
                cur.close()
                get_db().commit()
                return jsonify({'message': "successful insert account"})
            else:
                cur.close()
                get_db().rollback()

        else:
            return jsonify({'message': "account already exist"}), 500

@app.route('/api/login', methods=['post'])
def login():
    image_id =''
    if request.is_json:
        ret_json = request.json
        email = request.json['email']
        if (request.is_json and 'id' in request.json):
            id = request.json['id']
        else:
            with get_db().cursor() as cur:
                cur.execute('select account.id as id, image.id as image_id, account.gender from account left join image on account.id = image.belong_to where email=%s', (email,))
                result = cur.fetchone()
                if result:
                    id = result[0]
                    image_id = result[1] if result[1] else ''
                else:
                    return jsonify({'error': 'no user use this email address'})
        resp = Response(json.dumps({'email': email, 'user_id': id, 'image_id': image_id, 'gender': result[2]}))
        resp.set_cookie('email', email)
        resp.set_cookie('user_id', str(id))
        return resp
    else:
        return jsonify({'error': 'not valid json request'}), 500

@app.route('/api/upload_image', methods=['post'])
def upload_file():
    uid = request.form
    if 'loginPic' in request.form:
        image_id = request.form['loginPic'] 
    else:
        image_id = ''
    print(request.files)
    if 'image' not in request.files:
        return jsonify({'error': 'no file upload'}), 400
    else:
        if len(image_id)>0:
            file = request.files['image']
            buf = BytesIO(file.read())
            with get_db().cursor() as cur:
                cur.callproc('replaceimage', (buf.read(), file.filename, file.content_type, image_id))
                result = cur.fetchone()
                if(result):
                    cur.close()
                    get_db().commit()
                    return jsonify({'message': 'successful replace picture', 'image_id': result[0]})
                else:
                    cur.close()
                    get_db().rollback()
        elif uid :
            target = 'profile'
            file = request.files['image']

            buf = BytesIO(file.read())
            fname = file.filename
    
            with get_db().cursor() as cur:
                cur.callproc('addimage', (buf.read(), file.filename, file.content_type,int(request.form['user_id'])))
                result = cur.fetchone()
                if(result):
                    cur.close()
                    get_db().commit()
                    return jsonify({'result': 'successful upload picture', 'image_id': result[0]})
                else:
                    cur.close()
                    get_db.rollback()
                    return jsonify({'error': "can not insert into database"}), 400
        else:
            return jsonify({'error': "before upload picture must long in"})

FORMAT = {'image/jpeg':'JPEG', 'image/bmp':'BMP', 'image/png':'PNG', 'image/gif': 'GIF'}

@app.route('/api/image/<id>/<str_size>', methods=['get'])
def show_image(id, str_size):
    size = int(str_size)
    with get_db().cursor() as cur:
        cur.callproc('getimage', (id,))
        result = cur.fetchone()
        buf = BytesIO(result[1])
        if(size>0):
            im = Image.open(buf)
            im.thumbnail((size, size))
            buf = BytesIO(b'')
            im.save(buf, format=FORMAT[result[0].lower()])

        buf.seek(0)
   
        resp = Response(buf)
        resp.headers.set('Content-Type', result[0].lower())
        return resp

@app.route('/api/profile_image/<id>/<gender>', methods=['get'])
def show_profile(id, gender):
    with get_db().cursor() as cur:
        cur.execute('select id from image where belong_to=%s and target=%s', (id, 'profile'))
        result = cur.fetchone()
        if(result):
            resp = show_image(result[0], thumbSize)
            return resp
        else:
            if gender == 'female':
                return send_file('static/static/female.svg', mimetype='image/svg+xml')
            else:
                return send_file('static/static/male.svg', mimetype='image/svg+xml')       


@app.route('/api/delete_image/<id>', methods=['delete', 'get'])
def delete_image(id):
    with get_db().cursor() as cur:
        cur.callproc('deleteimage', (id,))
        cur.close()
    get_db().commit()
    return jsonify({'message': 'delete picture successful'})

@app.route('/api/user/<id>', methods=['get'])
def get_user(id):
    with get_db().cursor() as cur:
        cur.execute('select * from account where id = %s', (id,))
        result = cur.fetchone()
        cur.close()
        return jsonify({'id':result[0], 'first_name': result[1], 'last_name': result[2], 'email': result[3], 'telephone': result[4]})
    
    return jsonify({'message': 'get user unsuccessful'})

@app.route('/api/edit_user/<id>', methods=['post'])
def edit_user(id):
    with get_db().cursor() as cur:
        if request.is_json:
            d = request.json
            cur.execute('''update account set first_name=%s, last_name=%s, gender=%s, email=%s, telephone=%s where id = %s''', 
            (d['first_name'], d['last_name'], d['gender'],d['email'], d['telephone'], id))
    
    get_db().commit()
    return jsonify({'message':'successful update user'})

            


@app.route('/api/delete_user/<id>', methods=['delete', 'get'])
def delete_user(id):
    with get_db().cursor() as cur:
        cur.callproc('deleteuser', (id,))
        result = cur.fetchall()
        cur.close()
    get_db().commit()
    return jsonify({'message': 'delete user successful', 'result': result})


if __name__ == '__main__':
    app.run(debug=True, use_reloader=False)


@app.cli.command('debug')
def debug():
    app.run(debug=True, use_reloader=False)

