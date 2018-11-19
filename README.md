# Freeipa Puppet module

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with Freeipa Puppet Module](#setup)
    * [What Freeipa Puppet module affects](#what-freeipa-pupppet-module-affects)
    * [Setup requirements](#setup-requirements)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Authors](#authors)
6. [License](#license)

## Description

This module will install and configure FreeIPA servers, replicas, and clients.

## Setup

### What Freeipa Pupppet module affects

The module should not affect a previous installation of FreeIPA, it should fail trying.

Below are all items that module can affect:

 * Modifiy /etc/hosts (if `$freeipa::manage_host_entry` true)

 * Install the following packages if not present: autofs, bind-dyndb-ldap, epel-release, sssd-common, sssdtools, ipa-client, ipa-server, ipa-server-dns, kstart, openldap-clients

Installation of Freeipa server will obviously install a ntp server, a DNS server, a LDAP Directory, a Kerberos server, apache, Certmonger and PKI Tomcat.

### Setup Requirements

This module requires :

  * puppetlabs-stdlib

  * stahnma-epel

## Usage

### Example usage:

Creating an IPA master, with the WebUI proxied to `https://localhost:8440`.
```puppet
class {'freeipa':
    ipa_role                    => 'master',
    domain                      => 'example.lan',
    ipa_server_fqdn             => 'ipa-server-1.example.lan',
    admin_password              => 'vagrant123',
    directory_services_password => 'vagrant123',
    install_ipa_server          => true,
    ip_address                  => '10.10.10.35',
    enable_ip_address           => true,
    enable_hostname             => true,
    manage_host_entry           => true,
    install_epel                => true,
    webui_disable_kerberos      => true,
    webui_enable_proxy          => true,
    webui_force_https           => true,
}
```

Adding a replica:
```puppet
class {'::freeipa':
    ipa_role             => 'replica',
    domain               => 'example.lan',
    ipa_server_fqdn      => 'ipa-server-2.example.lan',
    domain_join_password => 'vagrant123',
    install_ipa_server   => true,
    ip_address           => '10.10.10.36',
    enable_ip_address    => true,
    enable_hostname      => true,
    manage_host_entry    => true,
    install_epel         => true,
    ipa_master_fqdn      => 'ipa-server-1.example.lan',
}
```

Adding a client:
```puppet
class {'::freeipa':
ipa_role             => 'client',
domain               => 'example.lan',
domain_join_password => 'vagrant123',
install_epel         => true,
ipa_master_fqdn      => 'ipa-server-1.example.lan',
}
```

### REFERENCE

A full description can be found in `REFERENCE.md`.

## Limitations

IPA masters and replicas works only on Centos >= 7.5

Acceptance tests are done :

 * with puppet5 from puppetlabs packages.

 * master and replica with centos7

 * clients with centos7 and ubuntu1604

Even if puppet 4.10 or IPv6 should work, they are not tested.

## Authors

Original work from Harvard University Information Technology, mainly written by Rob Ruma (https://github.com/huit/puppet-ipa)

then forked by John Puskar (https://github.com/jpuskar/puppet-freeipa)

then forked by ADULLACT (https://gitlab.adullact.net/adullact/puppet-freeipa) currently written by :
  * ADULLACT with Fabien Combernous
  * PHOSPHORE.si with Scott Barthelemy and Bertrand RETIF

## License

    Copyright (C) 2013 Harvard University Information Technology
    Copyright (C) 2018 Association des Développeurs et Utilisateurs de Logiciels Libres
                         pour les Administrations et Colléctivités Territoriales.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

