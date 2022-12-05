#  ---------------------------------------------------------
#  Azure Gaming - Unreal Cloud DDC
#
# Copyright (c) Microsoft Corporation. All rights reserved.
#  ---------------------------------------------------------
"""
Post Deployment Tests

Environment Variables

RG: Resource Group of Application
AAD_ID: Azure SP Application ID used for Authentication
OBJ_ID: Azure SP Object ID used for Authentication
AAD_SECRET: Azure Tenant
SUBSCRIPTION_ID: Azure Subscription ID

Install the latest testing utilities before using this file.

`pip install ../../../src/microsoft-industrailai`

After setting variables, and installing testing utilities, execute using the following command.

`pytest test_deploy.py`

"""
from microsoft.industrialai.utils.test_utils import get_aks_name, get_key_vault_names, get_key_vault_secret


def test_get_resources():
    assert get_aks_name()

    key_vaults = get_key_vault_names()
    assert key_vaults
    for key_vault in key_vaults:
        assert get_key_vault_secret("ucddc-storage-connection-string", key_vault)
        assert get_key_vault_secret("ucddc-db-connection-string", key_vault)
