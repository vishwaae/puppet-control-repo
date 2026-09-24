class role::vault {
  include profile::base
  include profile::vault_server
  include puppet_agent5
}
