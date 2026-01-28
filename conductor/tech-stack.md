# 技术栈：cfst-docker

本文档列出了 `cfst-docker` 项目所使用的核心技术。

## 核心技术
- **容器化技术 (Containerization): Docker**
  - 项目的核心是创建一个 Docker 镜像，用于封装和分发 `CloudflareSpeedTest` 工具。

## 脚本与自动化 (Scripting & Automation)
- **脚本语言 (Scripting Language): Shell Script**
  - 将使用 Shell 脚本来处理自动化任务，例如：获取最新的 `CloudflareSpeedTest` 二进制文件、执行 Docker 构建命令以及管理定时任务。

## 持续集成/持续部署 (CI/CD)
- **CI/CD 工具: GitHub Actions**
  - 将利用 GitHub Actions 建立一个自动化的工作流，用于构建、测试（如果适用）和发布 Docker 镜像到容器仓库。
