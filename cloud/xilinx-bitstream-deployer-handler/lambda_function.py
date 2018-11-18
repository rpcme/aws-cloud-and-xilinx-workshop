import logging
import sys
import os
import subprocess
import json
import boto3
from threading import Timer
import greengrasssdk
from botocore.session import Session


logger = logging.getLogger(__name__)
logging.basicConfig(stream=sys.stdout, level=logging.DEBUG)


client = greengrasssdk.client('iot-data')
s3 = boto3.resource('s3')


# This is where the bitstream is stored
# Assume there is only 1 folder with suffix `-aws-cloud-and-xilinx-workshop`
bucket = glob.glob1('/home/xilinx', '*-aws-cloud-and-xilinx-workshop')[0]
sync_folder_path = os.path.join("/home/xilinx", bucket)
topic = "/generator/camera"
bitstream = 'gstreamer_deephi.bit'
parameters = 'parameters.txt'


def download_from_cloud():
    session = Session()
    _ = session.get_credentials()

    # download bitstream
    s3.meta.client.download_file(bucket, bitstream,
                                 os.path.join(sync_folder_path, bitstream))
    client.publish(topic=topic,
                   payload='Downloaded {} from S3.'.format(bitstream))

    # download parameters if exists
    try:
        s3.Object(bucket, 'parameters.txt').load()
    except botocore.exceptions.ClientError as e:
        if e.response['Error']['Code'] == "404":
            pass
        else:
            raise
    else:
        s3.meta.client.download_file(bucket, parameter,
                                     os.path.join(sync_folder_path, parameters))
        client.publish(topic=topic,
                       payload='Downloaded {} from S3.'.format(parameters))

    return


def start_video_inference():
    num_seconds = 5
    threshold = 2
    # video application parameters are read from file if possible
    if os.path.isfile(os.path.join(sync_folder_path, parameters)):
        with open(os.path.join(sync_folder_path, parameters)) as f:
            num_seconds = f.read()
            threshold = f.read()
    _ = subprocess.check_output(
        'cd {0} & /usr/local/bin/pydeephi_yolo.py {1} {2}'.format(
            sync_folder_path, num_seconds, threshold), shell=True)


download_from_cloud()
start_video_inference()


def lambda_handler(event, context):
    return
