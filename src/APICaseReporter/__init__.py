"""Compatibility import; use RequestReporter for new suites."""

from request_reporter import RequestReporter, __version__

APICaseReporter = RequestReporter
__all__ = ["APICaseReporter", "__version__"]
