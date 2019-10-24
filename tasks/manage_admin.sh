#!/usr/bin/env bash
#
# Create and delete an admin account of FreeIPA

KINIT_CMD='/usr/bin/kinit'
KDESTROY_CMD='/usr/bin/kdestroy'
IPA_CMD='/usr/bin/ipa'
ECHO_CMD='/usr/bin/echo'

USED_COMMANDS="$KINIT_CMD $KDESTROY_CMD $IPA_CMD $ECHO_CMD"

#
# display a message about actions on :
#   * Kerberos ticket-granting ticket
#   * IPA object
#
message() {
  local action= status=
  action=$1
  status=$2

  case $action in
    init | destroy)
      if [ $status -eq 0 ]; then
        msg="action '${action}' on Kerberos ticket-granting ticket is done."
      else
        msg="action '${action}' on Kerberos ticket-granting ticket has failed."
      fi
    ;;
    user-add | group-add-member | user-del)
      if [ $status -eq 0 ]; then
        msg="action '${action}' on IPA object is done."
      else
        msg="action '${action}' on IPA object has failed."
      fi
    ;;
    missing-cmd)
      msg="command ${status} missing or can not be executed."
    ;;
    *)
      msg="Unexpected action '${action}' with function message()"
      exit 1
    ;;
  esac

  echo $msg
}

#
# check used commands are installed
#
is_commands_installed() {
  local commands=
  commands=$1

  for cmd in $commands; do
    if [ ! -x $cmd ]; then
      message 'missing-cmd' $cmd
      exit 1
    fi
  done
  return 0
}

#
# Obtain and destroy a Kerberos ticket-granting ticket
#
krb_tgt() {
  local krb_action= op_login= op_pwd= retval=
  krb_action=$1
  op_login=$2
  op_pwd=$3

  case $krb_action in
    init)
      $ECHO_CMD "${op_pwd}" | $KINIT_CMD "${op_login}"
      retval=$?
    ;;
    destroy)
      $KDESTROY_CMD
      retval=$?
    ;;
    *)
      msg="Unexpected krb_action '${krb_action}' with function krb_tgt()"
      exit 1
    ;;
  esac

  message $krb_action $retval

  if [ $retval -ne 0 ]; then
    exit $retval
  else
    return $retval
  fi
}

#
# Add user to FreeIPA
#
ipa_add_user() {
  local login= firstname= lastname= password= retval=
  login=$1
  firstname=$2
  lastname=$3
  password=$4

  $ECHO_CMD "${password}" | $IPA_CMD user-add "${login}" --first="${firstname}" --last="${lastname}"
  retval=$?

  message 'user-add' $retval

  if [ $retval -ne 0 ]; then
    krb_tgt destroy
    exit $retval
  else
    return $retval
  fi
}

#
# Add user to admins group
#
ipa_group_add_admins() {
  local login= retval=
  login=$1

  $IPA_CMD group-add-member admins --users="${login}"
  retval=$?

  message 'group-add-member' $retval

  if [ $retval -ne 0 ]; then
    krb_tgt destroy
    exit $retval
  else
    return $retval
  fi
}

#
# Delete user from FreeIPA
#
ipa_del_user() {
  local login= retval=
  login=$1

  $IPA_CMD user-del "${login}"
  retval=$?

  message 'user-del' $retval

  if [ $retval -ne 0 ]; then
    krb_tgt destroy
    exit $retval
  else
    return $retval
  fi

}

#
# Main
#

is_commands_installed $USED_COMMANDS

krb_tgt init "${PT_operator_login}" "${PT_operator_password}"

case $PT_ensure in
  present)
    ipa_add_user "${PT_login}" "${PT_firstname}" "${PT_lastname}" "${PT_password}"
    ipa_group_add_admins "${PT_login}"
  ;;
  absent)
    ipa_del_user "${PT_login}"
  ;;
  *)
    msg="Unexpected ensure value '${PT_ensure}'"
    exit 1
  ;;
esac

krb_tgt destroy
