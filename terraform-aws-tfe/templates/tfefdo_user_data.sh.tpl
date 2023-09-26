#! /bin/bash
set -euo pipefail

CONFIG_DIRECTORY="${config_directory}"
LICENSE_DIRECTORY="${config_directory}/license"
TLS_DIRECTORY="${config_directory}/tls"
DATA_DIRECTORY="${config_directory}/data"
LOGFILE="/var/log/${product}-cloud-init.log"
REQUIRED_PACKAGES="jq wget curl unzip"
PRODUCT_USER=1000
PRODUCT_GROUP=0
PRODUCT_USER_HOME_DIRECTORY="${config_directory}"
# Product Specific
TFE_SETTINGS_PATH="$CONFIG_DIRECTORY/docker-compose.yaml"
LICENSE_PATH="$LICENSE_DIRECTORY/${product}.hclic"
TFE_TLSBOOTSTRAPCERT_PATH="$TLS_DIRECTORY/cert.pem"
TFE_TLSBOOTSTRAPKEY_PATH="$TLS_DIRECTORY/privkey.pem"
TFE_TLSCABUNDLE_PATH="$TLS_DIRECTORY/ca_bundle.pem"

${generic_init_functions}

function fetch_tls_certificates {
  log "Fetching TLS certificates..."
  %{if ca_bundle_secret_arn != ""}
  log "Retrieving custom CA bundle"
  get_secrets "${ca_bundle_secret_arn}" > $TFE_TLSCABUNDLE_PATH
  CA_CERTS=$(cat $TFE_TLSCABUNDLE_PATH | jq -sR '.' | tr -d '"')
  %{ else }
  CA_CERTS=""
  %{ endif }

  %{if cert_secret_arn != "" }
  log "Retrieving TLS Public Cert"
  get_secrets "${cert_secret_arn}" > $TFE_TLSBOOTSTRAPCERT_PATH
  %{ endif }

  %{if privkey_secret_arn != "" }
  log "Retrieving TLS Private Key"
  get_secrets "${privkey_secret_arn}" > $TFE_TLSBOOTSTRAPKEY_PATH
  %{ endif}

  # * Ensure proper permissions on TLS certificates
  chmod -R 750 $TLS_DIRECTORY

  # * Ensure proper ownership on TLS certificates
  chown -R $PRODUCT_USER:$PRODUCT_GROUP $TLS_DIRECTORY

  log "Done fetching TLS certificates."
}

function directory_create {
  log "Creating necessary directories"

  directories=( $CONFIG_DIRECTORY $LICENSE_DIRECTORY $TLS_DIRECTORY)

  for directory in "$${directories[@]}"; do
    mkdir -p $directory
    log "Created $directory"
    chown $PRODUCT_USER:$PRODUCT_GROUP $directory
    chmod 750 $directory
  done
}

function user_group_create {
  log "Creating ${product} user and group..."
  groupadd --system $PRODUCT_GROUP

  useradd --system -m -d $PRODUCT_USER_HOME_DIRECTORY -g $PRODUCT_GROUP $PRODUCT_USER
  log "Done creating ${product} user and group"
}

function fetch_${product}_license {
  log  "Retrieving ${product} license"
  get_secrets ${license_secret_arn} > $LICENSE_PATH

  chmod 400 $LICENSE_PATH
  chown $PRODUCT_USER:$PRODUCT_GROUP $LICENSE_PATH

  LICENSE_RAW=$(get_secrets ${license_secret_arn})
  log  "Done fetching ${product} license."
}

function docker_pull_from_ecr {
  aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin ${custom_tbw_ecr_repo_uri}
  docker pull ${custom_image_tag}
}

function fetch_${product}_container {
  log "Pulling ${product} container..."
  docker login images.releases.hashicorp.com --username terraform --password $LICENSE_RAW
  docker pull images.releases.hashicorp.com/hashicorp/terraform-enterprise:${tfe_release_sequence}
}

function retrieve_${product}_passwords {
  log "Retrieving ${product} passwords"
  ENC_PASSWORD=$(get_secrets "${enc_password_arn}")
}

