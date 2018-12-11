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
import time
import subprocess
import os
import json
import greengrasssdk
import datetime
from threading import Timer


# Setup logging to stdout
logger = logging.getLogger(__name__)
logging.basicConfig(stream=sys.stdout, level=logging.DEBUG)


client = greengrasssdk.client('iot-data')


bucket = os.environ['BUCKET']
sync_folder_path = os.path.join("/home/xilinx", bucket)
download_path = "/home/xilinx/download"
topic = "compressor/video_inference"
parameters = 'parameters.txt'

def run_pydeephi_yolo():
    num_seconds = 5
    threshold = 2

    if os.path.isfile(os.path.join(download_path, parameters)):
        with open(os.path.join(download_path, parameters)) as f:
            num_seconds = int(f.readline())
            threshold = int(f.readline())
    logger.info("Running subprocess in {}".format(sync_folder_path))
    logger.info("Parameter number of seconds: {}".format(num_seconds))
    logger.info("Parameter threshold: {}".format(threshold))

    cmd = 'cd {} && '.format(sync_folder_path) + \
            'PYTHONPATH=/usr/lib/python3.6 ' + \
            '/usr/local/bin/pydeephi_yolo.py {} {}'.format(
            num_seconds, threshold)
    proc = subprocess.Popen(cmd, shell=True, 
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = proc.communicate()
    logger.info("{}".format(out))
    if err:
        logger.info("{}".format(err))

    return

while (1):
    run_pydeephi_yolo()
    time.sleep(1)

def lambda_handler(event, context):
    return
