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

This module requires :

  * `puppetlabs-stdlib`

  * `stahnma-epel`

Versions are given in `metadata.json` file.

### How does the module work.

Usually with a module, the desired state is described. If a value of parameter is changed, then during the next puppet run the node is modified to reach the desired state.
The version 3.x is a starting work to reach the target. But, the module is more an idempotent installer of FreeIPA.

So, to ensure that desired state described in code is applied on the node, puppet needs to login to kerberos. Puppet uses a fixed account `admin` to do this. It is possible to set the password of this account with parameter `freeipa::puppet_admin_password`. If `freeipa::enable_manage_admins` is true, the accounts of humans administrators are managed with hash `freeipa::humanadmins`. If you modify `freeipa::humanadmins`, next puppet run will take care to update the admins users on master node. The replication will to the job on replicas.

## Usage

### Example usage:

Creating an IPA master, with the WebUI proxied to `https://localhost:8440` and two admin accounts `jdupond` and `mgonzales`.
```puppet
class {'freeipa':
    ipa_role                    => 'master',
    domain                      => 'example.lan',
    ipa_server_fqdn             => 'ipa-server-1.example.lan',
    puppet_admin_password       => 'secret_abc,
    directory_services_password => 'secret_dir',
    install_ipa_server          => true,
    ip_address                  => '10.10.10.35',
    enable_ip_address           => true,
    enable_hostname             => true,
    manage_host_entry           => true,
    install_epel                => true,
    humanadmins                 => {
      jdupond => {
        ensure => 'present',
        password => 'secret123',
      },
      mgonzales => {
        ensure => 'present',
        password => 'secret456',
      },
      hzimmer => {
        ensure => 'absent',
      },
    },
}
```

Adding a replica:
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

Adding a client:
```puppet
class {'freeipa':
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

This module will not work well if managed passwords contain `'` or `\`. They must be banned.

Acceptance tests are done :

 * with last available versions of Puppet 5 and Puppet 6 from puppetlabs packages AIO (facter 3 is shiped).

 * with CentOS 7 for FreeIPA master and replica nodes. IPA masters and replicas works only on Centos >= 7.5.

 * with CentOS 7 and Ubuntu 16.06 for FreeIPA clients .

Puppet4 is EOL since 2019-01-01. Even if puppet 4.10 should work, it is not tested.

## Development

Home at URL https://gitlab.adullact.net/adullact/puppet-freeipa

Issues and MR are welcome. `CONTRIBUTING.md` gives some guidance about contributing process. 
If you follow these contributing guidelines your patch will likely make it into a release a little more quickly.

### Release Notes

Details in `CHANGELOG.md`. Key points :

 * release 1.6.1 : the fist release under `adullact` name space. nothing special.

 * releases 2.x : use code ready for Puppet 4.10 and 5.x, uses pdk as guidance, enable acceptance tests, rename classes from `easy_ipa` to `freeipa`.

 * releases 3.x : use public and private classes, enable Puppet 6 tests, drop Puppet 4 tests, refactor module to permit management of administrator accounts.

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

