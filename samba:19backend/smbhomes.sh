 q#! /bin/bash
# @edt ASIX M06 2018-2019
# instal.lacio
# -------------------------------------
mkdir -p /tmp/home/pere
mkdir -p /tmp/home/anna
mkdir -p /tmp/home/pau
mkdir /tmp/home/admin
cp /opt/docker/README.md /tmp/home/pere
cp /opt/docker/README.md /tmp/home/anna
cp /opt/docker/README.md /tmp/home/pau
cp /opt/docker/README.md /tmp/home/admin/README.admin
chown -R pere.users /tmp/home/pere
chown -R anna.users /tmp/home/anna
chown -R pau.users /tmp/home/pau
cp /opt/docker/smbldap.conf /etc/smbldap-tools/.
cp /opt/docker/smbldap_bind.conf /etc/smbldap-tools/.
smbpasswd -w secret
echo -e "secret\nsecret" | smbldap-populate -i /opt/docker/populate.ldif
