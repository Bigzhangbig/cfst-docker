# 轨道规范：添加 GitHub Action 自动编译多平台 Docker 镜像

## 1. 概述
本轨道旨在通过 GitHub Actions 实现 Docker 镜像的自动化流水线。系统将自动同步上游版本号，针对多种架构编译镜像，并推送至 GitHub Container Registry (GHCR)。

## 2. 功能需求
- **自动化构建流：**
    - 触发条件：代码推送到 `main` 分支。
    - 目标仓库：GitHub Container Registry (`ghcr.io`)。
- **多平台支持：**
    - 支持架构：`linux/amd64`, `linux/arm64`, `linux/arm/v7`, `linux/386`。
    - 使用 Docker Buildx 进行交叉编译。
- **智能标签管理 (Versioning)：**
    - **主版本同步：** 自动从 `scripts/install_cfst.sh` 或 GitHub API 获取上游 `CloudflareSpeedTest` 的最新版本号（如 `v2.2.5`）。
    - **子版本叠加：** 使用 `${GITHUB_RUN_NUMBER}` 作为子版本后缀（格式如 `v2.2.5-1`, `v2.2.5-2`）。
    - **固定标签：** 始终更新 `latest` 标签。
- **构建优化：**
    - 实现 GitHub Action 缓存机制（`type=gha`），加速多架构编译过程。

## 3. 非功能需求
- **自动化：** 自动提取版本号，无需人工手动修改 YAML。
- **安全性：** 使用 `GITHUB_TOKEN` 权限进行 GHCR 登录，遵循最小特权原则。

## 4. 验收标准
- [ ] 工作流能成功自动提取上游版本号并在日志中显示。
- [ ] 镜像成功推送到 GHCR，标签符合 `vX.X.X-Y` 格式。
- [ ] 验证 `latest` 标签确实指向最新的构建。
- [ ] 通过 `docker manifest inspect` 确认镜像支持指定的四种架构。

## 5. 范围之外
- 不支持 Docker Hub。
- 不包括自动创建 GitHub Release 的逻辑。
