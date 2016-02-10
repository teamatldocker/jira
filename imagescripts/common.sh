urldecode() {
    local data=${1//+/ }
    printf '%b' "${data//%/\x}"
}

parse_url() {
  local prefix=DATABASE
  [ -n "$2" ] && prefix=$2
  # extract the protocol
  local proto="`echo $1 | grep '://' | sed -e's,^\(.*://\).*,\1,g'`"
  local scheme="`echo $proto | sed -e 's,^\(.*\)://,\1,g'`"
  # remove the protocol
  local url=`echo $1 | sed -e s,$proto,,g`

  # extract the user and password (if any)
  local userpass="`echo $url | grep @ | cut -d@ -f1`"
  local pass=`echo $userpass | grep : | cut -d: -f2`
  if [ -n "$pass" ]; then
    local user=`echo $userpass | grep : | cut -d: -f1`
  else
    local user=$userpass
  fi

  # extract the host -- updated
  local hostport=`echo $url | sed -e s,$userpass@,,g | cut -d/ -f1`
  local port=`echo $hostport | grep : | cut -d: -f2`
  if [ -n "$port" ]; then
    local host=`echo $hostport | grep : | cut -d: -f1`
  else
    local host=$hostport
  fi

  # extract the path (if any)
  local full_path="`echo $url | grep / | cut -d/ -f2-`"
  local path="`echo $full_path | cut -d? -f1`"
  local query="`echo $full_path | grep ? | cut -d? -f2`"
  local -i rc=0

  [ -n "$proto" ] && eval "export ${prefix}_SCHEME=\"$scheme\"" || rc=$?
  [ -n "$user" ] && eval "export ${prefix}_USER=\"`urldecode $user`\"" || rc=$?
  [ -n "$pass" ] && eval "export ${prefix}_PASSWORD=\"`urldecode $pass`\"" || rc=$?
  [ -n "$host" ] && eval "export ${prefix}_HOST=\"`urldecode $host`\"" || rc=$?
  [ -n "$port" ] && eval "export ${prefix}_PORT=\"`urldecode $port`\"" || rc=$?
  [ -n "$path" ] && eval "export ${prefix}_NAME=\"`urldecode $path`\"" || rc=$?
  [ -n "$query" ] && eval "export ${prefix}_QUERY=\"$query\"" || rc=$?
}

read_var() {
  eval "echo \$$1_$2"
}

extract_database_url() {
  local url="$1"
  local prefix="$2"
  local mysql_install="$3"

  eval "unset ${prefix}_PORT"
  parse_url "$url" $prefix
  case "$(read_var $prefix SCHEME)" in
    postgres|postgresql)
      if [ -z "$(read_var $prefix PORT)" ]; then
        eval "${prefix}_PORT=5432"
      fi
      local host_port_name="$(read_var $prefix HOST):$(read_var $prefix PORT)/$(read_var $prefix NAME)"
      local jdbc_driver="org.postgresql.Driver"
      local jdbc_url="jdbc:postgresql://$host_port_name"
      local hibernate_dialect="org.hibernate.dialect.PostgreSQLDialect"
      local database_type="postgres72"
      ;;
    mysql|mysql2)
      if [ -z "$(read_var $prefix PORT)" ]; then
        eval "${prefix}_PORT=3306"
      fi
      local host_port_name="$(read_var $prefix HOST):$(read_var $prefix PORT)/$(read_var $prefix NAME)"
      local jdbc_driver="com.mysql.jdbc.Driver"
      local jdbc_url="jdbc:mysql://$host_port_name?autoReconnect=true&characterEncoding=utf8&useUnicode=true&sessionVariables=storage_engine%3DInnoDB"
      local hibernate_dialect="org.hibernate.dialect.MySQLDialect"
      local database_type="mysql"
      ;;
    *)
      echo "Unsupported database url scheme: $(read_var $prefix SCHEME)"
      exit 1
      ;;
  esac

  eval "${prefix}_JDBC_DRIVER=\"$jdbc_driver\""
  eval "${prefix}_JDBC_URL=\"$jdbc_url\""
  eval "${prefix}_DIALECT=\"$hibernate_dialect\""
  eval "${prefix}_TYPE=\"$database_type\""
}
