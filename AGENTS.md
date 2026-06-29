---
description: BasicLab OS iOS app — SwiftUI + Xcode MCP agent guide
alwaysApply: true
---

# AGENTS.md — BasicLab OS (iOS)

SwiftUI app for BasicLab OS. Xcode 26.6+, iOS 26.5+, **Mac Catalyst** enabled. Swift 5, iOS 26 Liquid Glass UI.

Sibling repos in this workspace:
- `basiclab_server` — FastAPI backend (`127.0.0.1:8000` in dev)
- `basiclab-os-web` — React web client (reference for API contracts & UX patterns)

## Platforms

- iPhone + iPad (`TARGETED_DEVICE_FAMILY = 1,2`)
- Mac via **Mac Catalyst** (`SUPPORTS_MACCATALYST = YES`)
- Minimum OS: iOS 26.5 — no legacy design fallbacks

## Xcode MCP (preferred for build / test / preview)

Cursor connects via `xcode-tools` MCP (`xcrun mcpbridge`). **Xcode must be running with this project open.**

| Task | Use | Do not use |
|------|-----|------------|
| Build | `BuildProject` | shell `xcodebuild` |
| Build errors | `GetBuildLog`, `XcodeListNavigatorIssues` | paste terminal output |
| Tests | `RunAllTests`, `RunSomeTests` | ad-hoc test scripts |
| SwiftUI UI check | `RenderPreview` | guess layout from code |
| Apple API docs | `DocumentationSearch` | outdated training data |
| File edits in project | `XcodeRead` / `XcodeWrite` / `XcodeUpdate` | assume flat filesystem |

Workflow: `XcodeListWindows` → get `tabIdentifier` → call other tools.

Project identifiers:
- **Project**: `BasicLabOS.xcodeproj`
- **Scheme**: `BasicLabOS`
- **Bundle ID**: `com.basiclabx.BasicLabOS`
- **Deployment target**: iOS 26.5

## Architecture

```
View → Service → APIClient → basiclab_server
```

| Layer | Path | Responsibility |
|-------|------|----------------|
| App | `BasicLabOS/App/` | `RootView` auth gate, `MainTabView` tab shell |
| Features | `BasicLabOS/Features/` | SwiftUI screens (`Auth/`, `Products/`, `Shared/`) |
| Design | `BasicLabOS/Design/` | Liquid Glass badges, `TabRootNavigation` shell modifiers |
| Services | `BasicLabOS/Services/` | `AuthService`, `ProductService`, `CategoryService` |
| Core | `BasicLabOS/Core/` | Config, networking, models, Keychain session |

**Auth flow**: `LoginView` → `AuthSessionStore` → Keychain (`SessionStore`) → `RootView` shows `MainTabView`.

**Main shell** (`MainTabView`): iOS 26 navigation — `TabView` + `.tabViewStyle(.sidebarAdaptable)` + `.tabBarMinimizeBehavior(.onScrollDown)`; each tab uses `NavigationStack` with `.tabRootNavigationStyle()` (`.toolbarTitleDisplayMode(.inlineLarge)`). Scroll content uses `.contentMargins` so system scroll-edge / Liquid Glass toolbar effects work. Logout UI deferred to future「我的」tab; search UI removed (restore later via `.searchable()` on the product tab).

**Product list**: `POST /api/v1/owned/products/list` (自营 / owned catalog — same as Web `/products` card mode). No detail navigation in v1.

### Product card fields (aligned with Web `ProductCatalogCard`)

| Card UI | API field |
|---------|-----------|
| 主图 | `main_image_url` |
| 推荐角标 | `is_featured` |
| 状态角标 | `status` |
| 标题 | `product_name` |
| 副标题 | `product_code` |
| Meta 行 | category tree label · `brand_name` · `series_name` |
| 价格 | usually absent in list payload → show「未提供」 |

Category labels: `GET /api/v1/pim/catalog/categories/tree` via `CategoryService`.

### Liquid Glass (iOS 26)

- **Functional layer** (glass): status/featured badges, price capsule, login CTA
- **Content layer** (material): card body, form fields
- Use `GlassEffectContainer` when multiple glass overlays share one media region
- Avoid `.interactive()` glass on every list cell (scroll performance)

Response envelope (from `basiclab_server`):

```json
{ "status": "success", "msg": "...", "trace_id": "...", "data": { ... } }
{ "status": "error", "error": { "error_code": "...", "message": "..." }, "trace_id": "..." }
```

Auth header: `Authorization: Bearer <access_token>`.

## Key commands

```bash
# iOS Simulator
xcodebuild -project BasicLabOS.xcodeproj -scheme BasicLabOS \
  -destination 'platform=iOS Simulator,name=iPhone 16' build

# Mac Catalyst
xcodebuild -project BasicLabOS.xcodeproj -scheme BasicLabOS \
  -destination 'platform=macOS,variant=Mac Catalyst' build

open BasicLabOS.xcodeproj
```

Backend dev server: `cd ../basiclab_server && make run-reload`

## Configuration

- **API base URL**: `AppConfig.apiBaseURL` — Debug uses `http://127.0.0.1:8000`.
- Debug build allows local HTTP via `NSAllowsLocalNetworking`.

## Do not do these things

- Do not bypass `Services/` from Views (no raw `URLSession` in SwiftUI views).
- Do not hand-roll API envelope parsing outside `APIClient`.
- Do not use shell `xcodebuild` when Xcode MCP is available and connected.
- Do not put Liquid Glass on entire card bodies (content layer uses material).
- Do not commit `xcuserdata/`, DerivedData, or secrets.

## Adding files

File System Synchronized Groups — new `.swift` files under `BasicLabOS/` are picked up automatically.

## Testing

Verify via Xcode MCP `BuildProject` + Simulator / Mac Catalyst manual runs. Unit test target TBD.
