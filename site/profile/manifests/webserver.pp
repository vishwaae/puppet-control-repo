class profile::webserver {
  include nginx
  # nginx comes from EPEL; epel-release is installed by puppet_agent5
  Package <| title == 'epel-release' |> -> Class['nginx']
}
