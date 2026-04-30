## Problem

Memex 目前仅支持 **English** (`en`) 和 **简体中文** (`zh`)。作为一款面向全球用户的个人生活记录应用，仅两种语言限制了大量潜在用户的使用体验——尤其是一款需要处理日常自然语言输入的 app。

## Proposed solution

新增以下语言的本地化支持：

| # | Locale | Language | 使用人数 |
|---|--------|----------|----------|
| 1 | `ko` | 한국어 (Korean) | ~80M+ |
| 2 | `ja` | 日本語 (Japanese) | ~125M+ |
| 3 | `zh-Hant` | 繁體中文 (Traditional Chinese) | ~50M+（台湾、香港、澳门） |
| 4 | `es` | Español (Spanish) | ~500M+ |
| 5 | `hi` | हिन्दी (Hindi) | ~600M+ |
| 6 | `ar` | العربية (Arabic) | ~400M+ |
| 7 | `pt` | Português (Portuguese) | ~260M+ |
| 8 | `fr` | Français (French) | ~280M+ |
| 9 | `ru` | Русский (Russian) | ~250M+ |
| 10 | `de` | Deutsch (German) | ~100M+ |
| 11 | `id` | Bahasa Indonesia | ~270M+ |
| 12 | `th` | ไทย (Thai) | ~70M+ |
| 13 | `vi` | Tiếng Việt (Vietnamese) | ~85M+ |

## Scope of work

当前代码库有两层本地化机制，每种新语言都需要同时覆盖：

### 1. ARB 文件（短 UI 字符串）
- `lib/l10n/app_en.arb` — 约 250+ 翻译 key（按钮、标签、toast、状态消息等）
- 每种新语言需要对应的 `app_<locale>.arb` 文件

### 2. `AppLocalizationsExt`（多行长文本）
- `lib/l10n/app_localizations_ext.dart` — mixin，约 20 个长文本属性（agent prompt、onboarding 文案、OAuth 消息、默认角色、分享文案等）
- 每种新语言需要 `app_localizations_ext_<locale>.dart` + 在 `lookupAppLocalizationsExt()` 中注册

### 3. 配置更新
- `l10n.yaml` — 无需改动（自动发现 ARB 文件）
- `app_localizations.dart` — `supportedLocales` 列表（`flutter gen-l10n` 自动生成）
- `ios/Runner/Info.plist` — 添加 locale 到 `CFBundleLocalizations`
- `android/app/src/main/res/` — 添加 `values-<locale>/strings.xml`（app 名称、快捷方式等 Android 专属字符串）

### 4. RTL 支持（Arabic）
- 验证所有布局在 `TextDirection.rtl` 下正常工作
- 检查 `Directionality` widget 使用、padding/margin 不对称、图标镜像等

### 5. Agent prompt 本地化
- Agent 系统 prompt 和语言指令已有本地化模式（`AppLocalizationsExt` 中的 `*LanguageInstruction` 属性）
- 新语言需要对应的 prompt 翻译，且需保证翻译质量不影响 LLM 交互效果

## Implementation approach

1. **机器翻译打底 + 人工审校** — 先用机器翻译生成 ARB 骨架文件，再由母语者审校，尤其是 agent prompt 部分（措辞直接影响 LLM 输出质量）
2. **社区贡献模式** — ARB 骨架就位后，为每种语言标记 `help wanted` + `good first issue`，方便母语者通过 PR 贡献翻译
3. **CI 校验** — 添加 lint 步骤，检查所有 ARB 文件的 key 集合一致（不遗漏翻译）

## Checklist

- [ ] 为 13 种新语言创建 ARB 骨架文件
- [ ] 为 13 种新语言创建 `AppLocalizationsExt` 实现
- [ ] 更新 `lookupAppLocalizationsExt()` switch 语句
- [ ] 添加 iOS `Info.plist` locale 条目
- [ ] 添加 Android `values-<locale>/strings.xml` 文件
- [ ] 验证 Arabic RTL 布局
- [ ] 添加 missing-key CI lint
- [ ] 各语言母语者审校
