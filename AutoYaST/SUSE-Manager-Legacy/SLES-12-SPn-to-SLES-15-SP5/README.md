This autoyast file has been used to upgrade from SLES12SP5 to SLES15SP5.
The SLES12 system has only the mandatory repositories (modules) activated.

Please do not change the kernel option according to the SUMA documentation.
Disabling the self update feature in combination with self_update=0 pt.options=self_update and using a distribution based on GM (first official release) media DVD, will delete the installation rather then upgrading it.

The autoupgrade option requires by default an registration server, however a SUMA server does not provided this expected functionality. Therefore the registration has to be turned off in the automation process. 

If the environment requires an HTTPS secure connection rather then HTTP for the repositories URL. The booted OS witch performs the upgrade needs to have the CA of the SUMA server imported before contacting the SUMA server.
This is done in the pre-script section.

Starting with SLES15SP5 there is no python2 module available anymore, only python3 is offered via a dedicated supported modules.
This needs to be consider during the upgrade. 

It is possible to removed orphan packages during the upgrade, this can be done in the software section of the autoyast file during the upgrade.
Another solution is to list the Non Compliant packages e.g via the WEB UI and delete these after the system has been upgraded and show up as a SLES15SP system.

