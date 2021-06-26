from pydub import AudioSegment 
from pydub.utils import make_chunks 
import requests
import shutil
import random
import os

latitude_min = 48.99
latitude_max = 49.036
longitude_min = 8.33
longitude_max = 8.47

add_element_url = "http://localhost:5000/api/elements/insert/"

myaudio = AudioSegment.from_file("Example.wav", "wav") 
chunk_length_ms = 80000 # pydub calculates in millisec 
chunks = make_chunks(myaudio,chunk_length_ms) #Make chunks of one sec 
for i, chunk in enumerate(chunks): 
    chunk_name = "{0}".format(i) 
    print ("exporting", chunk_name) 
    chunk.export(chunk_name, format="wav") 

    request_parameters = {}
    request_parameters.update({"x":random.uniform(latitude_min, latitude_max)})
    request_parameters.update({"y":random.uniform(longitude_min, longitude_max)})
    request_parameters.update({"voice":None})
    request_parameters.update({"typ":"\"question\""})
    request_parameters.update({"username":"\"main\""})
    id = requests.get(add_element_url, json = request_parameters).json().get("id")

    requests.post("http://localhost:5000/api/elements/" + str(id) + "/upload_voice/", files={'file': open("{0}".format(i), "rb")})

    os.remove("{0}".format(i))