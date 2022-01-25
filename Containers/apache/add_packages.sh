#!/bin/bash
set -e

zypper --non-interactive --gpg-auto-import-keys ref

zypper --non-interactive in aaa_base aaa_base-extras net-tools timezone python apache2 apache2-prefork
