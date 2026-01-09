# SUSE Multi-Linux Manager 5.1 Proxy autoinstallation templates

This action will re-install the proxy from scratch, meaning no cache will be preserved.


You can install it using AutoYaST:

1. Create an autoinstallation tree as outlined in the product documentation

2. Create an AutoYaST profile. You can use these examples as a starting point:
    * `MLM_Proxy-51-SLES-Install.xml` for a new installation of Multi-Linux Manager 5.1 Proxy.
    * `MLM_RBS-51-SLES-Upgrade.xml` for an upgrade of legacy Retail Branch Server 4.3 to Multi-Linux Manager 5.1 Retail Branch Server.

    * Ensure you change the `<user_password>` to match your own settings.
    * Create autoinstallation profile with adapted autoyast XML and based on autoinstallation distribution created in previous step.
    * Ensure distro label created in step 1 is set in the variable `distrotree`

## Profile variables

* org='organization_id'
* distrotree='autoinstallation_distribution_label'
* channel_prefix='clm_channel_prefix' or blank for SCC channels
* registration_key='activation_key_for_post_upgrade'

## Proxy configuration

After the re-instalation finished, Users just need to generated the proxy configuration and deploy it, as outlined in the product documentation.

Minions connected through the 4.3 proxy should be able to recover their connection to the MLM server using the newly configured proxy.


# Profile Source

This auto-installation profile example was created base on Don profiles: https://github.com/dvosburg/manager-build-profiles/blob/master/AutoYaST/SLES-15-SP6-installation/sles15sp6-from-scratch-clm-20250210.xml



