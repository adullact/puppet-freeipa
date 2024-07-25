# Freeipa Puppet module

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with Freeipa Puppet Module](#setup)
    * [What Freeipa Puppet module affects](#what-freeipa-pupppet-module-affects)
    * [Setup requirements](#setup-requirements)
    * [How does the module work](#how-does-the-module-work)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Release Notes](#development)


## Description

This module will install and configure FreeIPA servers, replicas, and clients.

## Setup

### What Freeipa Pupppet module affects

The module should not affect a previous installation of FreeIPA, it should fail trying.

Below are all items that module can affect:

 * Modifiy /etc/hosts (if `$freeipa::manage_host_entry` true)

 * Install the following packages if not present: autofs, bind-dyndb-ldap, epel-release, sssd-common, sssdtools, ipa-client, ipa-server, ipa-server-dns, openldap-clients

Installation of Freeipa server will obviously install a ntp server, a DNS server, a LDAP Directory, a Kerberos server, apache, Certmonger and PKI Tomcat.

### Setup Requirements

Requirements are given in [metadata.json](https://gitlab.adullact.net/adullact/puppet-freeipa/blob/master/metadata.json)file.

### How does the module work.

Usually with a module, the desired state is described. If a value of parameter is changed, then during the next puppet run the node is modified to reach the desired state.
But, the module is more an idempotent installer of FreeIPA. So changing a value of parameter does not change the value on the node.

## Usage

### Examples of usage:

Deploy an IPA master :

```puppet
class {'freeipa':
    ipa_role                    => 'master',
    domain                      => 'example.lan',
    ipa_server_fqdn             => 'ipa-server-1.example.lan',
    puppet_admin_password       => 'secret_abc',
    directory_services_password => 'secret_dir',
    install_ipa_server          => true,
    ip_address                  => '10.10.10.35',
    enable_ip_address           => true,
    enable_hostname             => true,
    manage_host_entry           => true,
    install_epel                => true,
    ipa_master_fqdn             => 'ipa-server-1.example.lan',
}
```

Add a replica:

The initial password of `admin` user have expiration set to 3 months. So, if the expiration is not handled and a replica is deployed after this limit, it is impossible to get kerberos TGT. And so the replica deployment fail (Note: the installer send an error message about network issue).

```puppet
class {'freeipa':
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

Add a client:

```puppet
class {'freeipa':
    ipa_role                    => 'client',
    domain                      => 'example.lan',
    password_usedto_joindomain  => 'vagrant123',
    install_epel                => true,
    directory_services_password => 'vagrant123',
    ipa_master_fqdn             => 'ipa.example.lan',
    puppet_admin_password       => 'vagrant123',
    ip_address                  => $ipaddress,
    ipa_master_fqdn             => 'ipa-server-1.example.lan',
}
```

Create an admin account with task :

`bolt task run freeipa::manage_admin operator_login='mylogin' operator_password='mysecret' ensure='present' login='jaimarre' firstname='Jean' lastname='Aimarre' password='newadminsecret' --nodes <ipamaster> --modulepath ~/modules`

Delete an admin account with task :

`bolt task run freeipa::manage_admin operator_login='mylogin' operator_password='mysecret' ensure='absent' login='jaimarre' --nodes <ipamaster> --modulepath ~/modules`

Add IPA server that is SubCA of a Microsoft PKI :

```puppet
class {'freeipa':
    # Same configs as master, but add the following:
    ca_subject             => 'CN=Secondary Certificate Authority,O=EXAMPLE.LAN",
    install_external_ca    => true,
    external_ca_type_ms_cs => true,
    external_ca_profile    => [
      'OID:MAJOR:MINOR'
    ],
}
```

Where `OID:MAJOR:MINOR` might be a template created in the AD.

The FreeIPA server will be partially created.  The certificate signing request
will be created in `/root/ipa.csr` that will have to be signed by the authority.

Then, a manual action is required to complete the installation:

```bash
ipa-server-install \
    --external-cert-file /root/ipa.crt \
    --external-cert-file /root/ca.crt
```

See [this blog post](https://frasertweedale.github.io/blog-redhat/posts/2017-08-14-ad-cs.html)
about this feature.

### REFERENCE

A full description can be found in [REFERENCE.md](https://gitlab.adullact.net/adullact/puppet-freeipa/blob/master/REFERENCE.md).

## Limitations

This module will not work well if managed passwords contain `'` or `\`. They must be banned.

Acceptance tests are done :

 * with last available versions Puppet 7 from puppetlabs packages All In One.

 * with CentOS 9 for FreeIPA master and replica nodes

With follwoing issue not fixed the acceptance tests about tasks are disabled :
https://github.com/puppetlabs/beaker-task_helper/issues/47
PR : https://github.com/puppetlabs/beaker-task_helper/pull/48

## Development

Home at URL https://gitlab.adullact.net/adullact/puppet-freeipa

Issues and MR are welcome. [CONTRIBUTING.md](https://gitlab.adullact.net/adullact/puppet-freeipa/blob/master/CONTRIBUTING.md) gives some guidance about contributing process.
If you follow these contributing guidelines your patch will likely make it into a release a little more quickly.

### Release Notes

Details in `CHANGELOG.md`. Key points :

 * release 1.6.1 : the fist release under `adullact` name space. nothing special.

 * releases 2.x : use code ready for Puppet 4.10 and 5.x, uses pdk as guidance, enable acceptance tests, rename classes from `easy_ipa` to `freeipa`.

 * releases 3.x : use public and private classes, enable Puppet 6 tests, drop Puppet 4 tests, refactor module to permit management of administrator accounts.

 * releases 4.x : some cleanup of unused code, updates depencies and install CA on replica by default.

 * releases 5.x : managment of admin accounts are moved from manifests to tasks.

### Contributors

Original work from Harvard University Information Technology, mainly written by Rob Ruma (https://github.com/huit/puppet-ipa)

then forked by John Puskar (https://github.com/jpuskar/puppet-freeipa)

then forked by ADULLACT (https://gitlab.adullact.net/adullact/puppet-freeipa) written by :
  * ADULLACT with Fabien Combernous
  * PHOSPHORE.si with Scott Barthelemy and Bertrand RETIF

### License

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

