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
