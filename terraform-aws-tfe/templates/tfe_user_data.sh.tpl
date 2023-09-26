#! /bin/bash
set -euo pipefail

CONFIG_DIRECTORY="${config_directory}"
LICENSE_DIRECTORY="${config_directory}/license"
TLS_DIRECTORY="${config_directory}/tls"
DATA_DIRECTORY="${config_directory}/data"
INSTALLER_DIRECTORY="${config_directory}/installer"
LOGFILE="/var/log/${product}-cloud-init.log"
REQUIRED_PACKAGES="jq wget curl unzip"
PRODUCT_USER="tfe"
PRODUCT_GROUP="tfe"
PRODUCT_USER_HOME_DIRECTORY="${config_directory}"
# Product Specific
TFE_SETTINGS_PATH="$CONFIG_DIRECTORY/tfe-settings.json"
TFE_LICENSE_PATH="$LICENSE_DIRECTORY/license.rli"
TFE_ONLINE_SH_PATH="$INSTALLER_DIRECTORY/install.sh"
TFE_TLSBOOTSTRAPCERT_PATH="$TLS_DIRECTORY/cert.pem"
TFE_TLSBOOTSTRAPKEY_PATH="$TLS_DIRECTORY/privkey.pem"
TFE_TLSCABUNDLE_PATH="$TLS_DIRECTORY/ca_bundle.pem"
TFE_AIRGAP_PATH="$INSTALLER_DIRECTORY/tfe-bundle.airgap"
REPL_BUNDLE_PATH="$INSTALLER_DIRECTORY/replicated.tar.gz"
REPL_CONF_PATH="/etc/replicated.conf"

${generic_init_functions}

function fetch_tls_certificates {
  log " Fetching TLS certificates..."
  %{if ca_bundle_secret_arn != ""}
  log "Retrieving custom CA bundle from ${ca_bundle_secret_arn}."
  get_secrets "${ca_bundle_secret_arn}" > $TFE_TLSCABUNDLE_PATH
  CA_CERTS=$(cat $TFE_TLSCABUNDLE_PATH | jq -sR '.' | tr -d '"')
  %{ else }
  CA_CERTS=""
  %{ endif }

  %{if cert_secret_arn != "" }
  log "Retrieving TLS Public Cert from ${cert_secret_arn}."
  get_secrets "${cert_secret_arn}" > $TFE_TLSBOOTSTRAPCERT_PATH
  %{ endif }

  %{if privkey_secret_arn != "" }
  log "Retrieving TLS Private Key from ${privkey_secret_arn}."
  get_secrets "${privkey_secret_arn}" > $TFE_TLSBOOTSTRAPKEY_PATH
  %{ endif}

  # Ensure proper permissions on TLS certificates
  chmod -R 400 $TLS_DIRECTORY

  # Ensure proper ownership on TLS certificates
  chown -R $PRODUCT_USER:$PRODUCT_GROUP $TLS_DIRECTORY

  log "Done fetching TLS certificates."
}

function directory_create {
  log "Creating necessary directories..."

  # Define all directories needed as an array
  directories=( $CONFIG_DIRECTORY $LICENSE_DIRECTORY $TLS_DIRECTORY $INSTALLER_DIRECTORY )

  # Loop through each item in the array; create the directory and configure permissions
  for directory in "$${directories[@]}"; do
    mkdir -p $directory
    log "Created $directory"
    chown $PRODUCT_USER:$PRODUCT_GROUP $directory
    chmod 750 $directory
  done

  log "Done creating necessary directories."
}

%{ if airgap_install }
function pull_airgap_bundles {
  log "Fetching airgap bundles..."
  retrieve_file_from_obj "${tfe_airgap_bundle_path}" "$TFE_AIRGAP_PATH" "$LOGFILE"
  retrieve_file_from_obj "${replicated_bundle_path}" "$REPL_BUNDLE_PATH" "$LOGFILE"
  cd $INSTALLER_DIRECTORY
  tar xvf $REPL_BUNDLE_PATH -C $INSTALLER_DIRECTORY
}
%{ endif }

