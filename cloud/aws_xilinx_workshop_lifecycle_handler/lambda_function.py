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
import boto3
import logging

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
streamHandler = logging.StreamHandler()
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
streamHandler.setFormatter(formatter)
logger.addHandler(streamHandler)

client_iot = boto3.client('iot')
client_iotdata = boto3.client('iot-data')
client_greengrass = boto3.client('greengrass')

def lambda_handler(event, context):
    region = context.invoked_function_arn.split(":")[3]
    account = context.invoked_function_arn.split(":")[4]
    arn = 'arn:aws:iot:{0}:{1}:cert/{2}'.format(region, account, event['principalIdentifier'])
    things = client_iot.list_principal_things(maxResults=123, principal=arn)
    topic = '$aws/things/{0}/shadow/update'.format(things['things'][0])
    payload = { "state": { "desired": { "is_connected": event['is_connected'] } } }
    client_iotdata.publish(topic=topic, payload=json.dumps(payload))
    # need to set reported state manually because... if disconnected, the device can't
    if event['type'] == 'disconnected':
        payload = { "state": { "reported": { "is_connected": event['is_connected'] } } }
        client_iotdata.publish(topic=topic, payload=json.dumps(payload))
    return
