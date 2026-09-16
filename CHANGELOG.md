# Changelog

All notable changes to the eSimplified iOS SDK.

This project follows [Semantic Versioning](https://semver.org). **MAJOR** for breaking API changes,
**MINOR** for new capability, **PATCH** for fixes. Pin with `upToNextMajorVersion` and a minor upgrade
will never break your build.

---

## [1.5.1] — 2026-09-16

### Fixed

- **A pending order now decodes.** An order that has been paid for but not yet provisioned carries no
  `qr_code`, `sm_dp_address`, `activation_code`, `country_name`, `country_code` or `profile`.
  `OrderDetail` required all six, so `fetchOrder` threw on every poll while the order sat in
  `pending` — the exact window an app polls hardest. All six are now optional.
  **If you read any of them, they are now `String?` / `EsimProfile?`.**
- **Decoding failures name the field.** `SdkError.debugDescription` reports the `DecodingError` kind
  and its coding path, so a schema mismatch tells you which key broke instead of "The data couldn't
  be read because it is missing". `errorDescription` — the string you show a customer — no longer
  leaks internals.

### Documentation

- Added `SDK_API_REFERENCE.md`: setup, the full purchase journey, eSIM installation, and every
  method and model. Every code example in it is compiled against the SDK.

## [1.5.0] — 2026-09-16

### Added

- **Content documents.** `fetchTerms`, `fetchPrivacy` and `fetchFaqs` (each with a `…Result` twin)
  return a ready-to-render `ContentDocument` tree — sections, categories and articles whose blocks
  are headings, paragraphs and lists. Replaces rendering these pages in a web view.
- New models: `ContentDocument`, `ContentNode`, `ContentBlock`, `ContentList`, `ContentListMarker`,
  `ContentListItem`.

Unknown block types decode as `ContentBlock.unknown` and unknown list markers as `.bullet`, so the
backend can extend the schema without breaking shipped apps. Skip `.unknown` when rendering.

## [1.4.0] — 2026-09-14

### Changed

- **`showLegacy` is now optional and omitted when `nil`.** `true` returns legacy eSIMs, `false`
  returns universal ones, and omitting it lets the backend decide. Affects `fetchEsims` and
  `fetchEsimsResult`.

## [1.3.0] — 2026-09-14

### Added

- `fetchProfile()` on `UserRepository`, backed by `GET customer/`.

### Changed

- `User` realigned to the API: eight `receive_*` notification flags, `acquisitionSource`, and
  `unique_referral_code` decoded as an alias for `referral_code`.

## [1.2.0] — 2026-09-09

### Added

- Install an eSIM from its own payload, without needing the order — `fetchEsimDetails` gained
  `includeBase64QrCode`.

## [1.1.0] — 2026-09-08

### Added

- One eSIM for Life support: `is_primary` on eSIMs, theme and FAQ repositories, paged orders and
  invoices.

### Changed

- An order's `country` is now nullable.

## [1.0.x] — 2026-08 and earlier

Initial releases. See the git history for detail.

---

[1.5.1]: https://github.com/eSimplified/esimplified-ios-sdk/releases/tag/1.5.1
[1.5.0]: https://github.com/eSimplified/esimplified-ios-sdk/releases/tag/1.5.0
[1.4.0]: https://github.com/eSimplified/esimplified-ios-sdk/releases/tag/1.4.0
[1.3.0]: https://github.com/eSimplified/esimplified-ios-sdk/releases/tag/1.3.0
[1.2.0]: https://github.com/eSimplified/esimplified-ios-sdk/releases/tag/1.2.0
[1.1.0]: https://github.com/eSimplified/esimplified-ios-sdk/releases/tag/1.1.0
