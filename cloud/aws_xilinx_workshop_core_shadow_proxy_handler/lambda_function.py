# Proxy based on what is in the delta payload.
import json
import greengrasssdk
import platform
import logging
from time import gmtime

client = greengrasssdk.client('iot-data')
my_platform = platform.platform()

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
streamHandler = logging.StreamHandler()
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
streamHandler.setFormatter(formatter)
logger.addHandler(streamHandler)

def lambda_handler(event, context):
    logger.info(event)
    if 'data' in event.keys():
        payload=event['data']
    else:
        logger.info('No Data found')
        return

    # For now, just automatically propagate to both lambdas. We can get smarter
    # later.
    if 'led' in payload.keys():
        client.publish(topic='func/io-error-handler', payload=json.dumps(payload))
    if 'bitstream_version' in payload.keys():
        client.publish(topic='func/bitstream-deploy-handler', payload=json.dumps(payload))
    return
