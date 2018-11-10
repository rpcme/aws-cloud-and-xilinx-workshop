import logging
import sys
import time
import json
import boto3
from threading import Timer

import greengrasssdk
from botocore.session import Session

# Setup logging to stdout
logger = logging.getLogger(__name__)
logging.basicConfig(stream=sys.stdout, level=logging.DEBUG)

client = greengrasssdk.client('iot-data')
s3 = boto3.resource('s3')

# This is where the overlay will output files.
path = "/home/xilinx/packages"
bucket = "bitstream-deployer"
topic = "/generator/camera"

client = greengrasssdk.client('iot-data')

def copy_to_s3(file):
    session = Session()
    creds = session.get_credentials()
    s3.meta.client.upload_file('{}/{}'.format(path,file), bucket, 'web/camera-images/{}'.format(file))
    return

def inference_watcher():
    Timer(1, inference_watcher).start()

inference_watcher()

def lambda_handler(event, context):
    logger.info("Received event data: {}".format(json.dumps(event)))
    client.publish(topic='hello/world', payload='Sent from Greengrass Core.')
    if os.path.isfile(volumePath + '/log.txt'):
        with open(volumePath + '/log.txt', 'r') as myfile:
            data = myfile.read()
        client.publish(topic='hello/world', payload=data)
    return
