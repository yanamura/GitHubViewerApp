# Architecture.md

## 1. 概要 (Overview)
本アプリケーションは、MVVM パターン**を採用します。
外部連携や特定の永続化手段への依存を隠蔽するためにData層を用意します。
状態管理には Swift の **Observation フレームワーク**（`@Observable`）を利用し、非同期・並行処理は **Swift 6 Concurrency** に完全準拠します。

---

## 2. ディレクトリ構成 (Directory Structure)

```text
SampleGH/
├── App/                # アプリライフサイクル (@main, RootTabView, DIコンテナ)
├── Domain/             # 純粋なSwift型・ビジネスロジック (UI/外部ライブラリ非依存)
│   ├── Model/          # Entity (Repository, Owner など)
│   └── Interface/      # プロトコル定義 (GitHubServiceProtocol, StorageProtocol など)
├── Data/               # データアクセス・外部連携の実装
│   ├── Network/        # URLSession, APIClient
│   └── Storage/        # KeychainManager, LocalFavoritesDataSource
└── Presentation/       # UI層 (SwiftUI, ViewModel)
    ├── Common/         # 画面横断で利用する共通UI部品 (AsyncAvatarView, ErrorView など)
    ├── Explore/        # ExploreView, ExploreViewModel, ExploreRow
    ├── Search/         # SearchView, SearchViewModel, SearchRow
    ├── Detail/         # DetailView, DetailViewModel, ReadmeView
    ├── Favorites/      # FavoritesView, FavoritesViewModel
    └── Settings/       # SettingsView, SettingsViewModel
SampleGHTests/
├── Common/             # テストで共通で使うヘルパーなど
├── Domain/             
│   ├── Model/          
│   └── Interface/      
├── Data/               
│   ├── Network/        
│   └── Storage/ 
```

---

## 3. データマッピング方針 (Data Mapping Policy)

- APIレスポンス用のDTOは作らない。`Domain/Model` のEntity（`Repository`, `Owner` など）が直接 `Decodable` に準拠し、`CodingKeys` でAPIのsnake_caseキーをマッピングする。
- 理由: DTOとEntityのフィールドがほぼ同一になるケースが多く、DTO→Entityの変換コードは重複・保守コストになるだけで得られる価値が小さいため。
- Entityのプロパティ名や型がAPIレスポンスと大きく異なる、または複数の外部APIから同一Entityを組み立てる必要が生じた場合は、その時点でDTOの導入を検討する。
