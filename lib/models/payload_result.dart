enum CampusAsset {
  defaultCampus('default', 'assets/images/campus_default.png'),
  promo('promo', 'assets/images/campus_event.png');

  const CampusAsset(this.payloadValue, this.assetPath);

  final String payloadValue;
  final String assetPath;
}

sealed class PayloadResult {
  const PayloadResult();
}

final class ValidPayload extends PayloadResult {
  const ValidPayload(this.asset);

  final CampusAsset asset;
}

final class InvalidPayload extends PayloadResult {
  const InvalidPayload(this.reason);

  final String reason;
}

PayloadResult validatePayload(Map<String, dynamic> data) {
  if (data['action'] != 'update_ui') {
    return const InvalidPayload('Rejected payload: action must be update_ui.');
  }

  final assetValue = data['asset'];
  if (assetValue is! String) {
    return const InvalidPayload('Rejected payload: asset is missing.');
  }

  for (final asset in CampusAsset.values) {
    if (asset.payloadValue == assetValue) {
      return ValidPayload(asset);
    }
  }

  return InvalidPayload('Rejected payload: unsupported asset "$assetValue".');
}
