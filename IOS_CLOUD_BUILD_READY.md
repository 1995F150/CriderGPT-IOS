# Xcode Cloud Build Readiness

## Checked items

- Existing `CriderGPT.xcodeproj`: not present in this checkout.
- App source folder: verified at `CriderGPT/App/CriderGPTApp.swift`.
- Expected `Info.plist` path: `CriderGPT/Info/CriderGPT-Info.plist` not found in this checkout.
- `CriderGPT/App/CriderGPTApp.swift` exists.
- StoreKit product IDs in `CriderGPT/Services/StoreKitService.swift`:
  - `cridergpt_plus_monthly`
  - `cridergpt_pro_monthly`
  - note: `cridergpt_lifetime` also exists in code.
- Supabase config in `CriderGPT/Core/AppConfig.swift` now reads `SUPABASE_URL` and `SUPABASE_ANON_KEY` from the app's Info.plist.
- No `service_role` Supabase key found in source code.

## Shared scheme

- Could not verify or create `CriderGPT.xcodeproj/xcshareddata/xcschemes/CriderGPT.xcscheme` because the Xcode project is not present in this repository checkout.

## Bundle identifier and project settings

- Bundle identifier could not be read because `project.pbxproj` is unavailable in this checkout.
- Development team, code signing style, deployment target, marketing version, and current project version cannot be confirmed without the Xcode project file.

## StoreKit product IDs

- Verified exact IDs present in `CriderGPT/Services/StoreKitService.swift`:
  - `cridergpt_plus_monthly`
  - `cridergpt_pro_monthly`
- No mismatched product IDs found in Swift source.

## Supabase readiness

- App uses `SUPABASE_URL` and `SUPABASE_ANON_KEY` from the app's Info.plist via `AppConfig`.
- No Supabase service role key was found in the iOS client code.
- The repo currently contains a default fallback URL/key in code; this should be replaced with real environment values in Xcode Cloud.

## Required manual steps in App Store Connect / Xcode Cloud

- Ensure `CriderGPT.xcodeproj` is committed to the repository.
- Confirm `CriderGPT.xcodeproj/xcshareddata/xcschemes/CriderGPT.xcscheme` is shared and committed.
- Set the correct bundle identifier in the project.
- Add the proper development team and provisioning profile settings in Xcode Cloud or App Store Connect.
- Configure `SUPABASE_URL` and `SUPABASE_ANON_KEY` in the app's Info.plist or equivalent environment for Xcode Cloud.
- Verify that StoreKit product IDs exist in App Store Connect for `cridergpt_plus_monthly` and `cridergpt_pro_monthly`.

## Known blockers

- `CriderGPT.xcodeproj` is missing from the current repository checkout.
- `CriderGPT/Info/CriderGPT-Info.plist` is missing from the current repo checkout.
- Cannot validate actual Xcode Cloud archive/build in Linux Codespaces.

## Reminder

Actual archive and build validation must run on Xcode Cloud or macOS with Xcode, not in GitHub Codespaces/Linux.
