class cuda::runtime {
  $_release = regsubst($::cuda::release, '\.', '-', 'G')
  $_packages = ["${::cuda::package_runtime}-${_release}"]
  ensure_packages($_packages)
}
