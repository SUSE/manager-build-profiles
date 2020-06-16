# OS Image build profiles

This directory contains build profiles for Kiwi image build system and can be used in SUSE Manager image profile as OS Image build type.

When using this repository as a source, do not forget to add a valid sub directory name to the URL. Examples:

* SLE11 templates
  * POS_Image-JeOS6-SLE11 -> https://github.com/SUSE/manager-build-profiles#master:OSImage/POS_Image-JeOS6-SLE11
  * POS_Image-Graphical6-SLE11 -> https://github.com/SUSE/manager-build-profiles#master:OSImage/POS_Image-Graphical6-SLE11

* SLE12 templates
  * POS_Image-JeOS6 -> https://github.com/SUSE/manager-build-profiles#master:OSImage/POS_Image-JeOS6
  * POS_Image-Graphical6 -> https://github.com/SUSE/manager-build-profiles#master:OSImage/POS_Image-Graphical6

* SLE15 templates
  * POS_Image-JeOS7 -> https://github.com/SUSE/manager-build-profiles#master:OSImage/POS_Image-JeOS7
  * POS_Image-Graphical7 -> https://github.com/SUSE/manager-build-profiles#master:OSImage/POS_Image-Graphical7


Make sure build hosts use the same base OS version as the templates you are trying to build. SLE11 templates are meant to be build on SLE11 build hosts, SLE12 templates on SLE12 build hosts.

## Image deployment

SLE11 and SLE12 POS images are meant to be deployed using kiwi-desc-saltboot Saltboot mechanism which is part of SUSE Manager / Uyuni for Retail. They are not meant to be deployed directly to the harddrive.

SLE15 POS images are meant to be deployed using dracuct-saltboot Saltboot mechanism which is part of the SUSE Manager / Uyuni for Retail. They are not meant to be deployed directly to the harddrive.

## Requests changes, bug reports

POS prefixed image templates are mirrored from internal build sources.

To report a bug or request a change, please use [Bugzilla](https://bugzilla.suse.com) or open a GitHub issue.
