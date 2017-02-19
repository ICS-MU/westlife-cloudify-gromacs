include ::gromacs

# setup CUDA only if release specified
$cuda_release = hiera('cuda::release')
if ("${cuda_release}" != '') and ($::has_nvidia_gpu == true) {
  warning("cuda_release: ${cuda_release}")
  include ::cuda
}
