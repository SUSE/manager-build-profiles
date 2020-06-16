A SUSE Manager Proxy is a SLE client with a special role.
You can install it using AutoYaST:

1. Create an autoinstallation tree as outlined in the product documentation.

    * Unpack a Unified Installer DVD1.
    * Use `SLE-Product-SUSE-Manager-Proxy-4.1-Pool for x86_64` as the base channel.
    * Make sure the `SUSE Manager Proxy 4.1 x86_64` product is completely mirrored.

2. Create an AutoYaST profile. You can use this example as a starting point.
Ensure you change the `<password>` to match your own settings.
