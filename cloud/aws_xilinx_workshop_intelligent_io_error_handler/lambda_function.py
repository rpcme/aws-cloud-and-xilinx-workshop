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
