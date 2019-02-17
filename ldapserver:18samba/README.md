# ldapserver:18samba

## @edt M06-ASIX 2018-2019

Servidor ldap amb edt.org, amb usuaris i grups, RDN=uid
Exercici per practicar tots els conceptes treballats **(ldap + samba + pam)**.

S'han afegit els grups que són posixGroup i identifiquen als membres del group amb l'atribut memberUid.

### Imatge:

  * **danicano/ldapserver:18samba** Un servidor ldap en funcionament amb els usuaris de xarxa. [Imatge ldapserver](https://hub.docker.com/r/danicano/ldapserver)

#### Arxius importants

  * **samba.schema**: arxiu tipus schema de LDAP amb les definicions necessàries per a emmagatzemar l'informació de SAMBA a la base de dades LDAP.

  * **slapd.conf**: l'arxiu de configuració del daemon slapd. Ens hem d'assegurar que conté un include a l'arxiu samba.schema.
  
#### Exemple de dades .ldif
Entitat **grups** per acollir els grups:
```
dn: ou=grups,dc=edt,dc=org
ou: groups
description: Container per a grups
objectclass: organizationalunit
```

Entitat grup usuaris:
```
dn: cn=usuaris,ou=groups,dc=edt,dc=org
description: Container per usuaris del sistema linux
objectclass: top
objectclass: posixGroup
gidNumber: 10000
cn: usuaris
memberUid: pau
memberUid: pere
memberUid: anna
memberUid: marta
memberUid: jordi
memberUid: admin
memberUid: user01
memberUid: user02
memberUid: user03
memberUid: user04
memberUid: user05
memberUid: user06
memberUid: user07
memberUid: user08
memberUid: user09
memberUid: user10
```

Entitat grup clients:
```
dn: cn=clients,ou=groups,dc=edt,dc=org
description: Container per clients del sistema linux
objectclass: top
objectclass: posixGroup
gidNumber: 10001
cn: clients
memberUid: mao
memberUid: ho
memberUid: hiro
memberUid: nelson
memberUid: robert
memberUid: ali
memberUid: konrad
memberUid: humphrey
memberUid: carles
memberUid: francisco
memberUid: vladimir
memberUid: jorge
```

#### Execució

```
$ docker run --rm --name server -h server --net ldapnet -d danicano/ldapserver:18samba
```

