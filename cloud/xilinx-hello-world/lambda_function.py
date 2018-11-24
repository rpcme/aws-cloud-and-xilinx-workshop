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
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
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
    '/sys/class/leds/ds3',
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
