from flask import Flask, request, jsonify, render_template, send_file
import sqlite3 as sqlite
import os
import shutil
import time
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

@app.route('/api/images/<id>/', methods=['GET'])
def api_get_image_by_id(id):
    conn = sqlite.connect('../data/elements.db')
    conn.row_factory = dict_factory
    cur = conn.cursor()
    image = cur.execute("SELECT image FROM elements WHERE id=" + id + ";").fetchall()[0].get("image")
    print(image)
    return send_file("../data/" + image + ".jpg", mimetype='image/gif')

@app.route('/api/voices/<id>/', methods=['GET'])
def api_get_voice_by_id(id):
    conn = sqlite.connect('../data/elements.db')
    conn.row_factory = dict_factory
    cur = conn.cursor()
    voice = cur.execute("SELECT voice FROM elements WHERE id=" + id + ";").fetchall()[0].get("voice")
    print(voice)
    return send_file("../data/" + voice, as_attachment=True)

@app.route('/api/elements/insert/', methods=['POST'])
def api_insert():
    query_parameters = request.json
    conn = sqlite.connect('../data/elements.db')
    conn.row_factory = dict_factory
    cur = conn.cursor()
    insert = build_insert(query_parameters)
    id = cur.execute(insert).lastrowid
    conn.commit()
    return jsonify({"id":id})

@app.route('/api/elements/<id>/upload_image/', methods=['POST'])
def api_upload_image(id):
    conn = sqlite.connect('../data/elements.db')
    conn.row_factory = dict_factory
    cur = conn.cursor()
    file = request.files.get("file")
    imdasid = file.filename
    with open("../data/"+str(imdasid)+".jpg", 'wb') as f:
        shutil.copyfileobj(file, f)

    cur.execute("UPDATE elements SET image=\""+imdasid+"\" WHERE id="+id+";")
    conn.commit()
    return "Inserted object"

@app.route('/api/elements/<id>/upload_voice/', methods=['POST'])
def api_upload_voice(id):
    conn = sqlite.connect('../data/elements.db')
    conn.row_factory = dict_factory
    cur = conn.cursor()
    file = request.files.get("file")
    filename = file.filename
    timestamp = time.time()
    with open("../data/"+str(timestamp)+"_"+filename, 'wb') as f:
        shutil.copyfileobj(file, f)

    cur.execute("UPDATE elements SET voice=\""+str(timestamp)+"_"+filename+"\" WHERE id="+id+";")
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
    query_parameters = request.args
    
    type = query_parameters.get('type')
    conn = sqlite.connect('../data/elements.db')
    conn.row_factory = dict_factory
    cur = conn.cursor()
    if type:
        element = cur.execute("SELECT id FROM elements WHERE type=" + type + ";").fetchall()
    else:
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
    link_to = dict.get('link_to')
    time = dict.get('time')
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
    if link_to:
        elements, values = add_to_elemts_and_values(elements, values, "link_to", link_to)
    if time:
        elements, values = add_to_elemts_and_values(elements, values, "time", time)
    elements += ")"
    values += ")"
    return "insert into elements " + elements + " values " + str(values) + ";"
        

def add_to_elemts_and_values(elements, values, element, value):
    elements += ", " + str(element)
    values += ", " + str(value)
    return elements, values

if __name__ == '__main__':
    if os.environ.get('PORT') is not None:
        app.run(debug=True, host='0.0.0.0', port=os.environ.get('PORT'))
    else:
        app.run(debug=True, host='0.0.0.0') 

