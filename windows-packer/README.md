# How to create images

Dont forget to use subnet with exception for PSRP (5986 port)

## Windows 

1. Download drivers from https://github.com/virtio-win/virtio-win-pkg-scripts and extract serial, netkvm + viostor to ```./drivers/[version]/[edition]/*```
2. Download and rename iso for windows distribution into ./iso/windows.iso
3. ```cd ws22gui-qemu```
3. Build via ```PACKER_LOG=1 packer build .```
4. Upload ```s3cmd put output/packer-windows-server s3://temp/windows-server.qcow2```
5. Create image

```bash
curl -k \
    -H "Authorization: Bearer `yc iam create-token`" \
    -H "Content-type: application/json" \
    -X POST \
    --data '{"folderId":"<folder-id>","name":"windows-server","description":"Windows server","os.type":"WINDOWS","minDiskSize":"53687091200","os":{"type":"WINDOWS"},"uri":"<presigned-url>"}' \
    https://compute.api.cloud.yandex.net/compute/v1/images
```

6. Create Virtual Machine in Cloud
7. Configure it, do a sysprep
