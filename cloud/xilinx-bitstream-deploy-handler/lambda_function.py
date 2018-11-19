import logging
import sys
import os
import glob
import subprocess
import json
import boto3
import botocore
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
bit_folder_path = "/home/xilinx/download"
topic = "/unit_controller/bitstream-deploy"
bitstream = 'gstreamer_deephi.bit'
parameters = 'parameters.txt'


def download_from_cloud():
    session = Session()
    _ = session.get_credentials()

    # download bitstream
    s3.meta.client.download_file(bucket, bitstream,
                                 os.path.join(bit_folder_path, bitstream))
    payload = {'message': 'Downloaded {} from S3 into {}.'.format(
        bitstream, bit_folder_path)}
    client.publish(topic=topic, payload=json.dumps(payload))

    # download parameters
    s3.meta.client.download_file(bucket, parameters,
                                 os.path.join(bit_folder_path, parameters))
    payload = {'message': 'Downloaded {} from S3 into {}.'.format(
        parameters, bit_folder_path)}
    client.publish(topic=topic, payload=json.dumps(payload))

    return


def lambda_handler(event, context):
    download_from_cloud()
    return
