#!/bin/bash
# 用 Release 元数据渲染下载页：docs/index.html 模板 -> <输出目录>/index.html
#
# 用法：
#   VERSION=v1.2.3 PUBLISHED_AT=2026-11-18T09:30:00Z ARTIFACT_DIR=artifacts \
#     scripts/generate-download-page.sh dist
#
# 可覆盖的环境变量：
#   VERSION       版本号（默认“未发布”）
#   PUBLISHED_AT  Release 发布时间，ISO 8601（默认“—”）
#   REPO_SLUG     owner/repo（默认从 git remote 推断）
#   ARTIFACT_DIR  含 TimeFloat-macOS-<arch>.zip 的目录，用于计算文件大小
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:-dist}"
TEMPLATE="$ROOT/docs/index.html"
ARTIFACT_DIR="${ARTIFACT_DIR:-$ROOT/build}"

if [ ! -f "$TEMPLATE" ]; then
  echo "Missing template: $TEMPLATE" >&2
  exit 1
fi

if [ -z "${REPO_SLUG:-}" ]; then
  REPO_SLUG="$(git -C "$ROOT" remote get-url origin 2>/dev/null \
    | sed -E 's#\.git$##; s#^(git@[^:]+:|https?://[^/]+/)##')"
fi

VERSION="${VERSION:-未发布}"
PUBLISHED_AT="${PUBLISHED_AT:-—}"

# 只展示日期部分，避免把时区细节丢给用户
case "$PUBLISHED_AT" in
  *T*) PUBLISHED_AT="${PUBLISHED_AT%%T*}" ;;
esac

html_escape() {
  local value="$1"
  value="${value//&/&amp;}"
  value="${value//</&lt;}"
  value="${value//>/&gt;}"
  value="${value//\"/&quot;}"
  printf '%s' "$value"
}

# 文件大小 -> 人类可读；文件不存在则显示占位符
human_size() {
  local file="$1"
  if [ ! -f "$file" ]; then
    printf '%s' "—"
    return
  fi
  local bytes
  case "$(uname -s)" in
    Darwin) bytes="$(stat -f%z "$file")" ;;
    *) bytes="$(stat -c%s "$file")" ;;
  esac
  awk -v b="$bytes" 'BEGIN {
    split("B KB MB GB", units, " ");
    i = 1;
    while (b >= 1024 && i < 4) { b /= 1024; i++ }
    printf (i == 1 ? "%.0f %s" : "%.1f %s"), b, units[i]
  }'
}

ARM64_SIZE="$(human_size "$ARTIFACT_DIR/TimeFloat-macOS-arm64.zip")"
X86_SIZE="$(human_size "$ARTIFACT_DIR/TimeFloat-macOS-x86_64.zip")"

REPO_URL="https://github.com/$REPO_SLUG"
RELEASES_URL="$REPO_URL/releases"
ARM64_URL="$REPO_URL/releases/latest/download/TimeFloat-macOS-arm64.zip"
X86_URL="$REPO_URL/releases/latest/download/TimeFloat-macOS-x86_64.zip"

mkdir -p "$OUT"

VERSION_HTML="$(html_escape "$VERSION")"
PUBLISHED_HTML="$(html_escape "$PUBLISHED_AT")"

while IFS= read -r line || [ -n "$line" ]; do
  line="${line//\{\{VERSION\}\}/$VERSION_HTML}"
  line="${line//\{\{PUBLISHED_AT\}\}/$PUBLISHED_HTML}"
  line="${line//\{\{ARM64_SIZE\}\}/$ARM64_SIZE}"
  line="${line//\{\{X86_SIZE\}\}/$X86_SIZE}"
  line="${line//\{\{ARM64_URL\}\}/$ARM64_URL}"
  line="${line//\{\{X86_URL\}\}/$X86_URL}"
  line="${line//\{\{REPO_URL\}\}/$REPO_URL}"
  line="${line//\{\{REPO_SLUG\}\}/$REPO_SLUG}"
  line="${line//\{\{RELEASES_URL\}\}/$RELEASES_URL}"
  printf '%s\n' "$line"
done < "$TEMPLATE" > "$OUT/index.html"

# 关闭 Jekyll 处理（分支部署时也安全）
: > "$OUT/.nojekyll"

echo "Generated $OUT/index.html (version: $VERSION, arm64: $ARM64_SIZE, x86_64: $X86_SIZE)"
