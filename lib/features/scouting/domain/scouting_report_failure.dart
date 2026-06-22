sealed class ScoutingReportFailure {
  const ScoutingReportFailure();
}

class MissingApiKeyFailure extends ScoutingReportFailure {
  const MissingApiKeyFailure();
}

class RateLimitFailure extends ScoutingReportFailure {
  const RateLimitFailure();
}

class NetworkFailure extends ScoutingReportFailure {
  const NetworkFailure(this.message);

  final String message;
}

class ParseFailure extends ScoutingReportFailure {
  const ParseFailure(this.message);

  final String message;
}

class ServerFailure extends ScoutingReportFailure {
  const ServerFailure(this.message);

  final String message;
}
