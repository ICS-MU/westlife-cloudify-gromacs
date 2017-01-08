include ::gromacs

# setup CUDA only if release specified
$cuda_release = hiera('cuda::release')
if ("${cuda_release}" != '') {
  warning("cuda_release: ${cuda_release}")
  include ::cuda
}
