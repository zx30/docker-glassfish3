#!/bin/bash

set -e

main () {
   configure
   msg "---> Starting Glassfish server"
   asadmin start-domain -v
}

msg () {
   echo -e "\033[1;33m${1}\033[0m"
}

# Prepare jvm-options mega-string
prepare () {
   echo "${1}" \
      | grep -e '^-[^ ]*$' \
      | sed -e 's/:/\\:/g' \
      | sed -e ':a;N;$!ba;s/\n/:/g'
}

configure () {
   if [ ! -f /.glassfish_configured ]; then
      msg "---> Configure Glassfish server"
      mkdir -p "${GLASSFISH_CONFIG}"

      if [ -f ${GLASSFISH_CONFIG}/setup.sh ]; then
         msg "---> Exec ${GLASSFISH_CONFIG}/setup.sh"
         ${GLASSFISH_CONFIG}/setup.sh
      fi

      msg "---> Start domain"
      asadmin start-domain

      # Modify password
      PASS=${GLASSFISH_PASSWORD:-$(pwgen -s 12 1)}
      GFPWD="/.gfpwd"
      ADMIN="--user=admin --passwordfile=${GFPWD}"
      echo "AS_ADMIN_PASSWORD=" > $GFPWD
      echo "AS_ADMIN_NEWPASSWORD=\"${PASS}\"" >> $GFPWD
      msg "---> Apply password"
      asadmin $ADMIN change-admin-password --domain_name domain1

      msg ""
      msg ""
      msg "╔══════════════════════════════════════════════════════════════════╗"
      msg "║                                                                  ║"
      msg "$(printf "║%+33s%-33s║" "admin:" "${PASS}")"
      msg "║                                                                  ║"
      msg "╚══════════════════════════════════════════════════════════════════╝"
      msg ""
      msg ""

      # Enable secure admin login
      echo "AS_ADMIN_PASSWORD=\"${PASS}\"" > $GFPWD
      msg "---> Enable secure admin"
      asadmin $ADMIN enable-secure-admin

      # Setup jvm-options
      OPTFILE="${GLASSFISH_CONFIG}/.jvm-options"
      DEFAULT=$(asadmin $ADMIN list-jvm-options | grep -e '^-[^ ]*$')
      if [ ! -f ${OPTFILE} ]; then
         msg "---> Create ${OPTFILE}"
         echo "${DEFAULT}" > "${OPTFILE}"
      fi
      OPTIONS=$(cat "${OPTFILE}")
      msg "---> Delete default jvm-options"
      asadmin $ADMIN delete-jvm-options "$(prepare "${DEFAULT}")"
      msg "---> Apply ${OPTFILE}"
      asadmin $ADMIN create-jvm-options "$(prepare "${OPTIONS}")"

      # Import resources
      for f in ${GLASSFISH_CONFIG}/*.xml; do
         if [ -f $f ]; then
            msg "---> Import ${f}"
            asadmin $ADMIN add-resources "${f}"
         fi
      done

      # Deploy *.war apps first
      for f in ${GLASSFISH_CONFIG}/*.war; do
         if [ -f $f ]; then
            msg "---> Deploy ${f}"
            asadmin $ADMIN deploy "${f}"
         fi
      done

      # Deploy *.ear apps
      for f in ${GLASSFISH_CONFIG}/*.ear; do
         if [ -f $f ]; then
            msg "---> Deploy ${f}"
            asadmin $ADMIN deploy "${f}"
         fi
      done
      
      msg "---> Stop domain"
      asadmin stop-domain
      touch /.glassfish_configured
      msg "---> Glassfish configured!"
   else
      msg "--> Glassfish already configured!"
   fi
}

main
                                                                                                    