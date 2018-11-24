# Proxy based on what is in the delta payload.
import json
import greengrasssdk
import platform
import logging

client = greengrasssdk.client('iot-data')

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
streamHandler = logging.StreamHandler()
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
streamHandler.setFormatter(formatter)
logger.addHandler(streamHandler)

def lambda_handler(event, context):
    logger.info(event)
    payload=event['state']

    # For now, just automatically propagate to both lambdas. We can get smarter
    # later.
    if 'led' in payload.keys():
        logger.info("found led")
        client.publish(topic='func/io-error-handler', payload=json.dumps(payload))
        logger.info("Publish completed.")
    if 'bitstream_version' in payload.keys():
        logger.info("found bitstream_version")
        client.publish(topic='func/bitstream-deploy-handler', payload=json.dumps(payload))
        logger.info("Publish completed.")
    return
