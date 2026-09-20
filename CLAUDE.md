## Architecture & Code Guidelines Summary
- Pattern: MVVM (SwiftUI + `@Observable`)
- Concurrency: Swift 6 Concurrency準拠 (`@MainActor` on ViewModels)
- Layer: Presentation / Domain / Data
- Data Mapping: DTOは作らず、`Domain/Model`のEntityに直接`Decodable`を準拠させて`CodingKeys`でマッピング

## Testing Policy
- Data, Domainに新規または変更を行った場合は、対応するテストを作成、更新すること
- テスト作成・修正後は `swift test` または `xcodebuild test` を実行し、すべてのテストがPassすることを確認すること。

## References
- 仕様・詳細設計が必要な場合のみ参照: `docs/spec.md`, `docs/ARCHITECTURE.md`
