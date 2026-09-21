## Architecture & Code Guidelines Summary
- Pattern: MVVM (SwiftUI + `@Observable`)
- Concurrency: Swift 6 Concurrency準拠 (`@MainActor` on ViewModels)
- Layer: Presentation / Domain / Data
- Data Mapping: DTOは作らず、`Domain/Model`のEntityに直接`Decodable`を準拠させて`CodingKeys`でマッピング

## Testing Policy
- Data/Domainの新規・変更時はテストを作成・更新し、全テストPassを確認すること（実行・実装の詳細は `swift-testing` スキル参照）。

## References
- 仕様・詳細設計が必要な場合のみ参照: `docs/spec.md`, `docs/ARCHITECTURE.md`
