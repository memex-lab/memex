我把 Gemma 4 塞进了自己做的纯本地 AI 笔记 App，踩了一路坑

最近给自己做的开源 Flutter 笔记应用 Memex 接入了 Gemma 4 本地推理，折腾了好几天，记录一下整个过程。

📦 GitHub: memex-lab/memex

Memex 是一个纯本地的 AI 知识管理应用，所有数据都在设备上，用户自带 LLM（Gemini、Claude、OpenAI 都支持）。这次想加一个完全离线的选项，不依赖任何云服务，于是盯上了 Gemma 4 E2B/E4B（代码两个都支持，实际使用的是 E4B）。

——

🔴 第一步：用 flutter_gemma，手机直接重启

最开始图省事，直接用了 flutter_gemma 这个 Flutter 包。它封装了 LiteRT-LM，API 看起来挺简洁。但跑起来问题很严重——偶尔会导致手机整个重启，不只是 app 崩溃，是整台手机直接黑屏重启。

具体原因还不清楚，但同一台手机、同一个模型文件，Google 官方的 Edge Gallery 就没这个问题。Edge Gallery 直接用 Kotlin API 调 LiteRT-LM，而 flutter_gemma 多了一层 Flutter Plugin 封装。考虑到稳定性风险太大，决定放弃 flutter_gemma，直接用官方 API。

——

🟡 第二步：绕过 flutter_gemma，直接用官方 Kotlin API

自己写 Platform Channel，直接调 Google 官方的 litertlm-android。

架构变成：
Dart → MethodChannel → Kotlin LiteRtLmPlugin → LiteRT-LM Engine

核心设计是 Engine 单例 + Conversation 按需创建：
• Engine 只初始化一次，加载 2.6GB 模型到 GPU 内存
• 每次推理新建 Conversation（轻量），用完关掉

这和 Edge Gallery 的做法一致。切换过来后，推理速度正常了，手机也不再重启。

Dart 侧的 GemmaLocalClient 实现了和云端 provider 相同的 LLMClient 接口，对上层 agent 完全透明——切换 Gemma Local 只需要改一个配置项。

——

🟡 第三步：多 Agent 并发——全局锁

Memex 有多个 Agent 并行跑（card agent 处理卡片、pkm agent 处理知识库、asset analysis 分析图片音频）。接入 Gemma 后发现并发调用会崩。

原因：LiteRT-LM 的 Engine 同一时间只允许一个 Conversation 存在。多个 Agent 同时请求时，第二个 createConversation 会报错，然后 native 层空指针崩溃。

解决方案是在 Dart 侧加全局锁，用 Promise Chain 实现 mutex。所有推理请求排队，一次只跑一个。锁在 stream 结束时释放。

关键点：Engine 初始化也必须在锁里面。因为图片分析需要 visionBackend，音频分析需要 audioBackend，如果两个请求并发触发 Engine 重建，native 层会崩。把初始化放进锁里后，按需切换 backend 就能正常工作了。

——

🟡 第四步：多模态——图片和音频

Gemma 4 E2B/E4B 支持图片和音频输入，这是选它的重要原因。但接入过程踩了不少坑。

图片：
• LiteRT-LM 不支持 WebP，只认 JPEG/PNG
• 图片太大会超过 patch 上限（2520 patches），导致 native 崩溃，需要限制最大边长（我用了 896px）
• Vision backend 在 MTK 芯片上用 GPU 会崩，改成 CPU 后稳定了

音频：
• LiteRT-LM 的 miniaudio 只支持 WAV/PCM，不支持 M4A/AAC
• 需要在 Kotlin 侧用 MediaExtractor + MediaCodec 把 M4A 解码成 16kHz mono PCM，包装成 WAV 再传给模型

Thinking mode + 多模态冲突：
• Gemma 4 支持 thinking mode，开启后模型会先推理再输出
• 但 thinking + vision 同时开启时，在某些设备上会崩溃
• 解决方案：检测到消息里有图片或音频时，自动关闭 thinking mode
• 另外注意：关闭 thinking 时要传 channels = null（使用模型默认配置），不能传空列表——空列表会禁用所有 channel，包括 vision 依赖的内部 channel

——

🟢 Gemma 4 实际表现——诚实评价

用了一段时间，总结一下 Gemma 4 E4B 在真实 agent 场景下的表现：

✅ 能用的地方：
• 读图：描述图片内容够用，识别文字、场景、UI 元素都 OK
• 音频转录：中文普通话识别率不错，短语音笔记场景够用
• 无格式要求的文本输出：写 insight、总结、评论之类的，质量还行
• Thinking mode：对纯文本任务有帮助，推理质量有提升

❌ 明显不足的地方：
• Function call 容易解析失败：模型生成的 JSON 格式不标准，LiteRT-LM 内置 parser 会直接抛异常
• ID 类字段生成错误率很高：比如 fact_id 这种格式化字符串，模型经常生成错误值
• 偶尔空响应：没有任何输出就结束了
• 复杂 JSON schema 处理差：嵌套数组和对象的 tool parameter 容易出错
• OpenCL sampler warning：在部分设备上会不断输出警告日志，不影响功能但日志很吵
• 发热严重：本地推理时手机发热明显，持续运行后手机检测到外壳和芯片温度过高，触发系统级自动降频，推理速度进一步下降

🔧 针对这些问题的 workaround：
• Function call 解析失败时，从错误信息里提取原始文本返回给 Dart，让 agent 重试
• ID 类字段不信任模型输出，直接从 agent state 里取正确值作为 fallback
• Tool description 用 Gson 序列化而不是字符串拼接，避免特殊字符破坏 JSON

——

📝 总结

整个接入过程的 PR：📦 memex-lab/memex/pull/4

核心经验：
• 用官方 Kotlin API 直接接，不要用第三方 Flutter 封装，出了问题很难排查
• Engine 单例，Conversation 按需创建，这是 LiteRT-LM 的正确用法
• 全局锁控制并发，Engine 初始化和推理都要在锁里
• 本地小模型做结构化输出要加 fallback，和云端大模型不同，不能完全信任它生成的格式化字段
• 多模态要注意格式限制：图片只支持 JPEG/PNG，音频只支持 WAV/PCM，需要在应用层做转换

Memex 完全开源，如果你也在做本地 AI 应用，欢迎参考：📦 memex-lab/memex

——

整体来说，这次接入让我看到了本地大模型在移动端应用的希望——完全离线、数据不出设备、多模态都能跑。但说实话，离能广泛应用还有一段距离：发热降频、结构化输出不稳定、多模态兼容性问题，这些都需要硬件和模型两端继续进步。期待本地模型能更快更好地发展。
