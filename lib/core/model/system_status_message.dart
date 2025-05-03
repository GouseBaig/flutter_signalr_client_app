class SystemStatusMessage {
  final bool isDown;
  final String id;
  final DateTime createdOn;
  final DateTime modifiedOn;
  final int systemType;

  SystemStatusMessage({
    required this.id,
    required this.isDown,
    required this.createdOn,
    required this.modifiedOn,
    required this.systemType,
  });

  factory SystemStatusMessage.fromJson(Map<String, dynamic> json) {
    return SystemStatusMessage(
      id: json['id'] ?? '',
      isDown: json['isDown'] ?? false,
      createdOn: DateTime.tryParse(json['createdOn'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      modifiedOn: DateTime.tryParse(json['modifiedOn'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      systemType: json['systemType'] ?? 0,
    );
  }
}
