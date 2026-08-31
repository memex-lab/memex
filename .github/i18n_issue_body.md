# i18n 语言扩展

中文 | [English](i18n_issue_body.en.md)

## 问题

Memex 已经提供 **13 种界面语言**：English (`en`)、简体中文 (`zh`)、繁體中文 (`zh_Hant`)、Deutsch (`de`)、日本語 (`ja`)、한국어 (`ko`)、Español (`es`)、हिन्दी (`hi`)、العربية (`ar`)、Português (`pt`)、Français (`fr`)、Bahasa Indonesia (`id`)、Русский (`ru`)。

原扩展清单里还缺两种：

| # | Locale | 语言 | 使用人数 |
|---|--------|----------|----------|
| 1 | `th` | ไทย (Thai) | ~70M+ |
| 2 | `vi` | Tiếng Việt (Vietnamese) | ~85M+ |

本文过去写的是「仅支持 English 和简体中文」。有新语言合入后请同步更新，避免贡献者重复添加已有语言。

## 方案

用与现有语言相同的两层本地化机制补齐泰语和越南语。

### 1. ARB 文件（短 UI 字符串）

- `lib/l10n/app_en.arb` — 模板，800+ key
- 每种语言需要 `app_<locale>.arb`

### 2. `AppLocalizationsExt`（多行长文本）

- `lib/l10n/app_localizations_ext.dart` — mixin（agent prompt、onboarding、OAuth HTML、默认角色、分享文案）
- 每种语言需要 `app_localizations_ext_<locale>.dart`，并在 `lookupAppLocalizationsExt()` 中注册

### 3. 配置

- `l10n.yaml` — 无需改动（自动发现 ARB）
- `app_localizations.dart` — `supportedLocales`（`flutter gen-l10n` 生成）
- `lib/l10n/supported_languages.dart` — 语言选择器
- `ios/Runner/Info.plist` — `CFBundleLocalizations`（目前只有 `en` 和 `zh-Hans`）
- `android/app/src/main/res/values-<locale>/strings.xml` — 应用名和快捷方式

### 4. RTL（阿拉伯语）

阿拉伯语已经合入。继续验证 `TextDirection.rtl` 布局。

### 5. Agent prompt 质量

`AppLocalizationsExt` 里的 `*LanguageInstruction` 会影响 LLM 输出。新语言需要母语者审校这些字符串，不能只翻译按钮文案。

## 实施

1. 机器翻译打底 ARB 骨架，再由母语者审校，尤其是 agent prompt
2. 骨架合入后为该语言标记 `help wanted` + `good first issue`
3. CI 应检查各 ARB 的 key 集合一致

## Checklist

- [x] 原扩展清单中 11 种语言的 ARB（ko, ja, zh_Hant, es, hi, ar, pt, fr, ru, de, id）
- [x] 对应的 `AppLocalizationsExt` 实现
- [x] `lookupAppLocalizationsExt()` switch
- [ ] 泰语 (`th`) ARB + Ext
- [ ] 越南语 (`vi`) ARB + Ext
- [ ] iOS `Info.plist` 补齐 `en` / `zh-Hans` 以外的 locale
- [ ] 各语言 Android `values-<locale>/strings.xml`
- [ ] 阿拉伯语 RTL 布局检查
- [ ] 缺 key 的 CI lint
- [ ] 各语言母语者审校
