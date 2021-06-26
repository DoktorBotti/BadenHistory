import requests
import shutil
import random

latitude_min = 48.99
latitude_max = 49.036
longitude_min = 8.33
longitude_max = 8.47

main_url = "https://katalog.landesmuseum.de/expodb/r1/export/aib?qry=text+any+%22*Arch%C3%A4ologie%20in%20Baden*%22&fmt=json&fst=1&len=2"
get_image_url = "https://katalog.landesmuseum.de/expodb/r1/image/aib?id="
add_element_url = "http://localhost:5000/api/elements/insert/"
response = requests.get(main_url)
items = response.json().get("records")
for item in items:
    id = item.get("imdasid")
    image = requests.get(get_image_url+id, stream=True)
    with open("data/"+id+".jpg", 'wb') as f:
       image.raw.decode_content = True
       shutil.copyfileobj(image.raw, f)
    request_parameters = {}
    request_parameters.update({"x":random.uniform(latitude_min, latitude_max)})
    request_parameters.update({"y":random.uniform(longitude_min, longitude_max)})
    request_parameters.update({"image":"\""+id+"\""})
    request_parameters.update({"title":"\'" + item.get("objekttitel") + "\'"})
    request_parameters.update({"text":"\'" + item.get("text") + "\'"})
    request_parameters.update({"place":"\'" + item.get("orte")[0].get("term") + "\'"})
    request_parameters.update({"latitude":item.get("orte")[0].get("latitude")})
    request_parameters.update({"longitude":item.get("orte")[0].get("longitude")})
    request_parameters.update({"voice":None})
    request_parameters.update({"typ":"\"collectable\""})
    request_parameters.update({"username":"\"main\""})
    requests.get(add_element_url, data = request_parameters)