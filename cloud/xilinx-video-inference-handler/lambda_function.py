import logging
import sys
import time
import json
import boto3
from threading import Timer

import greengrasssdk
from botocore.session import Session
from watchdog.events import FileSystemEventHandler
from watchdog.observers import Observer

# Setup logging to stdout
logger = logging.getLogger(__name__)
logging.basicConfig(stream=sys.stdout, level=logging.DEBUG)

client = greengrasssdk.client('iot-data')
s3 = boto3.resource('s3')

# This is where the overlay will output files.
path = "/home/xilinx/out"
bucket = "bitstream-deployer"
topic = "/generator/camera"

client = greengrasssdk.client('iot-data')

def copy_to_s3(file):
    session = Session()
    creds = session.get_credentials()
    s3.meta.client.upload_file('{}/{}'.format(path,file), bucket, 'images/{}'.format(file))
    return

def inference_watcher():
    Timer(1, inference_watcher).start()

class MyEventHandler(FileSystemEventHandler):
    def catch_all_handler(self, event):
        logger.info("File found: {}".format(event.src_path))

        if event.src_path.find('.txt') == -1:
            return

        logger.info("Text file found: {}".format(event.src_path))

        with open(event.src_path, 'r') as box_file:
            boxes = box_file.read()

        logger.info("Number of boxes found: {}".format(boxes))

        if int(boxes) == 0:
            return

        basename = event.src_path.split('/')[-1]
        pngname = basename.replace( '.txt', '.png')
        payload = { 'filename' : pngname }

        logger.info("Number of boxes found: {}".format(boxes))

        copy_to_s3(pngname)

        client.publish(topic=topic,
            payload=json.dumps(payload))

    def on_moved(self, event):
        self.catch_all_handler(event)

    def on_created(self, event):
        self.catch_all_handler(event)

    def on_deleted(self, event):
        self.catch_all_handler(event)

    def on_modified(self, event):
        self.catch_all_handler(event)

event_handler = MyEventHandler()
observer = Observer()
observer.schedule(event_handler, path, recursive=True)
observer.start()
inference_watcher()



#try:
#    while True:#
#        time.sleep(1)
#except KeyboardInterrupt:
#    observer.stop()
#observer.join()

def lambda_handler(event, context):
    logger.info("Received event data: {}".format(json.dumps(event)))
    client.publish(topic='hello/world', payload='Sent from Greengrass Core.')
    if os.path.isfile(volumePath + '/log.txt'):
        with open(volumePath + '/log.txt', 'r') as myfile:
            data = myfile.read()
        client.publish(topic='hello/world', payload=data)
    return
