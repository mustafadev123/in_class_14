# Cloud Courier Evidence and Reflection

## Test context

- Device: Samsung SM S731U1
- Platform: Android 17 (API 37)
- Notification permission: authorized
- FCM token: current installation token was available and copied without being displayed or recorded
- Valid payload title/body: `Campus event update` / `View the latest campus information`
- Valid custom data: `action=update_ui`, `asset=promo`
- T4 change: `asset=unknown`; all other fields remained the same

## Results

| Test | Expected handler/result | Observed result | Status | Evidence |
| --- | --- | --- | --- | --- |
| T1 Foreground | `onMessage`; promo title/image | `onMessage`, accepted diagnostic, Student Center image, receipt 1 | Pass | `evidence/T1_foreground.png` |
| T2 Background tap | `onMessageOpenedApp`; promo title/image | `onMessageOpenedApp`, accepted diagnostic, Student Center image, receipt 2 | Pass | `evidence/T2_background_tap.png` |
| T3 Cold-start tap | `getInitialMessage`; promo title/image | `getInitialMessage`, accepted diagnostic, Student Center image, receipt 1 on the new launch | Pass | `evidence/T3_cold_start_tap.png` |
| T4 Invalid foreground | `onMessage`; reject unknown asset and preserve content | `onMessage`, rejection diagnostic, Student Center title/image preserved, receipt 4, no crash | Pass | `evidence/T4_invalid_payload.png` |

## Graduate reflection

### Setup and payload

I registered a new Android Firebase app with the exact package name `com.mustafadev.cloud_courier` instead of reusing an Activity 13 registration. FlutterFire generated matching options, and initialization is awaited before listeners or widgets start. The `action` key must equal `update_ui`; the `asset` key is then mapped only to `default` or `promo`. This allowlist prevents a cloud value from becoming an arbitrary local asset path.

### Lifecycle and evidence

T1 reached `onMessage`, T2 reached `onMessageOpenedApp`, and the notification-triggered T3 launch reached `getInitialMessage`, as the labeled screenshots show. `onBackgroundMessage` is separately registered for non-UI background work because its isolate cannot directly mutate widget state. These results establish behavior for one Samsung device, Android 17, and notification-plus-data payload; they do not guarantee delivery across devices, force-stop conditions, connectivity states, or data-only payload policies. Permission authorizes notification display but does not prove delivery.

### Validation and next step

T4 changed `asset` to `unknown`. The validator reported the error while preserving the prior title and Student Center image. Listener cancellation and mounted/disposed guards prevent callbacks from updating dead UI. An alternative would construct asset paths dynamically, but that is shorter and unsafe. A feasible next improvement is a retryable initialization status; success would be observable when a simulated token failure displays an error and a retry later enables secure token copying without duplicate listeners. 

## Submission checklist

- Repository: `https://github.com/mustafadev123/in_class_14`
- Evidence: four PNG files in `evidence/`
- Reflection: this document
- Limitation: results apply only to the tested device/platform/payload conditions described above
