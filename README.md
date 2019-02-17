# SAMBA
## @edt Dani Cano ASIX M06-ASO Curs 2018-2019

Podeu trobar les imatges docker al Dockerhub de [danicano](https://hub.docker.com/u/danicano/)

### Imatge:

  * **danicano/ldapserver:18samba** Un servidor ldap en funcionament amb els usuaris de xarxa. [Imatge ldapserver](https://hub.docker.com/r/danicano/ldapserver)

  * **hostpam:18samba** host pam amb authenticació ldap. Monta els home dels usuaris samba (cifs) dintre del home de la maquina.
Atenció, per poder realitzar el mount cal que el container es generi amb l'opció **--privileged**. [Imatge hostpam](https://hub.docker.com/r/danicano/hostpam)

  * **danicano/samba:19backend**  servidor samba amb ldap com a backend.
Per posar en funcionament aquest model es necessàri un server ldap+hostpam+samba  [Imatge samba-backend](https://hub.docker.com/r/danicano/samba)

### Arquitectura:
Per a que dins d'un host es muntin els homes dels usuaris unix i ldap via samba necessitem:
  - Una xarxa propia per als conjunt de containers que utilitzem: sambanet.
  - Un servidor ldap amb els usuaris de xarxa: danicano/ldapserver:19smb.
  - Un servidor samba que utilitzi LDAP com a backend. També exporta els homes dels usuaris i
  estarà configurat per tenir usuaris ldap i locals.
  
Configuracio d'acceś al servidor LDAP:

-Per usuaris unix:
  - Samba requereix que els usuaris unix existeixin, poden ser locals o de xarxa via LDAP.
   El servidor samba ha d'estat configurat amb nscd i nslcd per poder accedir al ldap. Per
   poder confirmar i provar que tot està ben configurat, utilitzarem les eines getent  per poder
   llistar tots els usuaris i grups de xarxa.

- Per als homes:
  - Cal que els usuaris tinguin un directori home. Els usuaris locals ja tenen un directori al crear-se,
   cal crear els directoris als usuaris LDAP i assignar-li la propietat i el grup apropiat.
   
- Per als usuari samba:
  - Cal crear els comptes d'usuari samba (han d'existir el mateix usuari unix o ldap).
   Per a cada usuari crearem el seu compte amb l'ordre *smbpasswd* i assignant-li el passwd de samba.
   Es desarà en la base de dades ldap.

- El hostpam:
   - Necessitarem un hostpam ben configurat per tal d'accedir als usuaris locals i als LDAP i utilitzant 
   pam_mount.so per tal de muntar dins del home dels usuaris un home de xarxa via samba. Necessitarem 
   configurar el pam_mount.conf.xml que està a la ruta: */etc/security/pam_mount.conf.xml* per muntar el 
   recurs samba dels homes.

### Configuració SAMBA del ldapsamba:

Per tal de tenir la configuració del samba amb LDAP com a backend correctament, haurem de configurar i assegurar-nos:
	
  - Incorporar el paquet smbldap-tools al servidor samba.
  - Configurar correctament el servidor samba amb LDAP com a backend.
  - Per configurar-ho correctament haurem d'editar i configurar els fitxers:.
     - /etc/smbldap-tools/smbldap.conf* configurar el backend.
     - /etc/smbldap_bind.conf* configurar el rootDN i passwd per administrar ldap.
  - Per veure que estigui tot ben configurat, utilitzarem l'ordre *net getlocalsid* i
  - net getdomainsid**.
  - Desarem la informació fent el **smbldap-populate**.
  - Per poder verificar que el populate s'ha fer correctarem farem *ldapsearch -x -LLL*.
  - Per observar els usuaris root i nobody afegits farem l'ordre *pdbedit -L*.



### Execució:


```
docker network create netsamba

docker run --rm --name server --hostname server --network netsamba -d danicano/ldapserver:18samba

docker run --rm --name host --hostname host --network netsamba --privileged -it danicano/hostpam:18samba

docker run --rm --name samba --hostname samba --network netsamba --privileged -it danicano/samba:19backend

```


### Configuració de fitxers de samba:

/etc/samba/smb.conf
```
[global]
        workgroup = MYGROUP
        server string = Samba Server Version %v
        log file = /var/log/samba/log.%m
        max log size = 50
        security = user
        passdb backend = ldapsam:ldap://server
          ldap suffix = dc=edt,dc=org
          ldap user suffix = ou=usuaris
          ldap group suffix = ou=grups
          ldap machine suffix = ou=hosts
          ldap idmap suffix = ou=domains
          ldap admin dn = cn=Manager,dc=edt,dc=org
          ldap ssl = no
          ldap passwd sync = yes
        load printers = yes
        cups options = raw
[homes]
        comment = Home Directories
        browseable = no
        writable = yes
;       valid users = %S
;       valid users = MYDOMAIN\%S
[public]
        comment = Share de contingut public
        path = /var/lib/samba/public
        public = yes
        browseable = yes
        writable = yes
        printable = no
        guest ok = yes
[privat]
        comment = Share d'accés privat
        path = /var/lib/samba/privat
        public = no
        browseable = no
        writable = yes
        printable = no
        guest ok = yes
```
/etc/smbldap-tools/smbldap.conf
- En aquest fitxer de configuració em d'editar aquests apartats i posar:
  - slaveLDAP="ldap://server/"
  - masterLDAP="ldap://server/"
  - ldapTLS="0"
  - suffix="dc=edt,dc=org"
  - userdn="ou=usuaris,${suffix}"
  - computersdn="ou=hosts,${suffix}"
  - groupsdn="oi=grups,${suffix}"
  - idmapdn="ou=domains,${suffix}"
```
# $Id$
#
# smbldap-tools.conf : Q & D configuration file for smbldap-tools

#  This code was developped by IDEALX (http://IDEALX.org/) and
#  contributors (their names can be found in the CONTRIBUTORS file).
#
#                 Copyright (C) 2001-2002 IDEALX
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation; either version 2
#  of the License, or (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307,
#  USA.

#  Purpose :
#       . be the configuration file for all smbldap-tools scripts

##############################################################################
#
# General Configuration
#
##############################################################################

# Put your own SID. To obtain this number do: "net getlocalsid".
# If not defined, parameter is taking from "net getlocalsid" return
SID="S-1-5-21-4115538459-1596765595-1740180182"

# Domain name the Samba server is in charged.
# If not defined, parameter is taking from smb.conf configuration file
# Ex: sambaDomain="IDEALX-NT"
#sambaDomain="DOMSMB"

##############################################################################
#
# LDAP Configuration
#
##############################################################################

# Notes: to use to dual ldap servers backend for Samba, you must patch
# Samba with the dual-head patch from IDEALX. If not using this patch
# just use the same server for slaveLDAP and masterLDAP.
# Those two servers declarations can also be used when you have
# . one master LDAP server where all writing operations must be done
# . one slave LDAP server where all reading operations must be done
#   (typically a replication directory)

# Slave LDAP server URI
# Ex: slaveLDAP=ldap://slave.ldap.example.com/
# If not defined, parameter is set to "ldap://127.0.0.1/"
slaveLDAP="ldap://server/"

# Master LDAP server URI: needed for write operations
# Ex: masterLDAP=ldap://master.ldap.example.com/
# If not defined, parameter is set to "ldap://127.0.0.1/"
masterLDAP="ldap://server/"

# Use TLS for LDAP
# If set to 1, this option will use start_tls for connection
# (you must also used the LDAP URI "ldap://...", not "ldaps://...")
# If not defined, parameter is set to "0"
ldapTLS="0"

# How to verify the server's certificate (none, optional or require)
# see "man Net::LDAP" in start_tls section for more details
verify="require"

# CA certificate
# see "man Net::LDAP" in start_tls section for more details
cafile="/etc/pki/tls/certs/ldapserverca.pem"

# certificate to use to connect to the ldap server
# see "man Net::LDAP" in start_tls section for more details
clientcert="/etc/pki/tls/certs/ldapclient.pem"

# key certificate to use to connect to the ldap server
# see "man Net::LDAP" in start_tls section for more details
clientkey="/etc/pki/tls/certs/ldapclientkey.pem"

# LDAP Suffix
# Ex: suffix=dc=IDEALX,dc=ORG
suffix="dc=edt,dc=org"
# Where are stored Users
# Ex: usersdn="ou=Users,dc=IDEALX,dc=ORG"
# Warning: if 'suffix' is not set here, you must set the full dn for usersdn
usersdn="ou=usuaris,${suffix}"

# Where are stored Computers
# Ex: computersdn="ou=Computers,dc=IDEALX,dc=ORG"
# Warning: if 'suffix' is not set here, you must set the full dn for computersdn
computersdn="ou=hosts,${suffix}"

# Where are stored Groups
# Ex: groupsdn="ou=Groups,dc=IDEALX,dc=ORG"
# Warning: if 'suffix' is not set here, you must set the full dn for groupsdn
groupsdn="ou=grups,${suffix}"

# Where are stored Idmap entries (used if samba is a domain member server)
# Ex: idmapdn="ou=Idmap,dc=IDEALX,dc=ORG"
# Warning: if 'suffix' is not set here, you must set the full dn for idmapdn
idmapdn="ou=domains,${suffix}"

# Where to store next uidNumber and gidNumber available for new users and groups
# If not defined, entries are stored in sambaDomainName object.
# Ex: sambaUnixIdPooldn="sambaDomainName=${sambaDomain},${suffix}"
# Ex: sambaUnixIdPooldn="cn=NextFreeUnixId,${suffix}"
sambaUnixIdPooldn="sambaDomainName=${sambaDomain},${suffix}"

# Default scope Used
scope="sub"

# Unix password hash scheme (CRYPT, MD5, SMD5, SSHA, SHA, CLEARTEXT)
# If set to "exop", use LDAPv3 Password Modify (RFC 3062) extended operation.
password_hash="SSHA"

# if password_hash is set to CRYPT, you may set a salt format.
# default is "%s", but many systems will generate MD5 hashed
# passwords if you use "$1$%.8s". This parameter is optional!
password_crypt_salt_format="%s"
```

/etc/smbldap-tools/smbldap_bind.conf

```
# $Id$
#
############################
# Credential Configuration #
############################
# Notes: you can specify two differents configuration if you use a
# master ldap for writing access and a slave ldap server for reading access
# By default, we will use the same DN (so it will work for standard Samba
# release)
slaveDN="cn=Manager,dc=edt,dc=org"
slavePw="secret"
masterDN="cn=Manager,dc=edt,dc=org"
masterPw="secret"
~              
```
- Proves de la configuració

```
[root@samba docker]# net getlocalsid
SID for domain SAMBA is: S-1-5-21-4115538459-1596765595-1740180182

[root@samba docker]# pdbedit -L
pau:5000:Pau Pou
pere:5001:Pere Pou
anna:5002:Anna Pou
carles:11009:carles puigdemon
francisco:11010:francisco franco bahamonde
vladimir:11011:vladimir putin
root:0:root
nobody:99:Nobody
lila:1000:


[root@samba docker]# ldapsearch -x -LLL 
...
dn: cn=Print Operators,ou=grups,dc=edt,dc=org
objectClass: top
objectClass: posixGroup
objectClass: sambaGroupMapping
cn: Print Operators
gidNumber: 550
description: Netbios Domain Print Operators
sambaSID: S-1-5-32-550
sambaGroupType: 4
displayName: Print Operators

dn: cn=Backup Operators,ou=grups,dc=edt,dc=org
objectClass: top
objectClass: posixGroup
objectClass: sambaGroupMapping
cn: Backup Operators
gidNumber: 551
description: Netbios Domain Members can bypass file security to back up files
sambaSID: S-1-5-32-551
sambaGroupType: 4
displayName: Backup Operators

dn: cn=Replicators,ou=grups,dc=edt,dc=org
objectClass: top
objectClass: posixGroup
objectClass: sambaGroupMapping
cn: Replicators
gidNumber: 552
description: Netbios Domain Supports file replication in a sambaDomainName
sambaSID: S-1-5-32-552
sambaGroupType: 4
displayName: Replicators

```




