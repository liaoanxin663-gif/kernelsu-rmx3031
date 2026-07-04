# KernelSU-Next for realme GT Neo (RMX3031)

针对 **realme GT Neo（型号 RMX3031，天玑 1200，Android 11 / ColorOS V11，内核 4.14.186+）** 的自动化 KernelSU-Next 内核构建仓库。

> [!WARNING]
> 你之前把 GitHub Personal Access Token（PAT）发在了对话里。**请立刻到 GitHub Settings → Developer settings → Personal access tokens 中撤销该 Token，并重新生成一个只授予 `repo` 权限的新 Token。** 不要把 Token 再发给任何人或任何机器人。

## 这是什么？

这个仓库本身不包含内核源码，而是通过 **GitHub Actions** 自动完成以下工作：

1. 拉取 realme RMX3031 的 4.14 内核源码（默认 `ManshuTyagi/kernel_realme_RMX3031` 的 `R` 分支）。
2. 拉取并集成 **KernelSU-Next**（默认使用 `legacy` 分支，适配 4.14 等非 GKI 内核）。
3. 开启 `CONFIG_KSU` 与 kprobe 钩子，编译内核。
4. 用 **AnyKernel3** 打包成可直接在 TWRP 中卡刷的 zip。

## 前置条件

- realme GT Neo（RMX3031）
- Bootloader 已解锁
- 已刷入 TWRP / 橙狐等第三方 Recovery
- 已备份当前可用的 `boot.img`（防止变砖后无法恢复）
- 知道如何进 Fastboot / Recovery

## 使用方法

### 1. Fork / 使用本仓库

如果你已经通过本仓库的 GitHub Actions 触发构建，直接跳到下一步。

如果你想自己改源码或换 defconfig，可以在本仓库页面点击 **Actions → Build KernelSU for realme GT Neo (RMX3031) → Run workflow**。

### 2. 触发构建

进入仓库的 **Actions** 标签页，选择 **Build KernelSU for realme GT Neo (RMX3031)**，点击 **Run workflow**。

默认参数已适配 RMX3031：

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `kernel_repo` | `ManshuTyagi/kernel_realme_RMX3031` | 内核源码仓库 |
| `kernel_branch` | `R` | 内核源码分支 |
| `defconfig` | `RMX3031_defconfig` | 内核配置文件 |
| `ksu_version` | `legacy` | KernelSU-Next 分支/标签 |
| `ksu_method` | `kprobe` | 集成方式，`kprobe` 或 `manual` |

> 首次建议保持默认，直接点击 **Run workflow**。

### 3. 下载刷机包

构建完成后，在 Actions 运行结果页面的 **Artifacts** 区域下载 `kernelsu-rmx3031-<run编号>.zip`。

### 4. 刷入 TWRP

1. 把下载的 zip 复制到手机存储。
2. 关机，按住 **音量上 + 电源键** 进入 Recovery。
3. 在 TWRP 中选择 **Install**，找到 zip 包，滑动刷入。
4. 刷完后选择 **Reboot System**。
5. 开机后安装 [KernelSU-Next 管理器 APK](https://github.com/KernelSU-Next/KernelSU-Next/releases)，授予 Root 权限。

> 如果无法开机，请进入 TWRP 的 **Restore** 或直接刷回之前备份的 `boot.img`。

## 本地构建（可选）

如果你不想用 GitHub Actions，也可以在 Linux/WSL 中手动构建：

```bash
# 安装依赖
sudo apt update
sudo apt install -y git build-essential bc bison flex libssl-dev \
  libncurses-dev libelf-dev device-tree-compiler gcc-aarch64-linux-gnu \
  python2 python3 zip unzip

# 拉取内核
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-
git clone --depth=1 -b R https://github.com/ManshuTyagi/kernel_realme_RMX3031.git kernel
cd kernel

# 集成 KernelSU-Next
curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash -s legacy

# 开启 KernelSU
echo "CONFIG_KSU=y" >> arch/arm64/configs/RMX3031_defconfig
echo "CONFIG_KSU_KPROBE_HOOKS=y" >> arch/arm64/configs/RMX3031_defconfig
echo "CONFIG_KPROBES=y" >> arch/arm64/configs/RMX3031_defconfig
echo "CONFIG_KPROBE_EVENTS=y" >> arch/arm64/configs/RMX3031_defconfig

# 编译
make O=out RMX3031_defconfig
make O=out -j$(nproc)
```

## 常见问题

### 构建失败 / 编译报错

- 确认 defconfig 名称正确。
- 某些内核版本可能需要 `CONFIG_MODULES=y` 才能启用 kprobe。
- 如果 kprobe 在你的设备上不稳定导致卡开机，请改用 **manual** 集成方式：把 `ksu_method` 改为 `manual`，并手动把 KernelSU 的 hook 调用加到 `fs/exec.c`、`fs/open.c`、`fs/read_write.c`、`fs/stat.c`、`kernel/reboot.c` 中（参考 KernelSU-Next 官方文档）。

### 刷入后无法开机

- 立即进入 TWRP，刷回之前备份的 `boot.img`。
- 检查是否用了不匹配的 defconfig 或内核版本。

### KernelSU 管理器显示未安装

- 确认刷入的 zip 成功替换了 boot 分区。
- 检查内核配置里 `CONFIG_KSU=y` 是否真的生效。
- 某些 ColorOS 版本会验证 boot 签名，可能需要关闭 AVB / 禁用 boot 校验。

## 参考链接

- [KernelSU-Next 非 GKI 集成文档](https://kernelsu-next.github.io/webpage/zh_CN/pages/how-to-integrate-for-non-gki.html)
- [KernelSU-Next GitHub](https://github.com/KernelSU-Next/KernelSU-Next)
- [realme RMX3031 内核源码（4.14）](https://github.com/ManshuTyagi/kernel_realme_RMX3031)
- [AnyKernel3](https://github.com/osm0sis/AnyKernel3)
- [TWRP for RMX3031](https://dl.twrp.me/RMX3031/)

## 免责声明

刷机有风险，变砖需自负。请务必备份原始 `boot.img` 和重要数据。
