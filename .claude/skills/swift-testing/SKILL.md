---
name: swift-testing
description: >-
  Swift Testingフレームワークを使用したテストの作成、更新、実行、デバッグを行う際に使用するスキル。
  Xcodeプロジェクト(SampleGH)のテスト実行コマンドやモックの作成方針、命名規則を提供します。
---

# Swift Testing Guide (SampleGH)

このスキルは、SampleGH プロジェクトにおけるテスト作成・実行のワークフローとガイドラインを提供します。

## 1. テストフレームワークとコーディング規約

- **フレームワーク**: Swift Testing (`import Testing`) を使用します（XCTest ではなく Swift Testing を標準とします）。
- **アサーション**:
  - 通常の検証: `#expect(...)`
  - 前提条件のアンラップ・早期中断: `let value = try #require(...)`
- **ファイル命名規則**: テスト対象のファイル名に `Tests.swift` を付与します。
  - 例: `Repository.swift` → `RepositoryTests.swift`
  - 例: `GitHubService.swift` → `GitHubServiceTests.swift`
- **ディレクトリ配置**: `SampleGHTests/` 配下に、テスト対象と同じレイヤー階層で配置します。
  - `SampleGH/Domain/Model/Foo.swift` → `SampleGHTests/Domain/Model/FooTests.swift`
  - `SampleGH/Data/Network/Bar.swift` → `SampleGHTests/Data/Network/BarTests.swift`
- **テスト構造**:
  - `@Suite` または `@MainActor struct XxxTests` / `struct XxxTests` で構造化します。
  - テスト関数には `@Test` 属性を付与します。

## 2. テスト実行コマンド (Xcodebuild)

本プロジェクトは Xcode プロジェクト (`SampleGH.xcodeproj`) のため、`swift test` ではなく `xcodebuild` を使用してテストを実行します。

### 基本テスト実行コマンド
```bash
xcodebuild test \
  -project SampleGH.xcodeproj \
  -scheme SampleGH \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

### ビルドとテストの分離実行（高速再実行・CI同様のフロー）
```bash
# 1. テスト用ビルド
xcodebuild build-for-testing \
  -project SampleGH.xcodeproj \
  -scheme SampleGH \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -derivedDataPath DerivedData

# 2. テスト実行
xcodebuild test-without-building \
  -project SampleGH.xcodeproj \
  -scheme SampleGH \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -derivedDataPath DerivedData
```

## 3. モック / スタブの作成方針
- 複数のテストファイルで共有するモック（例: `MockTokenStorage`）は、`SampleGHTests/Common/` 配下に作成します。
- 1つのテストファイルでしか使わないモックは、そのテストファイル内に `private` で定義します（例: `GitHubServiceTests.swift` 内の `RecordingAPIClient`）。他のファイルからも使う必要が出たら `Common/` へ移動してください。
