import base64
import json
import logging
import os

import boto3

from botocore.exceptions import ClientError
from laceworksdk import LaceworkClient

LOGLEVEL = os.environ.get('LOGLEVEL', logging.INFO)
logger = logging.getLogger()
logger.setLevel(LOGLEVEL)

aws = boto3.Session()


def handler(event, context):
    logger.info(event)

    config_data = get_configuration_secret()

    try:
        os.environ['LW_ACCOUNT'] = config_data['account']
        os.environ['LW_API_KEY'] = config_data['api_key']
        os.environ['LW_API_SECRET'] = config_data['api_secret']
        default_account = config_data['default_account']
        intg_guid = config_data['intg_guid']
        org_map = config_data['org_map']
    except Exception as e:
        logger.error(f'Unable to parse secret data: {e}')

    lw_client = get_lacework_client()

    logger.info(org_map)

    aws_account_map = build_aws_account_map(org_map)
    logger.info(aws_account_map)

    lw_account_map = build_lw_account_map(default_account, aws_account_map)
    logger.info(lw_account_map)

    response = update_lacework_integration(
        lw_client,
        intg_guid,
        lw_account_map
    )
    logger.info(response)


def build_aws_account_map(org_map):
    account_map = {}

    for lw_account, ou_list in org_map.items():
        accounts = set()
        logger.info(f'Lacework Account {lw_account} / AWS Org ID {ou_list}')
        if isinstance(ou_list, list):
            for ou in ou_list:
                accounts.update(get_aws_accounts_by_ou(ou))
        else:
            logger.error('Supplied value was not a list of OUs')
        logger.info(f'Returned accounts: {accounts}')
        account_map[lw_account] = accounts

    return account_map


def get_aws_accounts_by_ou(ou):
    results = []

    organizations = aws.client('organizations')
    paginator = organizations.get_paginator('list_accounts_for_parent')
    responses = paginator.paginate(
        ParentId=ou
    )

    try:
        for response in responses:
            for account in response['Accounts']:
                results.append(account['Id'])
    except Exception as e:
        logger.error(f'Error when trying to access AWS Organizations API: {e}')

    return results


def build_lw_account_map(default_account, account_map):

    result = {
        'defaultLaceworkAccountAws': default_account,
        'integration_mappings': {}
    }

    for lw_account, aws_accounts in account_map.items():
        result['integration_mappings'][lw_account] = {
            'aws_accounts': list(aws_accounts)
        }

    return result


def get_configuration_secret():

    secret_name = os.environ['LACEWORK_SECRET_ARN']
    region_name = os.environ['AWS_REGION']

    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name,
    )

    try:
        secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
        if e.response['Error']['Code'] == 'DecryptionFailureException':
            logger.error(f'The secret {secret_name} couldn\'t be decrypted.')
        elif e.response['Error']['Code'] == 'InternalServiceErrorException':
            logger.error(f'An error occurred on service side.')
        elif e.response['Error']['Code'] == 'InvalidParameterException':
            logger.error(f'The request had invalid parameters.')
        elif e.response['Error']['Code'] == 'InvalidRequestException':
            logger.error(f'The request was invalid.')
        elif e.response['Error']['Code'] == 'ResourceNotFoundException':
            logger.error(f'The requested secret {secret_name} was not found.')

        raise e
    else:
        if 'SecretString' in secret_value_response:
            secret = secret_value_response['SecretString']
        else:
            secret = base64.b64decode(secret_value_response['SecretBinary'])

    return json.loads(secret)


def get_lacework_client():

    try:
        lw_client = LaceworkClient()
    except Exception as e:
        logger.error(f'Unable to configure Lacework client: {e}')

    return lw_client


def update_lacework_integration(lw_client, intg_guid, lw_account_map_file):

    request_body = {
        "accountMapping": lw_account_map_file
    }

    lw_client.set_org_level_access(True)
    response = lw_client.cloud_accounts.update(
        intg_guid,
        data=request_body
    )
    lw_client.set_org_level_access(False)

    return response
