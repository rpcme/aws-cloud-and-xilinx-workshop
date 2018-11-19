import json
import greengrasssdk
import platform
from threading import Timer


client = greengrasssdk.client('iot-data')
my_platform = platform.platform()


def greengrass_hello_world_run():
    if not my_platform:
        payload = {'message': 'Hello world! Sent from Greengrass Core'}
        client.publish(topic='hello/world', payload=json.dumps(payload))
    else:
        payload = {'message': 'Hello world! Sent from Greengrass Core '
                              'running on platform: {}'.format(my_platform)}
        client.publish(topic='hello/world', payload=json.dumps(payload))

    Timer(5, greengrass_hello_world_run).start()


greengrass_hello_world_run()


def lambda_handler(event, context):
    return
