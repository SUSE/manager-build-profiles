# SUSE Multi-Linux Manager 5.1+ Profiles

This directory contains AutoYaST profiles for SUSE Multi-Linux Manager version 5.1 and newer.
These profiles use the new, re-branded client tools channels.

**Note:** These profiles are NOT compatible with SUSE Manager 5.0 or older.

Each subdirectory contains a different AutoYaST profile with a description.

Check which variables each script uses before using it.

When the uploaded profile requires variables to be set, navigate to `Systems > Autoinstallation > Profiles`, select the profile to edit, and navigate to the `Variables` tab.
Specify the required variables, using this format:

```
<key>=<value>
```

For all installations, the `$redhat_management_server` variable will be set automatically and does not need to be defined.

These examples use the `$distrotree` variable, which must be defined as the distribution label used with this profile.
Set the variable to the same value that you selected in `Autoinstall Tree` in the `Details` tab.

Example:

```
distrotree=sles_sap15sp7-x86_64
```

when the distribution label is `sles_sap15sp7-x86_64`.

To report a bug or request a change, please use [Bugzilla](https://bugzilla.suse.com) or open a GitHub issue.
