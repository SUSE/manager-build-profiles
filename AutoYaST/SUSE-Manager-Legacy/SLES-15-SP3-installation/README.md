# SLES 15 SP3

Use these scripts as a base for a SLE15 SP3 installations. The system register at SUSE Manager using salt.

- [sles15-sp3-autoyast.xml](sles15-sp3-autoyast.xml)
- [sle_sap15-sp3-autoyast.xml](sle_sap15-sp3-autoyast.xml)

When using newer SUSE Manager/Uyuni versions (4.2+), you will need to replace the `$distrotree` variable in the AutoYaST profile with your kickstartable distribution tree name.

It might also be possible that **snippets** are not recognized by the booted installer. In this case, create a bootstrap script:

```shell
# mgr-bootstrap
```

Also, add the following section to the AutoYaST profile:

```xml
  <scripts>
    <init-scripts config:type="list">
      <script>
        <location>http://$redhat_management_server/pub/bootstrap/bootstrap.sh</location>
      </script>
    </init-scripts>
  </scripts>
```
