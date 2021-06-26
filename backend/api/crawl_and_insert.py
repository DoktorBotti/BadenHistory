import requests
import shutil
import random
import os
import time

latitude_min = 48.99
latitude_max = 49.036
longitude_min = 8.33
longitude_max = 8.47

main_url = "https://katalog.landesmuseum.de/expodb/r1/export/aib?qry=text+any+%22*Arch%C3%A4ologie%20in%20Baden*%22&fmt=json&fst=1&len=10"
get_image_url = "https://katalog.landesmuseum.de/expodb/r1/image/aib?id="
add_element_url = "http://localhost:5000/api/elements/insert/"
response = requests.get(main_url)
items = response.json().get("records")
for item in items:
   imdasid = item.get("imdasid")

   request_parameters = {}
   request_parameters.update({"x":random.uniform(latitude_min, latitude_max)})
   request_parameters.update({"y":random.uniform(longitude_min, longitude_max)})
   #request_parameters.update({"image":"\""+imdasid+"\""})
   request_parameters.update({"title":"\'" + item.get("objekttitel") + "\'"})
   request_parameters.update({"text":"\'" + item.get("text") + "\'"})
   request_parameters.update({"place":"\'" + item.get("orte")[0].get("term") + "\'"})
   request_parameters.update({"latitude":item.get("orte")[0].get("latitude")})
   request_parameters.update({"longitude":item.get("orte")[0].get("longitude")})
   request_parameters.update({"voice":None})
   request_parameters.update({"typ":"\"collectable\""})
   request_parameters.update({"username":"\"main\""})
   request_parameters.update({"time":time.time()})
   id = requests.post(add_element_url, json = request_parameters).json().get("id")

   reponse = requests.get(get_image_url+imdasid, stream=True)
   f = open(imdasid, 'wb')
   reponse.raw.decode_content = True
   shutil.copyfileobj(reponse.raw, f)
   requests.post("http://localhost:5000/api/elements/" + str(id) + "/upload_image/", files={'file': open(f.name, "rb")})
   f.close()
   os.remove(f.name)

