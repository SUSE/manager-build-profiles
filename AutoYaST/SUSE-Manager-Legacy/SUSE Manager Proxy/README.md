SUSE Manager Proxy autoinstallation templates

You can install it using AutoYaST:

1. Create an autoinstallation tree as outlined in the [product documentation](https://documentation.suse.com/suma/4.3/en/suse-manager/client-configuration/autoinst-distributions.html).

    * Unpack a Unified Installer DVD1 or install `tftpboot-installation-SLE-15-SP4-x86_64` package.
    * Create autoinstallation distribution providing path to the installation tree prepared in previous step.
    * Use `SLE-Product-SUSE-Manager-Proxy-4.3-Pool for x86_64` as the base channel.
    * Make sure the `SUSE Manager Proxy 4.3 x86_64` product is completely mirrored.
    * Enter `useonlinerepo insecure=1` as kernel options.

2. Create an AutoYaST profile. You can use this example as a starting point.

    * Start with template provided in this directory.
    * Ensure you change the `<user_password>` to match your own settings.
    * Ensure distro label created in step 1 matches path suffix of add on URL in autoyast XML (by default `proxy`).
    * Create autoinstallation profile with adapted autoyast XML and based on autoinstallation distribution created in previous step.