# TFE uses .rli extension
function fetch_${product}_license {
  log "Retrieving ${product} license..."
  get_secrets "${license_secret_arn}" > $TFE_LICENSE_PATH
  chmod 400 $TFE_LICENSE_PATH
  chown $PRODUCT_USER:$PRODUCT_GROUP $TFE_LICENSE_PATH
  log "Done fetching ${product} license."
}

function user_group_create {
  log "Creating ${product} user and group..."

  # Create the dedicated as a system group
  groupadd --system $PRODUCT_GROUP

  # Create a dedicated user as a system user
  useradd --system -m -d $PRODUCT_USER_HOME_DIRECTORY -g $PRODUCT_GROUP $PRODUCT_USER

  log "Done creating ${product} user and group"
}

function pull_online_installer {
  log "Retrieving TFE install script directly from Replicated."
  curl https://install.terraform.io/ptfe/stable -o $TFE_ONLINE_SH_PATH
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

function docker_pull_from_ecr {
  aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin ${custom_tbw_ecr_repo_uri}
  docker pull ${custom_image_tag}
}

function generate_replicated_config {
  log "Generating $REPL_CONF_PATH file."
  cat > $REPL_CONF_PATH << EOF
{
  "DaemonAuthenticationType": "password",
  "DaemonAuthenticationPassword": "$CONSOLE_PASSWORD",
  "ImportSettingsFrom": "$TFE_SETTINGS_PATH",
%{ if airgap_install ~}
  "LicenseBootstrapAirgapPackagePath": "$TFE_AIRGAP_PATH",
%{ else ~}
  "ReleaseSequence": ${tfe_release_sequence},
%{ endif ~}
  "LicenseFileLocation": "$TFE_LICENSE_PATH",
  "TlsBootstrapHostname": "${tfe_hostname}",
  "TlsBootstrapType": "${tls_bootstrap_type}",
%{ if tls_bootstrap_type == "server-path" ~}
  "TlsBootstrapCert": "$TFE_TLSBOOTSTRAPCERT_PATH",
  "TlsBootstrapKey": "$TFE_TLSBOOTSTRAPKEY_PATH",
%{ endif ~}
  "RemoveImportSettingsFrom": ${remove_import_settings_from},
  "BypassPreflightChecks": true
}
EOF
}

function generate_tfe_settings {
  log "Generating $TFE_SETTINGS_PATH file."
  cat > $TFE_SETTINGS_PATH << EOF
{
  "aws_access_key_id": {},
  "aws_instance_profile": {
      "value": "1"
  },
  "aws_secret_access_key": {},
  "backup_token": {},
  "ca_certs": {
    "value": "$CA_CERTS"
  },
  "capacity_concurrency": {
      "value": "${capacity_concurrency}"
  },
  "capacity_cpus": {},
  "capacity_memory": {
      "value": "${capacity_memory}"
  },
  "custom_image_tag": {
    "value": "${custom_image_tag}"
  },
  "disk_path": {},
  "enable_active_active": {
    "value": "${enable_active_active}"
  },
  "enable_metrics_collection": {
      "value": "${enable_metrics_collection}"
  },
  "enc_password": {
      "value": "$ENC_PASSWORD"
  },
  "extern_vault_addr": {},
  "extern_vault_enable": {
      "value": "0"
  },
  "extern_vault_path": {},
  "extern_vault_propagate": {},
  "extern_vault_role_id": {},
  "extern_vault_secret_id": {},
  "extern_vault_token_renew": {},
  "extra_no_proxy": {
    "value": "${extra_no_proxy}"
  },
  "force_tls": {
    "value": "${force_tls}"
  },
  "hairpin_addressing": {
    "value": "${hairpin_addressing}"
  },
  "hostname": {
      "value": "${tfe_hostname}"
  },
  "iact_subnet_list": {},
  "iact_subnet_time_limit": {
      "value": "60"
  },
  "installation_type": {
      "value": "production"
  },
  "log_forwarding_config": {
    "value": "$LOG_FORWARDING_CONFIG"
  },
  "log_forwarding_enabled": {
    "value": "${log_forwarding_enabled}"
  },
  "metrics_endpoint_enabled": {
      "value": "${metrics_endpoint_enabled}"
  },
  "metrics_endpoint_port_http": {
      "value": "${metrics_endpoint_port_http}"
  },
  "metrics_endpoint_port_https": {
      "value": "${metrics_endpoint_port_https}"
  },
  "pg_dbname": {
      "value": "${pg_dbname}"
  },
  "pg_extra_params": {
      "value": "sslmode=require"
  },
  "pg_netloc": {
      "value": "${pg_netloc}"
  },
  "pg_password": {
      "value": "${pg_password}"
  },
  "pg_user": {
      "value": "${pg_user}"
  },
  "placement": {
      "value": "placement_s3"
  },
  "production_type": {
      "value": "external"
  },
  "redis_host": {
    "value": "${redis_host}"
  },
  "redis_pass": {
    "value": "${redis_pass}"
  },
  "redis_port": {
    "value": "${redis_port}"
  },
  "redis_use_password_auth": {
    "value": "${redis_use_password_auth}"
  },
  "redis_use_tls": {
    "value": "${redis_use_tls}"
  },
  "restrict_worker_metadata_access": {
    "value": "${restrict_worker_metadata_access}"
  },
  "s3_bucket": {
      "value": "${s3_app_bucket_name}"
  },
  "s3_endpoint": {},
  "s3_region": {
      "value": "${s3_app_bucket_region}"
  },
%{ if kms_key_arn != "" ~}
  "s3_sse": {
      "value": "aws:kms"
  },
  "s3_sse_kms_key_id": {
      "value": "${kms_key_arn}"
  },
%{ else ~}
  "s3_sse": {},
  "s3_sse_kms_key_id": {},
%{ endif ~}
  "tbw_image": {
      "value": "${tbw_image}"
  },
  "tls_ciphers": {},
  "tls_vers": {
      "value": "tls_1_2_tls_1_3"
  }
}
EOF
}

function retrieve_${product}_passwords {
  log "Retrieving install secret 'console_password'."
  CONSOLE_PASSWORD=$(get_secrets "${console_password_arn}")

  log "Retrieving install secret 'enc_password'."
  ENC_PASSWORD=$(get_secrets "${enc_password_arn}" )
}

function tfe_install {
  bash $TFE_ONLINE_SH_PATH \
%{ if airgap_install ~}
    airgap \
%{ endif ~}
%{ if http_proxy != "" ~}
    http-proxy=${http_proxy} \
%{ else ~}
    no-proxy \
%{ endif ~}
%{ if extra_no_proxy != "" ~}
    additional-no-proxy=${extra_no_proxy} \
%{ endif ~}
%{ if enable_active_active == 1 ~}
    disable-replicated-ui \
%{ endif ~}
%{ if install_docker_before == true ~}
    no-docker \
%{ endif ~}
    private-address=$EC2_PRIVATE_IP \
    public-address=$EC2_PRIVATE_IP

  # docker pull custom tbw image if a custom image tag was provided
  if [[ ${tbw_image} == "custom_image" && ${custom_image_tag} != "hashicorp/build-worker:now" ]]; then
    log "Detected custom TBW image was specified. Attempting to docker pull ${custom_image_tag}."
    docker_pull_from_ecr
  fi

  log "Sleeping for a minute while TFE initializes."

  log "Polling TFE health check endpoint until app becomes ready..."
  while ! curl -ksfS --connect-timeout 5 https://$EC2_PRIVATE_IP/_health_check; do
    sleep 5
  done

  exit_script 0
}


function main {
  scrape_vm_info
  install_dependencies
  install_cloud_cli_tools
  user_group_create
  directory_create
  fetch_tls_certificates
  fetch_${product}_license
  retrieve_${product}_passwords
  configure_log_forwarding
  %{ if airgap_install }
  pull_airgap_bundles
  %{ endif }
  %{ if !airgap_install }
  pull_online_installer
  %{ endif }
  generate_replicated_config
  generate_tfe_settings
  tfe_install
}

main