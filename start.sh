#!bin/sh

tpl_suffix="properties.tpl"
root_dir="/consul-template"
data_dir="$root_dir/data"
output_dir="$root_dir/output"

# verify that all the needed environment variables are defined, fail fast if not
if [ -z "$CONFIG_ROOT" ] || \
   [ -z "$CONSUL_HTTP_ADDR" ]; then
    echo "CONFIG_ROOT, CONSUL_HTTP_ADDR must be defined"
    exit 1
fi

# grab all the keys from consul, and determine the different applications we have
echo "grabbing all application names from consul"
apps=$(curl -s "$CONSUL_HTTP_ADDR/v1/kv/?recurse\&keys" | \
    jq -r .[] | \
    grep -E "^$CONFIG_ROOT" | \
    sed -e "s:$CONFIG_ROOT/::g" -e "s:/.*::g"  | \
    uniq)
echo "application names found: $apps"

# ash does not directly support arrays, so we will do it the ash way
echo "deleting all data and output dirs"
rm -rf
echo "starting creating new template files"
set -- $apps
for app; do
    fn="${data_dir}/${app}.${tpl_suffix}"
    echo "deleting old file $fn"
    rm -rf "$fn"
    cat <<-EOF > ${fn}
		{{ range tree (print (env "CONFIG_ROOT") "/$app") }}
		{{ .Key | replaceAll "/" "." }}={{ .Value }}{{ end }}
	EOF
	echo "created file $fn"
done
echo "done creating template files"

# concat all the template names for the consul-template execution
TEMPLATES=$(find ${data_dir} -name "*.${tpl_suffix}" | \
    sed -r "s|${data_dir}/(.*).${tpl_suffix}|-template ${data_dir}/\1.${tpl_suffix}:${output_dir}/\1.properties|g" | \
    tr '\n' ' ')
echo "templates string: $TEMPLATES"

# If the data or config dirs are bind mounted then chown them.
# Note: This checks for root ownership as that's the most common case.
# (this is exactly what docker-entrypoint.sh does, and without it the
# dir will be owned by root and we'll get permission denied)
if [ "$(stat -c %u ${output_dir})" != "$(id -u consul-template)" ]; then
  chown consul-template:consul-template ${output_dir}
fi

# optional log line
if [ ! -z "$LOG_LEVEL" ]; then
    echo "log level is defined to $LOG_LEVEL"
    LOG_LINE="-log-level $LOG_LEVEL"
fi

echo "running execution command /bin/consul-template $@ $TEMPLATES"
/usr/local/bin/docker-entrypoint.sh $TEMPLATES $LOG_LINE
