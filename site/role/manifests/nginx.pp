class role::nginx {
  include profile::base
  include profile::webserver
  include puppet_agent5
}
