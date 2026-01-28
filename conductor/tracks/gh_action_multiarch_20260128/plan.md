# 实施计划 - 添加 GitHub Action 自动编译多平台 Docker 镜像

本计划旨在通过 GitHub Actions 实现 Docker 镜像的自动化多架构构建与发布。

## 阶段 1：版本提取脚本与环境准备 [checkpoint: f2db129]
- [x] 任务：创建或完善版本提取工具。 (5f87193)
- [x] 任务：配置 GitHub 仓库权限。 (Manual)
- [x] 任务：Conductor - 用户手动验证 '阶段 1：版本提取脚本与环境准备' (f2db129)

## 阶段 2：GitHub Action 工作流实现
- [x] 任务：编写 Docker 构建工作流文件。 (44e7131)
- [x] 任务：实现智能标签逻辑。 (44e7131)
- [ ] 任务：Conductor - 用户手动验证 '阶段 2：GitHub Action 工作流实现' (协议在 workflow.md 中)

## 阶段 3：多平台构建与发布验证 [checkpoint: 4b2809e]
- [x] 任务：使用 GitHub CLI (`gh`) 触发、监控并验证构建。 (3ae25cf)
- [x] 任务：验证远程仓库镜像。 (Manual via GH Actions Success)
- [x] 任务：Conductor - 用户手动验证 '阶段 3：多平台构建与发布验证' (4b2809e)

## 阶段 4：文档同步与最终交付
- [ ] 任务：更新 README.md 及项目文档。
    - [ ] 更新镜像下载路径为 `ghcr.io` 地址。
    - [ ] 说明版本号命名规则（主版本同步 + 子版本构建次数）。
- [ ] 任务：生成拉取测试命令。
    - [ ] 为用户提供明确的 `docker pull` 和 `docker run` 命令示例，用于验证远程镜像的可用性。
- [ ] 任务：Conductor - 用户手动验证 '阶段 4：文档同步与最终交付' (协议在 workflow.md 中)
