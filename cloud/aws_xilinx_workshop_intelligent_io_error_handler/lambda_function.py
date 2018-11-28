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


# Tweak the GPIO based on the shadow attribute.
# Respond to shadow to update the reported state.
import json
import greengrasssdk
import platform
import logging
import os

client = greengrasssdk.client('iot-data')

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
streamHandler = logging.StreamHandler()
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
streamHandler.setFormatter(formatter)
logger.addHandler(streamHandler)
topic = "$aws/things/{0}/shadow/update".format(os.environ['COREGROUP'])

SYSFS_LEDS = [
    '/sys/class/leds/ds3',
]

def lambda_handler(event, context):
    payload=event
    if 'led' in payload.keys():
        led = payload['led']
        logger.info('Writing LED value of {0}'.format(led))
        for f in SYSFS_LEDS:
            with open(os.path.join(f, 'brightness'), 'w') as fh:
                fh.write('{0}'.format(led))
        payload = { 'state' : { 'reported': { 'led': led } } }
        client.publish(topic=topic, payload=json.dumps(payload))
        return
    else:
        logger.info('Must be data from the subs...')
    return
