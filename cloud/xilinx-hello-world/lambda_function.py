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


import json
import greengrasssdk
import platform
from threading import Timer
import signal
import logging
import os


client = greengrasssdk.client('iot-data')
my_platform = platform.platform()

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
streamHandler = logging.StreamHandler()
formatter = logging.Formatter(
    '%(asctime)s - %(name)s - %(levelname)s - %(message)s')
streamHandler.setFormatter(formatter)
logger.addHandler(streamHandler)


def greengrass_hello_world_run():
    if not my_platform:
        payload = {'message': 'Hello world! Sent from Greengrass Core'}
        client.publish(topic='hello/world', payload=json.dumps(payload))
    else:
        payload = {'message': 'Hello world! Sent from Greengrass Core '
                              'running on platform: {}'.format(my_platform)}
        client.publish(topic='hello/world', payload=json.dumps(payload))

    Timer(5, greengrass_hello_world_run).start()


SYSFS_LEDS = [
    '/sys/class/leds/ds4',
    '/sys/class/leds/ds5',
    '/sys/class/leds/ds6'
]

def trap_my_signal(signal, frame):
    logger.info('In trap_signal')
    logger.info('In trap with signal {0}'.format(str(signal)))
    for f in SYSFS_LEDS:
        with open(os.path.join(f, 'brightness'), 'w') as fh:
            fh.write('{0}'.format('0'))

#signal.signal(signal.SIGINT, trap_my_signal)
#signal.signal(signal.SIGHUP, trap_my_signal)
signal.signal(signal.SIGTERM, trap_my_signal)
#signal.signal(signal.SIGKILL, trap_my_signal)

greengrass_hello_world_run()


def lambda_handler(event, context):
    return
