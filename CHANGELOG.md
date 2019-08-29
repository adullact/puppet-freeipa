# puppet-freeipa

## 4.3.0 :

** Closed Issues **

  * #93 allow puppetlabs/stdlib 6.x

## 4.2.0 :

** Closed Issues **

  * #88 module is not idempotent when manage admin is enabled but hash of admins is empty

## 4.1.1 :

** Closed Issues **

  * #86 missing CHANGLOG in version 4.1.0

## 4.1.0 :

** Closed Issues **

  * #84 set password for humain admins with enclosing quotes

## 4.0.0 :

** Closed Issues **

  * #75 missing kinit during admin management
  * #76 missing CA on replica
  * #78 remove webui_enable_proxy
  * #79 webui_force_https is not used
  * #80 no_ui_redirect is set to false by default

** Known Issues **

  * #70 change puppet_admin_password does not trigger keytab update

## 3.0.1 :

** Closed Issues **

  * #72 #73 fix README.md typo

** Known Issues **

  * #70 change puppet_admin_password does not trigger keytab update

## 3.0.0 :

** Closed Issues **

  * #63 #68 improve acceptance tests
  * #55 auto-reverse options requires setupdns
  * #53 #62 rename freeipa::config::admin_user in freeipa::config::keytab
  * #61 remove file /etc/ipa/primary 
  * #58 #59 declare privates classes as private
  * #51 #56 #64 #65 #66 #67 update README
  * #66 add contributing guide line
  * #10 #54 ensure administrator account is updated
  * #60 #62 remove k5login and permanant ticket for admin
  * #10 #54 #57 use custom type with Struct datatype

** Known Issues **

  * change puppet_admin_password does not trigger keytab update : #70

## 2.1.0 :

** Closed Issues **

  * remove last string facts by structured facts  : #48, #43
  * use datatype Stdlib::IP::Address              : #47
  * clean up puppetlabs-stdlib requirement        : #44
  * add custom fact giving configured ipa role    : #18

## 2.0.1 :

** Closed Issues **

  * clean up REFERENCES.md                        : #42
  * clean up domain name in tests and README      : #41
  * fix metadata.json                             : #39

## 2.0.0 :

** Closed Issues **

  * pin beaker-vagrant to version 0.5.0           : #36
  * remove selinux from module code               : #32
  * enable acceptance tests                       : #35, #34, #33, #31, #29, #26, #24, #22, #20
  * enable puppet datatype                        : #19
  * add licence file                              : #30
  * configure epel with module stahnma-epel       : #11
  * unit tests with rspec-puppet-facts            : #15
  * use pdk to receive guidance                   : #5
  * enable more rubucop cops                      : #17
  * rename classes from `easy_ipa` to `freeipa`   : #2
  * fix installation of master                    : #3
  * fix installation of replica                   : #4

## 1.6.1 :

** Closed Issues **

  * First release under `adullact` name space     : #1

