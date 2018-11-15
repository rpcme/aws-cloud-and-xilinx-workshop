import greengrasssdk
import platform
from threading import Timer
import time

client = greengrasssdk.client('iot-data')
my_platform = platform.platform()

def greengrass_hello_world_run():
    if not my_platform:
        client.publish(topic='greengrass/core/hello/world', payload='Hello world! Sent from Greengrass Core.')
    else:
        client.publish(topic='greengrass/core/hello/world', payload='Hello world! Sent from Greengrass Core running on platform: {}'.format(my_platform))
    Timer(5, greengrass_hello_world_run).start()

greengrass_hello_world_run()

def function_handler(event, context):
    return
