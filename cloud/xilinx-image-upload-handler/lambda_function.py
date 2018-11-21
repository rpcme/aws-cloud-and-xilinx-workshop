import logging
import sys
import glob
import subprocess
import os
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


# This is where the video inference results are stored
# Assume there is only 1 folder with suffix `-aws-cloud-and-xilinx-workshop`
bucket = glob.glob1('/home/xilinx', '*-aws-cloud-and-xilinx-workshop')[0]
sync_folder_path = os.path.join("/home/xilinx", bucket)
download_path = "/home/xilinx/download"
topic = "/unit_controller/image_upload"
parameters = 'parameters.txt'


def copy_to_s3(file):
    session = Session()
    _ = session.get_credentials()
    s3.meta.client.upload_file(os.path.join(sync_folder_path, file),
                               bucket, 
                               os.path.join('images', file))
    return


def inference_watcher():
    Timer(1, inference_watcher).start()


class MyEventHandler(FileSystemEventHandler):
    def catch_all_handler(self, event):
        logger.info("New file found: {}".format(event.src_path))

        if event.src_path.find('.txt') == -1:
            return

        logger.info("Text file found: {}".format(event.src_path))

        with open(event.src_path, 'r') as box_file:
            boxes = box_file.read()

        logger.info("Number of boxes found: {}".format(boxes))

        if int(boxes) == 0:
            return

        basename = event.src_path.split('/')[-1]
        jpgname = basename.replace('.txt', '.jpg')

        payload = {'Video_Frame_Image': jpgname,
                   'Num_Persons_Detected': boxes}
        copy_to_s3(jpgname)
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
observer.schedule(event_handler, sync_folder_path, recursive=True)
observer.start()
inference_watcher()


def lambda_handler(event, context):
    return
