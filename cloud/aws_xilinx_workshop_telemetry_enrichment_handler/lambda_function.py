# Enrich current payload with epoch (GMT) and carry on.
import json
import greengrasssdk
import platform
import logging
import time

client = greengrasssdk.client('iot-data')
my_platform = platform.platform()

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
streamHandler = logging.StreamHandler()
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
streamHandler.setFormatter(formatter)
logger.addHandler(streamHandler)

def lambda_handler(event, context):
    inbound_topic = context.client_context.custom['subject']
    logger.info('Client context: Topic: [{0}]'.format(inbound_topic))
    payload=event
    payload['timestamp']=int(time.time())
    client.publish(topic=inbound_topic, payload=json.dumps(payload))
    return
