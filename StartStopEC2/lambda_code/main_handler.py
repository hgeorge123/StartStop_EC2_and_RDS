from botocore.exceptions import ClientError
import boto3
import logging

# Instantiate logger
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Instantiate boto3 client
ec2 = boto3.client('ec2')

def lambda_handler(event, context):
    logger.info(f'event: {event}')

    # Get action value from event
    action = event.get('action')

    try:
        # Action value validation:
        if action is None:
            action = ''
        if action.lower() not in ['start', 'stop']:
            logger.error("Unknown action, only 'start' and 'stop' are valid.")

        else:
            # Get List of instances with tag "Auto-StartStop-Enabled" equal to "true"
            get_instances = ec2.describe_instances(
                Filters=[
                    {'Name': 'tag:Auto-StartStop-Enabled', 'Values': ['true']},
                    {'Name': 'instance-state-name', 'Values': ['running', 'stopped']}
                    ])
            
            Instances = get_instances["Reservations"][0]["Instances"]
            for instance in Instances:
                InstanceId = instance["InstanceId"]
                InstanceState = instance["State"]["Name"]
                # Stop Instance if action is "stop"
                if InstanceState == 'running' and action == 'stop':
                    logger.info("The instance {} will be stopped".format(InstanceId))
                    stop_instance = ec2.stop_instances(InstanceIds=[InstanceId])
                    logger.info(stop_instance)
                
                # Start Instance if action is "start"
                elif InstanceState == 'stopped' and action == 'start':
                    logger.info("The instance {} will be started".format(InstanceId))
                    start_instance = ec2.start_instances(InstanceIds=[InstanceId])
                    logger.info(start_instance)
                
                else:
                    logger.warning("The status of the instance {} is not right to start or stop".format(InstanceId))

    except ClientError as error:
        logger.error(error)
        return {
            'statusCode': 500,
            'response_from': 'Lambda',
            'body': error,
			'moreInfo': {
                'Lambda Request ID': '{}'.format(context.aws_request_id),
                'CloudWatch log stream name': '{}'.format(context.log_stream_name),
                'CloudWatch log group name': '{}'.format(context.log_group_name)
			}
        }