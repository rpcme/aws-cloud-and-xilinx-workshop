import logging
import sys
import os
import glob
import subprocess
import json
import boto3
import botocore
import greengrasssdk
from botocore.session import Session

logger = logging.getLogger(__name__)
logging.basicConfig(stream=sys.stdout, level=logging.DEBUG)

client = greengrasssdk.client('iot-data')
s3 = boto3.resource('s3')

# This is where the bitstream is stored
# Assume there is only 1 folder with suffix `-aws-cloud-and-xilinx-workshop`
bucket                = glob.glob1('/home/xilinx', '*-aws-cloud-and-xilinx-workshop')[0]
bucket_bitstream_path = 'bitstreams'
bit_folder_path       = "/home/xilinx/download"
bitstream             = 'gstreamer_deephi.bit'
parameters            = 'parameters.txt'
topic                 = "$aws/things/{0}/shadow/update".format(os.environ['COREGROUP'])

def lambda_handler(event, context):
    version = event['bitstream_version']
    session = Session()
    _ = session.get_credentials()

    bitsream_version='{0}/{1}/{2}'.format(bucket_bitstream_path, version, bitstream)
    parameters_version='{0}/{1}/{2}'.format(bucket_bitstream_path, version, parameters)

    # download bitstream
    s3.meta.client.download_file(bucket, bitsream_version,
                                 os.path.join(bit_folder_path, bitstream))

    # download parameters
    s3.meta.client.download_file(bucket, parameters_version,
                                 os.path.join(bit_folder_path, parameters))

    # All successful, now publish the update to the core shadow.
    payload = { 'reported': { 'version': version } }
    client.publish(topic=topic, payload=json.dumps(payload))
    return
