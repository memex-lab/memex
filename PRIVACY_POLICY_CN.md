# 隐私政策

最后更新：2025-07-13

## 概述

Memex（以下简称"本应用"）是一款本地优先的个人知识管理应用。我们致力于保护您的隐私。本政策说明本应用如何处理您的数据。

## 数据收集

**Memex 不会收集、存储或向外部服务器传输任何个人数据。**

您在应用中创建的所有数据（包括文字、照片、语音录音和 AI 生成的内容）均仅存储在您的设备上。

## 第三方服务

Memex 仅在您主动配置 API Key 后才会连接第三方大语言模型（LLM）服务商，包括：

- Google Gemini
- OpenAI
- Anthropic Claude
- AWS Bedrock

使用这些服务时，您的输入内容会发送至您选择的服务商以生成 AI 回复。关于各服务商如何处理您的数据，请参阅其隐私政策：

- [Google 隐私政策](https://policies.google.com/privacy)
- [OpenAI 隐私政策](https://openai.com/privacy)
- [Anthropic 隐私政策](https://www.anthropic.com/privacy)
- [AWS 隐私政策](https://aws.amazon.com/privacy/)

## 设备权限

Memex 可能会请求以下设备权限。通过这些权限获取的所有数据均存储在您的设备本地，不会上传到我们的服务器。

- **相机** — 用于拍照记录
- **麦克风** — 用于语音录入
- **相册** — 用于选择设备中已有的照片
- **健康/健身** — 用于读取健身数据（步数等），需您主动开启
- **生物识别（Face ID / Touch ID）** — 用于应用锁认证

## 端侧处理

以下功能完全在您的设备上运行，不会向外部发送数据：

- OCR 文字识别（Google ML Kit，端侧运行）
- 图像标签与场景识别（Google ML Kit，端侧运行）
- 照片 EXIF 元数据提取
- 本地数据库存储（SQLite）

## 分析与追踪

Memex 不包含任何分析、追踪或广告 SDK。

## 生物识别数据

如果您启用了应用锁，生物识别认证（Face ID / Touch ID）由操作系统处理。Memex 不会访问或存储您的生物识别数据。

## 儿童隐私

Memex 不会故意收集 13 岁以下儿童的任何信息。

## 政策变更

我们可能会不时更新本隐私政策。变更将在本文档中发布并更新日期。

## 联系方式

如果您对本隐私政策有任何疑问，请在以下地址提交 Issue：

https://github.com/memex-lab/memex/issues
