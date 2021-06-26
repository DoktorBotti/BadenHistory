from flask import Flask, request, jsonify, render_template, send_file
import sqlite3 as sqlite
import sys
import os
app = Flask(__name__)



def dict_factory(cursor, row):
    d = {}
    for idx, col in enumerate(cursor.description):
        d[col[0]] = row[idx]
    return d
    
@app.route('/', methods=['GET'])
def home():
    return """<h1>Main Page</h1>
    <p>As useless as it seems. Really. Do not request it.</p>
    """

@app.errorhandler(404)
def page_not_found(e):
    return render_template('404.html'), 404

@app.route('/api/elements/all/', methods=['GET'])
def api_get_all():
    conn = sqlite.connect('../data/elements.db')
    conn.row_factory = dict_factory
    cur = conn.cursor()
    elements_in_bounds = cur.execute("SELECT * FROM elements").fetchall()
    return jsonify(elements_in_bounds)


@app.route('/api/elements/in_bounds/', methods=['GET'])
def api_get_in_bounds():
    query_parameters = request.args
    conn = sqlite.connect('../data/elements.db')
    conn.row_factory = dict_factory
    cur = conn.cursor()
    elements_in_bounds = cur.execute(build_get_in_bounds(query_parameters)).fetchall()
    return jsonify(elements_in_bounds)

@app.route('/api/images/', methods=['GET'])
def api_get_image_by_id():
    query_parameters = request.args
    image = query_parameters.get("image")
    return send_file("../data/" + image + ".jpg", mimetype='image/gif')

@app.route('/api/elements/insert/', methods=['GET'])
def api_insert():
    query_parameters = request.json
    conn = sqlite.connect('../data/elements.db')
    conn.row_factory = dict_factory
    cur = conn.cursor()
    insert = build_insert(query_parameters)
    cur.execute(insert)
    conn.commit()
    return "Inserted object"

@app.route('/api/elements/', methods=['GET'])
def api_get_by_id():
    query_parameters = request.args
    
    id = query_parameters.get('id')
    conn = sqlite.connect('../data/elements.db')
    conn.row_factory = dict_factory
    cur = conn.cursor()
    element = cur.execute("SELECT * FROM elements WHERE id=" + id + ";").fetchall()
    return jsonify(element)

@app.route('/api/delete/', methods=['GET'])
def api_delete():
    query_parameters = request.args
    
    id = query_parameters.get('id')
    conn = sqlite.connect('../data/elements.db')
    conn.row_factory = dict_factory
    cur = conn.cursor()
    element = cur.execute("DELETE FROM elements WHERE id=" + id + ";")
    conn.commit()
    return "Element " + id + " gelöscht."

@app.route('/api/ids/', methods=['GET'])
def api_ids():
    conn = sqlite.connect('../data/elements.db')
    conn.row_factory = dict_factory
    cur = conn.cursor()
    element = cur.execute("SELECT id FROM elements;").fetchall()
    return jsonify(element)

def build_get_in_bounds(dict):
    x_min = dict.get('x_min')
    y_min = dict.get('y_min')
    x_max = dict.get('x_max')
    y_max = dict.get('y_max')
    return "SELECT * FROM elements WHERE x>" + x_min + " AND x<" + x_max + " AND y>" + y_min + " AND y<" + y_max + ";"

def build_insert(dict):
    x = dict.get('x')
    y = dict.get('y')
    image = dict.get('image')
    title = dict.get('title')
    text = dict.get('text')
    place = dict.get('place')
    latitude = dict.get('latitude')
    longitude = dict.get('longitude')
    voice = dict.get('voice')
    typ = dict.get('typ')
    username = dict.get('username')
    elements = "(x, y"
    values = "(" + str(x) + ", " + str(y)
    if image:
        elements, values = add_to_elemts_and_values(elements, values, "image", image)
    if title:
        elements, values = add_to_elemts_and_values(elements, values, "title", title)
    if text:
        elements, values = add_to_elemts_and_values(elements, values, "text", text)
    if place:
        elements, values = add_to_elemts_and_values(elements, values, "place", place)
    if latitude:
        elements, values = add_to_elemts_and_values(elements, values, "latitude", latitude)
    if longitude:
        elements, values = add_to_elemts_and_values(elements, values, "longitude", longitude)
    if voice:
        elements, values = add_to_elemts_and_values(elements, values, "voice", voice)
    if typ:
        elements, values = add_to_elemts_and_values(elements, values, "type", typ)
    if username:
        elements, values = add_to_elemts_and_values(elements, values, "username", username)
    elements += ")"
    values += ")"
    return "insert into elements " + elements + " values " + str(values) + ";"
        

def add_to_elemts_and_values(elements, values, element, value):
    elements += ", " + element
    values += ", " + value
    return elements, values


# A route to return all of the available entries in our catalog.
"""
@app.route('/api/v1/resources/books/all', methods=['GET'])
def api_all():
    conn = sqlite.connect('../data/books.db')
    conn.row_factory = dict_factory
    cur = conn.cursor()
    all_books = cur.execute("SELECT * FROM books;").fetchall()
    return jsonify(all_books)

@app.route("/api/v1/resources/books", methods=['GET'])
def api_filter():
    query_parameters = request.args
    
    id = query_parameters.get('id')
    published = query_parameters.get('published')
    author = query_parameters.get('author')

    to_filter = []
    query = build_select_books_query(author, id, published, to_filter)
    conn = sqlite.connect('../data/books.db')
    conn.row_factory = dict_factory
    cur = conn.cursor()
    
    results = cur.execute(query, to_filter).fetchall()
    
    return jsonify(results)

@app.route("/api/v1/resources/books/json", methods=['GET'])
def api_filter_json():
    books = request.get_json()
    results = []
    for book in books['books']:
        to_filter = []

        id = book['id']
        published = book['published']
        author = book['author']
        query = build_select_books_query(author, id, published, to_filter)

        conn = sqlite.connect('../data/books.db')
        conn.row_factory = dict_factory
        cur = conn.cursor()

        results.append(cur.execute(query, to_filter).fetchall()[0])

    return jsonify(results)


def build_select_books_query(author, id, published, to_filter):
    query = "SELECT * FROM books WHERE"
    if id:
        query += ' id=? AND'
        to_filter.append(id)
    if published:
        query += ' published=? AND'
        to_filter.append(published)
    if author:
        query += ' author=? AND'
        to_filter.append(author)
    if not (id or published or author):
        return page_not_found(404)
    query = query[:-4] + ';'
    return query

"""
if __name__ == '__main__':
    if os.environ.get('PORT') is not None:
        app.run(debug=True, host='0.0.0.0', port=os.environ.get('PORT'))
    else:
        app.run(debug=True, host='0.0.0.0') 

