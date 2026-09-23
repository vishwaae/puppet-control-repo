forge 'https://forge.puppet.com'

mod 'puppetlabs-stdlib', '6.6.0'
mod 'puppetlabs-concat', '6.4.0'
mod 'puppetlabs-apt', '7.6.0'

# vault, nginx, ntp — one bundled repo, pinned to a released tag
mod 'internal',
  :git => 'https://github.com/vishwaae/puppet-modules.git',
  :tag => 'v2-mod'

# standalone repo, tracking a branch's latest commit
mod 'timezone',
  :git => 'https://github.com/vishwaae/puppet-timezone-module.git',
  :branch => 'dev'

# standalone repo, pinned to one exact commit SHA
mod 'resolve_conf',
  :git => 'https://github.com/vishwaae/puppet-resolve_conf-module.git',
  :commit => 'bac855b'