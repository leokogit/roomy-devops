source qemu w10gui {
  iso_url          = "../iso/windows.iso"
  iso_checksum     = "sha256:f41ba37aa02dcb552dc61cef5c644e55b5d35a8ebdfac346e70f80321343b506"
  output_directory = "output/"

  accelerator  = "kvm"
  machine_type = "q35"
  qemuargs = [
    ["-parallel", "none"],
    ["-m", "4096M"],
    ["-smp", "cpus=2"],
    ["-nic", "none"]
  ]

  cpus             = 2
  memory           = 4
  disk_size        = "27000M"
  disk_compression = true
  cd_files = [
    "../drivers/netkvm/w10/amd64/*",
    "../drivers/viostor/w10/amd64/*",
    "../drivers/vioserial/w10/amd64/*",
    "../drivers/amd64/w10/*",
    "../scripts/qemu/*"
  ]

  communicator     = "none"
  shutdown_timeout = "300m"
}

build {
  sources = ["source.qemu.w10gui"]

  post-processors {
    post-processor manifest {
      output     = "manifest.json"
      strip_path = true
    }
  }
}
