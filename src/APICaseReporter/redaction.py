"""Redact configured fields before data reaches the template."""

import json
from typing import Any
from urllib.parse import parse_qsl, urlencode, urlsplit, urlunsplit

MASK = "[REDACTED]"


class Redactor:
    def __init__(self, headers: str, fields: str) -> None:
        self.header_names = {x.strip().lower() for x in headers.split(",") if x.strip()}
        self.field_names = {x.strip().lower() for x in fields.split(",") if x.strip()}
        self.secrets: set[str] = set()

    def remember(self, value: Any) -> None:
        if isinstance(value, str) and value:
            self.secrets.add(value)
            if value.lower().startswith("bearer "):
                self.secrets.add(value[7:])
        elif isinstance(value, dict):
            for item in value.values():
                self.remember(item)
        elif isinstance(value, list):
            for item in value:
                self.remember(item)

    def text(self, value: str) -> str:
        for secret in sorted(self.secrets, key=len, reverse=True):
            value = value.replace(secret, MASK)
        return value

    def clean(self, value: Any) -> Any:
        if isinstance(value, dict):
            result = {}
            for key, item in value.items():
                if str(key).lower() in self.field_names:
                    self.remember(item)
                    result[str(key)] = MASK
                else:
                    result[str(key)] = self.clean(item)
            return result
        if isinstance(value, (list, tuple)):
            return [self.clean(item) for item in value]
        if isinstance(value, str):
            return self.text(value)
        if value is None or isinstance(value, (bool, int, float)):
            return value
        return self.text(str(value))

    def headers(self, values: Any) -> dict[str, str]:
        result = {}
        for key, value in values.items():
            if key.lower() in self.header_names:
                self.remember(value)
                result[key] = MASK
            else:
                result[key] = self.text(str(value))
        return result

    def url(self, value: str) -> str:
        parts = urlsplit(value)
        pairs = []
        for key, item in parse_qsl(parts.query, keep_blank_values=True):
            if key.lower() in self.field_names:
                self.remember(item)
                item = MASK
            pairs.append((key, item))
        # URL userinfo can contain credentials even when no header exists.
        netloc = parts.netloc
        if "@" in netloc:
            credentials, host = netloc.rsplit("@", 1)
            self.remember(credentials)
            netloc = MASK + "@" + host
        return self.text(
            urlunsplit((parts.scheme, netloc, parts.path, urlencode(pairs), parts.fragment))
        )

    def body(self, value: Any, content_type: str) -> Any:
        if value is None:
            return None
        if isinstance(value, bytes):
            value = value.decode("utf-8", errors="replace")
        if not isinstance(value, str):
            return self.clean(value)
        if "application/x-www-form-urlencoded" in content_type:
            return self.clean(dict(parse_qsl(value, keep_blank_values=True)))
        try:
            return self.clean(json.loads(value))
        except (ValueError, TypeError):
            return self.text(value)
