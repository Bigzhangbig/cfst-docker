# 技术栈：cfst-docker

本文档列出了 `cfst-docker` 项目所使用的核心技术。

## 核心技术
- **容器化技术 (Containerization): Docker**
  - 使用 **Alpine Linux** 作为基础镜像，确保极致轻量。
  - 实现多架构 (`amd64`, `arm64`) 构建兼容。

## 脚本与自动化 (Scripting & Automation)
- **脚本语言 (Scripting Language): Shell Script**
  - 使用 **Bash** 编写核心包装脚本。
  - 集成 **jq** 和 **awk** 进行结果数据的处理与格式化筛选。
  - 使用 **curl** 实现与 GitHub Gist API 的交互。

## 持续集成/持续部署 (CI/CD)
- **CI/CD 工具: GitHub Actions**
  - **自动化流水线:** 实现代码推送自动触发构建。
  - **多架构编译:** 使用 **Docker Buildx** 和 **QEMU** 进行跨平台镜像合成。
  - **镜像托管:** 使用 **GitHub Container Registry (GHCR)** 进行版本化管理。
