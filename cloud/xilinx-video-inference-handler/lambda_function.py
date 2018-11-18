import logging
import sys
import glob
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
topic = "/generator/camera"


def copy_to_s3(file):
    session = Session()
    _ = session.get_credentials()
    s3.meta.client.upload_file(os.path.join(sync_folder_path, file),
                               bucket, file)
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
        pngname = basename.replace('.txt', '.png')
        payload = {'filename': pngname}

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


def lambda_handler(event, context):
    png_counter = len(glob.glob1(sync_folder_path, '*.png'))
    client.publish(topic=topic,
                   payload='captured {} pictures'.format(png_counter))
    if png_counter > 0:
        txt_files = glob.glob1(sync_folder_path, "*.txt")
        txt_files.sort(key=os.path.getmtime)
        latest_txt = txt_files[-1]
        if os.path.isfile(os.path.join(sync_folder_path, latest_txt)):
            with open(os.path.join(sync_folder_path, latest_txt), 'r') as f:
                data = 'latest capture has detected {} people'.format(f.read())
        else:
            data = 'cannot locate {}'.format(
                os.path.join(sync_folder_path, latest_txt))
        client.publish(topic=topic, payload=data)
    return
