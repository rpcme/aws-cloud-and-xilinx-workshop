import logging
import sys
import glob
import subprocess
import os
import json
import greengrasssdk


# Setup logging to stdout
logger = logging.getLogger(__name__)
logging.basicConfig(stream=sys.stdout, level=logging.DEBUG)


client = greengrasssdk.client('iot-data')


# This is where the video inference results are stored
# Assume there is only 1 folder with suffix `-aws-cloud-and-xilinx-workshop`
bucket = glob.glob1('/home/xilinx', '*-aws-cloud-and-xilinx-workshop')[0]
sync_folder_path = os.path.join("/home/xilinx", bucket)
download_path = "/home/xilinx/download"
topic = "/unit_controller/video-inference"
parameters = 'parameters.txt'


def run_pydeephi_yolo():
    num_seconds = 5
    threshold = 2
    # video application parameters are read from file if possible
    if os.path.isfile(os.path.join(download_path, parameters)):
        with open(os.path.join(download_path, parameters)) as f:
            num_seconds = int(f.readline())
            threshold = int(f.readline())
    _ = subprocess.check_output(
        'cd {0} & sudo /usr/local/bin/pydeephi_yolo.py {1} {2}'.format(
            sync_folder_path, num_seconds, threshold), shell=True)


def lambda_handler(event, context):
    payload = {'message': 'starting video inference'}
    client.publish(topic=topic, payload=json.dumps(payload))

    run_pydeephi_yolo()

    payload = {'message': 'stopped video inference'}
    client.publish(topic=topic, payload=json.dumps(payload))
    return
