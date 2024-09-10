# puppet-freeipa

## 7.0.0 :

** Closed MR **

 * drop support CentOS7, add CentOS9 !145
 * add Gems for vagrant requirement !144
 * allow puppetlabs-stdlib 10.x !143
 * drop Puppet 6 EOL !142
 * use pdk 3.2.0 and Ruby 3.2.0 !141
 * update epel dependency !140 (Patrick Brideau)
 * add allow-zone-overlap option during install !139 (Patrick Brideau)
 * add random-serial-numbers option during install !138 (Patrick Brideau)
 * support for external CA !137 (Patrick Brideau)
 * add ca_subject option !135 (Patrick Brideau)

** Known Issues **

 * change puppet_admin_password does not trigger password update #107

## 6.0.0 :

** Closed Issues **

  * some documentation clean up  #128
  * allow puppetlabs-stdlib < 9, puppet-epel < 5 #127
  * drop Puppet 5, add Puppet 7, use pdk 2.3.0, ruby 2.7.5 #126
  * stahnma-epel package deprecated, move to puppet-epel #123 (Petter Ostergren)
  * Document Update : missing ipa_master_fqdn mandatory parameter #118 (Vijay Kumar)
  * missing enable_hostname management for client #122
  * disable acceptance testing about tasks  #121

** Closed MR **

  * fix ordering of operations !128 (Patrick Brideau)
  * fix missing ' in README.md  !129 (Matteo A)
  * Use Sensitive data type for passwords !130 (Patrick Brideau)

** Known Issues **

  * change puppet_admin_password does not trigger password update #107

## 5.0.2 :

** Closed Issues **

  * doc update , delete with ensure present #116

** Known Issues **

  * change puppet_admin_password does not trigger password update #107

## 5.0.1 :

** Closed Issues **

  * add Ubuntu18.04 as supported OS for clients #113

** Known Issues **

  * change puppet_admin_password does not trigger password update #107

## 5.0.0 :

** Closed Issues **

  * Documentation Update, Adding a Client #109 (Vijay Kumar)
  * remove unused code #108
  * update pdk and remove all should usage by expect #99
  * bolt task should handle when ipa command returns 2 #103
  * doc update, deploy replica fail on network issue message #104
  * some doc cleanup #111
  * redirect stderr to stdout #102
  * missing quote around values in task #101
  * rename task create_admin as manage_admin #97
  * Add task create_admin and remove parameter enable_manage_admins #98

** Known Issues **

  * change puppet_admin_password does not trigger password update #107

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

