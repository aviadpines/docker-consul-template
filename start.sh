#!bin/sh

if [ -z "$TEMPLATE_URI" ]; then
    echo "TEMPLATE_URI must be defined"
    exit 1
fi

wget --directory-prefix=/consul-template/data/ $TEMPLATE_URI

/bin/consul-template "$@"
