# puppet-freeipa

## 3.0.0 :

** Closed Issues **

  * improve acceptance tests                      : #68, #63, 
  * auto-reverse options requires setupdns        : #55
  * rename freeipa::config::admin_user in freeipa::config::keytab : #53, #62
  * remove file /etc/ipa/primary                  : #61
  * declare privates classes as private           : #58, #59
  * update README                                 : #51, #56, #64, #65, #66, #67
  * add contributing guide line                   : #66
  * ensure administrator account is updated       : #10, #54
  * remove k5login and permanant ticket for admin : #60, #62
  * use custom type with Struct datatype          : #10, #54, #57

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

