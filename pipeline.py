import sqlite3
import os

from contextlib import closing
from flask import Flask, render_template, g, request, jsonify

app = Flask(__name__)

DATABASE = '%s/pipeline.db' % os.path.dirname(os.path.realpath(__file__))

app.config.from_object(__name__)
app.config.from_envvar('PIPELINE_SETTINGS', silent=True)

def init_db():
    with closing(connect_db()) as db:
        with app.open_resource('schema.sql') as f:
            db.cursor().executescript(f.read())
        db.commit()

def connect_db():
    return sqlite3.connect(DATABASE)

@app.before_request
def before_request():
    g.db = connect_db()

@app.teardown_request
def teardown_request(exception):
    if hasattr(g, 'db'):
        g.db.close()

@app.route('/')
def index():
    return render_template('pipeline.html')

@app.route('/top')
def top():

    cursor = g.db.execute('select name, hits from subreddits order by hits \
            desc limit 10')

    entries = [dict(name=row[0], hits=row[1]) for row in cursor.fetchall()]

    return jsonify(items=entries)


# TODO: Add some basic security to prevent curl requests spamming this route.
@app.route('/update', methods=['PUT'])
def add():

    sql = """insert or replace into subreddits (name, hits) 
             values (?, coalesce(
                        (select hits from subreddits where name = ?)
                    , 0) + 1);"""

    g.db.execute(sql, [request.form['name']] * 2)
    g.db.commit()

    return ''

if __name__ == '__main__':

    app.debug = True
    app.run(port=7001)