function configure_log_forwarding {
  log "Configuring Fluent Bit log forwarding"
  %{ if log_forwarding_enabled == 1}
  cat > "$CONFIG_DIRECTORY/fluent-bit.conf" << EOF
${fluent_bit_config}
EOF
  LOG_FORWARDING_CONFIG=$(sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g' $CONFIG_DIRECTORY/fluent-bit.conf)
  %{ else }
  LOG_FORWARDING_CONFIG=""
  %{ endif }
}

function generate_${product}_settings {
  log "Generating $TFE_SETTINGS_PATH file."
  TFE_TLSBOOTSTRAPCERT=$(basename "$TFE_TLSBOOTSTRAPCERT_PATH")
  TFE_TLSBOOTSTRAPKEY=$(basename "$TFE_TLSBOOTSTRAPKEY_PATH")
  TFE_TLSCABUNDLE=$(basename "$TFE_TLSCABUNDLE_PATH")
  cat > $TFE_SETTINGS_PATH << EOF
---
version: "3.9"
name: ${product}
services:
  tfe:
    %{ if custom_tbw_ecr_repo_uri != "" }
    image: ${custom_tbw_ecr_repo_uri}/terraform-enterprise:${custom_image_tag}
    %{ else }
    image: images.releases.hashicorp.com/hashicorp/terraform-enterprise:${tfe_release_sequence}
    %{ endif }
    restart: unless-stopped
    environment:
      TFE_HOSTNAME: "${tfe_hostname}"
      TFE_OPERATIONAL_MODE: "${operational_mode}"
      TFE_ENCRYPTION_PASSWORD: "$ENC_PASSWORD"
      TFE_DISK_CACHE_VOLUME_NAME: ${product}_terraform-enterprise-cache
      TFE_TLS_CERT_FILE: /etc/ssl/private/terraform-enterprise/$TFE_TLSBOOTSTRAPCERT
      TFE_TLS_KEY_FILE: /etc/ssl/private/terraform-enterprise/$TFE_TLSBOOTSTRAPKEY
      TFE_TLS_CA_BUNDLE_FILE: /etc/ssl/private/terraform-enterprise/$TFE_TLSCABUNDLE
      TFE_LICENSE: $LICENSE_RAW
      TFE_IACT_SUBNETS: ${tfe_iact_subnets}
      TFE_IACT_TRUSTED_PROXIES: ${tfe_iact_trusted_proxies}
      TFE_IACT_TIME_LIMIT: ${tfe_iact_time_limit}
      TFE_CAPACITY_CONCURRENCY: ${capacity_concurrency}
      TFE_CAPACITY_MEMORY: ${capacity_memory}

      # Database settings.
      TFE_DATABASE_USER: "${pg_user}"
      TFE_DATABASE_PASSWORD: "${pg_password}"
      TFE_DATABASE_HOST: "${pg_netloc}:${pg_port}"
      TFE_DATABASE_NAME: "${pg_dbname}"
      TFE_DATABASE_PARAMETERS: "sslmode=require"

      # Object storage settings.
      TFE_OBJECT_STORAGE_TYPE: "s3"
      TFE_OBJECT_STORAGE_S3_USE_INSTANCE_PROFILE: "true"
      TFE_OBJECT_STORAGE_S3_REGION: "$REGION"
      TFE_OBJECT_STORAGE_S3_BUCKET: "${s3_app_bucket_name}"
      TFE_OBJECT_STORAGE_S3_SERVER_SIDE_ENCRYPTION: "${s3_bucket_encryption}"
      TFE_OBJECT_STORAGE_S3_SERVER_SIDE_ENCRYPTION_KMS_KEY_ID: "${kms_key_arn}"

      # Logging
      %{ if log_forwarding_enabled }
      TFE_LOG_FORWARDING_ENABLED: ${log_forwarding_enabled}
      TFE_LOG_FORWARDING_CONFIG_PATH: $CONFIG_DIRECTORY/fluent-bit.conf
      %{ endif }
      %{ if metrics_endpoint_enabled }
      TFE_METRICS_ENABLE: ${metrics_endpoint_enabled}
      TFE_METRICS_HTTP_PORT: ${metrics_endpoint_port_http}
      TFE_METRICS_HTTPS_PORT: ${metrics_endpoint_port_https}
      %{ endif }


      %{ if operational_mode == "active-active" }
      # Vault settings.
      TFE_VAULT_CLUSTER_ADDRESS: "https://$EC2_PRIVATE_IP:8201"
      # Redis settings.
      TFE_REDIS_HOST: "${redis_host}"
      TFE_REDIS_PASSWORD: "${redis_pass}"
      TFE_REDIS_USE_TLS: ${redis_use_tls}
      TFE_REDIS_USE_AUTH: ${redis_use_password_auth}
      %{ endif }

    cap_add:
      - IPC_LOCK
    read_only: true
    tmpfs:
      - /tmp
      - /var/run
      - /var/log/terraform-enterprise
    ports:
      - "80:80"
      - "443:443"
      %{ if operational_mode == "active-active" }
      - "8201:8201"
      %{ endif }
      %{ if metrics_endpoint_enabled }
      - "${metrics_endpoint_port_http}:${metrics_endpoint_port_http}"
      - "${metrics_endpoint_port_https}:${metrics_endpoint_port_https}"
      %{ endif }

    volumes:
      - type: bind
        source: /var/run/docker.sock
        target: /var/run/docker.sock
      - type: bind
        source: $TLS_DIRECTORY
        target: /etc/ssl/private/terraform-enterprise
      - type: volume
        source: terraform-enterprise-cache
        target: /var/cache/tfe-task-worker/terraform
volumes:
  terraform-enterprise-cache:
EOF

awk 'NF' $TFE_SETTINGS_PATH > tmpfile && mv tmpfile $TFE_SETTINGS_PATH
}

function start_${product}_service {
  log "Starting ${product}."
  cd $CONFIG_DIRECTORY
  if [[ -n "$(command -v docker-compose)" ]]; then
    docker-compose up --detach
  else
      docker compose up --detach
  fi
  log "Polling TFE health check endpoint until app becomes ready..."
  while ! curl -ksfS --connect-timeout 5 https://$EC2_PRIVATE_IP/_health_check; do
    sleep 5
  done
  exit_script 0
}

main() {
  scrape_vm_info
  install_dependencies
  install_cloud_cli_tools
  directory_create
  fetch_tls_certificates
  fetch_${product}_license
  retrieve_${product}_passwords
  generate_${product}_settings
  fetch_${product}_container
  start_${product}_service
}

main "$@"