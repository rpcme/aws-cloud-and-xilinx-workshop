# Workshop: Integrate the AWS Cloud with Responsive Xilinx Machine Learning at the Edge
# Copyright (C) 2018 Amazon.com, Inc. and Xilinx Inc.  All Rights Reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


import logging
import sys
import os
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

bucket                = os.environ['BUCKET']
bucket_bitstream_path = 'bitstream_deploy'
bit_folder_path       = "/home/xilinx/download"
bitstream             = 'gstreamer_deephi.bit'
parameters            = 'parameters.txt'
topic                 = "$aws/things/{0}/shadow/update".format(os.environ['COREGROUP'])

def lambda_handler(event, context):
    logger.info(event)

    payload=event
    if 'bitstream_version' in payload.keys():
        if not os.path.exists(bit_folder_path):
            os.mkdir(bit_folder_path)

        version = event['bitstream_version']
        session = Session()
        _ = session.get_credentials()

        bitstream_version='{0}/{1}/{2}'.format(bucket_bitstream_path, version, bitstream)
        parameters_version='{0}/{1}/{2}'.format(bucket_bitstream_path, version, parameters)

        # download bitstream
        logger.info('Downloading bitstream [{0}]'.format(bitstream_version))
        s3.meta.client.download_file(bucket, bitstream_version,
                                     os.path.join(bit_folder_path, bitstream))

        # download parameters
        logger.info('Downloading parameters [{0}]'.format(parameters_version))
        s3.meta.client.download_file(bucket, parameters_version,
                                     os.path.join(bit_folder_path, parameters))

        # All successful, now publish the update to the core shadow.
        payload = { 'state' : { 'reported': { 'bitstream_version': version } } }
        client.publish(topic=topic, payload=json.dumps(payload))
        return
    else:
        logger.info("Hit Accepted or Rejected payload")
