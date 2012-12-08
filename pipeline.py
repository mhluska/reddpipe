import sqlite3
import os

from contextlib import closing
from flask import Flask, render_template, g, request, jsonify
from reverseproxied import ReverseProxied
from ratelimit import ratelimit

app = Flask(__name__)
app.wsgi_app = ReverseProxied(app.wsgi_app)

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

def most_pipelined_subreddits():

    cursor = g.db.execute('select name, hits from subreddit order by hits \
            desc limit 15')

    return [dict(name=row[0], hits=row[1]) for row in cursor.fetchall()]

@app.before_request
def before_request():
    g.db = connect_db()

@app.teardown_request
def teardown_request(exception):
    if hasattr(g, 'db'):
        g.db.close()

@app.route('/')
@app.route('/r/<name>/')
def index(name=''):

    subreddits = most_pipelined_subreddits()

    return render_template('pipeline.html', name=name, subreddits=subreddits)

@app.route('/subreddit')
def subreddit_index():

    return jsonify(items = most_pipelined_subreddits())

@app.route('/subreddit/update', methods=['PUT'])
@ratelimit(limit=300, per=60 * 15)
def subreddit_update():

    sql = """insert or replace into subreddit (name, hits) 
             values (?, coalesce(
                        (select hits from subreddit where name = ?)
                    , 0) + 1);"""

    g.db.execute(sql, [request.form['name']] * 2)
    g.db.commit()

    return ''

if __name__ == '__main__':

    app.debug = True
    app.run(port=7001)
