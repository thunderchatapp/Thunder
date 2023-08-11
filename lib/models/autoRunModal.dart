class AutotaskRun {
  String autotaskRunId;
  String autotaskId;
  String trigger;
  String status;
  String createdAt;
  String requestId;
  String encodedLogs;
  String result;

  AutotaskRun({
    required this.autotaskRunId,
    required this.autotaskId,
    required this.trigger,
    required this.status,
    required this.createdAt,
    required this.requestId,
    required this.encodedLogs,
    required this.result,
  });

  factory AutotaskRun.fromJson(Map<String, dynamic> json) {
    return AutotaskRun(
      autotaskRunId: json['autotaskRunId'],
      autotaskId: json['autotaskId'],
      trigger: json['trigger'],
      status: json['status'],
      createdAt: json['createdAt'],
      requestId: json['requestId'],
      encodedLogs: json['encodedLogs'],
      result: json['result'],
    );
  }
}
