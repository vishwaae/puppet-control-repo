class role::webserver {
  include profile::base
  include profile::webserver
  include puppet_agent7
}
